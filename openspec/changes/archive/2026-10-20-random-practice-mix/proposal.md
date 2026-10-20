# Proposal

## Why

The mode labeled Random currently browses a full-word card with prev/next and never rates progress. Learners expect Random to mix Flashcard, Quiz, and Typing so practice stays varied while still updating study levels.

## What Changes

- **BREAKING** for Random: remove the full-face browse card and prev/next sliding. Random becomes a session mode that, for each remaining word, runs one of Flashcard, Quiz, or Typing chosen at random with equal weight.
- While Random is selected, the mode control still shows Random. The active exercise for the current word follows that word’s drawn type (flip/rate, multiple choice, or typing) with the same rules those modes already have.
- Drawing a new exercise type happens when Random is entered for the current word and again when practice advances to the next remaining word under Random. Leaving Random for a fixed mode stops mixing.
- Pure Flashcard, Quiz, and Typing modes stay unchanged. Session start (Today practice, Learn new, home Practice, Continue) still opens Flashcard unless the learner picks Random.
- Tests inject a deterministic draw so scenarios can assert a specific exercise type without flaky RNG.

## Capabilities

### New Capabilities

- (none)

### Modified Capabilities

- `study-session`: Redefine Random as a mixed exercise mode; remove browse/slide Random requirements; keep Flashcard/Quiz/Typing behavior when drawn under Random.

## Impact

- `lib/features/home/widgets/set_study_page.dart` owns mode state and must track a per-word exercise draw under Random.
- Spec overview and Random-related requirements in `study-session`.
- Practice tests in `test/features/home/vocabulary_home_test.dart` (and related) that assert Random browse/peek/arrows.
- No library, Firestore, or empty-home suggestion changes (those stay in `career-suggestion-previews`).
