# Regex Scan

Mechanical, deterministic detection pass. The patterns below are regular expressions over the plain text; run them in order and record every hit with its location. Source: Simon Willison's llm-cliche-highlighter (tools.simonwillison.net), adapted to this skill's catalog; some regexes are verbatim from that tool (MIT-licensed style credit), some are derived from this catalog's entries.

## How to use

1. **Audit (before rewriting):** run every pattern below against the original text. HARD hits are the objective audit; then continue to the judgment-based patterns in `patterns.md` for everything the regexes cannot see (tone, uniformity, structure).
2. **Self-audit (after drafting):** run every HARD pattern against your draft.
3. **Gate (before delivery):** the rewrite is deliverable only when HARD patterns have zero hits and LIMIT patterns are within their limit. If a HARD pattern survives, fix it and re-run the scan. Never claim the scan passed without listing the patterns you ran.

If your harness has a shell, run the scan mechanically (Node, Python, or ripgrep) instead of by eye: extract each regex into a script and count matches per pattern. Mechanical execution beats eyeballing. If you have no shell, apply each pattern as an explicit search and report "pattern: 0 hits" for each.

Severity meanings:

- **HARD** — any hit blocks delivery. Fix the hit.
- **LIMIT n** — delivery allows at most n hits total; more blocks.
- **SOFT** — a hit is corroborating evidence, not a blocker. Assess context, then decide.

## HARD patterns

### Em dash / double hyphen
`—` or `--` anywhere, including quoted original text and your own commentary. Replace with a period or comma. The zero rule from SKILL.md, stated as a regex: nothing to match, just search for the two literals.

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
Flag runs of two or more consecutive sentences sharing a 4+ word skeleton (like "is a tiny state machine"). Collapse to one sentence or rewrite each around its own point. These three procedures have no compact regex; apply them as explicit sentence-by-sentence checks.

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