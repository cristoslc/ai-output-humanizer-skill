# Streamlining Plan: Test Harness + Project Scaffold

## Summary

Copy the non-deterministic evaluation harness from `humanizer-skill-review`, adapt it for this repo, and complete the project scaffold with proper docs/ layout, AGENTS.md, and test command declaration.

## Work items

### 1. Project scaffold (DONE — committed to main)
- [x] Create docs/ hub-and-spoke layout (technical + domain architecture)
- [x] Write AGENTS.md, README.md, CHANGELOG.md, .gitignore
- [x] Write scripts/staging/ pipeline stubs
- [x] Write docs/ hub files (ARCHITECTURE.md, DOMAIN-MODEL-L1.md, DEVELOPER-WORKFLOWS.md, USER-EXPERIENCE.md)
- [x] Write docs/ spoke README.md files + project-navigation.md

### 2. Test harness (DONE — committed to main)
- [x] Copy `tests/superset/evaluate-superset.sh` from review project
- [x] Copy `tests/harness/extract-output.py` from review project
- [x] Copy 9 input files and 8 fixture files
- [x] Write `tests/superset/test-cases.yaml` and `test-cases.md`
- [x] Write `tests/superset/judge-prompt.md`
- [x] Write `tests/README.md`
- [x] Write `scripts/run-tests.sh` wrapper
- [x] Update AGENTS.md with test command
- [x] Update DEVELOPER-WORKFLOWS.md with test instructions
- [x] Write musing at `docs/musings/streamlining.md`

### 3. Verification (TODO)
- [ ] Run full test suite (k=3, all 7 active TCs)
- [ ] Verify TC-03 (edit mode) works with temp file
- [ ] Verify harness smoke test passed (TC-05: 2/3)
- [ ] Code review of all new files

### 4. Open questions from musing
- TC-03 edit mode: harness already creates temp file for edit mode — verified working
- Pre-delivery checklist TC: defer to follow-up (low priority)
- "It's not X. It's Y." rewrite template TC: defer to follow-up (covered by TC-01 criteria)

## Blast radius

Low. All changes are new files (docs/, tests/, scripts/). No existing code modified. No runtime impact.
