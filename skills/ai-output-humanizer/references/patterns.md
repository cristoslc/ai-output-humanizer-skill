# Pattern Catalog

Full catalog of AI writing patterns to detect and fix. Each pattern includes what to watch for and how to fix it. Entries state their scope and exclusions so overlapping patterns do not double-flag the same text. Additions from 2026 on draw on awnist/slop-cop (github.com/awnist/slop-cop, MIT), whose taxonomy credits sneak's LLM_PROSE_TELLS.md (git.eeqj.de/sneak) and tropes.fyi, both queued as further upstream sources to mine.

## Formatting tells

### Em dashes
Replace with commas, periods, parentheses, or rewrite as two sentences. Target: zero. Hard max: one per 1,000 words. Catch both Unicode em dash (—) and double-hyphen (--).

### Hard wraps
Manual mid-paragraph line breaks: the paragraph wrapped at a fixed column, one bare newline joining sentence pieces. Fix by writing each prose paragraph as a single logical line; blank lines separate paragraphs. Headings, list items, block quotes, tables, and code fences are structural boundaries and keep their line breaks. Mechanical form: `references/regex-scan.md` § "Hard wraps (mid-paragraph line breaks)".

### Bold overuse
Strip bold from most phrases. One bolded phrase per major section at most. If something's important enough to bold, restructure the sentence to lead with it instead.

### Emoji in headers
Remove entirely. Exception: social posts may use one or two emoji sparingly at end of line, never mid-sentence.

### Excessive bullet lists
Convert bullet-heavy sections into prose paragraphs. Bullets only for genuinely list-like content (feature comparisons, step-by-step instructions, API parameters).

### Title case headings
Use sentence case for subheadings. Title case only for the piece's main title, if at all.

### Curly quotation marks
Curly quotes (" ") are a weak paste-from-chat signal — meaningful mainly in plain-text contexts. Treat as corroborating, never conclusive. Replace with straight quotes in plain-text/code; leave in finished publications.

### Inline-header lists
Bullet lists where each item starts with a bold header that repeats itself. Strip the bold header and write the point directly.

### List-label periods
In bulleted lists with short labels, LLMs end the label with a period instead of a colon. Fix the period to a colon and lowercase the start of the gloss.

### Hyphenated-pair overuse
Two problems: density (strings of hyphenated adjectives piled on one noun) and attributive/predicate error (hyphenated before noun, not after linking verb). Fix both.

## Sentence structure

### "It's not X — it's Y" / "This isn't about X, it's about Y"
Rewrite as a direct positive statement. Max one per piece. Includes the split-sentence form and multi-negation countdown.

### Hollow intensifiers
Cut genuine/genuinely, real (as in "a real improvement"), truly, quite frankly, to be honest, let's be clear, it's worth noting that. Just state the fact.

### Vague endorsement ("worth [verb]ing")
Cut or replace "worth reading," "worth paying attention to," "worth a look," "worth exploring," "worth checking out," "worth your time." Say why something matters instead.

### "Make X land" / impact-verb placeholders
"Make the concepts land," "makes the point hit," "that's where the argument lands," "this lands differently." "Land" (and siblings like "hit," "resonate," "stick," "work") used as a placeholder for the actual effect: the claim of impact substitutes for describing what happens in the reader's head. Replace with the concrete effect or the specific content that does the work: not "the submarine stories make the concepts land" but "the submarine stories are what make the rungs and the oscillation concrete." If you can't name what specifically lands, the sentence is asserting impact it hasn't earned — cut or concretize.

### Vague validity/status verbs
"Still holds," "remains the case," "continues to apply," "stands as discussed" — abstract stand-ins for restating the actual fact. Asserting that something is valid isn't the same as saying it. Cut the status verb and state the thing directly: not "the $220K figure still holds" but "$220K works."

### Hedging
Cut perhaps, could potentially, it's important to note that, to be clear. Make the point directly.

### Self-announcing honesty frames
"the honest gap," "honestly," "stated plainly," "to be clear," "let's be clear," "I'll be direct," "I'll be honest," "if I'm being honest" — meta-frames that announce candor instead of being candid. A plain statement of the fact *is* the candor; the label is filler. Cut the frame and state the point directly: not "The honest gap, stated plainly: I do not write production code day to day" but "I do not write production code day to day." The honesty-label pattern is most common when a writer is about to state a weakness or a concession, which is exactly when the reader is most alert to whether the candor is real. (Canonical in project-spoke `ai-writing-tells.md` § "Self-announcing honesty frames"; operator 2026-08-06.)

### Negative honesty assertions ("I won't claim X I don't have")
"I am not going to claim X I do not have," "I won't pretend to know Y," "I'm not going to oversell this" — asserting what you *won't* claim is the same meta-frame as labeling candor: it advertises integrity instead of letting the plain statement carry it. Stating the fact directly ("I have no recent React production work") reads as more honest than declaring you're too honest to claim it. A writer doing this often intends a soft concession; make the concession plain instead. If the point is simply that you don't have the experience, say so and move on.

### Missing bridge sentences
Each paragraph should connect to the last. If paragraphs could be rearranged without the reader noticing, add connective tissue.

### Single-sentence overload
A sentence that stacks an em dash aside, a parenthetical, and a subordinate clause is doing four sentences' work in one, and the long subject-verb distance it creates reads as a grammar error even when technically correct. If a sentence contains an em dash AND a parenthetical AND a subordinate clause, split it.

### Compulsive rule of three
Vary groupings. Use two items, four items, or a full sentence instead of triads. Max one "adjective, adjective, and adjective" pattern per piece. Also catches the disguised form: a parenthetical or appositive enumerating exactly three named entities with parallel role descriptions, e.g. "the three centers (A's X, B's Y, and C's Z)." Same forced-triad shape, just wearing parentheses instead of commas — fix the same way: a full sentence per item, or cut to two.

### Negative parallelisms
"It's not just about X, it's about Y" constructions. Also tailing-negation fragments: "no guessing," "no wasted motion" tacked onto the end of a sentence.

### Passive voice and subjectless fragments
"No configuration file needed" — rewrite with active voice and named actors when it makes the sentence clearer.

## Vocabulary

Flag AI-associated word choices wherever they occur, at full strength in every genre. Single hits of words with legitimate technical use (`robust`, `comprehensive`, `seamless`, `leverage`) are judgment calls; say so in the audit. Clusters and repeated density of flagged vocabulary are clear problems at any severity. `delve`, `tapestry`, `beacon`, `embark`, `testament to`, `game-changer`, `harness` are flagged anywhere, no exceptions.

Slop vocabulary from slop-cop, in two severities. Regex-flagged (SOFT scan, cluster escalation): synergy, holistic, transformative, cutting-edge, nuanced, unprecedented, noteworthy, enduring, intricacies, showcase, spearhead, streamline, foster, resonate, plus the elevated register one-offs ascertain, ameliorate, elucidate, promulgate, cognizant. Judgment-only (regex hit would be noise far more often than signal): dynamic, innovative, valuable, navigate in the figurative "navigate the challenges" sense, craft and boast as verbs. Filler adverbs, judgment calls when sentence-opening or purely ornamental: inherently, increasingly, remarkably, quietly, deeply, and "rather" as a bare intensifier ("rather good"), never inside "rather than".

Elevated-register swaps to plain equivalents: ascertain (find out), ameliorate (improve), elucidate (explain), promulgate (spread), cognizant (aware), "in the realm of" (in), "at this juncture" (now), "one must consider" (cut), "pertaining to" (about), "in regards to" (about), and "in a [adjective] way, manner, sense, fashion, or regard" collapses to the adverb ("in a crucial way" becomes "crucially"). (Scanner: SOFT § "Broader implications" / "in the realm of" for the phrase forms, § "In a [adjective] way/manner" for the collapse.)

## Template phrases

### Slot-fill constructions
"a [adjective] step towards [adjective] AI infrastructure" — if a phrase has a blank where a noun or adjective could go and still sound the same, it's too generic.

### Transition phrases
Moreover, Furthermore, Additionally, In today's [X], In an era where, It's worth noting that, Notably, Here's what's interesting, In conclusion, In summary, When it comes to, At the end of the day, That said, That being said, With that in mind, It follows that, Having said that, On the contrary.

### Generic conclusions
"The future looks bright," "Only time will tell," "One thing is certain," "As we move forward" — filler disguised as conclusions.

### Generic positive conclusions
"The future looks bright for the company. Exciting times lie ahead." — replace with a specific plan or fact.

## Structural issues

### Uniform paragraph length
Vary deliberately. Include some 1-2 sentence paragraphs and some longer ones.

### Formulaic openings
If the piece opens with broad context before getting to the point ("In the rapidly evolving world of...", "the ever-evolving landscape of...", "in today's fast-paced / digital world"), rewrite to lead with the news or the insight.

### Suspiciously clean grammar
Don't sand away all personality. Deliberate fragments, sentences starting with "And" or "But," comma splices for effect: if the natural voice uses them, keep them.

### Excessive structure
Too many headers in short text: more than 3 headings in under 300 words. Too many list items: 8+ bullets in under 200 words. Formulaic section headers: "Overview," "Key Points," "Summary," "Conclusion."

## Significance and framing

### Significance inflation
"Marking a pivotal moment in the evolution of..." or "a watershed moment for the industry." State what happened and let the reader judge significance. Also: "stands as a testament to," "is a testament to," "plays a crucial / pivotal / vital / key role in" — inflating significance instead of saying what happened. State the actual fact.

### Generic future-narrative closers
"May become one of the most important narratives of the next market cycle." Pattern: modal + "become" + (one of) the most [adjective] + (narrative/story/trend/theme).

### Hedge-stacked predictions
"Could potentially create," "may eventually unlock," "might ultimately transform." Pick one.

### "Real/actual" adjective inflation
"Real on-chain tokenomics," "actual reward sustainability" — using real/actual/genuine/true as empty intensifiers on abstract nouns. Drop the adjective and add the specific claim.

### False concession structure
"While X is impressive, Y remains a challenge." Both halves are vague. Make the concession specific or pick a side.

### Rhetorical question openers
"But what does this mean for developers?" — if you know the answer, just say it.

### Question-then-answer pairs
A rhetorical question answered by the very next sentence, especially a short pat answer ("What does this mean? It means trust."). Delete the question and keep the answer as a plain statement. (Extends "Rhetorical question openers"; the short pat answer is the tell the opener check misses.)

### Parenthetical hedging
"(and, increasingly, Z)" — if the aside matters, give it its own sentence.

### Numbered list inflation
"Three key takeaways" — only use when the content genuinely has that many discrete, parallel items. The LLM default extends past threes: drafted lists of exactly 3, 5, 7, or 10 items are the magic counts slop-cop observed. Ask whether the count came from the content or from the default; let a real list have its natural length, 4, 6, or 9.

### Self-labeling significance
"That last move is the contrarian one" — the label does the work the content was supposed to do. Cut the labeling sentence.

### Notability name-dropping
Listing media outlets without specific claims. "Cited in The New York Times, BBC, Financial Times, and The Hindu." One specific reference beats four name-drops.

### Historical analogy stacking
Rapid-fire lists of past technologies to borrow their weight ("like the printing press, the telegraph, and the internet before it"). Name the one parallel that does analytical work.

### Superficial -ing analyses
"Symbolizing the region's commitment to progress, reflecting decades of investment, and showcasing a new era of collaboration." Replace with specific facts.

### Promotional language
"Nestled within the breathtaking foothills," "a vibrant hub of innovation." Replace with plain description.

### Formulaic challenges
"Despite challenges, [subject] continues to thrive." Name the actual challenge and the actual response.

### Speculative scenario openers
"Imagine a world where..." — cut the hypothetical and state the real claim.

### False ranges
"From the Big Bang to dark matter" — list the actual topics or pick the one that matters.

### Novelty inflation
"He introduced a term," "a concept nobody's naming" — describe what the person did with the concept, not that they discovered it.

### Infomercial engagement hooks
"The catch?", "The kicker?", "Here's the thing," "Here's the kicker," "Here's what most people miss," "Here's the real." — delete the hook and state the thing.

### Social endorsement closers
"This one is worth your time:", "Do yourself a favor and read this." — say what the thing is and who it's for, then drop the CTA.

### Broader implications
"Broader implications," "wider implications," "implications for the broader landscape." Zooming out to unearned significance. State the actual implication or cut the phrase. (Scanner: SOFT.)

### Invented concept labels
"The attention paradox," "the trust vacuum," "the context creep," "the expertise chasm": a fake conceptual brand built by suffixing a noun with paradox, trap, creep, vacuum, inversion, or chasm. Describe the phenomenon in plain terms, or use the established name if one exists.

### Grandiose stakes
"Will fundamentally reshape how we think about everything," "will define the next era of computing," "has implications for the future of humanity": an ordinary point inflated to world-historical scale. Scale the claim to what was actually shown.

## Essay-voice tics

Source: llm-cliche-highlighter (Simon Willison, tools.simonwillison.net), a pattern library of ChatGPT-voiced blog-essay tics, which itself draws on Wikipedia's "Signs of AI writing" guide. These are rare in formal writing and dense in personal essays and dev blogs. Almost every fix is the same move: the tic announces or gestures at a point instead of stating it, so state it directly.

### Superlative totalizers ("that's the whole point")
"That's the whole point / game / thing," "consistency is the entire game," "the entire pitch is one sentence long," "here is the whole secret" — declaring totality about a detail. Say why it matters instead: not "consistency is the entire game" but "inconsistent names cost us an hour of debugging a week."

### "The punchline is ..."
"The punchline is that nobody wants to hear it." Announcing a point as a punchline instead of delivering it. Cut the framing and state the point.

### "That's not nothing"
"That's not nothing," "it is not nothing" — conceding small significance. Quantify the thing's actual weight or cut the sentence.

### "X is real, and it's not subtle"
"The improvement is real, and it's not subtle" — asserting realness instead of showing the thing. If it is real, give the number, quote, or example.

### "Worth naming"
"That loss is real and it's worth naming," "it's worth naming that ...," "Worth naming:" opener — announcing the value of naming the thing instead of naming it. Name it.

### Negation chains ("no X, no Y", "didn't X, didn't Y")
"No fluff, no filler, no jargon." "Did not flinch, did not blink, did not reach for the red pen." Two or more negated items in a row, also "didn't X, didn't Y." Keep at most one; rewrite as a positive statement about what the thing does or is.

### Corrective definition ("don't call it X, call it Y")
"Don't call it a rewrite. Call it a rescue." Negated verb + "it," then the same verb + "it." State the corrective claim directly: "It's a rescue: every test still passes and three bugs are gone."

### "You already know"
"You already know the answer." Excluding the reader or flattering them instead of informing. If the reader already knows, the sentence adds nothing; if they don't, tell them.

### "Sit with that"
"sit with that / this / it for a moment," "sit with the discomfort" — commanding a reflective pause instead of writing the reflection. Cut, or say the consequence of the point.

### "Turns out ..."
Sentence-initial "Turns out X" or "it turns out that X" — casual-revelation framing bolted to a tidy conclusion. State the discovered fact plainly.

### "Don't take my word for it"
The stock invitation to verify. Cut it; the passage works without it.

### "That's the part ..." gesture
"That's the part a schedule can't capture," "the part that makes me trust the rest," "my favourite part of ..." — pointing at a favoured detail without giving it. Name the detail.

### "The only X I trust"
"The only marketing I trust," "the only estimate I trust," "the only thing that matters" — the narrowing superlative reveal. Say why that one and not the others.

### "X is dead"
"Peer code review is dead," "X is dead; long live X" — obituary headlines standing in for an argument. A claim of death needs the specific fact: who moved away from it, why, to what.

### "That's why X mattered"
"That's why being able to open the environment mattered." Retroactively assigning significance with "that's why ... mattered / counted." State the actual consequence instead.

### Stranded auxiliary contrast
"The tool died; the data didn't." — a clause landing on a bare auxiliary (didn't, wouldn't, doesn't) to make the reversal. A legitimate human device, but a favorite of LLM voice; treat as corroborating, not conclusive. Keep at most one per piece.

## Communication artifacts

### Chatbot artifacts
"I hope this helps!", "Certainly!", "Absolutely!", "Great question!", "Feel free to reach out," "Let me know if you need anything else."

### "Let's" constructions
"Let's explore," "Let's take a look," "Let's break this down" — flag any "let's + verb" functioning as a transition rather than a genuine invitation.

### Sycophantic tone
"Great question!", "Excellent point!", "You're absolutely right!" — conversational rewards from chat interfaces.

### Acknowledgment loops
"You're asking about," "The question of whether," "To answer your question" — AI restates the prompt before answering.

### Unresolvable references (assumed thread context)
The chat's memory is not the reader's memory. Chat-shaped drafts resolve references out of the conversation instead of out of the document. In a finished deliverable the text is the referent's home: every numbered artifact arrives with its title, every lettered or numbered option arrives with the thing it stands for, and every pointer phrase names what it points at. The repair is a first-use gloss, not a recap; after the first use the bare label stands fine. This is the mirror of vague attribution: that tell under-specifies, this one over-specifies toward a referent the text alone cannot settle.

**Cold-copy test:** paste the deliverable into a blank file and resolve every numbered artifact, option label, and pointer phrase using only that file. Each one must answer from the file. The before/after for this pattern lives in `references/examples.md` § "Assumed-context references".

First mention says who; later mentions travel bare. The demo is the rule:

First use in a document: "PRO-4182, the retry backoff ticket, fixed the flaky tests."
Same document, five sentences later: "PRO-4182 also cleaned up the fixtures."

Exemptions: referents the document itself already defined, numbered artifacts in tracker-linked material where the ID is the standard lookup key, and replies inside the thread itself, where the recipient demonstrably holds the context. The test is resolvability, not the absence of an identifier.

### Confidence calibration phrases
"It's worth noting that," "Interestingly," "Surprisingly," "Importantly," "Significantly," "Notably," "Certainly," "Undoubtedly."

### Reasoning chain artifacts
"Let me think step by step," "Breaking this down," "Step 1:", "Here's my thought process" — chain-of-thought reasoning leaking into published prose.

### Cutoff disclaimers
"As of my last update," "While specific details are limited based on available information," "I don't have access to real-time data."

### Speculative gap-filling
"Maintains a relatively low public profile," "is believed to have," "likely began his career in" — guesses formatted as statements.

### Unfilled placeholders
`[Your Name]`, `[INSERT SOURCE URL]`, `[Describe the specific section]`, `2025-XX-XX`, `<!-- Add citation if available -->`.

### Citation markup leaks
`citeturn0search0`, `contentReference[oaicite:0]{index=0}`, `oai_citation`, `[attached_file:1]`, `grok_card`.

### AI-tool URL parameters
`utm_source=chatgpt.com`, `utm_source=copilot.com`, `utm_source=openai`, `utm_source=claude.ai`, `utm_source=perplexity.ai`, `referrer=grok.com`.

## Emotional and stylistic

### Emotional flatline
"What surprised me most," "I was fascinated to discover," "What struck me was," "I was excited to learn," "The most interesting part."

### Synonym cycling
AI rotates synonyms to avoid repeating a word: "developers… engineers… practitioners… builders" in the same paragraph. Human writers repeat the clearest word.

### Vague attributions
"Experts believe," "Studies show," "Research suggests," "Industry leaders agree" — without naming the expert, study, or leader.

### Filler phrases
"It is important to note that," "In terms of," "The reality is that" — mechanical padding.

### Recap-then-hollow-tail acknowledgment
Restating what someone just told you back to them, then closing with a low-content tail like "which I didn't have going in," "which was new information for me," or "that I hadn't considered." The thanks already implies the value; recapping their point and then flagging that it was new is redundant twice over. State the thanks once, without the recap or the tail: "Thanks for explaining X" carries the same meaning in a third of the words.

### Hashtag stuffing
6+ hashtags on a single short post. Fix: 2-3 specific tags max.

### Bullet lists of bare noun phrases
5+ consecutive bullet items where each is a short (≤6 word) adjective-plus-noun phrase with no verb. Convert to prose or rewrite as full claims.

### Copula avoidance
"Serves as," "features," "boasts," "presents," "represents" instead of "is" or "has."

### Emotional flatline (header form)
"Interesting part of the project:" / "Interesting thing here:" / "Interesting aspect:" — pre-announcing significance the writing hasn't earned.

## Rhythm and uniformity

### Echoing skeleton runs
Consecutive sentences built on the same multi-word skeleton: "The parser is a tiny state machine. The renderer is a tiny state machine." The shared frame makes the prose feel generated. Collapse into one sentence listing both subjects, or rewrite each sentence around its own point.

### Repeated sentence openers
Three or more consecutive sentences starting on the same word: "Maybe nobody needed it. Maybe the shortcut confused people. Maybe the redesign was overdue." Pronoun and article repetition is ordinary prose and fine; content-word repetition is the tell. Vary the openers or merge the sentences.

### Sentence length uniformity
If most sentences are 15-25 words, the text sounds robotic. Mix short punchy sentences (3-8 words) with longer flowing ones (20+).

### Paragraph length uniformity
If every paragraph is 3-5 sentences and roughly the same size, vary deliberately.

### Vocabulary repetition vs. synonym cycling
AI either repeats the same word mechanically or cycles through synonyms conspicuously. Human writers repeat when the word is right and vary when it's natural.

### Read-aloud test
If the text sounds like it could be read by a TTS engine without sounding weird, it's probably too uniform.

### Missing first-person perspective
Where appropriate, the writer should have opinions, preferences, and reactions. AI is relentlessly neutral.

### Over-polishing
Aggressively editing out every irregularity can push human writing toward AI statistical profiles. Don't sand away all personality.

## Stylometric signals

### Type-token ratio (TTR)
In prose over 200 words, TTR below 0.40 is worth a second look. Fix by broadening the what: name specific things, cite specific cases.

### Paragraph-reshuffle immunity
Can you swap two body paragraphs without breaking the piece? If yes, establish a through-line or decide whether the piece should be an explicit list.

### Treadmill effect / low information density
Read each paragraph and ask "what's actually new here?" If you could cut 40-60% and lose no information, cut it.

## When to rewrite from scratch vs. patch

If the text has 5+ flagged vocabulary hits across multiple categories, 3+ distinct pattern categories triggered, and uniform sentence/paragraph length, patching individual phrases won't fix it. Advise a full rewrite: state the core point in one sentence, then rebuild from there.

## Contrast denial and list templates

These three shapes substitute list-like rhythm for statements. They appear in otherwise clean prose, which is exactly why judgment matters more than regex here.

### Trailing denial ("X, not Y")
The sentence pivots at the end to deny what the reader might have assumed: "This is a style tool, not an authorship test." "Flags measure style, not authorship." One denial is plain human contrast and can stay when both sides are true and the contrast carries information. The tell is stacking them (two or more in one passage) or using them instead of saying what the thing is.

The regex only catches the comma form ("X, not Y"). Audit for the same tell in other clothes, which the regex cannot see: "flagged instead of rewritten", "kept rather than removed", "not merely X", "X, and not Y". If a sentence states its subject and then spends its tail distinguishing it from a lookalike, apply this pattern even though the scan shows no hit.

Before: "This is a style tool, not an authorship test. Flags measure style, not authorship."
After: "This is a style tool. It measures style only; pair flags with genre and register before acting on them."

### Colon-and-enumeration
A colon followed by three or more parallel noun phrases is a list wearing a sentence's clothes. It is the rule of three with a colon as the delivery mechanism.

Before: "The default shows up as recognizable shapes: signaling instead of informing, rule-driven rhythm, inflated significance, and chat leftovers."
After: "The default has a fingerprint. Sentences announce importance instead of adding a fact. Rhythm lands on schedule. Ordinary facts get dressed up as turning points. Chunks of the chat survive as leftovers."

Exemptions: real Markdown lists, short enumerations of names, files, or flags ("flags: --k, --only"), and definitions.

### Parenthetical triple
Three parallel items inside parentheses.

Before: "humans on autopilot (deadline pressure, genre drift, second-language phrasing) produce the same shapes"
After: "deadline pressure alone produces the same shapes"

Usually one member carries the point; write that member and drop the padding. If all three genuinely matter, each gets its own prose, not a parenthetical crowd.
Three parallel items inside parentheses.

Before: "humans on autopilot (deadline pressure, genre drift, second-language phrasing) produce the same shapes"
After: "deadline pressure alone produces the same shapes"

Usually one member carries the point; write that member and drop the padding. If all three genuinely matter, each gets its own prose, not a parenthetical crowd.
