#!/bin/sh
# scan.sh — dispatcher for the ai-output-humanizer mechanical regex scan.
#
# Usage: sh tools/scan.sh [file|-] [--json] [--engine node|python|perl|powershell] [--degraded]
#
# Tier 1: exec the first runtime the host has, fidelity-first (see
# docs/plans/regex-scanner-tool.md §3): node -> python3 -> perl.
#
# Tier 2: when no runtime exists, exit 3 with an ask-user message. Two
# user-consented recoveries: install a runtime (never install without
# asking), or the lower-fidelity degraded scan via `--degraded` (awk + grep
# subset; regexes that ERE cannot express are listed as skipped for LLM
# judgment; exit 4 marks reduced coverage).
#
# Exit codes: 0 within gate; 1 gate violation; 2 usage or catalog error;
# 3 no runtime found; 4 degraded scan within the scanned-subset gate.
#
# The prologue uses shell builtins only, so runtime detection works even with
# an empty PATH.

set -f

usage_die() { echo "scan: $1" >&2; exit 2; }

# HERE without external dirname (parameter expansion; "$0" always carries a
# slash in the documented invocation "sh tools/scan.sh").
case "$0" in
  */*) HERE=$(CDPATH= cd -- "${0%/*}" 2>/dev/null && pwd) ;;
  *)   HERE=$(pwd) ;;
esac
[ -n "$HERE" ] || usage_die "cannot resolve script directory"

json=0; degraded=0; engine=""; input=""; have_input=0
while [ $# -gt 0 ]; do
  case "$1" in
    --json) json=1 ;;
    --degraded) degraded=1 ;;
    --engine) [ $# -ge 2 ] || usage_die "--engine needs a value"; engine=$2; shift ;;
    --engine=*) engine=${1#--engine=} ;;
    -) [ "$have_input" -eq 0 ] || usage_die "multiple input files"; have_input=1; input="-" ;;
    -*) usage_die "unknown option: $1" ;;
    *) [ "$have_input" -eq 0 ] || usage_die "multiple input files"; have_input=1; input=$1 ;;
  esac
  shift
done

CATALOG="${SCAN_CATALOG:-$HERE/../references/regex-scan.md}"
[ -f "$CATALOG" ] || usage_die "catalog not found: $CATALOG"

# ---------------------------------------------------------------- degraded ---#
# Lower-fidelity deterministic subset, user-consented only (never default).
# awk does catalog parsing and ERE triage (pure string ops); grep -E does all
# regex matching (awk's dynamic-regex dialect differs between awks, so awk
# never matches).
if [ "$degraded" -eq 1 ]; then
  [ "$json" -eq 0 ] || usage_die "--json is unsupported with --degraded (text mode only)"

  in="$input"
  tmp_in=""
  if [ -z "$in" ] || [ "$in" = "-" ]; then
    in=$(mktemp "${TMPDIR:-/tmp}/scandegraded.XXXXXX") || usage_die "mktemp failed"
    tmp_in=$in
    cat > "$in" || usage_die "cannot read stdin"
  fi
  [ -f "$in" ] || usage_die "input file not found: $in"

  # Phase 1: catalog -> records.  Layout: five lines per record --
  #   sev / title / status / pattern / max   (patterns are single-line by
  #   catalog rule; multi-line or empty pattern bodies degrade to "skip").
  #   status: scan | skip (ERE-incompatible) | lit (em dash) | judge | error
  records=$(
    awk '
      /^## HARD patterns/ { flush(); sev="HARD"; next }
      /^## LIMIT patterns/  { flush(); sev="LIMIT"; next }
      /^## SOFT patterns/   { flush(); sev="SOFT"; next }
      /^### / {
        flush()
        title=substr($0,5)
        sub(/[ \t]+$/, "", title)
        fence=0; ready=0; body=""
        next
      }
      title != "" {
        if ($0 ~ /^```/) {
          if (fence) { fence=0; ready=1 } else { fence=1 }
          next
        }
        if (fence) { body = (body == "" ? $0 : body "\n" $0) }
        next
      }
      END { flush() }
      function ereify(p,  r, i, m2, ch, inclass) {
        r=""; inclass=0
        while (i < length(p)) {
          i++
          m2 = substr(p, i, 2)
          ch = substr(p, i, 1)
          if (m2 == "\\s") { r = r (inclass ? "[:space:]" : "\\s"); i++; continue }
          if (m2 == "\\w") { r = r (inclass ? "[:alnum:]_" : "\\w"); i++; continue }
          if (m2 == "\\d") { r = r (inclass ? "0-9" : "\\d"); i++; continue }
          if (m2 == "\\\\") { r = r "\\\\"; i++; continue }
          if (m2 == "[^" && !inclass) { inclass=1; r = r m2; i++; continue }
          if (ch == "[" && !inclass) { inclass=1; r = r ch; continue }
          if (ch == "]" && inclass) { inclass=0; r = r ch; continue }
          r = r ch
        }
        return r
      }
      function flush() {
        if (title == "") return
        status="judge"; pat="-"
        disp=title
        sub(/ — .*/, "", disp)
        if (ready) {
          p=body
          # ERE triage: (?: -> ( (harmless); reject lookarounds, backrefs,
          # \uXXXX escapes, and multi-line fences grep cannot express.
          # Bracket-class internals matter: BSD grep supports \s/\w outside
          # classes only, so inside classes we rewrite to POSIX classes.
          if (p ~ /\n/ || p == "") {
            status="skip"
          } else {
            gsub(/\(\?:/, "(", p)
            gsub(/\\u2019/, "\342\200\231", p)
            gsub(/\\u201d/, "\342\200\234", p)
            p = ereify(p)
            if (index(p, "(?=") > 0 || index(p, "(?!") > 0) status="skip"
            else if (p ~ /\\[0-9]/) status="skip"
            else if (p ~ /\\u[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]/) status="skip"
            else status="scan"
          }
          pat = (p == "" ? "-" : p)
        } else if (sev == "HARD") {
          if (index(title, "Em dash") > 0) status="lit"
          else status="error"
        }
        max=""
        if (match(title, /LIMIT [0-9]+/)) max=substr(title, RSTART+6, RLENGTH-6)
        if (max == "")
          print sev "\n" disp "\n" status "\n" pat "\n-"
        else
          print sev "\n" disp "\n" status "\n" pat "\n" max
        title=""; body=""; ready=0
      }
    ' "$CATALOG"
  )
  [ -n "$records" ] || { [ -n "$tmp_in" ] && rm -f "$tmp_in"; usage_die "catalog awk pass failed"; }

  recs_file=$(mktemp "${TMPDIR:-/tmp}/scanrecs.XXXXXX") || { [ -n "$tmp_in" ] && rm -f "$tmp_in"; usage_die "mktemp failed"; }
  printf '%s\n' "$records" > "$recs_file"

  viol=0
  while :; do
    IFS= read -r sev || break
    [ -n "$sev" ] || break
    IFS= read -r title
    IFS= read -r status
    IFS= read -r pat
    IFS= read -r max

    n=0
    list=""
    case "$status" in
      lit)
        list=$(grep -in -o -e '—' -e '--' -- "$in" 2>/dev/null)
        ;;
      scan)
        list=$(grep -Ein -o -e "$pat" -- "$in" 2>/dev/null)
        ;;
      skip)
        printf '%s  %s  SKIPPED — LLM JUDGMENT REQUIRED (regex beyond ERE)\n' "$sev" "$title"
        continue
        ;;
      judge)
        printf '%s  %s  JUDGMENT REQUIRED\n' "$sev" "$title"
        continue
        ;;
      error)
        echo "scan: catalog parse error: HARD section without a fence: \"$title\"" >&2
        rm -f "$recs_file" "$tmp_in" 2>/dev/null
        exit 2
        ;;
    esac
    if [ -n "$list" ]; then n=$(printf '%s\n' "$list" | wc -l | tr -d '[:space:]'); fi
    [ "$n" -ge 1 ] || n=0
    hits_word=hits
    [ "$n" -eq 1 ] && hits_word=hit
    printf '%s  %s  %s %s\n' "$sev" "$title" "$n" "$hits_word"
    if [ -n "$list" ]; then
      printf '%s\n' "$list" | sed 's/^\([0-9]*\):/  L\1  "/; s/$/"/'
    fi
    if [ "$sev" = "HARD" ] && [ "$n" -gt 0 ]; then viol=1; fi
    if [ "$sev" = "LIMIT" ] && [ "$max" != "-" ] && [ "$n" -gt "$max" ]; then viol=1; fi
  done < "$recs_file"

  rm -f "$recs_file" "$tmp_in" 2>/dev/null
  [ "$viol" -eq 1 ] && exit 1
  exit 4
fi

# ---------------------------------------------------------------- engines ---#
# Build forwarded args at top level: within a POSIX function, set-"--" is
# scoped to the function and lost on return.
set --
[ "$json" -eq 1 ] && set -- "$@" --json
[ "$have_input" -eq 1 ] && set -- "$@" "$input"

if [ -n "$engine" ]; then
  case "$engine" in
    node)
      command -v node >/dev/null 2>&1 || usage_die "--engine node: node not on PATH"
      exec node "$HERE/engines/scan.mjs" "$@"
      ;;
    python|python3)
      command -v python3 >/dev/null 2>&1 || usage_die "--engine python: python3 not on PATH"
      exec python3 "$HERE/engines/scan.py" "$@"
      ;;
    perl)
      command -v perl >/dev/null 2>&1 || usage_die "--engine perl: perl not on PATH"
      exec perl "$HERE/engines/scan.pl" "$@"
      ;;
    powershell)
      for runner in powershell pwsh powershell.exe pwsh.exe; do
        command -v "$runner" >/dev/null 2>&1 || continue
        exec "$runner" -NoProfile -File "$HERE/scan.ps1" "$@"
      done
      usage_die "--engine powershell: no powershell found"
      ;;
    *) usage_die "unknown engine: $engine (node|python|perl|powershell)" ;;
  esac
fi

probe()
{
  command -v "$1" >/dev/null 2>&1
}

if probe node; then
  exec node "$HERE/engines/scan.mjs" "$@"
fi
if probe python3; then
  exec python3 "$HERE/engines/scan.py" "$@"
fi
if probe perl; then
  exec perl "$HERE/engines/scan.pl" "$@"
fi

echo "scan: no supported runtime found (node, python3, perl)." >&2
echo "Options: ask the user to install one (apt/brew/dnf/apk; never install without asking)," >&2
echo "or run the lower-fidelity degraded scan (sh tools/scan.sh --degraded <file>;" >&2
echo "exit 4 marks reduced coverage), or use the explicit-search fallback in regex-scan.md." >&2
exit 3