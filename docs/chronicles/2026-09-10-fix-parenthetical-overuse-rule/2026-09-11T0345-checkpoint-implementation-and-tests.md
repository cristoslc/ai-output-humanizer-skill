**Responding to:** checkpoint after both work units (skill wiring, judge criteria), per operator request ("I'm seeing a lot of parentheticals creep into outputs, what could help?"); plan sections 1-4 and verification section.

**Status update: rule implemented in all four files, tests run, one pre-existing flaky failure recorded.**

## What changed

1. `skills/ai-output-humanizer/references/patterns.md` — new "Parenthetical overuse" entry under Sentence structure, immediately after "Parenthetical hedging" (patterns.md:130). Near-zero target, hard max 2 instances per 1,000 words counting open parens; fix menu (cut, comma pair, own sentence, fold in); exemptions (code, citations, technical notation, quoted material, voice-sample density cap); cross-references to "Single-sentence overload" and "Compulsive rule of three" as covering the stacked/parenthetical forms.
2. `skills/ai-output-humanizer/references/tolerance-matrix.md` — row `Parenthetical overuse`: linkedin skip, blog strict, technical-blog relaxed (notation parens OK), investor-email strict, docs relaxed (parameter/notation parens OK), casual skip (line 28).
3. `skills/ai-output-humanizer/SKILL.md` — five touchpoints: sentence-structure bullet with the 2-per-1,000 hard max (line 169); severity P2 (line 201); EM DASH RULE paragraph extended with displacement language and aside-family self-audit (line 74); pre-delivery checklist parenthetical density scan (line 94); rewrite-mode closing scan item 4, counting `(` instances with over-max-means-fix (line 100).
4. `tests/superset/test-cases.yaml` — judge criterion "Rewritten prose has at most 2 parenthetical instances per 1,000 words (code/notation/quotes exempt)" appended to TC-01 and TC-06 judge_criteria. `tests/superset/test-cases.md` — same criterion mirrored in both TCs' Judge criteria lists. `judge-prompt.md` uses a generic `{{TEST_CASE}}` template with no per-TC criteria enumeration, so it was not touched; `tests/README.md` lists only what each TC tests, not criteria, so it was not touched.

## Verification

Grep: "Parenthetical overuse" hits SKILL.md (2 lines), patterns.md (1), tolerance-matrix.md (1), test-cases.yaml (2 criterion lines); checklist and closing-scan items also hit on "parenthetical instances".

Test runs (k=3, from worktree, commit d3814d3):

- **TC-01**: 2/3 individual passes. pass@k 0.963 (threshold met at k level), pass^k 0.2963, suite verdict FAIL because one trial failed. Run 1 failed at confidence 0.85. **The judge's objection is unrelated to the new criterion**: the rewritten prose was called clean ("zero em dashes, no contrast constructions, sentence lengths vary 5-18 words, natural voice"); the failure was that the agent used em dashes as separators in its own "Issues found" list, violating the EM DASH RULE's entire-output scope. This is a pre-existing skill-compliance flake in report formatting, not a parenthetical issue; per plan, no skill-text change was made in response. Parenthetical counts in rewritten output: run 1 had 20 open parens but they sit in the issues-list scaffolding (quote — label bullets); runs 2 and 3 had 1 each.
- **TC-06**: 3/3 passes, pass^k 1.0, PASS. Parens in runs 1-2 (10 and 16) are all in the Issues found / What changed / self-audit reporting sections, not the rewritten prose; run 1's self-audit line explicitly reports "parentheticals (0, well under the 2 per 1,000 cap)", showing the rule took effect. Run 3: zero parens.

No judge objection contradicted the new criterion, so no re-run was needed under the plan's one-re-run provision. Full-suite run is deferred to sashay closure per instructions.

## Deviations

- None from plan content. One interpretation note: in test outputs, parentheses in the reporting scaffolding (issues list, self-audit) are not "rewritten prose" and the judge scored them accordingly; the SKILL.md closing-scan wording ("count `(` instances in the rewritten prose") already scopes the count the same way.
- results/ files left uncommitted (gitignored) as instructed.

Commits landing this work: e08bd6a (skill + references), bb0725c (test criteria), plus chronicle entries 12740d2 and d3814d3.