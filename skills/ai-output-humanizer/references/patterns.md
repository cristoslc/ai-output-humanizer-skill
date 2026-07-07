# Pattern Catalog

Full catalog of AI writing patterns to detect and fix. Each pattern includes what to watch for and how to fix it.

## Formatting tells

### Em dashes
Replace with commas, periods, parentheses, or rewrite as two sentences. Target: zero. Hard max: one per 1,000 words. Catch both Unicode em dash (—) and double-hyphen (--).

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

### Hedging
Cut perhaps, could potentially, it's important to note that, to be clear. Make the point directly.

### Missing bridge sentences
Each paragraph should connect to the last. If paragraphs could be rearranged without the reader noticing, add connective tissue.

### Compulsive rule of three
Vary groupings. Use two items, four items, or a full sentence instead of triads. Max one "adjective, adjective, and adjective" pattern per piece.

### Negative parallelisms
"It's not just about X, it's about Y" constructions. Also tailing-negation fragments: "no guessing," "no wasted motion" tacked onto the end of a sentence.

### Passive voice and subjectless fragments
"No configuration file needed" — rewrite with active voice and named actors when it makes the sentence clearer.

## Vocabulary

See `vocabulary-tiers.md` for the full 3-tier system.

## Template phrases

### Slot-fill constructions
"a [adjective] step towards [adjective] AI infrastructure" — if a phrase has a blank where a noun or adjective could go and still sound the same, it's too generic.

### Transition phrases
Moreover, Furthermore, Additionally, In today's [X], In an era where, It's worth noting that, Notably, Here's what's interesting, In conclusion, In summary, When it comes to, At the end of the day, That said, That being said.

### Generic conclusions
"The future looks bright," "Only time will tell," "One thing is certain," "As we move forward" — filler disguised as conclusions.

### Generic positive conclusions
"The future looks bright for the company. Exciting times lie ahead." — replace with a specific plan or fact.

## Structural issues

### Uniform paragraph length
Vary deliberately. Include some 1-2 sentence paragraphs and some longer ones.

### Formulaic openings
If the piece opens with broad context before getting to the point ("In the rapidly evolving world of..."), rewrite to lead with the news or the insight.

### Suspiciously clean grammar
Don't sand away all personality. Deliberate fragments, sentences starting with "And" or "But," comma splices for effect: if the natural voice uses them, keep them.

### Excessive structure
Too many headers in short text: more than 3 headings in under 300 words. Too many list items: 8+ bullets in under 200 words. Formulaic section headers: "Overview," "Key Points," "Summary," "Conclusion."

## Significance and framing

### Significance inflation
"Marking a pivotal moment in the evolution of..." or "a watershed moment for the industry." State what happened and let the reader judge significance.

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

### Parenthetical hedging
"(and, increasingly, Z)" — if the aside matters, give it its own sentence.

### Numbered list inflation
"Three key takeaways" — only use when the content genuinely has that many discrete, parallel items.

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
"The catch?", "The kicker?", "Here's the thing." — delete the hook and state the thing.

### Social endorsement closers
"This one is worth your time:", "Do yourself a favor and read this." — say what the thing is and who it's for, then drop the CTA.

## Communication artifacts

### Chatbot artifacts
"I hope this helps!", "Certainly!", "Absolutely!", "Great question!", "Feel free to reach out," "Let me know if you need anything else."

### "Let's" constructions
"Let's explore," "Let's take a look," "Let's break this down" — flag any "let's + verb" functioning as a transition rather than a genuine invitation.

### Sycophantic tone
"Great question!", "Excellent point!", "You're absolutely right!" — conversational rewards from chat interfaces.

### Acknowledgment loops
"You're asking about," "The question of whether," "To answer your question" — AI restates the prompt before answering.

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

### Hashtag stuffing
6+ hashtags on a single short post. Fix: 2-3 specific tags max.

### Bullet lists of bare noun phrases
5+ consecutive bullet items where each is a short (≤6 word) adjective-plus-noun phrase with no verb. Convert to prose or rewrite as full claims.

### Copula avoidance
"Serves as," "features," "boasts," "presents," "represents" instead of "is" or "has."

### Emotional flatline (header form)
"Interesting part of the project:" / "Interesting thing here:" / "Interesting aspect:" — pre-announcing significance the writing hasn't earned.

## Rhythm and uniformity

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
In prose over 200 words, TTR below 0.40 is worth a second look. Fix by broadening the what — name specific things, cite specific cases.

### Paragraph-reshuffle immunity
Can you swap two body paragraphs without breaking the piece? If yes, establish a through-line or decide whether the piece should be an explicit list.

### Treadmill effect / low information density
Read each paragraph and ask "what's actually new here?" If you could cut 40-60% and lose no information, cut it.

## When to rewrite from scratch vs. patch

If the text has 5+ flagged vocabulary hits across multiple categories, 3+ distinct pattern categories triggered, and uniform sentence/paragraph length, patching individual phrases won't fix it. Advise a full rewrite: state the core point in one sentence, then rebuild from there.
