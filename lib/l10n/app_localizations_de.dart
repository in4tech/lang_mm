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
  String get newTerm => 'Neuer Begriff';

  @override
  String get newFolder => 'Neuer Ordner';

  @override
  String get newFolderHint => 'Ordnernamen eingeben';

  @override
  String get createFolder => 'Erstellen';

  @override
  String get cancelAction => 'Abbrechen';

  @override
  String get navHome => 'Startseite';

  @override
  String get navLibrary => 'Bibliothek';

  @override
  String get libraryTitle => 'Deine Bibliothek';

  @override
  String get librarySets => 'Sets';

  @override
  String get libraryFolders => 'Ordner';

  @override
  String get librarySearchHint => 'Suchen';

  @override
  String libraryTermCount(int count) {
    return '$count Begriffe';
  }

  @override
  String librarySetCount(int count) {
    return '$count Sets';
  }

  @override
  String get libraryEmpty => 'Noch nichts hier';

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
  String get librarySortCreated => 'Erstellt';

  @override
  String get librarySortStudied => 'Gelernt';

  @override
  String get librarySearchFolder => 'Diesen Ordner durchsuchen';

  @override
  String get libraryStudy => 'Lernen';

  @override
  String get libraryAddSets => 'Sets hinzufügen';

  @override
  String get studyTodayPractice => 'Heute üben';

  @override
  String get studyLearnNew => 'Neue Vokabeln lernen';

  @override
  String get studyRandom => 'Zufällig';

  @override
  String get studyFlashcard => 'Karteikarte';

  @override
  String get studyQuiz => 'Quiz';

  @override
  String get studyTyping => 'Tippen';

  @override
  String get studyHard => 'Schwer';

  @override
  String get studyFamiliar => 'Vertraut';

  @override
  String get studyEasy => 'Leicht';

  @override
  String get studyList => 'Vokabelliste';

  @override
  String get studyStillLearning => 'Noch am Lernen';

  @override
  String get studyMastered => 'Gemeistert';

  @override
  String progressComplete(int percent) {
    return 'Der Fortschritt ist zu $percent% abgeschlossen.';
  }

  @override
  String get continueAction => 'Weiter';

  @override
  String get hotSearch => 'Beliebte Suche';

  @override
  String get suggestedSets => 'Vorgeschlagene Sets';

  @override
  String get suggestedPractice => 'Vorgeschlagenes Üben';

  @override
  String get saveWord => 'Speichern';

  @override
  String saveCount(int count) {
    return '$count Mal gespeichert';
  }

  @override
  String get editorDone => 'Fertig';

  @override
  String get editorBack => 'Alle Beiträge';

  @override
  String get editorTitle => 'Titel';

  @override
  String get editorTitleHint => 'Titel eingeben...';

  @override
  String get editorDescriptionHint => 'Beschreibung hinzufügen...';

  @override
  String get editorImport => 'Importieren';

  @override
  String get editorTerm => 'Begriff';

  @override
  String get editorTermHint => 'Begriff eingeben';

  @override
  String get editorDefinition => 'Definition';

  @override
  String get editorDefinitionHint => 'Definition eingeben';

  @override
  String get editorSentence => 'Satz';

  @override
  String get editorSentenceHint => 'Satz eingeben';

  @override
  String get editorDetails => 'Details';

  @override
  String get editorIpa => 'IPA';

  @override
  String get editorIpaHint => 'IPA eingeben';

  @override
  String get editorSingularPlural => 'Singular - Plural';

  @override
  String get editorSingularPluralHint => 'Singular und Plural eingeben';

  @override
  String get editorNote => 'Notiz';

  @override
  String get editorNoteHint => 'Notiz eingeben';

  @override
  String get editorType => 'Typ';

  @override
  String get editorChunking => 'Chunking';

  @override
  String get editorNoun => 'Nomen';

  @override
  String get editorVerb => 'Verb';

  @override
  String get editorAdj => 'Adjektiv';

  @override
  String get editorImageLinkHint => 'Bildlink eingeben';

  @override
  String get editorAddWord => 'Neues Wort hinzufügen';

  @override
  String get requiredField => 'Pflichtfeld';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get menuAchievements => 'Erfolge';

  @override
  String get menuSettings => 'Einstellungen';

  @override
  String get menuLightMode => 'Heller Modus';

  @override
  String get menuDarkMode => 'Dunkler Modus';

  @override
  String get menuLogOut => 'Abmelden';

  @override
  String get menuPrivacy => 'Datenschutz';

  @override
  String get menuHelp => 'Hilfe und Feedback';

  @override
  String get menuUpgrade => 'Upgrade';
}
