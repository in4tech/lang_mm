# Design

## Context

See proposal.md for why this change exists. The app is the Flutter counter template: one `lib/main.dart`, English strings inlined in the widget tree, and `test/widget_test.dart` pumping `MyApp` and asserting the counter moves from 0 to 1. There is no localization package, no generated strings, and no saved preference. SDK constraint is `^3.13.5`.

The spec requires an explicit locale. Leaving `MaterialApp.locale` unset would let Flutter follow the device, which violates "English on first launch."

## Goals / Non-Goals

**Goals:**

- One app-owned locale, set before the first frame, that drives both our copy and Flutter's Material/Cupertino strings.
- A language component whose labels do not themselves get translated.
- A string lookup that uses the English catalog when another language omits a key.
- Home-page `State` (the counter) stays mounted across a language change.

**Non-Goals:**

- Matching the device language on first launch.
- A design system beyond the language switcher and localized home-screen copy.
- Remote translation delivery, plural/gender rules beyond what these three strings need, or right-to-left layout.

## Decisions

### 1. Flutter gen-l10n, with English as the template

Use `flutter_localizations` (SDK), the `intl` package, and `flutter: generate: true`. Catalogs live in `lib/l10n/`:

- `l10n.yaml` with `template-arb-file: app_en.arb`, `output-dir: lib/l10n`, `nullable-getter: false`
- `app_en.arb`, `app_vi.arb`, `app_de.arb`

`gen-l10n` emits one getter per key. The English string is the `Intl.message` default, so a key absent from German or Vietnamese resolves to English at runtime. That is the missing-translation behavior; do not add a second fallback layer.

Commit the generated Dart. Do not hand-edit it. `lib/l10n/` is not gitignored.

Alternatives: `easy_localization` or hand-written maps add a dependency and a fallback path we would have to maintain. The app has no i18n stack yet, so the SDK generator is the smaller surface.

### 2. The app sets `locale`; it does not resolve from the device

`MaterialApp.locale` is always one of `Locale('en')`, `Locale('vi')`, or `Locale('de')`. Supported locales are those three, in that order, with English first. Delegates are `AppLocalizations.delegate` plus `GlobalMaterialLocalizations`, `GlobalWidgetsLocalizations`, and `GlobalCupertinoLocalizations`.

`AppLanguage` is a closed set:

| Value | Storage code | Locale | Label in the switcher |
| --- | --- | --- | --- |
| english | `en` | `en` | English |
| vietnamese | `vi` | `vi` | Tiếng Việt |
| german | `de` | `de` | Deutsch |

`AppLanguage.fromCode` returns `english` for null and for any other string. The switcher labels are constants on this type, not ARB entries, so they stay endonyms while the rest of the UI changes.

Alternative: `localeResolutionCallback` that prefers the device when it is `vi`, `en`, or `de`. Rejected because the spec says a Vietnamese or German device still starts in English.

### 3. Persist a language code with shared_preferences

Store the code under the key `app_language`. Read it in `main` before `runApp`, and pass the resolved `AppLanguage` in. An empty store and an unrecognized code both become English, so the first frame is already the right language (no English flash before German loads).

On selection, update listeners first, then write the code. A failed write leaves the in-memory language in place for this session; the next launch uses the last successful write, or English if none exists.

Alternative: an in-memory choice only. Rejected because the spec requires the choice to survive a restart. A database is unnecessary for one string.

### 4. Language state sits above the home page

A `ChangeNotifier` (`AppLanguageController`) owns the current language and the store. `LangApp` listens and rebuilds `MaterialApp` with the new `locale`. `home` is the existing counter page with no `Key` tied to the locale, so `_MyHomePageState` is updated in place and the counter value remains.

The language component is a `PopupMenuButton` in the home `AppBar`. Choosing an item calls `select` and does not navigate. The selected item shows a check. A segmented control was considered; "Tiếng Việt" plus two other labels is tight on a narrow phone, and a menu stays on the same screen.

### 5. Home-screen messages

Replace the hard-coded home strings with these keys. English keeps the template wording so the screen stays recognizable. Widget tests that only look for `0`, `1`, and `Icons.add` keep working.

| Key | English | Vietnamese | German |
| --- | --- | --- | --- |
| `homeTitle` | Flutter Demo Home Page | Trang chủ bản demo Flutter | Flutter-Demo-Startseite |
| `counterMessage` | You have pushed the button this many times: | Bạn đã nhấn nút này bấy nhiêu lần: | Sie haben die Schaltfläche so oft gedrückt: |
| `incrementAction` | Increment | Tăng | Erhöhen |

`MaterialApp.title` uses `homeTitle` as well, so the task switcher matches the app bar.

### 6. Tests inject the store

Widget tests use `SharedPreferences.setMockInitialValues` (empty, a known code, or a junk code) and, for the device-locale cases, override the test platform locale to `vi` or `de`. That proves the app ignores the device until the user chooses. No extra store interface unless mocking shared_preferences turns out to be awkward in this SDK; if it does, swap in a tiny in-memory store behind the same controller without changing the spec.

## Risks / Trade-offs

- [Preference read throws before `runApp`] → Catch it, start in English, and still run the app. A storage failure must not block launch.
- [Write fails after the user switches] → UI stays on the new language for this session; the next launch may return to the previous saved language. Acceptable for one local key; do not add an error dialog in this change.
- [Rebuilding `MaterialApp` resets the counter] → Do not key the home page by locale, and cover "counter survives a language change" in a widget test.
- [Generated l10n drifts from the ARB files] → Regenerate via `flutter gen-l10n` / `flutter pub get` as part of the implementation tasks, and do not edit the generated files.
- [Vietnamese or German Material strings are incomplete upstream] → We still set the locale. Gaps inside Flutter's own catalogs are out of scope; our catalogs still fall back to English.

## Migration Plan

There is no existing locale preference and no shipped data. Adding `app_language` is append-only. Rollback is reverting the change; an orphaned preference key is ignored by the previous build. No staged rollout.
