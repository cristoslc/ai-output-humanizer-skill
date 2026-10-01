# Plan: Bundled Regex Scanner Tool

Musing source: operator question "why isn't there a script inside the skill folder to run the regexes on arbitrary text?" Follow-up operator decisions: keep Perl polyglot; recover via ask-to-install; ship python/node/perl implementations with host detection; degraded deterministic fallback behind user consent.

## Problem

The skill's mandatory first pass is a mechanical regex scan (`references/regex-scan.md`), but the repo ships no executable that performs it. Every invocation re-performs the "extract each regex into a script" step ad hoc, per the doc's instruction ("If your harness has a shell, run the scan mechanically. Node, Python, or ripgrep"). Consequences:

1. **The determinism is aspirational.** An agent without a shell (the skill declares `compatibility: any-agent`, and `allowed-tools` has no Bash) falls back to eyeballing 26 patterns across its own draft. The delivery gate ("zero HARD hits") is then self-graded by the same model that wrote the text.
2. **Repeated ad hoc extraction.** Each shell-equipped session rebuilds the extraction step differently, or skips it under context pressure. The only committed executable is `tests/regex-scan-selftest.mjs`, which validates the patterns against curated samples but cannot scan arbitrary text.
3. **No machine-readable gate.** The eval harness (`tests/superset/`) scores the scan with an LLM judge; nothing in the loop can check "HARD = 0 hits" deterministically.

## Runtime constraint: no interpreter is in-box everywhere

The scanner must run in Win/mac/linux/WSL wherever the skill does. No single scripting runtime ships in the box on all four (Windows ships only PowerShell/cmd; macOS ships Perl but removed Python; standard Linux ships Perl but not Node; minimal images ship neither). Two additional constraints kill any "just use grep" baseline:

- **POSIX ERE cannot express the catalog.** The patterns use lookaheads (`(?![^...]`) and non-capturing groups. Machine-verified on this host: a negative-lookahead pattern makes `grep -E` hard-error (`repetition-operator operand invalid`, exit 2) rather than degrade, so ~6 of 26 patterns cannot run on grep at all; backreference support (`\1`, needed by the corrective-definition pattern) also differs between BSD and GNU grep.
- **JS flavor needs one mandatory conversion.** The catalog uses `\u2019`-style escapes. Perl reads `\u` as a titlecase modifier (so `\u2019` silently means something else); .NET, Python `re`, and JavaScript read it correctly. Any Perl engine must convert `\uXXXX` → `\x{XXXX}` before compiling.

Runtimes that support the full flavor (lookarounds + backrefs), all stdlib-only:

- **Node**: takes the catalog patterns verbatim — the catalog's canonical flavor IS JavaScript regex; the reference implementation.
- **Python 3** (`re`): honors `\uXXXX` escapes; near-verbatim.
- **Perl** (macOS `5.34+` in-box, Linux distros in-box): needs the `\uXXXX` → `\x{XXXX}` conversion.
- **PowerShell / .NET regex** (Windows in-box): near-verbatim.

## Goal

A small scanner inside the skill that runs the fenced patterns from `regex-scan.md` against arbitrary text and prints per-pattern results with severity. Single source of truth stays the `.md`. Dispatch picks the best runtime the host offers; when the host offers none, the agent asks the user to either install a runtime or accept a degraded deterministic scan plus LLM judgment for the remainder.

## Design decisions

### 1. Location and shape: dispatcher + three engines + PowerShell engine

Inside the skill folder so the skill remains self-contained:

```
skills/ai-output-humanizer/tools/
  scan.sh            # pure POSIX dispatcher: detection, exec, recovery message
  --degraded mode lives here too (awk + grep; see §5)
  engines/
    scan.mjs         # node engine (reference semantics; patterns verbatim)
    scan.py          # python 3.6+ engine (near-verbatim)
    scan.pl          # perl 5.10+ engine (\uXXXX → \x{XXXX} conversion)
  scan.ps1           # windows engine (.NET regex, in-box)
```

The single-file sh/Perl polyglot is dropped: once three engines ship, one file doesn't hold them, and separate engine files mean each engine is directly invocable and individually testable (this also removes the `perl -x` marker quirks from the risk list). Engines share one contract: `[input|-] [--json]`; a `SCAN_CATALOG` env override lets tests point at scratch catalog copies; the catalog resolves relative to the engine's own path (`../../references/regex-scan.md` from `engines/`, `../references/` from `scan.sh`/`scan.ps1`), so engines run correctly from any working directory.

`scan.sh` must stay thin: runtime detection, `exec`, recovery message, and the `--degraded` branch. No engine logic in sh itself.

### 2. Single source of truth stays the `.md` — it IS the shared data file

All four runtime engines parse the fenced regexes out of `references/regex-scan.md` at run time. Patterns are never duplicated into code. Severity is derived from which heading block a `###` section sits under (`## HARD patterns` / `## LIMIT patterns` / `## SOFT patterns`); LIMIT numerals parse out of heading text. Sections without a code fence come back flagged `regex: null` (the regex-less procedures). Malformed catalog structure is a parse error, exiting 2 — a bad edit to `regex-scan.md` must not silently scan nothing.

The em dash / double hyphen check stays a literal (the md states "nothing to match, just search for the two literals"); all engines hardcode it, as the self-test does.

The Perl engine applies the `\uXXXX` → `\x{XXXX}` conversion on the extracted pattern text and errors on `\u` sequences it cannot convert; node and python engines consume patterns verbatim. A doc note in `regex-scan.md` records this engine-flavor contract so future pattern edits know what each engine accepts.

No separate data file. The markdown already is the shared data file, read at run time by all engines; a committed `patterns.json` copy would add a second artifact whose only failure mode is drift from the catalog. If a neutral exchange format ever becomes genuinely necessary, that is the moment to add it.

### 3. Dispatch order: fidelity-first, node → python3 → perl

`scan.sh` probes with `command -v` in this order:

1. **node** — verbatim patterns, zero conversion; this engine's semantics are by construction the reference ones (same engine as the self-test).
2. **python3** — near-verbatim, in-box on most Linux/WSL images.
3. **perl** — in-box on macOS; correct after the escape conversion.

Preference is fidelity-first (fewest translations between the doc and execution), not availability-first, because availability varies by host while fidelity is a fixed property. The parity fixtures (§8) make the order less critical — every shipped engine is held to the same reference vectors — but the ordering documents intent and keeps the conversion burden on the least-used engine.

### 4. Tier 2 recovery: ask the user, never auto-install or auto-degrade

When no runtime is found, `scan.sh` exits 3 with a structured stderr message:

```text
scan: no supported runtime found (node, python3, perl).
Options: ask the user to install one (apt/brew/dnf/apk commands vary by runtime),
ask whether to run the lower-fidelity degraded scan (--degraded), or use the
explicit-search fallback in regex-scan.md.
```

The skill instruction (§9) directs the executing agent to ask the user which recovery to take, before either installing a package or running the degraded mode. Rationale: this is a style tool; installing system packages or accepting reduced scan coverage are both user-owned decisions, and a build pipeline (the likely home of runtime-less environments) may prefer either option over mutating its image. Ask first, never silent.

### 5. Degraded deterministic mode (`--degraded`): grep/awk subset, honest exit

`scan.sh --degraded` runs when the user consents (never auto-selected):

- **Engine**: POSIX sh + awk + `grep -E`, all in-box on mac/linux/WSL. awk extracts the fenced patterns, applies a mechanical ERE triage, and drives the per-pattern scan; grep executes; awk computes 1-based line/col spans from per-line match offsets.
- **ERE triage**: `(?:` → `(` rewrite (harmless — nothing counts capture groups); any pattern containing `(?=`, `(?!`, or `\1` is **not** translated — it is listed as `SKIPPED — LLM JUDGMENT REQUIRED` and never affects the results of others. Roughly 20 of 26 patterns scan; the 6-7 with lookarounds/backrefs skip.
- **Exit semantics**: `exit 4` = degraded scan completed, no violations in the scanned subset, coverage < 100%. Violations in the scanned subset still `exit 1`. The output header states coverage ("degraded: 20/26 patterns mechanical"). The SKIPPED patterns, plus the regex-less LIMIT procedures, fall to LLM judgment — which is where the existing `patterns.md`/explicit-search material already lives.
- **Why a flag, not a default**: silent coverage loss in a delivery gate is the failure mode this tool exists to prevent. Fidelity reduction must be consented to by the user, per §4.

### 6. CLI contract

```bash
sh tools/scan.sh input.txt       # dispatch: node → python3 → perl
cat input.txt | sh tools/scan.sh
tools/scan.ps1 input.txt         # windows (in-box PowerShell)

sh tools/scan.sh --engine perl input.txt   # force one engine (tests, comparison)
sh tools/scan.sh --degraded input.txt      # consented degraded mode (§5)
... --json                                 # machine-readable (all engines)
```

Output, text mode: one block per pattern, in document order.

```
HARD  One-line contrast ("It's not X, it's Y")     0 hits
HARD  Split sentence ("It's not X. It's Y.")       1 hit
  L14 col5-L14 col34  "This is not about speed, it is about shipping."
```

- Spans are 1-based `line`/`column` pairs. Runtime engines decode UTF-8 before computing spans (Perl: `open :encoding(UTF-8)`; node: utf8 buffers; python: text mode) or byte/char confusion shifts every column past the first curly quote.
- JSON mode emits `[{ name, severity, count, spans: [{start, end, text}] }]` on stdout, diagnostics on stderr.

Exit codes: `0` = within gate, full fidelity. `1` = gate violation. `2` = usage or catalog parse error. `3` = no runtime found (dispatcher only; triggers the §4 ask). `4` = degraded scan completed within the scanned-subset gate (§5). SOFT patterns never affect the exit code; "AI vocabulary words" escalation (3+ hits) prints a note but is an agent action, not an exit-code change.

### 7. Regex-less LIMIT procedures: reported, not faked

"Stacked rhetorical questions", "Repeated sentence openers", and "Echoing skeleton runs" have no fence and no compact regex. All engines (including degraded mode) print them as:

```
LIMIT Repeated sentence openers (runs of 3+)      JUDGMENT REQUIRED
      no mechanical implementation; see regex-scan.md
```

and they never affect the exit code. The exit code covers exactly what executed, nothing more.

### 8. Parity as the enforcement mechanism

Five regex-consuming implementations (node, python, perl, PowerShell, degraded awk) is the design's main liability, answered by the dev-side parity harness in `tests/regex-scan-selftest.mjs`:

- On the dev host, the self-test invokes each available engine directly (node always; perl/python/ps1 skipped with a note when absent) and asserts **identical `{name, severity, count}` vectors** over the fixture corpus.
- Fixtures: `tests/superset/inputs/tc07-split-its-not.txt` (split-sentence + three-sentence hits), `tc01-happy-path.txt` (em dash literal hit), a seeded multi-pattern violation with known counts, and a UTF-8 input with curly quotes (guards offset/line math).
- Degraded-mode vectors are asserted to be a subset of the full-engine vectors, with the SKIPPED set exactly equal to the triaged patterns — so a triage bug can't hide a pattern silently.
- The inline catalog parse keeps validating `regex-scan.md` structure.

The `.md` as sole source of truth limits drift risk to harness code, never patterns; the parity suite turns that risk into a red CI light.

### 9. Portability wiring: instructions in `regex-scan.md`, not `allowed-tools`

`SKILL.md` and its `allowed-tools` list stay untouched — the any-agent contract is preserved, and no harness that lacks a shell is newly broken. The only skill-folder edit is in `regex-scan.md` § "How to use", replacing the current generic "extract each regex into a script" sentence with:

> The bundled scanner runs all fenced patterns mechanically: `sh tools/scan.sh <file>` (dispatches to node, python3, or perl; Windows: `tools/scan.ps1`). `--json` for a machine-readable result; exit 0 means the HARD/LIMIT gate passes at full fidelity; exit 3 means no runtime was found — ask the user whether to install one (never install without asking) or to run the lower-fidelity degraded scan (`--degraded`, exit 4, covers 20/26 patterns mechanically). Prefer the scanner over ad hoc extraction.

The existing "no shell → explicit search" paragraph stays unchanged as the last-resort fallback.

## Changes

### 1. `skills/ai-output-humanizer/tools/scan.sh` (new)
Pure POSIX dispatcher: fidelity-first detection (node → python3 → perl), `--engine` override, structured exit-3 ask-user message, `--degraded` grep/awk subset mode with ERE triage and exit-4 semantics. No engine logic beyond the degraded branch.

### 2. `skills/ai-output-humanizer/tools/engines/scan.mjs` (new)
Node engine, patterns verbatim. Reference implementation.

### 3. `skills/ai-output-humanizer/tools/engines/scan.py` (new)
Python 3.6+ engine, near-verbatim.

### 4. `skills/ai-output-humanizer/tools/engines/scan.pl` (new)
Perl 5.10+ engine with the `\uXXXX` conversion contract.

### 5. `skills/ai-output-humanizer/tools/scan.ps1` (new)
PowerShell 5.1+ engine, patterns near-verbatim via .NET regex.

### 6. `skills/ai-output-humanizer/references/regex-scan.md` (modified)
- The § "How to use" wiring sentence and recovery contract from §9.
- One added note: the engine-flavor contract (Perl conversion; node/python/.NET verbatim) so future pattern edits stay within what engines accept.

### 7. `tests/` (modified, dev-side only)
Parity harness per §8: per-engine vectors, degraded-subset assertion, fixture set as listed.

### 8. `AGENTS.md` / `docs/DEVELOPER-WORKFLOWS.md` (modified, one line each)
Add the parity test next to the self-test in the test command block; note the scanner's role.

No installer script or vendored library: recovery is the exit-3 message plus agent-asked consent; full-expression engines are the runtimes themselves.

## Out of scope

- Naive heuristics for the regex-less LIMIT procedures (deferred until a real corpus shows agents skip the judgment pass).
- Wiring `--json` output into `evaluate-superset.sh` as a deterministic judge criterion (natural follow-up; separate plan).
- Any change to `SKILL.md`, `allowed-tools`, or the pattern catalog itself.
- ERE-canonical rewrite of the catalog (forks semantics; the degraded mode is subset-and-flag instead).
- Scanning Markdown structure — input is plain prose, same as the manual pass.

## Known risks

- **Five implementations can drift.** The parity harness (§8) is the structural answer, and it must be run on every catalog change; `AGENTS.md`'s test command block makes that the default path. The `.md` as sole pattern source keeps drift confined to harness code.
- **Flavor edges beyond the fixtures** (unicode `\w`/`\b` differences between engine families, e.g. Python/Perl treating `\w` as unicode by default): possible silent divergence on inputs the fixtures don't cover. Mitigation: fixtures include a unicode-stress case; divergence found in practice becomes a fixture, not a code fix.
- **macOS may drop `/usr/bin/perl`** — inconsequential under this design (perl is already the last-choice engine); macOS hosts dispatch to node/python3 if present, else the §4 ask.
- **Minimal images lack all three runtimes** — the exact case §4/§5 serve: ask-to-install or consented degraded scan; never silent degradation.
- **Degraded triage becomes stale** if the catalog gains new lookahead/backref patterns: triage is mechanical (pattern-text inspection), flagged in output, and asserted by the subset test, so it cannot silently mark a scannable pattern as skipped.

## Verification

1. `node tests/regex-scan-selftest.mjs` — passes, now including per-engine parity vectors and the degraded-subset assertions.
2. Dispatcher runs on macOS, Linux dash (`/bin/sh`), and one WSL distro: `tc07` hits split-sentence + three-sentence patterns; `tc01` hits the em dash literal; a clean fixture exits 0; a seeded violation exits 1; corrupting one fence in a scratch copy of `regex-scan.md` exits 2.
3. `--engine` forced runs for each available engine produce identical vectors to the parity suite's expectations.
4. UTF-8 span check: a line with curly quotes reports correct `L/C` offsets from every engine present on the test host.
5. `--json` output parses with `JSON.parse` on every engine; spans round-trip against the text-mode report.
6. Exit-3 path: dispatcher run with a PATH lacking all three runtimes; confirm the structured ask message on stderr and exit 3, with no partial scan output.
7. Degraded mode: `--degraded` on the fixture corpus; confirm `exit 4` within-subset, `exit 1` on a seeded HARD violation in the scanned subset, and the SKIPPED list matching the triage expectations exactly.
8. Windows path exercised on a real Windows box at least once before merge (WSL does not substitute — it dispatches to a Unix engine, not scan.ps1).

## Blast radius

Moderate-low. Five new files under the skill's `tools/` (four full-fidelity engines + dispatcher with one degraded branch), two catalog-doc paragraphs, test-side changes only. No change to the skill's instruction surface for agents without a shell; their last-resort path is byte-identical to today's. Wherever any of the three Unix runtimes exists, scans are fully mechanical; where none exists, the user chooses between a consented degraded scan and the documented fallback. The principal ongoing cost is parity discipline on catalog changes, enforced by the default test command.