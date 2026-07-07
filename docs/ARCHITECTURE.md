# Technical Architecture

This project is an **opencode skill** — a single markdown file (`SKILL.md`) with reference documents. There is no runtime, no server, no build pipeline.

## C4 model

### Context

```
[Writer] --uses--> [opencode] --loads--> [AI Output Humanizer Skill]
```

### Container

Single container: the skill definition at `skills/ai-output-humanizer/SKILL.md`, loaded by opencode's skill system at startup.

### Component

- `SKILL.md` — skill instructions, process, output format
- `references/patterns.md` — full pattern catalog
- `references/vocabulary-tiers.md` — 3-tier vocabulary system
- `references/tolerance-matrix.md` — per-context rule strictness
- `references/examples.md` — before/after transformations

### Deployment

Not applicable — the skill is loaded from the local filesystem by opencode.

## Tech stack

- **Runtime:** opencode (agent framework)
- **Language:** Markdown (skill definition)
- **No external dependencies, no build step, no CI/CD**

See `docs/technical-architecture/` for detail.
