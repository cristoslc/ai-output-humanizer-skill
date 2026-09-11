**Responding to:** code review findings

Fixes for the two should-fix findings from the code review (see the intent entry above), then a TC-01 re-run.

**Fix 1 — `patterns.md:8`:** dropped "parentheses," from the em dash fix menu. It now reads "Replace with commas, periods, or rewrite as two sentences." The menu no longer routes em dash replacements into parentheses, the displacement the new parenthetical density rule bans.

**Fix 2 — `SKILL.md:94` and `SKILL.md:100`:** both parenthetical exemption statements now carry the full set from `patterns.md:131`: code, technical notation, citations, and quoted material, plus the voice-calibration cap (rewrites cap at the writing sample's own parenthetical density). Wording kept compact, matching the existing checklist/scan style. No other rule text changed.

**Verification:**

1. `grep -n "parentheses" patterns.md` — line 8 clean; only remaining hit is line 67, the unrelated "wearing parentheses instead of commas" note in the forced-triad entry.
2. `./scripts/run-tests.sh --only TC-01 --k 3` on commit `0d4634f`: **3/3 pass** (confidences 0.95, 0.95, 0.85), pass^k 1.0, suite PASS, 216s. The prior em-dash-in-issues-list flake did not recur.

Test results stayed in `tests/superset/results/` (gitignored); not committed.