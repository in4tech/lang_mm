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
  String get newTerm => 'New term';

  @override
  String get newFolder => 'New folder';

  @override
  String get newFolderHint => 'Enter folder name';

  @override
  String get createFolder => 'Create';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get navHome => 'Home';

  @override
  String get navLibrary => 'Library';

  @override
  String get libraryTitle => 'Your library';

  @override
  String get librarySets => 'Flashcard sets';

  @override
  String get libraryFolders => 'Folders';

  @override
  String get librarySearchHint => 'Search';

  @override
  String libraryTermCount(int count) {
    return '$count terms';
  }

  @override
  String librarySetCount(int count) {
    return '$count sets';
  }

  @override
  String get libraryEmpty => 'Nothing here yet';

  @override
  String get libraryFolderEmpty => 'Add a set and it will show up here.';

  @override
  String get addFlashcardSets => 'Add flashcard sets';

  @override
  String get addStudyMaterials => 'Add study materials';

  @override
  String get addMaterialsRecents => 'Recents';

  @override
  String get createNew => 'Create new';

  @override
  String get navNotification => 'Notification';

  @override
  String get vocabularySet => 'Your vocabulary set';

  @override
  String get setOfWords => 'Set of words';

  @override
  String get allLabel => 'All';

  @override
  String get allVocabulary => 'All vocabulary';

  @override
  String get wordsLearned => 'Words learned';

  @override
  String get wordsNotLearned => 'Words not yet learned';

  @override
  String get wordSearch => 'Search vocabulary';

  @override
  String get loadMore => 'Load more';

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
  String get librarySortCreated => 'Created';

  @override
  String get librarySortStudied => 'Studied';

  @override
  String get librarySearchFolder => 'Search this folder';

  @override
  String get libraryStudy => 'Study';

  @override
  String get libraryAddSets => 'Add sets';

  @override
  String get folderAddTag => 'Add tag';

  @override
  String get setAddOrRemoveTags => 'Add or remove tags';

  @override
  String get setRemoveFromFolder => 'Remove from folder';

  @override
  String get moreOption => 'More option';

  @override
  String get folderEdit => 'Edit';

  @override
  String get folderShare => 'Share';

  @override
  String get folderUnpin => 'Unpin from sidebar';

  @override
  String get folderPin => 'Pin to sidebar';

  @override
  String get folderSave => 'Save';

  @override
  String get folderDelete => 'Delete';

  @override
  String get folderDeleteTitle => 'Delete this folder?';

  @override
  String get folderDeleteBody =>
      'The folder will be permanently deleted, but you\'ll be able to find the items from it in your library.';

  @override
  String get folderDeleteConfirm => 'Delete folder';

  @override
  String get studyTodayPractice => 'Today practice';

  @override
  String get studyPracticeAlert =>
      'You are in a practice session. Do you want to leave?';

  @override
  String get studyPracticeStay => 'Stay';

  @override
  String get studyPracticeLeave => 'Leave';

  @override
  String get studyPracticeOk => 'OK';

  @override
  String get studyLearnNew => 'Learn new vocab';

  @override
  String get studyRandom => 'Random';

  @override
  String get studyFlashcard => 'Flashcard';

  @override
  String get studyQuiz => 'Quiz';

  @override
  String get quizChooseAnswer => 'Choose an answer';

  @override
  String get quizDontKnow => 'Don\'t know?';

  @override
  String get quizWrongResult => 'No sweat, you\'re still learning!';

  @override
  String get quizTryLater => 'Give this one a try later!';

  @override
  String get quizPraiseNice => 'Nice!';

  @override
  String get quizPraiseGreat => 'Great job!';

  @override
  String get quizPraiseAwesome => 'Awesome!';

  @override
  String get quizPraiseGotIt => 'You got it!';

  @override
  String get quizPraiseBrilliant => 'Brilliant!';

  @override
  String get studyTyping => 'Typing';

  @override
  String get typingYourAnswer => 'Your answer';

  @override
  String get typingHint => 'Type the term';

  @override
  String get typingCheck => 'Next';

  @override
  String get studyHard => 'Hard';

  @override
  String get studyFamiliar => 'Familiar';

  @override
  String get studyEasy => 'Easy';

  @override
  String get studyShortcut => 'Shortcut';

  @override
  String get studyTapForMeaning => 'Tap the card to see the meaning';

  @override
  String get studyTrackProgress => 'Track progress';

  @override
  String get studyNotYetStudied => 'Not yet studied';

  @override
  String get studyStudiedAction => 'Studied';

  @override
  String get studyFlipShortcut => 'Press Space or click the card to flip';

  @override
  String get studyKnow => 'Know';

  @override
  String get studyList => 'Vocabulary list';

  @override
  String get studyStillLearning => 'Still learning';

  @override
  String get studyMastered => 'Mastered';

  @override
  String get studyCompleteTitle => 'Congratulations!';

  @override
  String get studyCompleteHeadline =>
      'Wow, you know your stuff! You\'ve sorted all the cards.';

  @override
  String get studyCompleteOne => 'You finished 1 word.';

  @override
  String studyCompleteMany(int count) {
    return 'You finished $count words.';
  }

  @override
  String get studyCompleteDone => 'Done';

  @override
  String get studyCompleteContinue => 'Continue';

  @override
  String get studyHowYoureDoing => 'How you\'re doing';

  @override
  String get studyNextSteps => 'Next steps';

  @override
  String get studyTermsLeft => 'Terms left';

  @override
  String get studyPracticeWithQuestions => 'Practice with questions';

  @override
  String get studyRestartFlashcards => 'Restart Flashcards';

  @override
  String studyLevelMove(int from, int to) {
    return 'Lv.$from → Lv.$to';
  }

  @override
  String studyLevelMoveFromNew(int to) {
    return 'New → Lv.$to';
  }

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

  @override
  String get editorDone => 'Done';

  @override
  String get editorBack => 'All posts';

  @override
  String get editorTitle => 'Title';

  @override
  String get editorTitleHint => 'Enter a title...';

  @override
  String get editorDescriptionHint => 'Add a description...';

  @override
  String get editorImport => 'Import';

  @override
  String get editorTerm => 'Term';

  @override
  String get editorTermHint => 'Enter term';

  @override
  String get editorDefinition => 'Definition';

  @override
  String get editorDefinitionHint => 'Enter definition';

  @override
  String get editorSentence => 'Sentence';

  @override
  String get editorSentenceHint => 'Enter sentence';

  @override
  String get editorDetails => 'Details';

  @override
  String get editorIpa => 'IPA';

  @override
  String get editorIpaHint => 'Enter IPA';

  @override
  String get editorSingularPlural => 'Singular - Plural';

  @override
  String get editorSingularPluralHint => 'Enter singular and plural';

  @override
  String get editorNote => 'Note';

  @override
  String get editorNoteHint => 'Enter a note';

  @override
  String get editorType => 'Type';

  @override
  String get editorChunking => 'Chunking';

  @override
  String get editorNoun => 'Noun';

  @override
  String get editorVerb => 'Verb';

  @override
  String get editorAdj => 'Adj';

  @override
  String get editorImageLinkHint => 'Enter image link';

  @override
  String get editorAddWord => 'Add new word';

  @override
  String get editorAddType => 'Add type';

  @override
  String get editorTypeNameHint => 'Enter type';

  @override
  String get termRequired => 'Enter a term';

  @override
  String get definitionRequired => 'Enter a definition';

  @override
  String get titleRequired => 'Enter a title';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get menuAchievements => 'Achievements';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuLightMode => 'Light mode';

  @override
  String get menuDarkMode => 'Dark mode';

  @override
  String get menuLogOut => 'Log out';

  @override
  String get menuPrivacy => 'Privacy policy';

  @override
  String get menuHelp => 'Help and feedback';

  @override
  String get menuUpgrade => 'Upgrade';
}
