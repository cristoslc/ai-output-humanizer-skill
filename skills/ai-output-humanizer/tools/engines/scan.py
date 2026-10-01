#!/usr/bin/env python3
# Mechanical regex-scan engine (python3). One of the four catalog engines.
# Parses ../references/regex-scan.md at run time and never duplicates patterns
# into code. Catalog patterns are consumed near-verbatim: python's re honors
# \uXXXX escapes, lookaheads, and backreferences.
#
# Contract (identical across engines): engine [file|-] [--json]
# Exit: 0 within gate; 1 gate violation; 2 usage or catalog parse error.
#
# Run: python3 scan.py input.txt
#      cat input.txt | python3 scan.py --json
import io
import json
import re
import sys
import os

CATALOG = os.environ.get("SCAN_CATALOG") or os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "..", "..", "references", "regex-scan.md"
)

def die2(msg):
    sys.stderr.write("scan: %s\n" % msg)
    sys.exit(2)

try:
    with io.open(CATALOG, "r", encoding="utf-8") as f:
        md = f.read()
except IOError as e:
    print("scan: catalog not found: %s" % CATALOG, file=sys.stderr)
    sys.exit(2)

# ---------------------------------------------------------------- parse ---#
entries = []
parse_error = None
sev = None
title = None
kind = None
buf = None

def flush():
    global title, buf, parse_error
    if title is None:
        return
    if buf is not None:
        entries.append({"title": title, "sev": sev, "kind": "regex", "source": "\n".join(buf)})
    elif sev in ("LIMIT", "SOFT"):
        entries.append({"title": title, "sev": sev, "kind": "judgment", "source": None})
    elif sev == "HARD":
        if "Em dash" in title:
            entries.append({"title": title, "sev": sev, "kind": "literal", "source": None})
        else:
            parse_error = 'HARD section without a fence: "%s"' % title
    else:
        parse_error = "section outside HARD/LIMIT/SOFT: \"%s\"" % title
    title = None
    buf = None

for raw in md.split("\n"):
    m = re.match(r"^## (HARD|LIMIT|SOFT) patterns\s*$", raw)
    if m:
        flush()
        sev = m.group(1)
        continue
    if title is not None and raw.startswith("```"):
        if buf is None:
            buf = []
        else:
            entries.append({"title": title, "sev": sev, "kind": "regex", "source": "\n".join(buf)})
            title = None
            buf = None
        continue
    if title is not None and buf is not None:
        buf.append(raw)
        continue
    if raw.startswith("### "):
        flush()
        title = raw[4:].strip()
        buf = None
        continue
    if title is not None:
        continue  # prose before an opening fence
flush()

if parse_error:
    print("scan: catalog parse error: %s" % parse_error, file=sys.stderr)
    sys.exit(2)
if len(entries) == 0:
    print("scan: catalog parse error: no pattern sections found", file=sys.stderr)
    sys.exit(2)

for e in entries:
    e["name"] = e["title"].split(" — ")[0]
    m = re.search(r"LIMIT (\d+)", e["title"])
    e["max"] = int(m.group(1)) if (e["sev"] == "LIMIT" and m) else None

# ---------------------------------------------------------------- input ---#
args = sys.argv[1:]
json_mode = False
file_arg = None
saw = False
for a in args:
    if a == "--json":
        json_mode = True
    elif a == "-":
        if saw:
            die2("multiple input files")
        file_arg, saw = "-", True
    elif a.startswith("--"):
        die2("unknown option: %s" % a)
    else:
        if saw:
            die2("multiple input files")
        file_arg, saw = a, True

try:
    if file_arg is None:
        if sys.stdin.isatty():
            die2("no input file and stdin is a terminal (usage: engine [file|-] [--json])")
        text = sys.stdin.read()
    elif file_arg == "-":
        text = sys.stdin.read()
    else:
        with io.open(file_arg, "r", encoding="utf-8", errors="strict") as f:
            text = f.read()
except IOError as e:
    die2("cannot read input: %s" % e)

# ----------------------------------------------------------------- scan ---#
def clip(s):
    s = s.replace("\n", "⏎")
    return s if len(s) <= 64 else s[:61] + "..."

line_starts = [0]
for i, ch in enumerate(text):
    if ch == "\n":
        line_starts.append(i + 1)

def lc(idx):
    lo, hi = 0, len(line_starts) - 1
    while lo < hi:
        mid = (lo + hi + 1) // 2
        if line_starts[mid] <= idx:
            lo = mid
        else:
            hi = mid - 1
    return {"line": lo + 1, "col": idx - line_starts[lo] + 1}

results = []
violation = False
for e in entries:
    if e["kind"] == "judgment":
        results.append({"name": e["name"], "severity": e["sev"], "count": None, "judged": True, "spans": []})
        continue
    if e["kind"] == "literal":
        rx = re.compile("—|--", re.IGNORECASE)
    else:
        try:
            rx = re.compile(e["source"], re.IGNORECASE)
        except re.error as err:
            print(
                "scan: catalog parse error: pattern \"%s\" does not compile: %s" % (e["name"], err),
                file=sys.stderr,
            )
            sys.exit(2)
    spans = []
    for m in rx.finditer(text):
        start = lc(m.start())
        end = lc(m.end())
        spans.append({"start": start, "end": end, "text": clip(m.group(0))})
    n = len(spans)
    results.append({"name": e["name"], "severity": e["sev"], "count": n, "judged": False, "spans": spans})
    if e["sev"] == "HARD" and n > 0:
        violation = True
    if e["sev"] == "LIMIT" and e["max"] is not None and n > e["max"]:
        violation = True

# --------------------------------------------------------------- output ---#
out = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", newline="\n")
if json_mode:
    out.write(json.dumps(results, ensure_ascii=False) + "\n")
else:
    width = max(len(r["name"]) for r in results)
    lines = []
    for r in results:
        if r["judged"]:
            label = "JUDGMENT REQUIRED"
        else:
            label = "%d %s" % (r["count"], "hit" if r["count"] == 1 else "hits")
        lines.append("%s  %s  %s" % (r["severity"], r["name"].ljust(width), label))
        for s in r["spans"]:
            lines.append(
                '  L%d col%d-L%d col%d  "%s"'
                % (s["start"]["line"], s["start"]["col"], s["end"]["line"], s["end"]["col"], s["text"])
            )
    out.write("\n".join(lines) + "\n")
out.flush()
sys.exit(1 if violation else 0)