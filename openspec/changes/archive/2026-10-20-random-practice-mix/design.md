# Design

## Context

See proposal.md for why. Practice modes live in `set_study_page.dart` as `_PracticeMode { random, flashcard, quiz, typing }`. Random today renders the full word via `_cardLines`, shows prev/next, peeks the next card, and blocks `_rate` / `_skipNew`. Quiz and Typing already share result/rating plumbing; Flashcard has flip, swipes, and exit motion.

## Goals / Non-Goals

**Goals:**

- Under Random, reuse the existing Flashcard / Quiz / Typing UI and advance/rating paths by selecting an exercise type per current word.
- Keep the mode chip labeled Random while mixing.
- Make draws testable with an injectable RNG.

**Non-Goals:**

- Changing pure Flashcard, Quiz, or Typing behavior when those modes are selected from the menu.
- Reintroducing a browse-all-fields mode under another name.
- Weighted draws, “no repeat until all three seen,” or session-wide fixed type.
- Career empty-home work (`career-suggestion-previews`).

## Decisions

### Session mode vs exercise type

Keep `_mode == random` as the menu selection. Add `_exercise` (or equivalent) of `{ flashcard, quiz, typing }` that is only meaningful when `_mode == random`. When `_mode` is a fixed mode, render from `_mode` directly. When `_mode == random`, render and gate ratings from `_exercise`.

```text
  _mode (menu)          _exercise (draw)
  ---------------       -----------------
  random          -->   flashcard | quiz | typing
  flashcard       -->   (n/a, use flashcard)
  quiz            -->   (n/a)
  typing          -->   (n/a)
```

Alternative: replace `_mode` with only three modes and drop Random. Rejected — product keeps a Random entry in the four-mode menu.

### When to draw

Call `drawExercise()`:

1. When entering Random from the mode menu (current word).
2. When advancing to the next remaining word while `_mode` stays Random (after rate / skip / studied / exit complete).
3. When restarting a session into Random (if ever offered).

Do **not** redraw on flip, quiz choice, typing check, or while a Flashcard exit animation runs.

Uniform choice among three. Default `Random()` in production; tests pass a queue or seeded function so scenarios can force Quiz then Typing, etc.

### Rendering

Factor the practice body so QuizCard / TypingCard / `_FlashcardStage` branch on `effectiveMode` (`_mode == random ? _exercise : _mode`). Rating rows use the same effective mode. Prev/next arrows only for the old Random path — remove that branch entirely.

Clear quiz/typing result state whenever the exercise type or current word changes under Random (same as `_selectMode` / `_advance` already clear).

### Mode menu

Selecting Flashcard / Quiz / Typing sets `_mode` to that value and clears `_exercise`. Selecting Random sets `_mode` to random and draws immediately. Mode control label stays `studyRandom` while `_mode == random`.

### Spec overview

Main `study-session` Purpose updated to describe mixed Random (done alongside this design).

## Risks / Trade-offs

- [Duplicate logic if Random special-cases ratings] → Always delegate to effective mode helpers; no separate Random rating path.
- [Flaky tests from RNG] → Inject draws; never assert probabilities in widget tests.
- [Learners miss browse-all-fields] → Accepted; out of scope to rename or restore.

## Migration Plan

No persisted mode. In-flight sessions are ephemeral. Rollback restores browse Random.

## Open Questions

None — equal per-word draw and replacement of browse Random are fixed for this change.
