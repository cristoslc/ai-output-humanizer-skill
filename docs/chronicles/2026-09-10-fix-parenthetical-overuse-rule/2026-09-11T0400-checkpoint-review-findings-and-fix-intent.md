**Responding to:** code review findings (orchestrator review loop, step 8)

Code review of `git diff gh/main` found no blockers. Two should-fix findings, both real contradictions with the new rule:

1. `patterns.md:8` em dash fix menu still routes replacements into "parentheses", the exact displacement the new rule bans. Fix: drop "parentheses" from that menu.
2. `SKILL.md:94` (checklist) and `SKILL.md:100` (final scan) exempt code/notation/quotes but omit the voice-sample density-cap exemption that `patterns.md:131` grants, so a voice-calibrated rewrite from a parenthetical-heavy sample would fail the hard gate. Fix: align the exemption wording across all three statements (also aligning "citations").

Nits deferred: sub-1,000-word pro-rating (finding 3) and missing example (finding 4) are optional; the P2-vs-hard-gate calibration (finding 5) mirrors the em dash precedent and stays as is.

Per operator request trace: this closure loop runs because the operator reported parenthetical creep in outputs (docs/plans/parenthetical-overuse-rule.md).

**Intent:** fix the two should-fix findings, then re-run TC-01 (the full-suite run showed 2/3 fails, all from the em-dash-in-issues-list flake in the agent's own scaffolding, unrelated to the new criterion; TC-06 passed 3/3). Success: findings addressed, TC-01 k=3 passes, suite green, then rebase and hand to operator.