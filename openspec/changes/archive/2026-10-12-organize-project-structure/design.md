# Design

## Context

See proposal.md for why the folders change. Today `LangApp` lives in `lib/main.dart`. Language preference code lives in `lib/localization/` (`AppLanguage`, `AppLanguageController`, `AppLanguageStore`, `AppLanguageScope`, `LanguageSwitcher`). Generated catalogs stay in `lib/l10n/`. The dashboard is `lib/home/`: `vocabulary_home.dart`, five widgets, `home_sample.dart`, and `home_style.dart` (`HomeColors` and `HomeText`). Imports use `package:lang/...`. The app is `publish_to: none`.

## Goals / Non-Goals

**Goals:**

- One folder per screen under `lib/features/`, with the home screen as the pattern.
- A startup file, an app shell, a language-preference folder, and a shared theme folder that do not belong to one screen.
- Tests follow the same split, except catalog-only tests.

**Non-Goals:**

- Renaming classes, widgets, or ARB keys.
- Adding barrel files.
- Creating empty feature folders.
- Changing what the home shows or how language is stored.

## Decisions

### Feature folders, not layers

Put each screen in `lib/features/<screen>/`. The home screen keeps `vocabulary_home.dart` at the feature root, panels in `widgets/`, and `HomeSample` in `sample/`.

A `presentation/` / `domain/` / `data/` split was considered. The home still renders a fixed sample and has no repository, so that split would add empty layers.

### `language/` next to `l10n/`

Rename `lib/localization/` to `lib/language/`. `lib/l10n/` remains the generated catalogs (`l10n.yaml` `arb-dir` stays `lib/l10n`). Class names stay. Only the import prefix changes, from `package:lang/localization/` to `package:lang/language/`.

Keeping the name `localization` was considered. It sits beside `l10n` and the two are easy to mix up: one is the user's choice, the other is generated strings.

### Theme files keep the current type names

Split `lib/home/home_style.dart` into `lib/theme/home_colors.dart` (`HomeColors`) and `lib/theme/home_text.dart` (`HomeText`). `HomeText` imports `HomeColors`. Call sites change the import and keep `HomeColors` and `HomeText`.

Leaving both types in one `lib/theme/home_style.dart` was considered. Two files match the split already described, and `HomeText` is the only type that needs the color file.

### `LangApp` moves; `main` stays the entry

`lib/app/lang_app.dart` owns `LangApp`. `lib/main.dart` keeps `main`, loads the controller, and calls `runApp`. Tests that pump `LangApp` import `package:lang/app/lang_app.dart`.

### No barrels

Each file is imported by its path, which is what the code does now. A `features/home/home.dart` export was considered and skipped so a move does not add a second public surface.

### Tests

| Current | Destination |
| --- | --- |
| `test/app_language_test.dart` | `test/language/app_language_test.dart` |
| `test/app_language_controller_test.dart` | `test/language/app_language_controller_test.dart` |
| `test/language_persistence_test.dart` | `test/language/language_persistence_test.dart` |
| `test/language_switcher_test.dart` | `test/language/language_switcher_test.dart` |
| `test/vocabulary_home_test.dart` | `test/features/home/vocabulary_home_test.dart` |
| `test/vocabulary_home_language_test.dart` | `test/features/home/vocabulary_home_language_test.dart` |
| `test/home_sample_test.dart` | `test/features/home/home_sample_test.dart` |
| `test/widget_test.dart` | stays |
| `test/home_chrome_l10n_test.dart` | stays |
| `test/l10n_fallback_test.dart` | stays |

`widget_test.dart` stays at the test root because it is the app-entry smoke, not a home unit. The two catalog tests stay because they only read `AppLocalizations`. Assertions stay as they are; only imports and paths change.

### Target tree

```text
lib/
  main.dart
  app/lang_app.dart
  l10n/
  language/
    app_language.dart
    app_language_controller.dart
    app_language_store.dart
    app_language_scope.dart
    language_switcher.dart
  theme/
    home_colors.dart
    home_text.dart
  features/home/
    vocabulary_home.dart
    sample/home_sample.dart
    widgets/
      home_header.dart
      home_sidebar.dart
      statistics_panel.dart
      today_panel.dart
      recent_panel.dart
```

## Risks / Trade-offs

- [A missed `package:lang/home/` or `package:lang/localization/` import] → `flutter analyze` and `flutter test` after the moves. Delete `lib/home/` and `lib/localization/` once empty.
- [Splitting `home_style.dart` drops a symbol] → `HomeColors` and `HomeText` are the only public types in that file. `vocabulary_home_test.dart` is the only test that names `HomeColors`.
- [Deeper paths for a small app] → The extra folders are the ones the next screen will copy. No empty feature folders.

## Migration Plan

1. Move the language files, then the home files, then extract `LangApp`.
2. Update every `package:lang/` import to the new path.
3. Move the tests in the table and update their imports.
4. Run `flutter analyze` and `flutter test`.
5. Rollback is reverting the move commit. No data or asset migration.

## Open Questions

None.
