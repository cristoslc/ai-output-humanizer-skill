**Responding to:** continuing the parenthetical overuse sashay, per operator request ("I'm seeing a lot of parentheticals creep into outputs, what could help?"); plan section 4.

**Intent: add the parenthetical judge criterion to TC-01/TC-06 and mirror it in test-cases.md.**

What: append "Rewritten prose has at most 2 parenthetical instances per 1,000 words (code/notation/quotes exempt)" to the `judge_criteria` lists of TC-01 and TC-06 in `tests/superset/test-cases.yaml`. Also add the same line to the TC-01 and TC-06 "Judge criteria" lists in `tests/superset/test-cases.md`, which enumerates criteria per TC. `judge-prompt.md` uses a generic `{{TEST_CASE}}` template (no per-TC enumeration), so it needs no change. `tests/README.md` only lists what each TC tests (no criteria), so it stays untouched. Then run `./scripts/run-tests.sh --only TC-01 --k 3` and `--only TC-06 --k 3`, recording pass/fail counts and judge objections in a chronicle entry.

Why: the harness can only detect regression on the new rule if the judge scores against it.

Success looks like: criterion present in both TCs in both files; TC-01 and TC-06 pass k=3 with the new criterion; results (gitignored) not committed.