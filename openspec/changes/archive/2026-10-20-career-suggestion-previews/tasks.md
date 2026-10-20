# Tasks

## 1. Career template data

- [x] 1.1 Replace `SuggestionTemplates` in `lib/features/home/suggestions/suggestion_templates.dart` with the ten `SuggestionPack`s from design.md (12 words each, lead terms for chips/practice), including IPA/gloss for every word, and verify a small unit or widget assertion that there are 10 packs, Healthcare is first, and its first term is `diagnosis`.
- [x] 1.2 Expose derived helpers for chips, set titles with word counts, and practice labels from those packs, and verify the chip order matches design.md (diagnosis through ticket).

## 2. Empty-home preview UI

- [x] 2.1 Make `SuggestionColumns` select a pack and featured term (default Healthcare / diagnosis), render set rows with word counts, and show the pack title plus term list on the right, verifying the empty home in `test/features/home/vocabulary_home_test.dart` shows Healthcare, diagnosis, and ten set rows without writing the library.
- [x] 2.2 Wire set-row, chip, practice-row, and preview-term taps to update the preview only, and verify Healthcare → Software Engineering, the `deploy` chip, Practice "diagnosis", and tapping `prescription` update the featured word while Save still leaves the library empty.
- [x] 2.3 Update language and launch tests (`vocabulary_home_language_test.dart`, `widget_test.dart`, related empty-home assertions) for the new English templates and German/Vietnamese chrome, and verify those tests pass.

## Workflow follow-up

- Archive the change after review when implementation is complete.
- Sync or archive specs so main `home-screen` and `app-localization` pick up the deltas.
