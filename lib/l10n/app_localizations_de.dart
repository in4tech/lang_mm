// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get homeTitle => 'Flutter-Demo-Startseite';

  @override
  String get counterMessage => 'Sie haben die Schaltfläche so oft gedrückt:';

  @override
  String get incrementAction => 'Erhöhen';

  @override
  String get missingTranslationProbe => 'Missing translation probe';
}
