# Developer Workflows

## Build

No build step. The skill is plain Markdown loaded by opencode at runtime.

## Test

Non-deterministic evaluation harness in `tests/`. Runs k trials per test case, scores outputs with an LLM judge, and computes pass^k metrics.

```bash
# Full suite (k=3, 7 test cases)
./scripts/run-tests.sh

# 5 trials per test case (more reliable)
./scripts/run-tests.sh --k 5

# Single test case
./scripts/run-tests.sh --only TC-01
```

See `tests/README.md` for full documentation.

## Deploy

No deployment. The skill lives in this repo and is loaded from the local filesystem.

## CI/CD

None. This is a personal project with no pipeline.

## Local dev

1. Clone the repo
2. Add the skill path to your opencode config's `skills.paths`
3. Restart opencode
4. Invoke the skill with test text

See `docs/developer-workflows/` for detail.
