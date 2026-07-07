#!/usr/bin/env python3
"""Extract the final assistant text from an opencode run --format json stream.

Usage: extract-output.py <input.json> <output.md>
"""
import json
import sys


def main() -> int:
    src, dst = sys.argv[1], sys.argv[2]
    text = ""
    with open(src) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                ev = json.loads(line)
            except json.JSONDecodeError:
                continue
            if ev.get("type") == "text":
                part = ev.get("part", {})
                if isinstance(part, dict):
                    t = part.get("text", "")
                    if t.strip():
                        text = t
            if ev.get("type") == "output" and ev.get("text"):
                t = ev["text"]
                if t.strip():
                    text = t
    with open(dst, "w") as f:
        f.write(text if text else "(no output captured)\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
