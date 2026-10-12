# Design

## Context

See proposal.md for why this change exists. The specs in this change say what the web home shows. The counter home stays on every other platform.

The app is one `MaterialApp` in `lib/main.dart`. `MyHomePage` is the counter, and `LanguageSwitcher` is a `PopupMenuButton` with `Icons.language` in the app bar. Catalogs already exist at `lib/l10n/app_{en,vi,de}.arb` with `homeTitle`, `counterMessage`, `incrementAction`, and an English-only `missingTranslationProbe`. Generated files under `lib/l10n/` are committed and must not be hand-edited. `l10n.yaml` uses `app_en.arb` as the template and `nullable-getter: false`.

Widget tests pump `LangApp` on the default surface (800 by 600) and look for the counter, `Icons.add`, and the old home titles ("Flutter Demo Home Page", "Trang chủ bản demo Flutter", "Flutter-Demo-Startseite").

## Goals / Non-Goals

**Goals:**

- One fixed sample model drives every region, so the pictured numbers cannot drift between widgets.
- The 1440-wide frame scrolls on a smaller surface instead of overflowing.
- Chrome comes from the existing gen-l10n catalogs. On the vocabulary home, the avatar opens the current language menu.
- The counter home, its strings, and its app-bar language menu stay on every platform other than web.

**Non-Goals:**

- Showing this dashboard on Android, iOS, macOS, or any other non-web target.
- A second layout below 1440.
- A vocabulary store, navigation, or a chart package.
- A custom icon set or a networked font.

## Decisions

### 1. Show the vocabulary home on web, fed by one sample

`LangApp` keeps the counter page. It shows the vocabulary home only when `kIsWeb` is true. A constructor flag, defaulting to `kIsWeb`, lets a VM test opt into the vocabulary home; widget tests that omit it still get the counter, because `kIsWeb` is false there. Put the screen, its regions, and the sample under `lib/home/`. Leave the counter state in `lib/main.dart`.

The sample is a const value, not stored preferences: German A1 statistics (5/20, 25%, bars labeled 3 and 2, legend percents 0/0/0/0/25/75), four identical today's rows (`das Auto fahren` / `das, -s` and `die Frage verstehen` / `die, -n`), and recent cards for German A1 at 25%, A2 at 50%, German B1 at 93%, and a fourth card. The frame clips that fourth card. Its label is not readable, so the sample uses "German B2 vocabulary" at 93% (the same green fill as B1 in the export). Homepage is selected, My vocab is expanded, My vocab 2 is collapsed. There is no selection state to keep: a language rebuild cannot reset it.

Search, New vocab, Practice, Continue, Library, Notification, the All control, the menu control, and the Recent chevron are visible controls with empty handlers. Search does not accept text. The All control is drawn on, knob on the right, and does not toggle.

Alternative: interactive sidebar and a filtering search. Rejected for this slice; the specs require those controls to leave the sample unchanged.

### 2. Paint the desktop frame and scroll it

The body is a column fixed at 1440 wide: an 80px header, then a row with a 288px sidebar and the content column (statistics beside today's vocabulary, then Recent). Colors, radii, and type sizes come from the export (Poppins, white canvas, border `#D0D5DD`, selected nav `#E4ECFA` / `#2E76C9`, New vocab `#022A8C`, Practice `#0051FF`, Continue gradient `#0063CC` to `#0033CC`, level colors from the export). Wrap that frame in vertical and horizontal scroll views so an 800 by 600 test surface does not overflow.

The statistics bars are a row of rounded rectangles in the sample's heights (tall red, shorter orange, then four short bars). No chart dependency.

Icons are Material approximations of the export (menu, home, folder, notifications, search, book, add, expand). The lang mark is the provided logo at `assets/images/lang_logo.png` (139 by 48). No avatar photo was provided; the avatar is a 48px circle filled `#022A8C`.

Alternative: `google_fonts` at runtime. Rejected because the app must render Poppins offline and in tests. Bundle Poppins 300, 400, 500, and 600 under `assets/fonts/` and register the family in `pubspec.yaml`.

### 3. The avatar opens the existing language menu

Keep `LanguageSwitcher` as a `PopupMenuButton<AppLanguage>` with the same items (endonym plus a check on the active language). On the counter page its button stays `Icons.language`. On the vocabulary home its button child is the avatar circle. Choosing a language still calls `AppLanguageController.select` and does not navigate. Do not key either home widget on locale.

On the counter, `MaterialApp.title` stays `homeTitle`. On the vocabulary home, `MaterialApp.title` and the visible statistics heading both use `statisticsHeading`.

### 4. Chrome keys sit beside the counter strings

Keep `homeTitle`, `counterMessage`, `incrementAction`, and the English-only `missingTranslationProbe`. Add the chrome keys below. `progressComplete` takes an int `percent`. `statisticsHeading` is the vocabulary home title. Run `flutter gen-l10n` and commit the generated Dart.

| Key | English | Vietnamese | German |
| --- | --- | --- | --- |
| `statisticsHeading` | Your vocabulary statistics | Thống kê từ vựng của bạn | Deine Vokabelstatistik |
| `searchHint` | Find your vocab... | Tìm từ vựng... | Vokabeln suchen... |
| `newVocab` | New vocab | Từ mới | Neue Vokabel |
| `navHome` | Homepage | Trang chủ | Startseite |
| `navLibrary` | Library | Thư viện | Bibliothek |
| `navNotification` | Notification | Thông báo | Benachrichtigung |
| `vocabularySet` | Your vocabulary set | Bộ từ vựng của bạn | Dein Vokabelset |
| `setOfWords` | Set of words | Bộ từ | Wortset |
| `allLabel` | All | Tất cả | Alle |
| `wordsLearned` | Words learned | Từ đã học | Gelernte Wörter |
| `wordsNotLearned` | Words not yet learned | Từ chưa học | Noch nicht gelernte Wörter |
| `levelMastered` | Lv.6 - Mastered | Lv.6 - Thành thạo | Lv.6 - Gemeistert |
| `levelGood` | Lv.5 - Good | Lv.5 - Tốt | Lv.5 - Gut |
| `levelFamiliar` | Lv.4 - Familiar | Lv.4 - Quen | Lv.4 - Vertraut |
| `levelLearning` | Lv.3 - Learning | Lv.3 - Đang học | Lv.3 - Lernen |
| `levelHard` | Lv.2 - Hard | Lv.2 - Khó | Lv.2 - Schwer |
| `levelForgot` | Lv.1 - Forgot | Lv.1 - Quên | Lv.1 - Vergessen |
| `todaysVocabulary` | Today's vocabulary | Từ vựng hôm nay | Vokabeln von heute |
| `practice` | Practice | Luyện tập | Üben |
| `recent` | Recent | Gần đây | Zuletzt |
| `progressComplete` | The process is {percent}% complete. | Tiến trình đã hoàn thành {percent}%. | Der Fortschritt ist zu {percent}% abgeschlossen. |
| `continueAction` | Continue | Tiếp tục | Weiter |

Set names, vocabulary entries, `5/20`, bar labels, and percents stay literal sample data.

### 5. Keep the counter tests and add vocabulary-home tests

`test/widget_test.dart`, `test/language_switcher_test.dart`, `test/language_persistence_test.dart`, and `test/l10n_fallback_test.dart` stay on the counter. They pump `LangApp` without the vocabulary-home flag, still expect the counter to move from 0 to 1, and still expect `homeTitle` ("Flutter Demo Home Page", "Trang chủ bản demo Flutter", "Flutter-Demo-Startseite"). The fallback test still expects the English probe.

New tests pass the vocabulary-home flag. They expect English chrome and the German A1 sample, no counter and no `Icons.add`, and Practice leaving 5/20 in place. A language test on that home expects the statistics heading and Practice to follow Vietnamese, German, and English, with 5/20 and the expanded My vocab row unchanged. The menu still opens from `PopupMenuButton<AppLanguage>`, which is the avatar on that home.

## Risks / Trade-offs

- [Material icons and a solid avatar differ from the exported vectors and photo] → Match layout, color, and copy first. Swap in assets later without changing the sample or the catalogs.
- [Bar labels 3 and 2 do not equal the 75% and 25% legend] → Paint both as specified. Do not "fix" the sample.
- [Fourth recent card's real name is clipped in the frame] → Use German B2 at 93% until a full label exists.
- [800 by 600 tests never show the whole frame at once] → Assert on text and the avatar menu, not on scroll position or pixel diffs.
- [`kIsWeb` is false in `flutter test`] → The vocabulary-home flag is the only way those tests reach the dashboard. A test that forgets the flag still covers the counter, so a missing flag fails the new home assertions rather than the old ones.
- [Web and the other targets now disagree about the first screen] → The split is explicit and temporary. The counter strings stay in the catalogs so the non-web home does not lose copy.

## Migration Plan

Add the web home beside the counter. No stored user data depends on either screen. Language codes in `shared_preferences` stay valid. Rollback is reverting this change.
