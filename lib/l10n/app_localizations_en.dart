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

  @override
  String get statisticsHeading => 'Your vocabulary statistics';

  @override
  String get searchHint => 'Find your vocab...';

  @override
  String get newVocab => 'New vocab';

  @override
  String get navHome => 'Homepage';

  @override
  String get navLibrary => 'Library';

  @override
  String get navNotification => 'Notification';

  @override
  String get vocabularySet => 'Your vocabulary set';

  @override
  String get setOfWords => 'Set of words';

  @override
  String get allLabel => 'All';

  @override
  String get wordsLearned => 'Words learned';

  @override
  String get wordsNotLearned => 'Words not yet learned';

  @override
  String get levelMastered => 'Lv.6 - Mastered';

  @override
  String get levelGood => 'Lv.5 - Good';

  @override
  String get levelFamiliar => 'Lv.4 - Familiar';

  @override
  String get levelLearning => 'Lv.3 - Learning';

  @override
  String get levelHard => 'Lv.2 - Hard';

  @override
  String get levelForgot => 'Lv.1 - Forgot';

  @override
  String get todaysVocabulary => 'Today\'s vocabulary';

  @override
  String get practice => 'Practice';

  @override
  String get recent => 'Recent';

  @override
  String progressComplete(int percent) {
    return 'The process is $percent% complete.';
  }

  @override
  String get continueAction => 'Continue';

  @override
  String get hotSearch => 'Hot search';

  @override
  String get suggestedSets => 'Suggested sets';

  @override
  String get suggestedPractice => 'Suggested practice';

  @override
  String get saveWord => 'Save';

  @override
  String saveCount(int count) {
    return '$count saves';
  }
}
