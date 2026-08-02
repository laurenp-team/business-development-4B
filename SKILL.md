---
name: meeting-research-memo
description: Turn one meeting-notes excerpt + its matched Stage 1 research excerpt into a connected memo, applying two fixed completeness/inclusion rules the same way every time. Use when generating a per-meeting memo from a paired notes file and research file.
---

# Meeting Research Memo

## Inputs

You will be given two file paths in the prompt:
- A meeting notes excerpt (one meeting only)
- The Stage 1 research excerpt matched to that same meeting

Read both files in full before drafting anything.

## Rule 1 — Complete follow-up requirements

For each commitment mentioned in the notes, identify three things, using ONLY
text actually present in the notes:

- **Action**: a specific, concrete task (not "follow up" or "stay in touch")
- **Owner**: ONE named individual or role tied to a specific person — a team,
  "we", "both sides", or any unnamed collective does NOT qualify
- **Deadline**: a specific date or a bounded timeframe tied to the meeting
  (e.g. "within two weeks") — "soon", "in the interim", "eventually" do NOT
  qualify

If all three are present, state the follow-up plainly with all three.

If any element is missing or too vague, say explicitly which element(s) are
missing and that a person needs to supply them before anyone acts on this
follow-up.

NEVER invent or infer an owner or deadline that isn't stated, even if it
seems like an obvious or likely candidate (e.g. assuming the Project Manager
who wrote the notes is the owner just because they're the author). If the
notes don't name a specific individual for a specific action, the owner is
missing — full stop.

## Rule 2 — Rules for inclusion

For each research item in the matched block, include it only if it connects
to something in these meeting notes: a named competitor, a specific
requirement raised, or a concern raised. Skip anything that doesn't connect,
this applies per item, not to the section as a whole. If every item in the
block is skipped this way, state that outright rather than leaving the
section blank.

For each included item, state whether it is a confirmed fact (public record,
cited data, documented policy) specific to this situation, or a general
pattern/trend/best practice that may or may not hold here — say so explicitly
either way.

## Memo template

Structure the output exactly as follows, in Markdown:

```
# Memo: [Meeting title from notes]

**Attendees:** [from notes]

## Meeting Summary
[2-4 neutral sentences summarizing what happened]

## Follow-Up Actions
[Apply Rule 1 to every commitment mentioned. For each: either state the
complete action/owner/deadline, or state what's missing.]

## Connected Research
[Apply Rule 2 to every research item in the matched block. For each included
item: what it is, why it connects, and whether it's confirmed-specific or a
general pattern. If nothing connects, say so outright.]

## Needs Human Sign-Off
[A consolidated bullet list of every gap flagged above: missing owners,
missing deadlines, vague actions, and any research noted as an unconfirmed
general pattern rather than a confirmed fact. This is the checklist a person
must clear before anyone acts on this memo.]
```

## Safety-net self-check (run before finalizing)

Before writing the final output, re-read your own draft against Rule 1 and
Rule 2:

- Does any owner or deadline appear that isn't literally present in the
  source notes? If so, remove the invention and flag it as missing instead.
- Is every incomplete follow-up explicitly labeled as incomplete, rather than
  silently dropped or smoothed over?
- Is any research section blank without an explicit "nothing connects"
  statement?
- Does every included research item have a stated connection back to the
  meeting notes?

If you find a violation, fix it before finalizing. If a gap can't be fixed
without fabricating information, say so plainly in the memo instead of
papering over it.

Write the finished memo to the output path given in the prompt. Do not ask
clarifying questions — apply the rules exactly as written and flag whatever
needs a human decision.
