import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lang/features/home/vocabulary_home.dart';
import 'package:lang/library/vocabulary_library.dart';
import 'package:lang/library/vocabulary_set.dart';
import 'package:lang/l10n/app_localizations.dart';
import 'package:lang/language/app_language_controller.dart';
import 'package:lang/language/app_language_scope.dart';
import 'package:lang/theme/app_theme_controller.dart';
import 'package:lang/theme/app_theme_mode.dart';
import 'package:lang/theme/app_theme_scope.dart';
import 'package:lang/theme/app_theme_store.dart';
import 'package:lang/theme/home_palette.dart';

class LangApp extends StatefulWidget {
  const LangApp({
    super.key,
    required this.controller,
    this.themeController,
    this.library = VocabularyLibrary.empty,
    this.setStore,
  });

  final AppLanguageController controller;
  final AppThemeController? themeController;
  final VocabularyLibrary library;
  final VocabularySetStore? setStore;

  @override
  State<LangApp> createState() => _LangAppState();
}

class _LangAppState extends State<LangApp> {
  late AppThemeController _themeController;
  var _ownsThemeController = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
    _bindTheme(widget.themeController);
  }

  @override
  void didUpdateWidget(LangApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_rebuild);
      widget.controller.addListener(_rebuild);
    }
    if (oldWidget.themeController != widget.themeController) {
      _themeController.removeListener(_rebuild);
      if (_ownsThemeController) {
        _themeController.dispose();
      }
      _bindTheme(widget.themeController);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    _themeController.removeListener(_rebuild);
    if (_ownsThemeController) {
      _themeController.dispose();
    }
    super.dispose();
  }

  void _bindTheme(AppThemeController? controller) {
    _ownsThemeController = controller == null;
    _themeController =
        controller ?? AppThemeController(const UnavailableAppThemeStore());
    _themeController.addListener(_rebuild);
  }

  void _rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final language = widget.controller.language;
    final localizations = lookupAppLocalizations(language.locale);
    final dark = _themeController.mode == AppThemeMode.dark;
    return AppLanguageScope(
      controller: widget.controller,
      child: AppThemeScope(
        controller: _themeController,
        child: MaterialApp(
          title: localizations.statisticsHeading,
          locale: language.locale,
          supportedLocales: const [Locale('en'), Locale('vi'), Locale('de')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: _themeData(HomePalette.light),
          darkTheme: _themeData(HomePalette.dark),
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          home: VocabularyHome(
            library: widget.library,
            setStore: widget.setStore,
          ),
        ),
      ),
    );
  }
}

ThemeData _themeData(HomePalette palette) {
  final dark = palette == HomePalette.dark;
  return ThemeData(
    brightness: dark ? Brightness.dark : Brightness.light,
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: palette.page,
    extensions: [palette],
  );
}
