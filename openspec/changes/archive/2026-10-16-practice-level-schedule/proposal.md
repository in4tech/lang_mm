# Proposal

## Why

Today practice shows every word in the open set and stores only Hard, Familiar, or Easy. A word the learner already knows comes back the same way as a word they have never seen, and the home locks at most eight non-easy words for the whole calendar day. The learner needs a level on each word, a reminder based on that level, and a practice screen that separates a new word from one already on the ladder.

## What Changes

- **BREAKING** Each studied word has its own level from 1 to 6 and a next reminder time. Easy raises the level by 1, up to 6. Familiar keeps the level. Hard drops any level to 1. A new word has no level until the learner marks it studied, which sets level 1.
- Reminder delays, measured from the moment of the rating: level 1 in 1 hour, level 2 in 1 day, level 3 in 3 days, level 4 in 7 days, level 5 in 15 days, level 6 in 30 days. Easy on level 6 stays at 6 and schedules 30 days.
- **BREAKING** Today's vocabulary and a set's Today practice are one queue: every due word first, then at most eight new words. A word just rated or swiped leaves that session. The frozen daily list of at most eight non-easy words is no longer stored.
- The practice screen shows the session position, the set name, a mode menu (Random, Flashcard, Quiz, Typing), and a close control. Still learning counts levels 1 through 5. Know counts level 6. Track progress starts on and hides those counts together with the rating controls.
- In Flashcard, a new word offers two swipes: left keeps it new, right sets level 1. From level 1 up, Hard, Familiar, and Easy are shown. Random, Quiz, and Typing keep their current card behavior and do not change a level.
- Home statistics count words at each real level. Level 3 and level 5 can be above zero. A new word is not level 1. Words learned is the level 6 count.
- Practice chrome for the new controls has Vietnamese, English, and German copy.

Assumptions:

- One month is 30 days. Every rating, including Familiar, starts that delay from the current time.
- A stored `hard` mark is read as level 2, `familiar` as level 4, and `easy` as level 6, each due now. A word with no mark stays new.
- Track progress applies to the open practice visit and starts on. Turning it off leaves stored levels and reminder times unchanged.
- The new chrome replaces the practicing column on the study page. The vocabulary home sidebar stays.
- Home Practice, Continue, and a set's Today practice use the same queue rule. Home Practice and Today's vocabulary span loaded sets. The set button and Continue span that set.
- A set with no Firestore id, or no signed-in user, keeps the level on screen for the session and writes nothing.
- The on-device vocabulary library still does not store levels or a today list.

## Capabilities

### New Capabilities

### Modified Capabilities

- `study-session`: Practice shows the session chrome, the mode menu, and Track progress. Flashcard rates a new word with two swipes and a leveled word with Hard, Familiar, and Easy.
- `study-progress`: A word stores a level and a reminder time. The practice queue is derived from due words and new words. The stored calendar day list is removed.
- `home-screen`: Statistics use the six real levels, and Today's vocabulary plus Practice and Continue follow the due queue.
- `app-localization`: The new practice labels exist in Vietnamese, English, and German.

## Impact

- `lib/features/home/widgets/set_study_page.dart` replaces the practicing header, chips, and always-on rating row with the new chrome, and builds the set queue from levels.
- `lib/library/study_progress.dart`, `lib/features/home/home_from_library.dart`, `vocabulary_home.dart`, `statistics_panel.dart`, and `today_panel.dart` read levels and reminder times. `chooseDayList` and the `agenda` write stop being the source of Today's vocabulary.
- `firestore.rules` for `progress` must allow a level and a reminder time. The `marks` value check and the `agenda` day-list rules no longer describe the stored study.
- `lib/l10n/app_en.arb`, `app_vi.arb`, and `app_de.arb` gain the practice labels.
- Tests in `test/library/study_progress_test.dart` and `test/features/home/vocabulary_home_test.dart` cover the queue, the level steps, and the home counts.
