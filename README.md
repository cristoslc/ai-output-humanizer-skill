# AI Output Humanizer

An opencode skill that strips the patterns AI models leave in prose, from contrast templates that argue with nobody to chatbot leftovers and em dashes on every noun. It keeps your meaning and your voice and removes the tells, then audits itself until every one is gone.

Works in any agent or harness that supports SKILLS.md.

**Before:**

> It's worth noting that these findings have important implications for how we navigate the challenges of forecast ensembling moving forward. When individual model rankings are unstable across geography and time, performance-weighted ensemble methods may not deliver the meaningful improvements over equal-weight approaches that practitioners hope for, highlighting the importance of continued and careful evaluation in this rapidly evolving area.

**After:**

> If individual model rankings are unstable across geography and time, ensemble methods that weight models by past performance may not improve on equal-weight approaches.

More before/after pairs (scientific writing, travel writing, marketing copy) live in [`skills/ai-output-humanizer/references/examples.md`](skills/ai-output-humanizer/references/examples.md).

## Background

Language models write by picking the phrase that best fits the widest range of readers and subjects. That optimization has a fingerprint, including:

- Sentences announce importance instead of adding a fact
- Rhythm shows up by rule rather than by ear
- A same-length triple lands on schedule, every time
- Ordinary facts get dressed up as turning points
- Chunks of the chat itself survive as leftovers in the text

Wikipedia documents these shapes on its [Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) page, where editors use them to catch machine-written text. This skill turns a synthesized version of that catalog into an editing workflow your agent can run.

## What it is and isn't

This is a **style tool**, not an authorship test. The patterns it flags are statistically more common in LLM output, but humans under deadline pressure, writing in an unfamiliar genre, or writing in a second language produce the same shapes. Flags measure how AI-sounding a text is. They are not evidence about who or what wrote it.

Point it at anything. The same patterns run at the same strength on an API doc as on a blog post, and the same goes for commit messages and changelogs. The rewrite strips the tells but keeps the register, so a humanized technical document still sounds like technical documentation. Technical and formal writing never picks up casual voice. Parameter lists and code blocks belong to the genre, so the rewrite leaves them standing. Quoted material and attributed text stay word-for-word. A tell inside quoted text gets flagged, and the quote itself goes untouched.

## Modes


| Mode                | What it does                                                                             | Use when                                                                                         |
| ------------------- | ---------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| `rewrite` (default) | Audits the text, delivers a fully reworked version                                       | You want clean prose back and don't mind it being reworked                                       |
| `audit`             | Flags AI patterns grouped by severity, changes nothing                                   | You want to see what's wrong and fix it yourself, or you're checking text you don't want altered |
| `patch`             | Fixes a named file in place with minimal, targeted edits of a few words per flagged span | You have a file and only the bad spans should change; already-clean passages stay untouched      |


Voice calibration is optional in `rewrite`: paste 2-3 paragraphs of your own writing and the rewrite matches your sentence length, vocabulary level, and habits. Without a sample, choose a named profile (`casual`, `professional`, `technical`, `warm`, `blunt`). If you name neither, the skill infers register from the input.

## How it works

1. **Regex scan.** A deterministic 25-pattern scan (`references/regex-scan.md`) runs first, mechanically, with HARD, LIMIT, and SOFT severities. HARD hits block delivery until fixed.
2. **Judgment audit.** The skill reads the text for what regexes cannot see: tone, uniformity, structure, significance inflation, citing the specific text for each finding.
3. **Draft rewrite.** A clean version with all audit findings addressed.
4. **Self-audit.** The draft is re-scanned against every HARD pattern and every remaining tell is listed and fixed. This step is mandatory; so is a final re-scan after the last fix.

That loop, audit and re-check until the scan is clean, is the iterate-to-convergence workflow. Nothing ships until the mechanical scan reports zero hard-pattern hits.

## Installation

Install or update globally with the skills CLI:

```bash
npx skills add cristoslc/ai-output-humanizer-skill -g
```

This copies the skill into every detected agent directory (`~/.agents/skills/` and agent-specific locations such as `~/.config/opencode/skills/`) and handles updates on re-run. No manual file copying. The skill is plain Markdown, so any agent that reads a `SKILL.md` works.

## Usage

Ask in plain language:

```
humanize this: [text]
```

```
audit this: [text]
```

"Detect AI patterns in: [text]" also routes to audit mode. For files:

```
patch this file: [path]
```

"Edit this file: [path]" also routes to patch mode. In patch mode the file is edited on disk and the response is a list of before/after changes, not a copy of the file.

See [`skills/ai-output-humanizer/SKILL.md`](skills/ai-output-humanizer/SKILL.md) for the full workflow, severity tiers, trigger words, and output formats.

## What's inside

- [`patterns.md`](skills/ai-output-humanizer/references/patterns.md): the full pattern catalog with before/after examples
- [`regex-scan.md`](skills/ai-output-humanizer/references/regex-scan.md): the 25 mechanical patterns with severity tiers
- [`examples.md`](skills/ai-output-humanizer/references/examples.md): before/after transformations per genre

## Testing

The repo carries two test layers:

```bash
node tests/regex-scan-selftest.mjs     # deterministic regex checks, runs in seconds
./scripts/run-tests.sh [--k N] [--only TC-NN]   # LLM-judged eval (default k=3, 7 test cases)
```

The selftest verifies every scan pattern fires on a known-bad sample and stays silent on a clean one. The eval harness runs the skill through `opencode` k times per case and scores the output with an LLM judge against per-case criteria; details in [`tests/README.md`](tests/README.md).

## Project structure

```
.
├── skills/ai-output-humanizer/
│   ├── SKILL.md              # the skill itself (primary artifact)
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
