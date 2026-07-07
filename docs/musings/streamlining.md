# Streamlining the AI Output Humanizer Project

## Current state

The project has a solid scaffold (docs/, AGENTS.md, CHANGELOG.md, .gitignore, scripts/staging/) and a well-tested SKILL.md at v1.0.0. But it's missing the test harness that the review project built — the superset evaluation framework with 8 test cases, k-trials, pass^k metrics, and LLM judge scoring.

## What to streamline

### 1. Copy the superset test harness

The review project at `~/Documents/code/humanizer-skill-review/tests/superset/` has a complete non-deterministic eval harness:

- `evaluate-superset.sh` — 404-line bash harness with k-trials, pass^k/pass@k, JSONL logging
- `test-cases.yaml` / `test-cases.md` — 8 test case definitions
- `inputs/` — 9 input files (8 TCs + 1 voice sample)
- `fixtures/` — 8 expected-behavior descriptions
- `judge-prompt.md` — LLM judge template

The harness at `tests/harness/` has `extract-output.py` for parsing opencode JSON streams.

### 2. Adapt paths

The review project uses `REPO="$(cd "$(dirname "$0")/../.." && pwd)"` to find the repo root. In this project, the test harness will live at `tests/superset/` and `tests/harness/`. Paths need to point to `skills/ai-output-humanizer/SKILL.md` instead of the review project's layout.

### 3. What to drop

- The cross-candidate comparison harness (exercise-skill.sh, score-outputs.py, build-matrix.py, repo-context.py) — that was for comparing 5 candidates, not needed here
- The corpus fixtures (blog-post.md, email.md, etc.) — the superset inputs already cover the same ground
- The trove infrastructure (build-trove.py) — not needed for a single-skill project

### 4. What to add

- A `scripts/run-tests.sh` that wraps `evaluate-superset.sh` with sensible defaults
- Test command declaration in AGENTS.md
- Updated DEVELOPER-WORKFLOWS.md

### 5. Test command

```bash
./scripts/run-tests.sh [--k N] [--only TC-NN]
```

Default: k=3, all 7 active test cases (TC-03 excluded as it requires a real file path).

## Open questions

- Should TC-03 (edit mode) be adapted to work with a temp file? The review project's TC-03 input is a meta-instruction ("Edit the file at /tmp/draft.md") which requires the harness to create the file first. The harness already does this for edit mode. Worth keeping.
- Should we add a TC for the pre-delivery checklist? The SKILL.md has a 6-item checklist that could be verified programmatically.
- Should we add a TC for the "it's not X. It's Y." rewrite template? The SKILL.md has a specific rewrite template for this pattern.
