**Responding to:** sashay kickoff, per operator request ("I'm seeing a lot of parentheticals creep into outputs, what could help?", captured in docs/musings/parenthetical-creep.md and planned in docs/plans/parenthetical-overuse-rule.md).

**Intent: implement the parenthetical overuse rule across skill files and judge criteria.**

What: two work units. Unit 1 wires the rule into the skill: a "Parenthetical overuse" entry in `references/patterns.md` (density target near-zero, hard max 2 instances per 1,000 words, fix menu, exemptions, cross-references to "single-sentence overload" and "compulsive rule of three"), a row in `references/tolerance-matrix.md`, and five touchpoints in `SKILL.md` (fix-list bullet, severity P2, em-dash displacement note, pre-delivery checklist item, rewrite-mode closing scan). Unit 2 adds the judge criterion to TC-01 and TC-06 in `tests/superset/test-cases.yaml` and mirrors it in `tests/superset/test-cases.md`.

Why: the skill bans em dashes to zero but has no density rule for parentheticals; displacement from the dash ban is the suspected cause of parenthetical creep in outputs.

Success looks like: `grep "Parenthetical overuse"` hits SKILL.md, patterns.md, tolerance-matrix.md, and test-cases.yaml; TC-01 and TC-06 pass with k=3 under the new judge criterion; chronicle updated at each checkpoint; changes land on `gh` PR #1 as a draft (not marked ready).