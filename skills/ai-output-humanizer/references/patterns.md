# Pattern Catalog

Full catalog of AI writing patterns to detect and fix. Each pattern includes what to watch for and how to fix it. Entries state their scope and exclusions so overlapping patterns do not double-flag the same text. Additions from 2026 on draw on awnist/slop-cop (github.com/awnist/slop-cop, MIT), whose taxonomy credits sneak's LLM_PROSE_TELLS.md (git.eeqj.de/sneak) and tropes.fyi; both were mined for the 1.6.1 additions.

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

### Unicode arrow decoration
Unicode arrows (→, ⇒, ←) inside running prose or text-drawn flow chains ("input → processing → output") stand in for the connecting sentence. Write out the relation, or let a sentence carry it ("Input produces Output"). Exempt: real tables, code blocks, shell pipelines, step chains, and before/after notation, where the arrow is genre furniture. (Scanner: SOFT § Unicode arrow decoration.)

### Wh-word headings
Section titles built on Where/What/Why ("Where the market is stuck today," "What we do differently," "Why this matters"). The default shape the model reaches for when it has to name a section; the tell is independent of what the heading's body says. One such heading is a judgment call; several per piece is the template showing. Rename to the section's actual claim ("Adoption stalled on data access"). (Scanner: SOFT § Wh-word headings.)

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
Cut perhaps, could potentially, it's important to note that, to be clear. Make the point directly. The stacked form is the tell at full strength: five hedges in one sentence ("it's worth noting that, while this may not be universally applicable, in many cases it can potentially offer...") communicates nothing. Keep at most one hedge per sentence.

### Self-announcing honesty frames
"the honest gap," "honestly," "stated plainly," "to be clear," "let's be clear," "I'll be direct," "I'll be honest," "if I'm being honest" — meta-frames that announce candor instead of being candid. A plain statement of the fact *is* the candor; the label is filler. Cut the frame and state the point directly: not "The honest gap, stated plainly: I do not write production code day to day" but "I do not write production code day to day." The honesty-label pattern is most common when a writer is about to state a weakness or a concession, which is exactly when the reader is most alert to whether the candor is real. (Canonical in project-spoke `ai-writing-tells.md` § "Self-announcing honesty frames"; operator 2026-08-06.) The performative-vulnerability form is the same move in a costume: "And yes, I'm openly in love with the platform model," "And yes, since we're being honest: ..." — a polished, risk-free confession that borrows the shape of honesty without paying for it. Real candor is specific and uncomfortable; either write the uncomfortable specifics or delete the frame.

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

### Almost hedges
"almost always," "almost never," "almost certainly," "almost exclusively" — a micro-hedge that dodges commitment while sounding decisive. Less obvious than the full hedge stack. Either commit to the unqualified claim, or pick an honest qualifier ("usually," "rarely") that carries information. (Scanner: SOFT § "Almost" hedges.)

### Unnecessary contrast connectives
A "whereas," "as opposed to," "unlike," or "except that" clause appended to a sentence that already says it: "Models write one register above where a human would, whereas human writers tend to match register to context." The test: delete the clause; if the sentence still carries everything it needs, the contrast was filler and the clause dies. Keep the contrast only when both sides carry information.

### Unnecessary elaboration
The sentence keeps going after making its point, and the tail restates what an earlier word already meant: "use fifteen of them per paragraph, consistently, throughout the entire piece" — the tail after "paragraph" adds nothing. Cut the last third when it repeats. Document-level: the same test applies to a closing paragraph that only re-airs the piece. Exclusion: developing a genuine analogy or example is elaboration that earns its place; only cut elaboration that adds no information.

### Gerund fragment litany
Two or more consecutive standalone fragments opening on a gerund or present participle: "Measuring velocity. Getting a number. Calling it progress." Rewrite as full sentences with subjects, or merge into one sentence. (Scanner: LIMIT; regex-less, judged.)

### Listicle in a trench coat
Prose paragraphs doing list work through ordinals: "The first issue is that... The second issue is that... The third issue is..." Two or more ordinal openers in a passage; convert to an actual list, or dissolve the ordinals so the prose follows the argument's own order. Related to "Excessive enumeration"; extends numbered-list inflation into continuous prose. (Scanner: LIMIT; regex-less, judged.)

### Passive voice and subjectless fragments
"No configuration file needed" — rewrite with active voice and named actors when it makes the sentence clearer.

## Vocabulary

Flag AI-associated word choices wherever they occur, at full strength in every genre. Single hits of words with legitimate technical use (`robust`, `comprehensive`, `seamless`, `leverage`) are judgment calls; say so in the audit. Clusters and repeated density of flagged vocabulary are clear problems at any severity. `delve`, `tapestry`, `beacon`, `embark`, `testament to`, `game-changer`, `harness` are flagged anywhere, no exceptions.

Slop vocabulary from slop-cop, in two severities. Regex-flagged (SOFT scan, cluster escalation): synergy, holistic, transformative, cutting-edge, nuanced, unprecedented, noteworthy, enduring, intricacies, showcase, spearhead, streamline, foster, resonate, plus the elevated register one-offs ascertain, ameliorate, elucidate, promulgate, cognizant. Judgment-only (regex hit would be noise far more often than signal): dynamic, innovative, valuable, navigate in the figurative "navigate the challenges" sense, craft and boast as verbs, multifaceted, underscores as a verb ("this underscores the need"), landscape as a domain noun ("the AI landscape"), realm, and the figurative-inhabitance phrase "where X actually lives". Filler adverbs, judgment calls when sentence-opening or purely ornamental: inherently, increasingly, remarkably, quietly, deeply, essentially, ultimately, particularly, arguably, fundamentally, and "rather" as a bare intensifier ("rather good"), never inside "rather than".

Elevated-register swaps to plain equivalents: ascertain (find out), ameliorate (improve), elucidate (explain), promulgate (spread), cognizant (aware), utilize (use), commence (start), facilitate (help), endeavor (try), demonstrate (show, in prose sense; keep the technical sense in engineering docs), "in the realm of" (in), "at this juncture" (now), "one must consider" (cut), "pertaining to" (about), "in regards to" (about), and "in a [adjective] way, manner, sense, fashion, or regard" collapses to the adverb ("in a crucial way" becomes "crucially"). (Scanner: SOFT § "Broader implications" / "in the realm of" for the phrase forms, § "In a [adjective] way/manner" for the collapse.)

## Template phrases

### Slot-fill constructions
"a [adjective] step towards [adjective] AI infrastructure" — if a phrase has a blank where a noun or adjective could go and still sound the same, it's too generic.

### Transition phrases
Moreover, Furthermore, Additionally, In today's [X], In an era where, In an era of [X], It's worth noting that, Notably, Here's what's interesting, In conclusion, In summary, When it comes to, At the end of the day, Moving forward, That said, That being said, With that in mind, It follows that, Having said that, On the contrary. The paragraph-level form is connector addiction: three or more consecutive paragraphs opening on a transition word (However, Furthermore, Moreover, Additionally, That said) chain into a template. Rewrite those openings to start with their subject.

### Generic conclusions
"The future looks bright," "Only time will tell," "One thing is certain," "As we move forward" — filler disguised as conclusions. The never-ending form stacks clause after clause instead of landing one point, as if the piece cannot bear to stop. Read the final paragraph: if it keeps extending and restating, land the strongest single line and stop there.

### Generic positive conclusions
"The future looks bright for the company. Exciting times lie ahead." — replace with a specific plan or fact.

## Structural issues

### Uniform paragraph length
Vary deliberately. Include some 1-2 sentence paragraphs and some longer ones.

### Pivot paragraphs
A one-sentence paragraph that exists only to transition: "But here's where it gets interesting." "Which raises an uncomfortable truth." It contains zero information and the actual point sits in the next paragraph. Delete the pivot and let the point open its paragraph directly.

### Fractal summaries
"What I'll tell you; what I'm telling you; what I just told you" applied at every level: every section opens by previewing its content and closes by recapping it, and the whole document previews and recaps too. One preview at the top and one synthesis at the end is plenty. Cut the per-section framing.

### Announce-then-answer preambles
A structural announcer before the point: "Two constraints shape the design," "Two continuations are worth supporting," "The more important point is..." It names the count or shape of what follows instead of delivering it. The sentence sets up the answer instead of being the answer; it pairs with compulsive counting (the stated number) and the ordinal delivery ("The first... The second..." — see Listicle in a trench coat). Cut the announcer and lead with the content.

### Formulaic openings
If the piece opens with broad context before getting to the point ("In the rapidly evolving world of...", "the ever-evolving landscape of...", "in today's fast-paced / digital world", "In an era of rapid technological change..."), rewrite to lead with the news or the insight. The "era-of" form is the model stalling while it finds its argument; delete the first paragraph entirely when a test read proves the piece improves without it.

### Premise stacking
A point, often a question, preceded by a paragraph of the evidence for it, so the point is made two or three times before it is finally stated: the internal doc says X, a teammate says roughly X, the region comparison supports X, and then the question "is X available here?" arrives already answered. Also linked to reasoning leaks. Compress: ask the question, then give the one piece of evidence that answers it.

### Suspiciously clean grammar
Don't sand away all personality. Deliberate fragments, sentences starting with "And" or "But," comma splices for effect: if the natural voice uses them, keep them.

### Excessive structure
Too many headers in short text: more than 3 headings in under 300 words. Too many list items: 8+ bullets in under 200 words. Formulaic section headers: "Overview," "Key Points," "Summary," "Conclusion." And the five-paragraph prison: a rigid introduction that previews the argument, 3-5 body points, and a conclusion that restates the thesis, applied when nobody asked for an essay. Break the arc when the content doesn't demand it.

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
"(and, increasingly, Z)" — if the aside matters, give it its own sentence. The comma-wrapped qualifier family works the same way: "(of course)," "(to be fair)," "(needless to say)," "(in fairness)," "(admittedly)," "(to be sure)," "(it must be said)," "(after all)," "(as everyone knows)" — parenthetical asides performing nuance without changing the argument. (Scanner: SOFT § Comma parenthetical qualifiers.)

### Numbered list inflation
"Three key takeaways" — only use when the content genuinely has that many discrete, parallel items. The LLM default extends past threes: drafted lists of exactly 3, 5, 7, or 10 items are the magic counts slop-cop observed. Ask whether the count came from the content or from the default; let a real list have its natural length, 4, 6, or 9. The prose cousin is compulsive counting: stating the exact number before the list exists ("Five things we wish to discuss," "Four reasons why this will work") as if getting the count right were itself the achievement. Drop the announced count and let the items stand on their content.

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
"Despite challenges, [subject] continues to thrive." Name the actual challenge and the actual response. The full formula: acknowledge the difficulties only to dismiss them, opening "Despite its [positive qualities], [subject] faces challenges..." and closing "Despite these challenges, [optimistic conclusion]." Replace the frame with the specific difficulty and the specific answer.

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

### Belaboring the unnecessary
A minor or uncontroversial point stated, then defended as if an objection was coming: "We are setting this out in full rather than quietly changing the recommendation, because the failure mode is the reason it matters." Nobody was going to raise the objection; the defense adds nothing. Cut to the plain statement.

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

### Quotable one-liners
A standalone line dressed to be pulled out and quoted with zero context: "Story points are a planning tool with no fixed unit," "Every metric that rewards volume punishes leverage." Slide bait; it carries no new information and proves nothing on its own. If the line holds a real claim, give the argument behind it in the same passage; otherwise cut it.

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
"You're asking about," "The question of whether," "To answer your question" — AI restates the prompt before answering. The tie-back is the same artifact at close: the reply delivers the point, then bolts a summary of itself back onto the original ask ("So, to answer your question: yes, the employee can be added to the app," "In short, this gives you everything you need to ship"). Once the answer is given, stop.

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
"Let me think step by step," "Breaking this down," "Step 1:", "Here's my thought process" — chain-of-thought reasoning leaking into published prose. The subtler form narrates the writing itself instead of the subject: "What that changes in the design is smaller than it might appear, and what it changes is worth being precise about," "I want to be exact about my own role here." The reader gets a voiceover of the piece's own moves. Delete the voiceover; do the move.

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
"What surprised me most," "I was fascinated to discover," "What struck me was," "I was excited to learn," "The most interesting part." Related is the empathy performance: emotional language so generic it could apply to anything ("This can be a deeply challenging experience," "Your feelings are valid."). Replace with the specific feeling or the specific situation, or cut.

### Synonym cycling
AI rotates synonyms to avoid repeating a word: "developers… engineers… practitioners… builders" in the same paragraph. Human writers repeat the clearest word.

### Vague attributions
"Experts believe," "Studies show," "Research suggests," "Industry leaders agree" — without naming the expert, study, or leader. The familiarity variant borrows the reader's supposed prior knowledge as the unnamed authority: "famously," "notoriously," "considered a classic," "as we all know." If you can't name the source, the claim doesn't have one.

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

### Two-clause compound monotony
Most sentences are two balanced independent clauses joined by a comma and a conjunction ("X, and Y.", "..., which is why Z.", "..., because they never change the argument.") — every sentence two similar-length halves, the same shape over and over. Human prose mixes one-clause sentences, front-loaded subordinate clauses, and complexity embedded mid-sentence. Fix in order: try deleting the second clause (it is often redundant); if it carries meaning, make it its own sentence; otherwise front the subordinate clause or embed a relative clause mid-sentence instead of appending.

### Paragraph length uniformity
If every paragraph is 3-5 sentences and roughly the same size, vary deliberately. The section-level form counts too: if the first section runs about 150 words and every later section lands between 130 and 170, split or merge so the sizes vary for content reasons.

### Vocabulary repetition vs. synonym cycling
AI either repeats the same word mechanically or cycles through synonyms conspicuously. Human writers repeat when the word is right and vary when it's natural. The self-echo form: the piece reuses one of its own distinctive phrases pages later as if paying it off ("quietly disappeared" surfacing again in a unrelated section). Once is a motif, twice without intent is the pattern; rewrite the second use plain.

### Read-aloud test
If the text sounds like it could be read by a TTS engine without sounding weird, it's probably too uniform.

### Missing first-person perspective
Where appropriate, the writer should have opinions, preferences, and reactions. AI is relentlessly neutral.

### Over-polishing
Aggressively editing out every irregularity can push human writing toward AI statistical profiles. Don't sand away all personality. The absence-of-mess test is the same read: model prose never contradicts itself mid-paragraph and catches it, never takes a tangent and walks it back, never risks a joke that could fall flat, never leaves a thought genuinely unfinished. A couple of deliberate rough edges are healthy; polish that erases all of them is the tell.

### Dead metaphor recurrence
Stock metaphors used as if fresh, then repeated: "game-changer," "double-edged sword," "tip of the iceberg," "north star," "perfect storm," "elephant in the room," "building blocks." "game-changer" is flagged anywhere by the vocabulary rule; recurrence (the same metaphor or two in a row) is the rhythm tell. Replace with the comparison the actual topic affords, at most once each.

### Coined metaphor crutch
A forced simile or coined metaphor reached for because it sounds clever: "Tracking productivity with that metric is like tracking weight loss with a scale you also calibrate." Nobody would say it in conversation and it clarifies nothing. A favorite variant steals a word from the prompt and repurposes it as a metaphor for something unrelated. Cut, or state the point directly.

### Dramatic fragments (corroborating)
Sentence fragments as standalone paragraphs for manufactured emphasis: "Full stop." "Let that sink in." "He published this. Openly. In a book. As a priest." Corroborating signal, same treatment as the stranded auxiliary: a piece may keep one; two or more is the pattern. Expand into a complete sentence that adds information, or delete.

### Short-hook paragraphs
Standalone one-line paragraphs whose only job is suspense or audience handling ("And that's where it all went wrong."). Cut the line, or give it actual content as a full paragraph.

### Staccato bursts (corroborating)
Three or more very short sentences in a row at matching cadence and length: "The data is clear. The trend is undeniable. The conclusion is obvious." Corroborating signal; merge at least two into a longer sentence or vary the lengths so they stop landing on the same beat.

## Stylometric signals

### Type-token ratio (TTR)
In prose over 200 words, TTR below 0.40 is worth a second look. Fix by broadening the what: name specific things, cite specific cases.

### Paragraph-reshuffle immunity
Can you swap two body paragraphs without breaking the piece? If yes, establish a through-line or decide whether the piece should be an explicit list. The extreme form is content duplication: whole sections or paragraphs repeated verbatim inside one piece, a leftover from lost tracking. Merge or delete the duplicate.

### Treadmill effect / low information density
Read each paragraph and ask "what's actually new here?" If you could cut 40-60% and lose no information, cut it.

### One-point dilution
One thesis restated across thousands of words with rotating metaphors, framings, and examples, adding nothing: an 800-word argument becomes 4,000 words of circular repetition; a single argument restated eight ways. Whole-piece counterpart of the treadmill effect, which names paragraph-level padding. Fix: state the point once, then keep only framings that carry a genuinely new angle and cut the rest.

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

Exemptions: real Markdown lists, short enumerations of names, files, or flags ("flags: --k, --only"), and definitions. The cadence survives without the colon too: a short setup clause followed by an elaboration, repeated ("X means Y. Y demands Z. Z resists W.") is the same list rhythm wearing prose; vary the shape or collapse the chain.

### Parenthetical triple
Three parallel items inside parentheses.

Before: "humans on autopilot (deadline pressure, genre drift, second-language phrasing) produce the same shapes"
After: "deadline pressure alone produces the same shapes"

Usually one member carries the point; write that member and drop the padding. If all three genuinely matter, each gets its own prose, not a parenthetical crowd.
