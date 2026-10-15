# Proposal

## Why

A rating on the study page disappears when the page closes, and the home still paints statistics, Today's vocabulary, and Recent as empty once a folder exists. The user cannot see which words they marked, continue a set, or practice a stable list for the day.

## What Changes

- Random shows one face with the word's term, IPA, singular and plural, sentence, definition, note, and image, with the next cards peeking behind. The arrows slide to the previous or next word. A tap does not flip the card.
- Flashcard hides the answer. A tap flips between the term face (term, IPA, image) and the meaning face (definition, sentence, note). A second tap returns to the term face of the same word. Khó, Quen, and Dễ record that word's mark and move to the next word, which opens on the term face. Flashcard does not use the arrows to change words.
- Quiz and Typing keep the flat card they have now.
- The latest mark for each studied word is stored in Cloud Firestore project `langmm-ca0d0`, apart from the set document. A later rating of the same word overwrites that mark. The device library still does not store learned counts or a today list.
- Home statistics and Recent are calculated from those marks and the loaded sets. They are not stored again.
- Today's vocabulary is a practice list fixed for the local calendar day, at most eight words that are not yet easy. Practice opens that list as a flashcard session.

Assumptions:

- On the last Flashcard word, Khó, Quen, or Dễ still records the mark and leaves that word on its term face.
- The same three buttons record a mark in Random, Quiz, and Typing when the open set has a Firestore id. Only Flashcard also advances.
- A set with no Firestore id, or a signed-in user who is missing, keeps the mark on screen for the session and writes nothing.
- All starts on. All off shows the set whose progress was updated last. A library with folders and no progress still shows 0/0, 0%, an empty today list, and no Recent cards.
- Lv.3 Learning and Lv.5 Good stay at 0%. The study buttons do not record those two levels.
- Practice on an empty today list stays on the vocabulary home.

## Capabilities

### New Capabilities

- `study-session`: Random slides between full word faces. Flashcard flips a word between its term and its meaning, and Khó, Quen, and Dễ advance to the next word.
- `study-progress`: The latest mark of each studied word, and the day's practice list, are stored in Cloud Firestore for the signed-in user.

### Modified Capabilities

- `home-screen`: When the user has progress or a day list, statistics, Today's vocabulary, and Recent show those values. Practice opens today's list as a flashcard session. An empty library still hides the dashboard.

## Impact

- `lib/features/home/widgets/set_study_page.dart` gains the two card motions and writes a mark when Khó, Quen, or Dễ is pressed.
- `lib/features/home/vocabulary_home.dart`, `statistics_panel.dart`, `today_panel.dart`, `recent_panel.dart`, and `home_from_library.dart` read marks and the day list instead of the empty dashboard.
- The loaded set keeps the Firestore id that `libraryFromCloud` currently drops, so a mark can name its set. `VocabularySet` gains no learned count of its own.
- New Firestore collection documents `progress/{uid}_{setId}` and `agenda/{uid}_{yyyy-mm-dd}`, plus `firestore.rules` entries for them. `sets` stays create-only and is not given a mark field.
- Tests for the study page and the vocabulary home cover the flip, the slide, the stored mark, and the three home regions.
