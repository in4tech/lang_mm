// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get homeTitle => 'Flutter Demo Home Page';

  @override
  String get counterMessage => 'You have pushed the button this many times:';

  @override
  String get incrementAction => 'Increment';

  @override
  String get missingTranslationProbe => 'Missing translation probe';
}
