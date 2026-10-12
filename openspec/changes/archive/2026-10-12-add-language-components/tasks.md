# Tasks

## 1. Localization catalogs

- [x] 1.1 Add `flutter_localizations` (SDK), `intl`, and `shared_preferences` to `pubspec.yaml`, set `flutter: generate: true`, and add `l10n.yaml` with `arb-dir: lib/l10n`, `template-arb-file: app_en.arb`, `output-localization-file: app_localizations.dart`, `output-dir: lib/l10n`, and `nullable-getter: false`. Verify `flutter pub get` exits 0.
- [x] 1.2 Add `app_en.arb`, `app_vi.arb`, and `app_de.arb` with `homeTitle`, `counterMessage`, and `incrementAction` using the copy in design.md. Add `missingTranslationProbe` to the English catalog only. Run `flutter gen-l10n`, commit the generated files under `lib/l10n/`, and do not hand-edit them. Verify the generated supported locales are `en`, `vi`, and `de`, and a test that loads German localizations returns the English probe string.

## 2. Language model and saved choice

- [x] 2.1 Add `AppLanguage` for `en`, `vi`, and `de`, with storage code, `Locale`, endonym (`English`, `Tiếng Việt`, `Deutsch`), and `fromCode` that returns English for null and for any other code. Verify a unit test for those cases passes.
- [x] 2.2 Add `AppLanguageController` that reads `app_language` before `runApp`, notifies listeners and then saves on select, and starts in English when the read throws. Verify tests using `SharedPreferences.setMockInitialValues` for an empty store, `de`, `vi`, and an unsupported code, plus a throwing read double that still resolves to English.

## 3. Shell and language component

- [x] 3.1 Set `MaterialApp.locale` from the controller to `en`, `vi`, or `de` (never unset), register `AppLocalizations` plus the global Material, Widgets, and Cupertino delegates, and replace the home title, counter message, and increment tooltip with the generated getters. Do not key the home page by locale. Widget tests pump the app with an explicit initial language and mocked preferences. Verify the existing counter test still goes from 0 to 1.
- [x] 3.2 Add an app-bar `PopupMenuButton` that lists the three endonyms, checks only the active language, and selects in place without navigating. Verify a widget test where the platform locale is Vietnamese and preferences are empty: copy is English; the menu shows `Tiếng Việt`, `English`, and `Deutsch` with only English checked; choosing Vietnamese updates the three home strings and the check; the counter keeps its current value; choosing German and then English updates those strings the same way.
- [x] 3.3 Verify a widget test for the next launch: saved `de` opens in German, saved `vi` opens in Vietnamese, an unsupported saved code opens in English, and after the user selects German a new app start reads that saved code and opens in German.

## 4. Integration

- [x] 4.1 Run `flutter analyze` and `flutter test`. Verify both exit 0.
