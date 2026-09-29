# Tests

Non-deterministic evaluation harness for the ai-output-humanizer skill. Exercises the skill against 7 test cases, scores outputs with an LLM judge, and computes pass^k metrics.

## Layout

- `superset/inputs/` — 8 input files (7 test cases + 1 voice sample)
- `superset/fixtures/` — 7 expected-behavior descriptions
- `superset/evaluate-superset.sh` — main harness (k-trials, pass^k, JSONL logging)
- `superset/judge-prompt.md` — LLM judge template
- `superset/test-cases.yaml` / `test-cases.md` — test case definitions
- `superset/results/` — per-run outputs and logs (gitignored)
- `harness/extract-output.py` — parses opencode JSON event streams

## Run it

```bash
# Full suite (k=3, 6 test cases)
./scripts/run-tests.sh

# 5 trials per test case (more reliable)
./scripts/run-tests.sh --k 5

# Single test case
./scripts/run-tests.sh --only TC-01

# Re-judge existing outputs (skip exercise)
./scripts/run-tests.sh --skip-exercise
```

## Test cases

| ID | Name | Mode | What it tests |
|----|------|------|---------------|
| TC-01 | Happy path | rewrite | Standard rewrite, em dash rule, pattern removal |
| TC-02 | Audit mode | audit | Flag-only, no rewriting, pattern grouping |
| TC-03 | Patch mode | patch | In-place file patching, minimal changes |
| TC-04 | Voice calibration | rewrite | Voice matching from writing sample |
| TC-05 | Tech docs | rewrite | Technical docs processed at full pattern strength |
| TC-06 | Convergence | rewrite | Self-audit and iterate-to-convergence |
| TC-07 | Split "It's not X. It's Y." | rewrite | Split-construction removal, rewrite template |

TC-03 is excluded from the default run (requires a real file path).

## How it works

1. **Exercise** — feeds the SKILL.md + input text to `opencode run`, captures the output
2. **Judge** — sends (SKILL.md, input, output, criteria) to an LLM judge via `opencode run`
3. **Score** — computes pass^k and pass@k across k trials
4. **Log** — writes session-enriched JSONL to `results/logs/`

## Costs

Each trial = 1 exercise call + 1 judge call. Default run (k=3, 6 TCs) = 36 LLM calls. Use `--only` to scope down.
