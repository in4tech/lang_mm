# Design

## Context

See proposal.md for why. The study page keeps marks in a `Map` that dies with the widget. `libraryFromCloud` keeps `CloudSetRecord.id` only long enough to match folders, then builds a `VocabularySet` with no id. `sets` documents are create-only and their word arrays have no per-word id. The signed-in user is the anonymous uid from `main`. Statistics, Today's vocabulary, and Recent render a `HomeSample` that `homeFromLibrary` leaves empty.

## Goals / Non-Goals

**Goals:**

- One progress document per user and set, and one agenda document per user and local date.
- Home numbers and the study selection are read from those documents. They are not copied into a second store.
- The Firestore id travels with the loaded set without being written into the `sets` document.

**Non-Goals:**

- A review history, a due date, or intervals.
- Rating buttons for Lv.3 Learning and Lv.5 Good.
- Editing a stored set, or giving words their own ids.
- Linking the anonymous uid to a named account.

## Decisions

### Progress is its own document

`progress/{uid}_{setId}`:

```
ownerId:   uid
setId:     set id
marks:     { "0": "easy", "3": "hard" }
updatedAt: server timestamp
```

The key `"0"` is the word's index in `sets/{setId}.words`. A rating merges that one key and `updatedAt`. The set document is not updated.

Alternative: store the mark on the set. Rejected because `sets` cannot be updated, and a shared set would mix learners. Alternative: one document per word. Rejected because opening a set would be one read per word; a set fits in one document.

### The day list is create-once

`agenda/{uid}_{yyyy-mm-dd}`, with the date taken from the device clock, not UTC:

```
ownerId:   uid
date:      "yyyy-mm-dd"
words:     [ { setId, index } ]    // length 0 to 8
createdAt: server timestamp
```

Candidates are loaded sets that have an id. `hard`, then `familiar`, then unmarked, and within a mark the library order then the word index. `easy` words are skipped. Cap 8. A missing document is created, including an empty `words` array when nothing qualifies. A later open on the same date rewrites `words` only when the stored array is empty and a candidate now exists. A non-empty array is left as stored. The chip text is read from the set.

Alternative: derive "today" from per-word timestamps. Rejected because a rating would change the list under Practice.

### Rules follow the owner

`progress` and `agenda` allow read, create, and the updates above only when `request.auth.uid` equals `ownerId` and the document id is `{uid}_{setId}` or `{uid}_{date}`. Mark values are only `hard`, `familiar`, and `easy`. Delete is denied. `sets` gains no rule and no field.

### The set id stays off the Firestore set map

`VocabularySet` gains an optional id. `libraryFromCloud` copies `CloudSetRecord.id` onto it. `vocabularySetDocument` still omits that id, so a `sets` write is unchanged. The on-device library encode adds the id beside the set when it is present, and decode reads it back. Marks and the day list are not written there.

### Home reads, then counts

On open, and when study closes, load `progress` where `ownerId` is the uid, plus today's agenda document. Join by set id.

Statistics scope is every loaded set while All is on. All off uses the progress document with the latest `updatedAt`. The fraction is the `easy` count over the word count. Each legend percent is that level's count over the same word count, rounded to the nearest integer, with a zero denominator shown as 0%. Unmarked words are Lv.1. Lv.3 and Lv.5 stay 0%. Bar labels are the counts above zero.

Recent is one card per joined progress document, `updatedAt` descending. The percent uses the same easy ratio. Below 50% uses `HomeSample.forgot`, from 50% until 90% `HomeSample.learning`, and from 90% `HomeSample.progressGreen`. Continue opens that set in Flashcard at position 0.

Today lays the agenda out two words per row, term plus singular and plural. Practice opens Flashcard whose order is the agenda. The last rating in that order stays on the last listed word.

A missing uid or a failed read leaves the empty dashboard the home already shows for a library with folders.

### The card motions stay in the study page

Random keeps the arrows. Changing word runs a horizontal slide of the top card; up to two following words peek behind it, offset and not tappable. One word does not slide.

Flashcard drops the arrows. A tap runs a Y-axis half turn, swaps the face at the midpoint, and completes the turn so the text is upright. The term face is term, IPA, and image. The meaning face is definition, sentence, and note. Empty values are omitted. A second tap turns back. Hard, Familiar, and Easy reset to the term face and, except on the last word, advance one step in the current order.

Quiz and Typing keep today's instant arrow change and do not flip. Those arrows still record nothing by themselves. The three rating buttons call the same write in every mode. Only Flashcard advances.

When `MediaQuery.disableAnimations` is set, the face and the word change without a turn or a slide.

The write goes through a store the page receives, the same way the editor receives `VocabularySetStore`. The page does not construct a Firestore client. A null store, or a set id that is null, updates the on-screen selection only.

## Risks / Trade-offs

- [Word index is the identity] → Safe while `sets` cannot be updated. An edit flow later has to add word ids before it rewrites `words`.
- [Rounded percents can miss 100] → Each level is rounded on its own. The spec asks for the nearest whole number, not a partition that sums to 100.
- [Agenda can name a missing set] → The row is skipped. The stored list is not rewritten.
- [Rules deployed after the client] → Writes fail closed. Ship the rules with the client that writes.
- [Anonymous uid is the learner] → Reinstalling starts a new uid and an empty dashboard. Account linking is a later change.

## Migration Plan

Existing `sets` documents stay as they are. No backfill: a user with no `progress` document still sees 0/0, no today rows, and no Recent cards. Rollback is the previous client, which does not read the new collections. The new rules can remain.
