import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lang/features/home/vocabulary_home.dart';
import 'package:lang/l10n/app_localizations.dart';
import 'package:lang/language/app_language_controller.dart';
import 'package:lang/language/app_language_scope.dart';

class LangApp extends StatefulWidget {
  const LangApp({super.key, required this.controller});

  final AppLanguageController controller;

  @override
  State<LangApp> createState() => _LangAppState();
}

class _LangAppState extends State<LangApp> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onLanguageChanged);
  }

  @override
  void didUpdateWidget(LangApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onLanguageChanged);
      widget.controller.addListener(_onLanguageChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final language = widget.controller.language;
    final localizations = lookupAppLocalizations(language.locale);
    return AppLanguageScope(
      controller: widget.controller,
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
        theme: ThemeData(
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const VocabularyHome(),
      ),
    );
  }
}
