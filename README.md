# AI Output Humanizer

An opencode skill that strips the tells language models leave in prose, from announced importance to scheduled rhythm and chatbot leftovers. It keeps the meaning and the voice, then audits itself until every tell is gone.

Works in any agent or harness that reads a `SKILL.md`.

**Before:**

> It's worth noting that these findings have important implications for how we navigate the challenges of forecast ensembling moving forward. When individual model rankings are unstable across geography and time, performance-weighted ensemble methods may not deliver the meaningful improvements over equal-weight approaches that practitioners hope for, highlighting the importance of continued and careful evaluation in this rapidly evolving area.

**After:**

> If individual model rankings are unstable across geography and time, ensemble methods that weight models by past performance may not improve on equal-weight approaches.

More pairs (scientific writing, travel writing, marketing copy) live in [`skills/ai-output-humanizer/references/examples.md`](skills/ai-output-humanizer/references/examples.md).

## Background

Language models write by picking the phrase that best fits the widest range of readers and subjects. That optimization has a fingerprint:

- Sentences announce importance instead of adding a fact
- Rhythm shows up by rule rather than by ear
- Same-length triples land on schedule
- Ordinary facts get dressed up as turning points
- Chunks of the chat survive as leftover prose

Wikipedia catalogues these on its [Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) page. The skill turns a synthesized version of that catalog into an editing workflow agents can run.

## What it is and isn't

This is a **style tool**, not an authorship test. The patterns are statistically more common in LLM output, but humans under deadline or writing in a second language produce the same shapes. Flags measure how AI-sounding a text is. They are not evidence about who wrote it.

Point it at anything. The same patterns run at the same strength on an API doc as on a blog post. The rewrite strips the tells but keeps the register, so a humanized technical document still sounds like technical documentation. Parameter lists and code blocks belong to the genre and stay standing. Quoted material stays word-for-word; a tell inside a quote gets flagged, and the quote itself goes untouched.

## Modes

| Mode                | What it does                                                                             | Use when                                                                                         |
| ------------------- | ---------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| `rewrite` (default) | Audits the text, delivers a fully reworked version                                       | You want clean prose back and don't mind it being reworked                                       |
| `audit`             | Flags AI patterns grouped by severity, changes nothing                                   | You want to see what's wrong and fix it yourself, or you're checking text you don't want altered |
| `patch`             | Fixes a named file in place with minimal, targeted edits of a few words per flagged span | You have a file and only the bad spans should change; already-clean passages stay untouched      |

Voice calibration is optional in `rewrite`. Paste 2-3 paragraphs of your own writing and the rewrite matches your rhythm and word level. Without a sample, choose a named profile (`casual`, `professional`, `technical`, `warm`, `blunt`), or let the skill infer register from the input.

## How it works

1. **Regex scan.** A 25-pattern mechanical scan runs first, with HARD, LIMIT, and SOFT severities. HARD hits block delivery until fixed.
2. **Judgment audit.** The skill reads for what regexes cannot see. It checks tone, uniformity, structure, and significance inflation, and ties each finding to the specific text.
3. **Draft rewrite.** Every finding addressed.
4. **Self-audit.** The draft is re-scanned against every HARD pattern, every surviving tell is listed and fixed, then the text is scanned once more. Mandatory.

Audit and re-check until the scan is clean: that is the iterate-to-convergence loop. Nothing ships while a hard pattern still hits.

## Installation

```bash
npx skills add cristoslc/ai-output-humanizer-skill -g
```

The skills CLI copies the skill into every detected agent directory (such as `~/.config/opencode/skills/`) and handles updates on re-run.

## Usage

Plain language, three entry points:

```bash
humanize this: [text]       # rewrite
audit this: [text]          # audit; "detect AI patterns in ..." also routes here
patch this file: [path]     # patch; "edit this file ..." also routes here
```

Patch mode edits the file on disk and returns a list of before/after changes, not a copy of the file. See [`skills/ai-output-humanizer/SKILL.md`](skills/ai-output-humanizer/SKILL.md) for the full workflow, severity tiers, trigger words, and output formats.

## Inside the skill

- [`patterns.md`](skills/ai-output-humanizer/references/patterns.md): the full catalog, with before/after examples
- [`regex-scan.md`](skills/ai-output-humanizer/references/regex-scan.md): the 25 mechanical patterns and their severities
- [`examples.md`](skills/ai-output-humanizer/references/examples.md): genre before/after pairs and full response examples

## Testing

```bash
node tests/regex-scan-selftest.mjs     # deterministic regex checks, seconds to run
./scripts/run-tests.sh [--k N] [--only TC-NN]   # LLM-judged eval (default k=3, 7 test cases)
```

The selftest proves every scan pattern fires on a known-bad sample and stays silent on a clean one. The harness runs the skill through `opencode` k times per case and scores the output with an LLM judge; details in [`tests/README.md`](tests/README.md).

## Project structure

```
.
├── skills/ai-output-humanizer/
│   ├── SKILL.md              # the skill itself
│   └── references/           # pattern catalog, regex scan, examples
├── docs/                     # architecture, domain model, UX, plans, tech debt
├── tests/                    # regex selftest + LLM-judged eval harness
└── scripts/                  # test runner
```

## Sources

- [Wikipedia: Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing)
- [conorbronsdon/avoid-ai-writing](https://github.com/conorbronsdon/avoid-ai-writing)
- [blader/humanizer](https://github.com/blader/humanizer)
- [brandonwise/humanizer](https://github.com/brandonwise/humanizer)
- [stephenturner/skill-deslop](https://github.com/stephenturner/skill-deslop)
- [lguz/humanize-writing-skill](https://github.com/lguz/humanize-writing-skill)
- Simon Willison's llm-cliche-highlighter ([tools.simonwillison.net](https://tools.simonwillison.net/))

## License

MIT. See [`CHANGELOG.md`](CHANGELOG.md) for version history.