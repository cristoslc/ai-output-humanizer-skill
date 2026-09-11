# Plan: Parenthetical Overuse Rule

Musing source: `docs/musings/parenthetical-creep.md`

## Problem

The skill bans em dashes to zero but has no density rule for parentheticals. Test-corpus evidence and operator observation show parenthetical asides creeping into rewritten output. Likely cause: displacement from the em dash crackdown, plus LLM over-reliance on parentheses as a qualification device.

## Goal

Rewritten prose carries near-zero parenthetical asides, matching the em dash discipline but calibrated softer. The skill must also name the displacement risk so the self-audit watches substitute density, not just the banned tell.

## Changes

### 1. `references/patterns.md` — new pattern entry

Add under "Sentence structure" (near "Parenthetical hedging") a new entry: **Parenthetical overuse**.

- What: parenthetical asides used at high density, or used where the em dash used to live.
- Target: near-zero. Hard max: 2 instances per 1,000 words in rewritten prose. Count instances (open parens), not characters.
- Fix menu: cut, comma pair, own sentence, or fold into the sentence.
- Exemptions (do not flag): code, citations, technical notation, quoted material, and rewrites whose voice sample itself uses parentheticals (match the sample; cap at the sample's density).
- Cross-reference: "single-sentence overload" and "disguised rule of three" entries, which catch stacked/parenthetical forms of those patterns. This entry covers the remaining density problem.

### 2. `references/tolerance-matrix.md` — new row

Add row `Parenthetical overuse`:

- linkedin: skip (short-form, parens are a normal voice there)
- blog: strict
- technical-blog: relaxed (notation parens OK)
- investor-email: strict
- docs: relaxed (parameter/notation parens OK)
- casual: skip

### 3. `SKILL.md` — wire the rule in

- Add "Parenthetical overuse" to the sentence-structure bullet list in "What to remove or fix".
- Add to severity P2 in "Severity tiers".
- Extend the "EM DASH RULE" paragraph with displacement language: banning one aside mechanism can inflate substitutes (parentheticals, semicolons); the self-audit must scan the aside family, not just em dashes.
- Add to the pre-delivery checklist: a parenthetical density scan item (2 per 1,000 words hard max in rewritten prose).
- Add to the rewrite-mode final scan: count `(` instances in the rewritten prose; over max means fix before delivery.

### 4. Judge criterion (harness)

Add a judge criterion to relevant TCs (TC-01, TC-06) and `judge-prompt.md`: "Rewritten prose has at most 2 parenthetical instances per 1,000 words (code/notation/quotes exempt)". This lets the harness detect regression on the new rule.

### 5. New test case (optional, low priority)

TC-10: an input deliberately stuffed with parentheticals, verify the rewrite cuts density. Only if the above lands cleanly; do not block the main changes on it.

## Out of scope

- Semicolon/colon density rules (watch first, rule later if evidence shows displacement there).
- Changing the em dash threshold.

## Verification

1. `./scripts/run-tests.sh --only TC-01` and `--only TC-06` (k=3): judge criteria including the new parenthetical criterion pass.
2. Grep the skill dir: new pattern present in patterns.md, SKILL.md checklist, tolerance matrix row present.
3. Full suite before merge (sashay closure loop handles this).