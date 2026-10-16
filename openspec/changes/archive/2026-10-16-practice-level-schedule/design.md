# Design

## Context

See proposal.md for why. `progress/{uid}_{setId}` stores `marks` as `hard`, `familiar`, or `easy` by word index, and `firestore.rules` rejects any other value. `agenda/{uid}_{yyyy-mm-dd}` stores at most eight words for the local date and is not rewritten once it has words. `chooseDayList` builds that list. The study page keeps those marks in a `Map` and, while practicing, shows Random and Flashcard plus Hard, Familiar, and Easy for every word. Quiz and Typing already render a flat card but are not in the mode row. The home sidebar stays outside `SetStudyPage`.

## Goals / Non-Goals

**Goals:**

- Keep one progress document per user and set. A rating updates one word and leaves the others in place.
- Derive the practice queue from levels and reminder times. Do not write it.
- Ship the progress rules in the same change as the client that writes a level.

**Non-Goals:**

- A backfill that rewrites existing progress documents.
- Persisting Track progress, an undo control, or a hint that reveals the meaning.
- Push notifications when a reminder time arrives.
- Changing Learn new, which still opens the editor.
- Word ids. The word index stays the identity while `sets` cannot be updated.

## Decisions

### A word stores a level and a due time

`progress/{uid}_{setId}` gains:

```
ownerId:   uid
setId:     set id
words:     { "0": { "level": 2, "dueAt": timestamp } }
updatedAt: server timestamp
```

`level` is an integer from 1 to 6. `dueAt` is the client instant plus the delay of the level just stored: 1 hour, 1 day, 3 days, 7 days, 15 days, or 30 days. Easy from 1–5 stores `level + 1`. Familiar stores the same level. Hard stores 1. The studied swipe on a word with no level stores 1. Easy on 6 stores 6. The not-yet-studied swipe writes nothing.

The write uses a field path for that index, so one rating does not replace the whole `words` map. `updatedAt` stays a server timestamp and still orders Recent.

Alternative: keep storing `hard`, `familiar`, and `easy`. Rejected because levels 1, 3, and 5 cannot be represented, and a mark has no reminder time. Alternative: one document per word. Rejected because a set still fits in one read.

### Old marks are read, not rewritten

When `words` has no entry for an index, `marks` is read once: `hard` is level 2, `familiar` is level 4, `easy` is level 6, and each is due at the read time. No mark and no `words` entry is a new word. The next rating of that word writes `words` and leaves the old `marks` field as it is.

### The queue is a pure function

Given the loaded sets, their levels, and the clock:

1. Words with `dueAt` at or before now, soonest first. The same `dueAt` keeps loaded-set order, then word index.
2. Words with no level, in that same order, stopped at eight.

Home Practice and Today's vocabulary use every loaded set. Today practice and Continue use the open set. The study page copies that list when practice opens. A rating or either swipe drops that word from the rest of the visit, so a left swipe cannot return as a new word in the same visit. The fraction uses the list length from the open, not the number still remaining.

`chooseDayList` and the agenda read and write are no longer called. Existing `agenda` documents stay where they are.

Alternative: refresh the queue after every rating. Rejected because a left swipe would put the same new word back immediately.

### Rules allow the new field and still name the owner

`progress` create and update allow `words` and `updatedAt` for the signed-in owner, with the document id `{uid}_{setId}`. `level` outside 1–6 is refused by the store before the write. Delete stays denied. `sets` gains no field. `agenda` rules stay so old documents remain owner-only; the new client does not write them.

Alternative: delete `agenda` rules in this change. Rejected because a document already stored would then be unreadable leftovers with no client need to touch them.

### Practice chrome stays in the study column

The practicing branch of `SetStudyPage` replaces the back-and-title row, the two mode chips, and the always-visible rating row.

- The mode control shows the active mode. Opening it lists Random, Flashcard, Quiz, Typing, in that order, and closes on a choice. Today practice, home Practice, and Continue start on Flashcard.
- The center shows the 1-based index, the opened count, a bar of that share, and the current word's set name. Close calls the existing leave-practice path.
- Track progress is state on that visit, starting on. On: Still learning is levels 1–5 of the current set, Know is level 6, and Flashcard shows the rating controls. Off: those counts, the three buttons, and the two swipes hide, and nothing is written.
- A new Flashcard word shows the two labels and accepts a horizontal drag. A word at level 1–6 shows Hard, Familiar, and Easy. Space flips the same way a tap does.
- Random, Quiz, and Typing keep their current cards and arrows. They do not show the rating controls.

The set summary beside the page counts levels 1–6 the same way as the home legend. Its learned count is level 6. New words stay in the word total and out of every level.

A null store, or a null set id, updates the on-screen level only.

## Risks / Trade-offs

- [Client clock sets `dueAt`] → The same clock already chose the local study date. Tests inject the clock.
- [Old `marks` and new `words` can both exist] → Read `words` first. Do not delete `marks` until a later cleanup.
- [Rules deployed after the client] → Writes fail closed. Ship the rules with the client.
- [A long due list has no cap] → Due words are owed. Only new words stop at eight.
- [Level percents need not sum to 100] → Each level is rounded on its own, and new words sit in the denominator only.
- [Word index is the identity] → Safe while `sets` cannot be updated.

## Migration Plan

No backfill. A user with only `marks` sees those words as levels 2, 4, or 6 and due now. A user with no progress still sees 0/0, no Recent cards, and Today's vocabulary filled only from new words, up to eight. Rollback is the previous client: it ignores `words` and still reads `marks`. Leave the new rules in place only after that client is gone, because the previous client writes `marks`.
