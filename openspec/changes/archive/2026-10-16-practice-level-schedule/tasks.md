# Tasks

## 1. Level and queue

- [x] 1.1 Add the level step and the reminder delay in `lib/library/study_progress.dart`: Easy adds 1 up to 6, Familiar keeps the level, Hard stores 1, a studied new word stores 1, and a skipped new word stores nothing. Delays are 1 hour, 1 day, 3 days, 7 days, 15 days, and 30 days from the rating time. Verify with `test/library/study_progress_test.dart`.
- [x] 1.2 Add the practice queue: due words soonest first, then at most eight new words, scoped to one set or to every loaded set. A word due later is omitted. Verify the Kind-before-Haus, future-word, eight-new-word, and cross-set cases in `test/library/study_progress_test.dart`.
- [x] 1.3 Read a stored `hard` mark as level 2, `familiar` as level 4, and `easy` as level 6, each due at the read time, when that index has no `words` entry. Verify that case in `test/library/study_progress_test.dart`.

## 2. Progress document

- [x] 2.1 Write one word through a `words.{index}` field path on `progress/{uid}_{setId}`, and read `words` before leftover `marks`. Stop creating and reading `agenda` for the queue. Verify a second rating keeps the first word in `test/library/study_progress_test.dart`.
- [x] 2.2 Update `firestore.rules` so the owner can create and update `words` and `updatedAt` on their own progress document. Verify a level outside 1–6 is refused before a write by the store test in `test/library/study_progress_test.dart`.

## 3. Home

- [x] 3.1 Count levels 1 through 6 in `lib/features/home/home_from_library.dart`. The learned fraction is the level 6 count over the word count. A new word stays in that total and out of every level. All off still uses the progress document with the latest `updatedAt`. Verify the 1/4 and the level 1, 3, and 5 cases in `test/features/home/vocabulary_home_test.dart`.
- [x] 3.2 Fill Today's vocabulary from the practice queue, two words on a row, and open Flashcard from Practice on the first queued word. An empty queue leaves Practice on the home. Verify Kind and Haus, and the future-word absence, in `test/features/home/vocabulary_home_test.dart`.
- [x] 3.3 Recent uses the level 6 share and the same bar colors. Continue opens Flashcard on that set's queue, or the study page with no card when the queue is empty. Verify the 50% and 93% cards and Continue on Kind in `test/features/home/vocabulary_home_test.dart`.

## 4. Practice screen

- [x] 4.1 Add Still learning, Know, Track progress, Not yet studied, Studied, and "Press Space or click the card to flip" to `app_en.arb`, `app_vi.arb`, and `app_de.arb`, with the Vietnamese and German copy from the localization delta. Verify the three languages in `test/home_chrome_l10n_test.dart`.
- [x] 4.2 Replace the practicing header in `lib/features/home/widgets/set_study_page.dart` with the mode menu (Random, Flashcard, Quiz, Typing), the session position and bar, the set name, and close. Today practice, home Practice, and Continue start on Flashcard and use the queue from group 1. Verify "2 / 4", the menu, and close in `test/features/home/vocabulary_home_test.dart`.
- [x] 4.3 Track progress starts on. On, show Still learning and Know for the current set, the two swipes for a new word, and Hard, Familiar, and Easy from level 1 up. Off, hide those controls and write nothing. Space flips Flashcard. Random, Quiz, and Typing do not show the rating controls. A rated or swiped word stays out of the rest of the visit. Verify the swipe, Easy advancing to the next term, and Quiz leaving the level unchanged in `test/features/home/vocabulary_home_test.dart`.
