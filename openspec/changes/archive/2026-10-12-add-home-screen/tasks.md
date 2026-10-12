# Tasks

## 1. Assets and chrome catalogs

- [x] 1.1 Bundle Poppins 300, 400, 500, and 600 under `assets/fonts/`, register the family in `pubspec.yaml`, and add the provided lang mark at `assets/images/lang_logo.png`. Verify `flutter pub get` exits 0 and both asset paths are declared.
- [x] 1.2 Add the chrome keys from design.md to `lib/l10n/app_en.arb`, `app_vi.arb`, and `app_de.arb`, including `statisticsHeading` and the `percent` placeholder on `progressComplete`. Keep `homeTitle`, `counterMessage`, `incrementAction`, and the English-only `missingTranslationProbe`. Run `flutter gen-l10n` and commit the generated files without hand-editing them. Verify a test that loads each locale reads the design.md `statisticsHeading` and `practice` strings, the German catalog still returns the English probe and "Flutter-Demo-Startseite" for `homeTitle`, and `flutter test test/l10n_fallback_test.dart test/widget_test.dart` exits 0.

## 2. Sample content

- [x] 2.1 Add a const home sample under `lib/home/` with German A1 statistics (5/20, 25%, bar labels 3 and 2, legend percents 0/0/0/0/25/75), four identical today's rows (`das Auto fahren` / `das, -s` and `die Frage verstehen` / `die, -n`), recent cards for German A1 at 25%, A2 at 50%, German B1 at 93%, and German B2 at 93%, Homepage selected, My vocab expanded with German A1 and A2, and My vocab 2 collapsed. Verify a unit test for those values passes.

## 3. Home screen

- [x] 3.1 Keep the counter page. Show the 1440-wide vocabulary home from design.md only when `kIsWeb` is true or the `LangApp` vocabulary-home flag is set: scrolling frame, header (menu, logo, read-only "Find your vocab...", New vocab, avatar), sidebar, statistics with the All control drawn on, today's vocabulary, and clipped Recent row. Use the sample for content and the generated chrome getters for labels. On that home, set `MaterialApp.title` and the statistics heading from `statisticsHeading` and apply Poppins. On the counter, keep `homeTitle` and the app-bar `Icons.language` menu. Empty handlers for search, New vocab, Practice, Continue, Library, Notification, All, the menu control, and the Recent chevron. On the vocabulary home, point `LanguageSwitcher` at the avatar circle and keep the same menu items. Verify a widget test that sets the flag shows the English header, selected Homepage, expanded My vocab, 5/20 and 25%, four today's rows, the three progress sentences, a partly visible fourth card, and no counter or `Icons.add`, and that tapping Practice leaves 5/20 in place. Verify `test/widget_test.dart` still moves the counter from 0 to 1 when the flag is omitted.
- [x] 3.2 Add vocabulary-home coverage beside the existing counter language tests. Leave `test/language_switcher_test.dart`, `test/language_persistence_test.dart`, and `test/l10n_fallback_test.dart` on the counter. Verify a test that sets the vocabulary-home flag: a Vietnamese or German device still starts in English; choosing Vietnamese, German, and English updates `statisticsHeading` and Practice in place, keeps 5/20 and the expanded My vocab row, and checks only the active endonym. Verify the counter language tests still pass unchanged, including saved `de` and `vi`, an unsupported code opening in English, and the English missing-translation probe.

## 4. Integration

- [x] 4.1 Run `flutter analyze` and `flutter test`. Verify both exit 0.
