# 2026-09-11T0530 — checkpoint: TC-09 adjudication, counterfactual runs

## Intent

TC-09 blocked the suite (2/3) across the two full-suite runs and the solo re-run. Adjudicated with a counterfactual experiment before handoff.

## Counterfactual design

Ran TC-09 solo (k=3) at the pre-fix commit `9b195a5` in a detached temp worktree, twice, against the branch-tip result at `26f65e0`.

## Results

| Commit | Sessions | TC-09 results |
|---|---|---|
| `9b195a5` (pre-fix) | 2C8DCDEE, E1460197 | 3/3, 1/3 |
| `26f65e0` (branch tip) | 34B2EBB6, B2FFCA4F, EA4EE25F | 2/3, 2/3, 2/3 |

The flake occurs at both commits. At `9b195a5` it failed 1/3 with the same failure mode seen at `26f65e0` (criterion 4: rewrite does not use the literal `[Y] matters more than [X]` template; judge quotes "the phrase 'matters more than' never appears"). One passing `9b195a5` run even shows the judge accepting a truncated form ("Structure matters more.") at confidence 0.92 — judge strictness varies per sampling.

## Verdict

Pre-existing flake in TC-09's criterion 4 ("Rewrite uses template Y matters more than X", evaluate-superset.sh:89-90). Not caused by this PR's changes (fix commits touched only patterns.md:8 and SKILL.md:94/100 exemption wording). The failing rewrites are semantically equivalent ("The difference is structure", "Structure does the real work") but miss the mandated literal phrase.

Decision: proceed to operator handoff with TC-09 documented as a pre-existing flake. A separate fix (loosen the criterion wording or align SKILL.md template mandate with judge strictness) is out of scope for this sashay.

## Artifacts

- Temp worktree `.worktrees/fix/tmp-tc09-9b195a5` used for counterfactual, removed after.
- Failure reasons preserved at `/var/folders/.../opencode/tc09-b2ffca4f/` (session B2FFCA4F).
- Result logs: sessions 2C8DCDEE, E1460197, EA4EE25F in per-worktree gitignored results dirs.
