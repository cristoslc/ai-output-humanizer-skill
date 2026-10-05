# Regex Scan

Mechanical, deterministic detection pass. The patterns below are regular expressions over the plain text; run them in order and record every hit with its location. Source: Simon Willison's llm-cliche-highlighter (tools.simonwillison.net), adapted to this skill's catalog; some regexes are verbatim from that tool (MIT-licensed style credit), some are derived from this catalog's entries. The 2026 additions draw on awnist/slop-cop (MIT), and the 1.6.1 additions on tropes.fyi and sneak's LLM_PROSE_TELLS.md (git.eeqj.de/sneak/prompts), both credited upstream by slop-cop.

## How to use

1. **Audit (before rewriting):** run every pattern below against the original text. HARD hits are the objective audit; then continue to the judgment-based patterns in `patterns.md` for everything the regexes cannot see (tone, uniformity, structure).
2. **Self-audit (after drafting):** run every HARD pattern against your draft.
3. **Gate (before delivery):** the final rewrite body ships only when the bundled scanner exits 0 on a file holding that body (HARD patterns at 0 hits, LIMIT patterns within limit). On exit 1, fix every reported hit, save the file, and re-run; loop up to three times, and if a hit survives the third loop, disclose the survivors in the delivery as findings of their own. Run the gate on the rewrite body plus the literal em dash and double hyphen search (`—` or `--`) over the complete final response: the issues list, the self-audit, and quoted original text included, since the em dash ban covers commentary and quotes while the body scan carries the remaining catalog patterns. If the scanner exits 3, follow the no-runtime ask-user contract above; with no shell at all, report per-pattern hit counts with the delivery. Never deliver a clean claim without naming the engine, the file scanned, and the exit code.

The bundled scanner runs all fenced patterns mechanically: `sh tools/scan.sh <file>` (dispatches to the node, python3, or perl engine the host has; Windows: `tools/scan.ps1`). Same output contract on every engine; `--json` for a machine-readable result; exit 0 means the HARD/LIMIT gate passes at full fidelity. Exit 3 means no runtime was found: ask the user whether to install one (apt/brew/dnf/apk; never install without asking) or to run the lower-fidelity degraded scan (`sh tools/scan.sh --degraded <file>`, exit 4, covers the ERE-compatible subset mechanically and lists the rest for LLM judgment). Prefer the scanner over ad hoc extraction. If you have no shell, apply each pattern as an explicit search and report "pattern: 0 hits" for each.

Severity meanings:

- **HARD** — any hit blocks delivery. Fix the hit.
- **LIMIT n** — delivery allows at most n hits total; more blocks.
- **SOFT** — a hit is corroborating evidence, not a blocker. Assess context, then decide.

## HARD patterns

### Em dash / double hyphen
`—` or `--` anywhere, including quoted original text and your own commentary. Replace with a period or comma. The zero rule from SKILL.md, stated as a regex: nothing to match, just search for the two literals.

### Hard wraps (mid-paragraph line breaks)
```
[a-z,;][ \t]*\r?
[ \t]*[a-z]
```
Prose paragraphs wrapped by hand at a fixed column, one bare newline joining the pieces. The mechanical signature: the previous line ends on a lowercase letter, a comma, or a semicolon, and the next line continues in lowercase; that pair of lines is one paragraph split mid-sentence. The fence body spans two physical lines on purpose: the pattern needs the newline itself, so a body carrying it degrades to skip under the line-based grep engine, and the script engines match across the newline at full fidelity. Fix: every prose paragraph becomes one logical line, blank lines separate paragraphs. Headings, list items, block quotes, table rows, code fences, and front matter are structural boundaries and keep their breaks; a hit inside a fence or front matter is a scan artifact, judge it manually and leave the fence alone.

### "It's not X, it's Y" (one-line contrast)
```
\b(?:it|this|that)(?:['’]s|\s+(?:is|was))\s+not\s+[^.!?\n,;—–]{1,60}[,;—–]\s*(?:it|this|that)(?:['’]s|\s+(?:is|was))\b
```
Case-insensitive, global.

### "It's not X. It's Y." (split sentence)
```
\b(?:isn['’]t|is\s+not)\s+[^.!?\n]{1,80}[.!?]\s*(?:it['’]s|it\s+is|this['’]s|this\s+is|that['’]s|that\s+is)\b
```
Also scan line breaks: `it's not` followed (next line) by `it's`. This is the TC-07 pattern; use the rewrite template in SKILL.md before delivering.

### Three-sentence variant ("It's about X. It's not. It's about Y.")
```
\bit(?:['’]s|\s+is)\s+not\s*[.!?](?=\s*(?:\n\s*)?[A-Za-z"'])
```
Flags the bare negated sentence that opens a contrast triad, whatever precedes or follows it. On a hit, apply the rewrite template in SKILL.md before delivering.

### "Not just X, but Y" (intensified negative parallelism)
```
\bnot\s+(?:just|only|merely|simply)\s+[^.!?\n;]*?\bbut(?:\s+also)?\b
```

### "Not X, but Y" (plain negative parallelism)
```
\bnot\s+(?!(?:just|only|merely|simply)\b)[^.!?\n;]{1,100}?\bbut\b
```

### Negation chains ("no X, no Y")
```
\bno[-\s][^,.;:!?—…]*,\s*(?:and\s+|or\s+)?no[-\s][^,.;:!?—…]*
```

### "Did not X, did not Y" chains
```
\b(?:did\s+not|didn['’]t)\s+\w+[^.!?\n]*,\s*(?:and\s+|or\s+)?(?:did\s+not|didn['’]t)\b
```

### Corrective definition ("don't call it X, call it Y")
```
\b(?:do\s+not|don['’]t)\s+(?:just\s+|simply\s+|merely\s+)?(\w+)(?:\s+(?:of|about|at|on|for|with|to))?\s+it\b[^.!?\n]*?[.!?;,;—–]['"\u201d\u2019]*\s*(?:just\s+|simply\s+|merely\s+)?\1(?:\s+(?:of|about|at|on|for|with|to))?\s+it\b
```

### Superlative totalizers
```
\b(?:that|this)(?:['’]s|\s+(?:is|was))\s+the\s+whole\b(?:\s+\w+)?|(?:\b(?:is|was|are|were)|['’]s)\s+the\s+(?:whole|entire)\b(?:\s+\w+)?|\bthe\s+entire\s+[\w'’-]+(?:\s+[\w'’-]+){0,4}?\s+(?:is|was|are|were)\b|\bhere(?:['’]s|\s+is)\s+the\s+whole\b
```

### "The punchline is"
```
\bthe\s+punchline(?:\s+(?:is|was|being)\b|\s*[:?])
```

### "That's not nothing"
```
\b(?:that|this|it|which)(?:['’]s|\s+(?:is|was))\s+not\s+nothing\b
```

### "X is real, and ..." / "worth naming"
```
\bis\s+real\b(?![\s-]+(?:estate|time|life|world|quick)\b)[^.!?\n]*?\b(?:and|not)\b|[^.!?\n]*\bworth\s+naming\b(?!\s+names\b)
```

### Performative honesty / "sit with that" / "you already know" / "turns out" / "take my word"
```
\bI\s+(?:will\s+not|won['’]t)\s+pretend\b|\b(?:I['’]ll|let['’]s|to)\s+be\s+(?:honest|clear|blunt|real)\b|(?:^|[.!?—–]\s+|\n)(?:Honestly|Look|Truthfully|Frankly)\s*,|\bsit(?:s|ting)?\s+with\s+(?:that|this|it)\b|\byou\s+already\s+know\b|(?:(?:^|[.!?—]\s+|\n)Turns\s+out\b|\bit\s+turns\s+out\s+that\b)|\btake\s+my\s+word\s+for\b
```

### "That's the part ..." / "the only X I trust" / "X is dead" / "that's why X mattered"
```
\b(?:that|this|it)(?:['’]s|\s+(?:is|was))\s+the\s+part\b|\bthe\s+part\s+that\s+(?:makes|made|gets|got|keeps|kept)\s+(?:me|you|us|it)\b|\bthe\s+only\s+[\w'’-]+(?:\s+[\w'’-]+){0,2}?\s+(?:I|you|we|it|they)\s+(?:trust|need|care|want|use|believe)\b|\bthe\s+only\s+[\w'’-]+\s+that\s+(?:matters|counts|works)\b|\b[\w\s]{3,30}\s+(?:is|are)\s+dead\b|\blong\s+live\s+\w+\b|\b(?:that|this)(?:['’]s|\s+(?:is|was))\s+why\b[^.!?\n]{0,80}?\b(?:matter(?:s|ed)?|count(?:s|ed)?)\b
```

### Significance inflation
```
\b(?:stand|stands|serve|serves)\s+as\s+(?:a|an)\s+(?:\w+\s+)?(?:testament|reminder)\b|\bis\s+(?:a|an)\s+(?:\w+\s+)?testament\s+to\b|\bplay(?:s|ed|ing)?\s+(?:a|an)\s+(?:\w+\s+)?(?:crucial|pivotal|vital|key)\s+role\b|\b(?:ever-)?(?:evolving|changing|shifting)\s+landscape\b
```

### Didactic hedging
```
\bit(?:['’]s|\s+(?:is|was))\s+(?:also\s+)?(?:important|worth|crucial|essential|vital)\s+(?:to\s+(?:note|remember|understand)|noting|mentioning)\b(?:\s+that\b)?|\bit\s+should\s+be\s+noted\b
```

### Promotional boilerplate
```
\bnestled\s+(?:in|on|among|between|along|at)\b|\bin\s+the\s+heart\s+of\b|\bhidden\s+gem\b|\bbreathtaking\b|\bboasts?\s+(?:a|an|the)\b|\bstunning\s+(?:views?|scenery|architecture)\b|\brich\s+(?:cultural\s+|historical\s+)?(?:heritage|tapestry)\b
```

### Chatbot leftovers and citation markup
```
\bas\s+an\s+ai(?:\s+language)?\s+model\b|\bas\s+of\s+my\s+last\s+(?:update|training)\b|\bknowledge\s+cutoff\b|contentReference|oaicite|turn0(?:search|news|image)\d*|utm_source=|\bi\s+hope\s+this\s+helps\b|\bcertainly\b(?=!)|\bgreat\s+question\b
```

### Superficial participle tails
```
,\s+(?:highlighting|underscoring|emphasizing|showcasing|reflecting|demonstrating|illustrating|solidifying|cementing|reinforcing)\s+(?:its|his|her|their|our|the|a|an|how|that|what|both)\b
```

### Vague attribution to unnamed authorities
```
\b(?:many|some|several|most)?\s*(?:experts|critics|observers|scholars|analysts|commentators)\s+(?:have\s+|often\s+|widely\s+)?(?:argu(?:e|es|ed)|not(?:e|es|ed)|suggest(?:s|ed)?|believ(?:e|es|ed)|agree[ds]?|claim(?:s|ed)?)\b|\bindustry\s+reports?\s+(?:suggest|indicate|show)\w*\b
```

### Despite-challenges formula
```
\bdespite\s+(?:these|those|such|its|their|the|numerous|ongoing)\s+(?:\w+\s+)?challenges\b|\bremains\s+to\s+be\s+seen\b|\btime\s+will\s+tell\b
```

## LIMIT patterns

### Stranded auxiliary contrast — LIMIT 1
```
[;:]\s+[^.;:!?\n]{2,50}\s(?:did|does|do|was|were|is|are|has|have|had|can|could|would|will)(?:n['’]t)?\s*[.;]
```
A legitimate human device. At most one per piece; more is the run-length tell.

### Stacked rhetorical questions — LIMIT 1
Count runs of 2+ question marks in consecutive sentences. One rhetorical question per piece is allowed; a run of two or more must be reduced to a single question or an answer.

### Repeated sentence openers — LIMIT 0 (runs of 3+)
Flag any run of three or more consecutive sentences opening on the same non-function word (skip I, it, the, a, an, this, that, we, you, they, there, but, and, so, in, as, if). Fix by varying openers or merging.

### Echoing skeleton runs — LIMIT 0 (runs of 2+)
Flag runs of two or more consecutive sentences sharing a 4+ word skeleton (like "is a tiny state machine"). Collapse to one sentence or rewrite each around its own point. These five procedures have no compact regex; apply them as explicit sentence-by-sentence checks.

### Gerund fragment litany — LIMIT 0 (runs of 2+)
Flag runs of two or more consecutive standalone paragraphs or lines opening on a gerund or present participle fragment: "Measuring velocity. Getting a number. Calling it progress." Rewrite as full sentences with subjects, or merge into one.

### Listicle in a trench coat — LIMIT 0 (runs of 2+)
Flag passages carrying two or more ordinal openers doing list work in continuous prose: "The first issue is...", "The second issue is...". Convert to a real list or dissolve the ordinals.

## SOFT patterns

### AI vocabulary words — SOFT
```
\b(?:delv(?:e|es|ed|ing)|tapestr(?:y|ies)|meticulous(?:ly)?|pivotal|intricate(?:ly)?|interplay|underscor(?:e|es|ed|ing)|garner(?:s|ed|ing)?|bolster(?:s|ed|ing)?|vibrant|bustling|multifaceted|seamless(?:ly)?|commendable|ever-evolving)\b
```
One hit can be coincidence. Several in one piece escalates: fix the hits and rerun as HARD if the piece initially showed 3+.

### Curly quotation marks — SOFT
Corroborating signal in plain-text output; never block on it. See `patterns.md`.

### "Experts suggest" with named sources — SOFT
The generic regex above hard-flags unnamed attribution. Attribution naming a specific person or publication is soft and usually correct; verify the name is real.

### Trailing denial ("X, not Y") — SOFT
```
,\s*not\s+(?!surprisingly|including|coincidentally|only|just|merely|simply|that|to\s)(?:[\w'’-]+(?:\s+[\w'’-]+){0,2})(?=[.!?;:\n]|$)
```
Catches the denial form with no "but" ("a style tool, not an authorship test"), which the negative-parallelism HARD patterns above miss. A single instance can be legitimate human contrast; stacked denials or denials substituting for a positive statement are the tell. The judgment entry in `patterns.md` has the before/after.

### Colon-and-enumeration — SOFT
```
:\s*[^.:;!?]{15,}[,;]\s*[^.:;!?]{10,}[,;]\s*(?:and\s+)?[^.:;!?]{10,}
```
A colon followed by three or more parallel comma-separated phrases in prose: a list wearing a sentence's clothes. Real Markdown lists and short enumerations of names, files, or flags are exempt. Fix by splitting: one sentence per item that matters.

### Assumed-context labels — SOFT
```
\b(?:option|variant|approach|plan|phase|scenario|spike)\s+(?:[a-dA-D]|[0-9])\b
```
A hit is corroboration, not a blocker: it routes the span to the judgment check in `patterns.md` § "Unresolvable references (assumed thread context)". A label with a first-use gloss ("Option A, the streaming migration") passes the resolvability check; the judgment pass decides how each hit resolves. Bare ticket IDs (`ABC-123`) are deliberately not scanned: they are standard and usually resolvable by tracker lookup, and resolvability is a judgment call no regex can make.

### "Almost" hedges — SOFT
```
\balmost\s+(?:always|never|certainly|exclusively|entirely|completely|invariably|universally)\b
```
Hedging where the claim needs a stance. Commit, or pick the honest qualifier ("usually", "rarely"). Judgment entry: `patterns.md` § "Almost hedges".

### Comma parenthetical qualifiers — SOFT
```
,\s*(?:of course|to be fair|it should be said|needless to say|in fairness|admittedly|to be sure|it must be said|after all|as everyone knows)\s*,
```
The comma-wrapped form only ("This is, of course, a simplification."); a sentence-initial "Of course," is ordinary speech and passes. Integrate the qualifier into the sentence or cut it. Judgment entry: `patterns.md` § "Parenthetical hedging".

### "In a [adjective] way/manner" filler — SOFT
```
\bin\s+(?:a|an)\s+[\w-]+(?:\s+[\w-]+)?\s+(?:way|manner|sense|fashion|regard)\b
```
Collapse to the adverb ("in a crucial way" becomes "crucially"). Idioms like "in a big way" and the bare hedge "in a sense" (no adjective, so not scanned) are judgment calls.

### "Broader implications" / "in the realm of" — SOFT
```
\b(?:broader|wider)\s+implications?\b|\bin\s+the\s+realm\s+of\b|\bat\s+this\s+juncture\b|\bone\s+must\s+consider\b|\bpertaining\s+to\b|\bin\s+regards\s+to\b
```
Zooming out to unearned significance, or elevated register padding. State the actual implication and use the plain phrase. Judgment entry: `patterns.md` § "Broader implications".

### "Rather than" preference framing — SOFT
```
\b\w+(?:\s+\w+){1,6}\s+rather\s+than\s+\w+(?:\s+\w+){1,5}\b
```
Two or more words on each side of "rather than": the preference-framing shape LLMs use to show nuance. Short natural contrasts ("walk rather than run") fall under the word minimum and pass. One per passage at most, same rule as the trailing denial.

### Semicolon negation pivot — SOFT
```
\b(?:not|never|no longer|don['’]t|doesn['’]t|isn['’]t|wasn['’]t|aren['’]t)\b(?:(?![;.!?\n—–]).){3,80};
```
A negated first clause before a semicolon, the reframe shape "not X; Y". Plain prose where the semicolon carries a real connection ("We shipped Monday; support was ready.") passes on judgment. Corroborating only.

### "Highlights the" + abstract noun — SOFT
```
\b(?:highlights?|highlighted|highlighting)\s+the\s+(?:importance|need|significance|value|role|impact|fact|challenges?|complexity|potential|limitations?|urgency|gaps?|contrast|tensions?|reality|severity|concerns?|problems?|issues?|difficult(?:y|ies)|dangers?|failures?|successes?|disparit(?:y|ies)|inequalit(?:y|ies)|tradeoffs?)\b
```
Extends the HARD participle-tails pattern to finite verbs: "This highlights the importance of X" is the same empty significance claim. Replace the verb with show/shows/showed/showing, or cut the phrase and state the actual fact.

### Unicode arrow decoration — SOFT
```
→
```
The arrow as a transition inside running prose. Write out the relation ("Input produces Output"). Exempt: tables, step chains, shell pipelines, code, and before/after notation, where the arrow is genre furniture.

### Wh-word headings — SOFT
```
(?:^|\n)#{1,6}\s+(?:Where|What|Why)\b
```
Section titles built on Where/What/Why: the model's default shape when naming a section. Several per piece is the template showing; rename each to the section's actual claim. Judgment entry: `patterns.md` § "Wh-word headings".

## Engine contract

The bundled engines (`tools/scan.sh`, `tools/scan.ps1`, `tools/engines/scan.mjs|scan.py|scan.pl`) read these fences directly; the markdown above is the single source of truth for the patterns. Catalog edits must stay inside the shared flavor:

- Supported across all engines: non-capturing groups, lookaheads/lookbehinds, backreferences (`\1`), `{n,m}` intervals, and `\uXXXX` escapes.
- Perl engine converts `\uXXXX` to `\x{XXXX}` mechanically. Treat every bare `$` in a fence as JS end-anchor semantics; the Perl engine rewrites it to `\z`. Writing `$` inside a character class, or a literal `@`, breaks the Perl engine and is forbidden here.
- Degraded mode (ERE + grep) skips patterns containing lookaheads, backreferences, or `\uXXXX` escapes, and multi-line fences (grep is line-based and cannot match across a newline); it lists them as `SKIPPED — LLM JUDGMENT REQUIRED`; it rewrites `(?:` and in-class `\s`/`\w`/`\d` to POSIX classes.
- Every `###` section under `## HARD patterns` needs exactly one fenced regex, except "Em dash / double hyphen" (a literal search, no fence). Fence-less sections are allowed only under `## LIMIT patterns` and `## SOFT patterns`.
- Limit patterns declare their max in the heading (`— LIMIT n`). Engines enforce it against total hits for the fenced patterns only.
- Engines emit identical reports by construction; `node tests/regex-scan-selftest.mjs` (repo dev side) asserts parity and must run after any catalog edit.