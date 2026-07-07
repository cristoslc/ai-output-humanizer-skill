# AI Output Humanizer Skill — Agent Guidance

## Purpose

See `PURPOSE.md` — one-paragraph outcome.

## Project structure

- `skills/ai-output-humanizer/SKILL.md` — the skill definition (primary artifact)
- `skills/ai-output-humanizer/references/` — pattern catalog, vocabulary tiers, tolerance matrix, examples
- `docs/` — architecture, domain model, developer workflows, UX

## Hubs and spokes

See `docs/agents-detail/project-navigation.md` for the full directory map.

## Test command

```bash
./scripts/run-tests.sh [--k N] [--only TC-NN]
```

Runs the non-deterministic evaluation harness. Default: k=3, 7 test cases. See `tests/README.md` for details.

## Test command exemption

No standard unit-test framework applies. The test harness uses `opencode run` to exercise the skill and an LLM judge to score outputs. This is the project's test suite — run it before declaring changes complete.
