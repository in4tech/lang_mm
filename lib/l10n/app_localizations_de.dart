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

  @override
  String get statisticsHeading => 'Deine Vokabelstatistik';

  @override
  String get searchHint => 'Vokabeln suchen...';

  @override
  String get newVocab => 'Neue Vokabel';

  @override
  String get navHome => 'Startseite';

  @override
  String get navLibrary => 'Bibliothek';

  @override
  String get navNotification => 'Benachrichtigung';

  @override
  String get vocabularySet => 'Dein Vokabelset';

  @override
  String get setOfWords => 'Wortset';

  @override
  String get allLabel => 'Alle';

  @override
  String get wordsLearned => 'Gelernte Wörter';

  @override
  String get wordsNotLearned => 'Noch nicht gelernte Wörter';

  @override
  String get levelMastered => 'Lv.6 - Gemeistert';

  @override
  String get levelGood => 'Lv.5 - Gut';

  @override
  String get levelFamiliar => 'Lv.4 - Vertraut';

  @override
  String get levelLearning => 'Lv.3 - Lernen';

  @override
  String get levelHard => 'Lv.2 - Schwer';

  @override
  String get levelForgot => 'Lv.1 - Vergessen';

  @override
  String get todaysVocabulary => 'Vokabeln von heute';

  @override
  String get practice => 'Üben';

  @override
  String get recent => 'Zuletzt';

  @override
  String progressComplete(int percent) {
    return 'Der Fortschritt ist zu $percent% abgeschlossen.';
  }

  @override
  String get continueAction => 'Weiter';
}
