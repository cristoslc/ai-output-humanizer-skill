# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.6.0] - 2026-10-03

### Added

- Pattern "Hard wraps (mid-paragraph line breaks)" (scan count 26 → 27): the rewrite is delivered with every prose paragraph as one logical line, blank lines separating paragraphs, and structural boundaries (headings, list items, block quotes, tables, code fences, front matter) keeping their breaks. The catalog fence body spans two physical lines, whose join carries the newline the pattern matches, so grep-based degraded mode skips it honestly (grep is line-based and cannot match across a newline) while the node, python3, and perl engines scan at full fidelity; the engine contract documents the multi-line triage and the selftest's expected SKIPPED set now covers it. The self-audit step, final scan list, pre-delivery checklist, formatting-tells summary, and patch-mode verification carry the rule, and `references/examples.md` gained the § "Hard wraps" before/after. `tests/regex-scan-selftest.mjs` gained three pattern cases plus a `hardwrap.txt` fixture (one hard wrap, one seeded em dash) in the engine-parity layer; `clean.txt` and `utf8.txt` were unwrapped to keep holding their exit-0 gate under the new pattern. SKILL.md bumped to 1.6.0.

## [1.7.0] - 2026-10-03

### Added

- Catalog expansion from awnist/slop-cop (github.com/awnist/slop-cop, MIT; its taxonomy credits sneak's LLM_PROSE_TELLS.md and tropes.fyi, both queued as further upstream sources to mine). `regex-scan.md` count 27 → 35: eight new SOFT scans ("Almost" hedges, Comma parenthetical qualifiers, "In a [adjective] way/manner" filler, "Broader implications"/"in the realm of" elevations, "Rather than" preference framing, Semicolon negation pivot (tempered-dot form, so degraded mode skips it to LLM judgment), "Highlights the" + abstract noun extending the HARD participle-tails pattern to finite verbs, and Unicode arrow decoration with tables, pipelines, code, and before/after notation exempt), two new fence-less LIMIT procedures (Gerund fragment litany, Listicle in a trench coat), and an AI-vocabulary alternation extension (synergy, holistic, transformative, cutting-edge, nuanced, unprecedented, noteworthy, enduring, intricacies, showcase, spearhead, streamline, foster, resonate, ascertain, ameliorate, elucidate, promulgate, cognizant). `patterns.md` gained the matching judgment entries (almost hedges, unnecessary contrast connectives, unnecessary elaboration with a sentence-vs-document tier note, gerund litany, listicle in a trench coat, broader implications, invented concept labels, grandiose stakes, pivot paragraphs, fractal summaries, dead metaphor recurrence, one-point dilution, dramatic fragments, short-hook paragraphs, staccato bursts, unicode arrows), the magic list counts (3, 5, 7, 10) on numbered-list inflation, the question-then-answer pair on rhetorical openers, comma-wrapped qualifiers on parenthetical hedging, phrase-list extensions (transitions, generic conclusions, infomercial hooks, "Let's"/"think of it as" preambles), elevated-register swaps with plain equivalents, and a scope-and-exclusions rule in the intro so overlapping patterns do not double-flag the same text. Dramatic fragments and staccato bursts are corroborating (stranded-auxiliary treatment) to stay consistent with the deliberate-fragments and varied-length rules; risky vocabulary (dynamic, innovative, valuable, navigate, craft, boast) stays judgment-only in the catalog because regex hits on them are noise far more often than signal. Selftest gained a failure-expecting and no-hit case for all eight new scans plus an extended AI-vocabulary sample; run green with node, python3, and perl in parity and consistent degraded triage. SKILL.md bumped to 1.7.0 (new patterns named in its category bullets; scan count reference updated).

### Fixed

- Stale pattern-count references aligned at 35 to match the expanded catalog (27 mechanical patterns after 1.6.0, plus eight new SOFT scans): README.md "How it works" and "Inside the skill" (2), SKILL.md reference wiring (1), examples.md transcript counts (2).

> Note: several judgment entries and both LIMIT procedures named above did not persist to disk in the 1.7.0 commit; they are delivered in 1.7.1 ("completed the 1.7.0 integration").

## [1.7.1] - 2026-10-03

### Added

- Tier D mining of the two upstream sources slop-cop credits, completing the 1.7.0 plan and going beyond it: tropes.fyi (49 tropes, by ossama.is) and sneak's LLM_PROSE_TELLS.md (git.eeqj.de/sneak/prompts, the iteratively self-de-LLM'd catalog).
- New judgment patterns in `patterns.md`: Two-clause compound monotony (sneak's big missed tell; most sentences are two balanced independent clauses joined by comma+conjunction), Coined metaphor crutch (forced similes; sibling of dead metaphor recurrence), Premise stacking (a question preceded by a paragraph of its own evidence), Announce-then-answer preambles ("Two constraints shape the design"; structural announcers), Quotable one-liners (standalone slide-bait lines), Belaboring the unnecessary (defending an objection nobody would raise), and Wh-word headings (Where/What/Why section-title shape, with a new SOFT fenced scan `(?:^|\n)#{1,6}\s+(?:Where|What|Why)\b`, scan count 35 → 36).
- Entry extensions in `patterns.md`: Hedging gained the stacked-hedge form (five hedges in one sentence; max one hedge per sentence); Self-announcing honesty frames gained the performative-vulnerability form; Reasoning chain artifacts gained the reasoning leak (narrating the writing's own moves); Acknowledgment loops gained the tie-back (closing by looping the answer back to the original ask); Vague attributions gained the appeal to familiarity ("famously," "notoriously," "a classic," "as we all know"); Numbered list inflation gained compulsive counting (stating the exact count before the list); Formulaic openings gained "In an era of..."; Formulaic challenges gained the full dismiss-the-difficulties arc; Emotional flatline gained the empathy performance; Transition phrases gained connector addiction (3+ consecutive paragraphs opening on transition words); Paragraph length uniformity gained symmetrical section lengths; Excessive structure gained the five-paragraph prison; Vocabulary repetition gained self-echo (the piece pays off its own distinctive phrase); Paragraph-reshuffle immunity gained verbatim content duplication; Generic conclusions gained the never-ending conclusion (clauses stacked instead of landing); Parenthetical hedging gained the comma-qualifier family; Colon-and-enumeration gained the colon-less repeated short-setup/elaboration cadence; Trailing denial unchanged.
- `patterns.md` vocabulary extended: judgment-only list gained multifaceted, underscores (verb), landscape (domain noun), realm, and "where X actually lives"; filler adverbs gained essentially, ultimately, particularly, arguably, fundamentally; elevated-register swaps gained utilize (use), commence (start), facilitate (help), endeavor (try), demonstrate (show; keep the technical sense in engineering docs).
- Completed the 1.7.0 integration that did not persist in its commit (edit-tool incident): judgment entries for almost hedges, unnecessary contrast connectives, unnecessary elaboration (with sentence-vs-document tier note and the analogy-development exclusion), gerund fragment litany, listicle in a trench coat, pivot paragraphs, fractal summaries, dead metaphor recurrence, dramatic fragments and staccato bursts (corroborating), short-hook paragraphs, one-point dilution, and unicode arrow decoration; the two fence-less LIMIT procedures in `regex-scan.md` (Gerund fragment litany, runs of 2+; Listicle in a trench coat, 2+ ordinal openers); and the comma-qualifier + colon-cadence extensions. Also removed a verbatim duplicate of the Parenthetical triple block that the same incident left behind. SKILL.md bullets now reference only entries that exist; README/SKILL/examples counts updated 35 → 36; `tests/regex-scan-selftest.mjs` gained a Wh-word headings case.

## [1.5.0] - 2026-09-30

### Added

- Bundled scanner (`skills/ai-output-humanizer/tools/`) that runs the regex-scan.md catalog mechanically on arbitrary text. Tier 1 dispatches fidelity-first to the first runtime the host has (node -> python3 -> perl); Windows runs `tools/scan.ps1` (in-box PowerShell). All engines parse the catalog markdown at run time (single source of truth; no pattern is duplicated into code), emit identical reports byte-for-byte, and enforce the HARD/LIMIT gate via exit codes (0 pass, 1 violation, 2 usage/catalog parse error). Tier 2: with no runtime available, exit 3 presents an ask-user message; the agent asks the user to either install a runtime (never auto-install) or consent to the lower-fidelity `--degraded` scan (awk + grep ERE subset, ~20/26 patterns mechanical, SKIPPED patterns listed for LLM judgment, exit 4 marks reduced coverage). Regex-less LIMIT procedures (stacked questions, repeated openers, echoing skeletons) surface as JUDGMENT REQUIRED everywhere without affecting the exit code. `tests/regex-scan-selftest.mjs` gained three layers: the existing pattern cases, an engine-parity harness (byte-identical text reports + per-engine JSON over five fixtures, including tc07/tc01), and dispatcher tests (--engine passthrough, degraded triage vs expected SKIPPED set, corrupt-catalog exit 2 via SCAN_CATALOG, exit-3 message under an empty PATH). `regex-scan.md` gained the wiring sentence and an "Engine contract" section documenting the shared flavor. Pending: one smoke run of `tools/scan.ps1` on a real Windows box (WSL dispatches to a Unix engine and does not substitute). SKILL.md bumped to 1.5.0.

## [1.4.0] - 2026-09-29

### Added

- Pattern "Unresolvable references (assumed thread context)" and a SOFT scan for bare option, plan, phase, spike, and similar labels (scan count 25 → 26): the output resolves every ticket ID, option label, and pointer phrase out of the text itself, with a first-use gloss and bare later uses; the self-audit, pre-delivery checklist, and P1 tier carry a cold-copy check. Instruction surfaces (catalog entry, SKILL.md wiring, scan prose) are encoded positive-only, quoting no failing form; the failing shape and its fix live only in `references/examples.md` § "Assumed-context references". Selftest gained five SOFT cases. The Project Hal global spoke (`.agents/agents-md-detail/ai-writing-tells.md`) gained the same tell and checklist item in the same encoding (that repo, not this one). SKILL.md bumped to 1.4.0.

## [1.3.2] and earlier

### Changed

### Changed

- Ran the skill on its own SKILL.md (rewrite mode) and a deeper judgment pass. Rewrite pass fixed seven prose tells outside quoted pattern examples: a four-item parenthetical in the vocabulary rule, the "it's a list, not an argument" trailing denial, an "instead of editing for its own sake" tail (merged with the existing over-editing rule), a mirror-echo sentence in patch mode, and three question-form parenthetical triples in the mirror-from-sample bullets. Judgment pass (sentence-length stats, uniformity, repetition, treadmill) cut the promotional "best" from the frontmatter description, dropped a "the flags measure style only" sentence duplicated from Scope and limits, broke the 64-word self-audit sentence's duplicate variant quoting (variants remain in the checklist and rewrite template), and split the mirror-from-sample paragraph in two. Quoted pattern examples untouched. SKILL.md bumped to 1.3.2.

- Fixed the README and SKILL.md "point it at anything" passages, which themselves contained a rule-of-three ("Parameter lists, numbered steps, and code blocks"), a trailing denial the regex cannot see ("flagged instead of rewritten"), and the self-labeling closer "That is source fidelity." Both passages rewritten to positive statements. The trailing-denial guidance in `references/patterns.md` and the SKILL.md self-audit, checklist, and final scan now name the regex-blind variants ("instead of Y", "rather than Y", "not merely Y") so the self-audit layer catches what the scan misses. SKILL.md bumped to 1.3.1.

- Added two mechanical patterns (trailing denial "X, not Y", colon-and-enumeration; both SOFT) with selftest samples; scan count 23 → 25. The judgment catalog gained the contrast-denial and list-template family with before/after examples. SKILL.md rewritten to pass its own catalog: its prose no longer uses em-dash separators, trailing denials, colon enumerations, or rule-of-three; the pre-delivery checklist and final scan now cover the new family. All four `examples.md` pairs rebuilt so Before and After carry identical meaning, and output-format few-shots added for rewrite, audit, and patch responses. SKILL.md bumped to 1.3.0.

- Removed genre-based refusal ("When NOT to use this skill"), the context profiles, the tolerance matrix, and the vocabulary-tiers file. Pattern rules now apply at full strength to every genre the skill is pointed at; humanizing is not conversationalizing, so the target voice for technical and formal writing stays plain and technical while the tells still go. Quoted material, code, and attributed text remain protected as source fidelity, not refusal. Vocabulary guidance folded into `references/patterns.md`; `references/vocabulary-tiers.md` and `references/tolerance-matrix.md` deleted. TC-05 repurposed from "Opt-out" to "Tech docs (full-strength patterns)" with a clean no-op criterion, and rewrite mode now states that clean text returns unchanged. SKILL.md bumped to 1.2.0.
- Rewrote the "After" showcase texts in `references/examples.md` to pass the skill's own scan gate: blog (em dash removed, forced "point, then evidence, then a second point" cadence restructured), travel ("the whole story" superlative removed), marketing (em dash swapped for a colon). "Before" quotes unchanged as intentional slop demonstrations. SKILL.md bumped to 1.1.1.
- Renamed modes for clarity: detect is now audit (flag only), edit is now patch (minimal in-place fixes). "detect" and "edit this file" remain working trigger phrases. SKILL.md bumped to 1.1.0; test-case names, fixture filenames, and harness mode routing updated to match.

### Added

- Pattern: "make X land" / impact-verb placeholders (land/hit/resonate/stick as substitutes for the concrete effect)

### Added

- Initial skill scaffold with rewrite, detect, and edit modes
- Pattern catalog, vocabulary tiers, tolerance matrix, and examples
- Voice calibration from writing sample or named profiles
- Self-audit and iterate-to-convergence workflow
- Non-native English handling
