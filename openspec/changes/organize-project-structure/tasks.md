# Tasks

## 1. Language folder

- [x] 1.1 Move `app_language.dart`, `app_language_controller.dart`, `app_language_store.dart`, `app_language_scope.dart`, and `language_switcher.dart` from `lib/localization/` to `lib/language/`, and point imports inside those files at `package:lang/language/`. Verify `lib/localization/` is gone and the five files are under `lib/language/`.
- [x] 1.2 Update every remaining `package:lang/localization/` import, and move `app_language_test.dart`, `app_language_controller_test.dart`, `language_persistence_test.dart`, and `language_switcher_test.dart` to `test/language/`. Verify `flutter test test/language` passes.

## 2. Home feature and theme

- [x] 2.1 Split `lib/home/home_style.dart` into `lib/theme/home_colors.dart` (`HomeColors`) and `lib/theme/home_text.dart` (`HomeText`), and delete `home_style.dart`. Verify both theme files exist and `HomeText` still uses `HomeColors`.
- [x] 2.2 Move `vocabulary_home.dart` to `lib/features/home/`, `home_sample.dart` to `lib/features/home/sample/`, and `home_header.dart`, `home_sidebar.dart`, `statistics_panel.dart`, `today_panel.dart`, and `recent_panel.dart` to `lib/features/home/widgets/`. Update their imports to `package:lang/features/home/` and `package:lang/theme/`. Verify `lib/home/` is gone.
- [x] 2.3 Move `vocabulary_home_test.dart`, `vocabulary_home_language_test.dart`, and `home_sample_test.dart` to `test/features/home/` and update their imports, including `HomeColors` from `package:lang/theme/home_colors.dart`. Verify `flutter test test/features/home` passes.

## 3. App shell

- [x] 3.1 Move `LangApp` from `lib/main.dart` to `lib/app/lang_app.dart`. Leave `main` loading the language controller and calling `runApp`. Point tests that construct `LangApp` at `package:lang/app/lang_app.dart`. Verify `flutter test test/widget_test.dart test/language` passes.

## 4. Integration

- [x] 4.1 Run `flutter analyze` and `flutter test`. Verify analyze reports no issues, every test passes, `lib/home/` and `lib/localization/` are absent, and no empty feature folder was added.
