# Proposal

## Why

A new user on the empty web home sees placeholder suggestion rows (Love / Study / Work) with no real career vocabulary and no way to inspect a set. That undercuts the empty-home purpose: show useful starter material people would actually search for by profession, and let them preview it before they create their own library.

## What Changes

- **BREAKING** for empty-home suggestion content: replace the five Love/Study/Work-style set names, hot-search chips, featured word, and practice rows with **ten profession vocabulary packs** (Healthcare, Software Engineering, Finance & Banking, Hospitality & Tourism, Marketing & Sales, Education & Teaching, Law & Legal, Logistics & Supply Chain, Design & Creative, Customer Support), each with fixed English template words.
- Suggested sets become richer career rows (name + word count) under the existing two-column empty home.
- Activating a suggested set, a hot-search chip tied to a pack, or a suggested-practice row **opens a preview** of that pack’s words on the empty home (featured word + scrollable term list). Preview does **not** add folders, sets, or words to the library.
- Save on the empty home still does not store anything. New vocab, Library, and other chrome keep their current behavior.
- Suggestion template strings stay English in every UI language; only chrome headings (and any new preview labels) are localized.

## Capabilities

### New Capabilities

- (none)

### Modified Capabilities

- `home-screen`: Empty-home suggestion columns list the ten career packs, update chips / featured word / practice rows, and show an in-place preview without writing the library.
- `app-localization`: New preview chrome (if any) exists in Vietnamese, English, and German; existing suggestion headings stay; template pack names and words stay English.

## Impact

- `lib/features/home/suggestions/suggestion_templates.dart` grows from name lists to career packs with word payloads.
- `lib/features/home/widgets/suggestion_columns.dart` gains selection/preview UI state.
- Empty-home assertions in `test/features/home/vocabulary_home_test.dart`, `test/features/home/vocabulary_home_language_test.dart`, and `test/widget_test.dart` update to the new templates and preview behavior.
- Spec deltas under `home-screen` and `app-localization`. No Firestore, library store, or study-session changes.
