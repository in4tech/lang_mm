# Proposal

## Why

`lib/home/` currently mixes the dashboard widgets, shared colors and type, and the pictured sample. The sidebar already names later screens, so the next feature would land in that same folder. The layout should be split by screen before those screens exist.

## What Changes

- Keep `main.dart` as startup only: load the saved language, then `runApp`. Move `LangApp` into `lib/app/lang_app.dart`.
- Rename `lib/localization/` to `lib/language/`. `lib/l10n/` stays the generated catalogs.
- Move `HomeColors` and `HomeText` from `lib/home/home_style.dart` into `lib/theme/`.
- Move the vocabulary home under `lib/features/home/`: the screen at the feature root, its panels under `widgets/`, and `HomeSample` under `sample/`.
- Mirror that layout in tests: `test/language/` and `test/features/home/`. Leave catalog tests that only read `lib/l10n/` at the test root.
- **BREAKING** for in-repo imports: `package:lang/localization/...` becomes `package:lang/language/...`, and home types move under `package:lang/features/home/...` and `package:lang/theme/...`. Nothing is published.
- Leave `assets/fonts/` and `assets/images/` in place. Do not add empty folders for Library, Practice, or Notification.
- Visible behavior stays as it is today: the app opens on the vocabulary home, language choice and persistence are unchanged, and the pictured sample stays in place.

## Capabilities

### New Capabilities

None. This is a file layout change.

### Modified Capabilities

None. `app-localization` requirements stay as they are.

## Impact

- `lib/main.dart`, `lib/localization/`, and `lib/home/`, plus every test that imports those paths.
- No ARB edits, no asset moves, and no new dependencies.
