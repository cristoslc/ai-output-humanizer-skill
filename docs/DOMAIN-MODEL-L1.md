# Domain Model — L1 Glossary

## Bounded context: Writing Quality

### Core concepts

- **AI-ism** — A textual pattern statistically more common in LLM output than human writing. Signals, not proof.
- **Voice** — The distinctive register, sentence rhythm, and word choice that makes writing sound like a specific person.
- **Mode** — One of three operating modes: rewrite (fix + output), detect (flag only), edit (in-place file fixes).
- **Self-audit** — The skill re-reads its own output to catch remaining AI patterns before delivery.
- **Iterate-to-convergence** — Repeat audit → fix → re-audit until no AI patterns remain.

### Key business rules

1. Em dashes are the single most common AI tell — zero em dashes in final output.
2. Non-native English text must not be flagged for AI patterns.
3. Ethics framing must accompany every output: signals, not proof.
4. Voice calibration from a writing sample takes priority over named profiles.

### Avoid

- "AI detector" — this is a writing-quality tool, not a verdict.
- "Humanizer" as a verb — the skill rewrites, it doesn't "humanize" in the sense of adding errors.

See `docs/domain-architecture/` for L2 detail.
