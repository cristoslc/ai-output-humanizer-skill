# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

[1.4.0] - 2026-09-29

### Added

- Pattern "Unresolvable references (assumed thread context)" and a SOFT scan for bare option, plan, phase, spike, and similar labels (scan count 25 → 26): the output resolves every ticket ID, option label, and pointer phrase out of the text itself, with a first-use gloss and bare later uses; the self-audit, pre-delivery checklist, and P1 tier carry a cold-copy check. Instruction surfaces (catalog entry, SKILL.md wiring, scan prose) are encoded positive-only, quoting no failing form; the failing shape and its fix live only in `references/examples.md` § "Assumed-context references". Selftest gained five SOFT cases. The Project Hal global spoke (`.agents/agents-md-detail/ai-writing-tells.md`) gained the same tell and checklist item in the same encoding (that repo, not this one). SKILL.md bumped to 1.4.0.

## [Unreleased]

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
