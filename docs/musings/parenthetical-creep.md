# Parenthetical creep in outputs

## Observation

Outputs from the skill (and chat replies generally) are leaning on parentheticals more than a human writer would. The em dash crackdown likely pushed this: when the primary escape hatch for asides gets banned to zero, the pressure migrates to the next available aside mechanism. Parentheticals are the nearest substitute.

Evidence from the current test result corpus (open parens per run file, includes legit uses in quotes/labels):

- TC-01: 3, 4, 1
- TC-02: 4, 0, 3
- TC-04: 3, 6, 3
- TC-06: 6, 0, 1
- TC-07: 2, 0, 3
- TC-08: 2, 2, 1
- TC-09: 1, 3, 0

Not a smoking gun on its own; the harness output has legitimate parens (cliché labels, quoted spans). But the shape matches the displacement hypothesis: each run has *some*, and several runs stack 2+ parentheticals in a single rewritten paragraph. TC-04 run-2 has 6 in a short output.

## Related pattern already catalogued

`patterns.md` has "Parenthetical hedging" (the "(and, increasingly, Z)" form) but nothing that treats parenthetical *density* as its own tell. The single-sentence-overload rule and the disguised rule-of-three rule both mention parentheticals, but only as components.

## Hypothesis

Two mechanisms, possibly both real:

1. **Displacement.** Suppressing one tell class (em dashes) without a density cap on the substitutes lets the pressure move rather than disappear. The fix in the skill should be a substitute-budget rule: when you kill one aside mechanism, name the alternatives and cap them.
2. **Trained-in habit.** LLMs may just over-use parentheses as a hedging/qualification device regardless of em dash bans. In that case the fix is a standalone density rule, independent of the em dash rule.

Either way, the same rule helps: a parenthetical density target with a rewrite instruction (own sentence, comma pair, or cut), mirroring the shape of the em dash rule but calibrated softer.

## Candidate fix shape (for a plan)

Add a "Parenthetical overuse" rule to the catalog with:

- Target: near-zero in rewritten prose. Hard max: 2 per 1,000 words. (Calibrate vs. em dash's zero/1-per-1k.)
- Fix instruction: same menu as em dashes, commas, periods, own sentence, or cut.
- Exemptions: code, citations, technical notation, quoted material, and voice-calibrated rewrites where the sample itself uses parentheticals (match the sample).
- Add to the pre-delivery checklist as a scan item.
- Consider whether the SKILL.md "EM DASH RULE" block should name the displacement risk explicitly: banning one tell can inflate another; the self-audit should check substitute density.

Also worth checking: does the same displacement show up for semicolons or colons? The audit prompt should watch the whole "aside family" (em dash, parenthetical, semicolon) rather than one member at a time.

## Open questions

- Is 2 per 1,000 words the right threshold? Too tight might trigger false positives in technical writing; the tolerance matrix may need a row.
- Should density count parenthetical *characters* or *instances*? Instances are simpler and match how the em dash rule counts.
- Does the judge prompt need a parenthetical criterion, or is this fixable purely in the skill text? A judge criterion would let the harness detect regression.

## Disposition

Crystallized into a plan: `docs/plans/parenthetical-overuse-rule.md`. Sashay started from that plan.