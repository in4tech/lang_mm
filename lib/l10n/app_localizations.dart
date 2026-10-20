import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('vi'),
  ];

  /// Title shown in the counter app bar and the app switcher on non-web platforms.
  ///
  /// In en, this message translates to:
  /// **'Flutter Demo Home Page'**
  String get homeTitle;

  /// Message above the counter on the non-web home screen.
  ///
  /// In en, this message translates to:
  /// **'You have pushed the button this many times:'**
  String get counterMessage;

  /// Tooltip for the button that increments the counter.
  ///
  /// In en, this message translates to:
  /// **'Increment'**
  String get incrementAction;

  /// English-only string used to verify fallback. Not shown in the home screen.
  ///
  /// In en, this message translates to:
  /// **'Missing translation probe'**
  String get missingTranslationProbe;

  /// Title of the vocabulary statistics region and the web app title.
  ///
  /// In en, this message translates to:
  /// **'Your vocabulary statistics'**
  String get statisticsHeading;

  /// Placeholder in the vocabulary home search field.
  ///
  /// In en, this message translates to:
  /// **'Find your vocab...'**
  String get searchHint;

  /// Button that starts a new vocabulary entry.
  ///
  /// In en, this message translates to:
  /// **'New vocab'**
  String get newVocab;

  /// Menu item that opens the word editor.
  ///
  /// In en, this message translates to:
  /// **'New term'**
  String get newTerm;

  /// Menu item that opens the new-folder dialog.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get newFolder;

  /// Placeholder in the new-folder dialog.
  ///
  /// In en, this message translates to:
  /// **'Enter folder name'**
  String get newFolderHint;

  /// Button that creates a folder from the dialog.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createFolder;

  /// Button that closes a dialog without saving.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// Sidebar navigation label for the home screen.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Sidebar navigation label for the library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// Heading of the library page.
  ///
  /// In en, this message translates to:
  /// **'Your library'**
  String get libraryTitle;

  /// Library filter for vocabulary sets.
  ///
  /// In en, this message translates to:
  /// **'Flashcard sets'**
  String get librarySets;

  /// Library filter for folders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get libraryFolders;

  /// Placeholder in the library search field.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get librarySearchHint;

  /// How many terms a library set contains.
  ///
  /// In en, this message translates to:
  /// **'{count} terms'**
  String libraryTermCount(int count);

  /// How many sets a library folder contains.
  ///
  /// In en, this message translates to:
  /// **'{count} sets'**
  String librarySetCount(int count);

  /// Shown when the selected library filter has no rows.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get libraryEmpty;

  /// Hint under the empty folder title.
  ///
  /// In en, this message translates to:
  /// **'Add a set and it will show up here.'**
  String get libraryFolderEmpty;

  /// Button that opens the picker for adding sets to a folder.
  ///
  /// In en, this message translates to:
  /// **'Add flashcard sets'**
  String get addFlashcardSets;

  /// Title of the dialog that adds flashcard sets to a folder.
  ///
  /// In en, this message translates to:
  /// **'Add study materials'**
  String get addStudyMaterials;

  /// Picker tab for the most recently listed flashcard sets.
  ///
  /// In en, this message translates to:
  /// **'Recents'**
  String get addMaterialsRecents;

  /// Action in the add-sets dialog that starts a new flashcard set.
  ///
  /// In en, this message translates to:
  /// **'Create new'**
  String get createNew;

  /// Sidebar navigation label for notifications.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get navNotification;

  /// Sidebar section label above the vocabulary folders.
  ///
  /// In en, this message translates to:
  /// **'Your vocabulary set'**
  String get vocabularySet;

  /// Sidebar action for adding a set of words.
  ///
  /// In en, this message translates to:
  /// **'Set of words'**
  String get setOfWords;

  /// Label for the All switch on the statistics card.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allLabel;

  /// Statistics title shown when the All switch includes every set.
  ///
  /// In en, this message translates to:
  /// **'All vocabulary'**
  String get allVocabulary;

  /// Caption under the learned side of the statistics chart.
  ///
  /// In en, this message translates to:
  /// **'Words learned'**
  String get wordsLearned;

  /// Caption under the not-yet-learned side of the statistics chart.
  ///
  /// In en, this message translates to:
  /// **'Words not yet learned'**
  String get wordsNotLearned;

  /// Search field in the learned and not-yet-learned word list.
  ///
  /// In en, this message translates to:
  /// **'Search vocabulary'**
  String get wordSearch;

  /// Button that shows the next page of words in a word list dialog.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMore;

  /// Legend label for level 6.
  ///
  /// In en, this message translates to:
  /// **'Lv.6 - Mastered'**
  String get levelMastered;

  /// Legend label for level 5.
  ///
  /// In en, this message translates to:
  /// **'Lv.5 - Good'**
  String get levelGood;

  /// Legend label for level 4.
  ///
  /// In en, this message translates to:
  /// **'Lv.4 - Familiar'**
  String get levelFamiliar;

  /// Legend label for level 3.
  ///
  /// In en, this message translates to:
  /// **'Lv.3 - Learning'**
  String get levelLearning;

  /// Legend label for level 2.
  ///
  /// In en, this message translates to:
  /// **'Lv.2 - Hard'**
  String get levelHard;

  /// Legend label for level 1.
  ///
  /// In en, this message translates to:
  /// **'Lv.1 - Forgot'**
  String get levelForgot;

  /// Heading of the today's vocabulary panel.
  ///
  /// In en, this message translates to:
  /// **'Today\'s vocabulary'**
  String get todaysVocabulary;

  /// Action on the today's vocabulary panel.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practice;

  /// Heading above the recent vocabulary sets.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// Library sort that orders items by when they were created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get librarySortCreated;

  /// Library sort that orders items by when they were studied.
  ///
  /// In en, this message translates to:
  /// **'Studied'**
  String get librarySortStudied;

  /// Placeholder for the search field inside a folder.
  ///
  /// In en, this message translates to:
  /// **'Search this folder'**
  String get librarySearchFolder;

  /// Button on a folder page that starts study.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get libraryStudy;

  /// Button on a folder page that adds flashcard sets.
  ///
  /// In en, this message translates to:
  /// **'Add sets'**
  String get libraryAddSets;

  /// Folder menu action that adds a tag.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get folderAddTag;

  /// Flashcard set menu action that adds or removes tags.
  ///
  /// In en, this message translates to:
  /// **'Add or remove tags'**
  String get setAddOrRemoveTags;

  /// Flashcard set menu action that removes the set from its folder.
  ///
  /// In en, this message translates to:
  /// **'Remove from folder'**
  String get setRemoveFromFolder;

  /// Tooltip for a three-dot more menu button.
  ///
  /// In en, this message translates to:
  /// **'More option'**
  String get moreOption;

  /// Folder menu action that edits the folder.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get folderEdit;

  /// Folder menu action that shares the folder.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get folderShare;

  /// Folder menu action that unpins the folder from the sidebar.
  ///
  /// In en, this message translates to:
  /// **'Unpin from sidebar'**
  String get folderUnpin;

  /// Folder menu action that pins the folder to the sidebar.
  ///
  /// In en, this message translates to:
  /// **'Pin to sidebar'**
  String get folderPin;

  /// Button that saves a renamed folder.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get folderSave;

  /// Folder menu action that deletes the folder.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get folderDelete;

  /// Title of the dialog that confirms deleting a folder.
  ///
  /// In en, this message translates to:
  /// **'Delete this folder?'**
  String get folderDeleteTitle;

  /// Explanation in the dialog that confirms deleting a folder.
  ///
  /// In en, this message translates to:
  /// **'The folder will be permanently deleted, but you\'ll be able to find the items from it in your library.'**
  String get folderDeleteBody;

  /// Button that confirms deleting a folder.
  ///
  /// In en, this message translates to:
  /// **'Delete folder'**
  String get folderDeleteConfirm;

  /// Selected practice action on a flashcard set.
  ///
  /// In en, this message translates to:
  /// **'Today practice'**
  String get studyTodayPractice;

  /// Confirmation shown when a sidebar item is clicked during practice.
  ///
  /// In en, this message translates to:
  /// **'You are in a practice session. Do you want to leave?'**
  String get studyPracticeAlert;

  /// Button that keeps the current practice session.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get studyPracticeStay;

  /// Button that leaves the current practice session.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get studyPracticeLeave;

  /// Button that dismisses the practice-session alert.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get studyPracticeOk;

  /// Action that opens the editor for a flashcard set.
  ///
  /// In en, this message translates to:
  /// **'Learn new vocab'**
  String get studyLearnNew;

  /// Practice mode that shuffles the set.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get studyRandom;

  /// Practice mode that shows one card at a time.
  ///
  /// In en, this message translates to:
  /// **'Flashcard'**
  String get studyFlashcard;

  /// Practice mode that shows the definition first.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get studyQuiz;

  /// Prompt above the Quiz options before the learner answers.
  ///
  /// In en, this message translates to:
  /// **'Choose an answer'**
  String get quizChooseAnswer;

  /// Reveals the Quiz answer without choosing an option.
  ///
  /// In en, this message translates to:
  /// **'Don\'t know?'**
  String get quizDontKnow;

  /// Shown when the learner chooses the wrong Quiz option.
  ///
  /// In en, this message translates to:
  /// **'No sweat, you\'re still learning!'**
  String get quizWrongResult;

  /// Shown when the learner chooses Don't know in Quiz.
  ///
  /// In en, this message translates to:
  /// **'Give this one a try later!'**
  String get quizTryLater;

  /// Rotating praise shown after a correct Quiz answer.
  ///
  /// In en, this message translates to:
  /// **'Nice!'**
  String get quizPraiseNice;

  /// Rotating praise shown after a correct Quiz answer.
  ///
  /// In en, this message translates to:
  /// **'Great job!'**
  String get quizPraiseGreat;

  /// Rotating praise shown after a correct Quiz answer.
  ///
  /// In en, this message translates to:
  /// **'Awesome!'**
  String get quizPraiseAwesome;

  /// Rotating praise shown after a correct Quiz answer.
  ///
  /// In en, this message translates to:
  /// **'You got it!'**
  String get quizPraiseGotIt;

  /// Rotating praise shown after a correct Quiz answer.
  ///
  /// In en, this message translates to:
  /// **'Brilliant!'**
  String get quizPraiseBrilliant;

  /// Practice mode that asks the learner to type the definition.
  ///
  /// In en, this message translates to:
  /// **'Typing'**
  String get studyTyping;

  /// Label above the Typing answer field.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get typingYourAnswer;

  /// Placeholder in the Typing answer field.
  ///
  /// In en, this message translates to:
  /// **'Type the term'**
  String get typingHint;

  /// Submits the typed Typing answer and advances.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get typingCheck;

  /// Rating that marks a word as hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get studyHard;

  /// Rating that marks a word as familiar.
  ///
  /// In en, this message translates to:
  /// **'Familiar'**
  String get studyFamiliar;

  /// Rating that marks a word as easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get studyEasy;

  /// Label on the flashcard hint that explains how to reveal the meaning.
  ///
  /// In en, this message translates to:
  /// **'Shortcut'**
  String get studyShortcut;

  /// Flashcard hint shown until the learner taps the card.
  ///
  /// In en, this message translates to:
  /// **'Tap the card to see the meaning'**
  String get studyTapForMeaning;

  /// Switch that shows or hides practice ratings.
  ///
  /// In en, this message translates to:
  /// **'Track progress'**
  String get studyTrackProgress;

  /// Left swipe on a new flashcard.
  ///
  /// In en, this message translates to:
  /// **'Not yet studied'**
  String get studyNotYetStudied;

  /// Right swipe on a new flashcard.
  ///
  /// In en, this message translates to:
  /// **'Studied'**
  String get studyStudiedAction;

  /// Flashcard hint for the Space key and a click.
  ///
  /// In en, this message translates to:
  /// **'Press Space or click the card to flip'**
  String get studyFlipShortcut;

  /// Count of words marked easy on the study page.
  ///
  /// In en, this message translates to:
  /// **'Know'**
  String get studyKnow;

  /// Heading above the words in a flashcard set.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary list'**
  String get studyList;

  /// Filter for words that are not mastered.
  ///
  /// In en, this message translates to:
  /// **'Still learning'**
  String get studyStillLearning;

  /// Filter for words marked easy.
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get studyMastered;

  /// Heading on the page shown when practice finishes.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get studyCompleteTitle;

  /// Headline on the finished practice summary.
  ///
  /// In en, this message translates to:
  /// **'Wow, you know your stuff! You\'ve sorted all the cards.'**
  String get studyCompleteHeadline;

  /// Message when a practice session of one word is complete.
  ///
  /// In en, this message translates to:
  /// **'You finished 1 word.'**
  String get studyCompleteOne;

  /// Message when a practice session of several words is complete.
  ///
  /// In en, this message translates to:
  /// **'You finished {count} words.'**
  String studyCompleteMany(int count);

  /// Button that leaves the finished practice page.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get studyCompleteDone;

  /// Continue control on the finished practice summary.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get studyCompleteContinue;

  /// Heading above the practice session result bars.
  ///
  /// In en, this message translates to:
  /// **'How you\'re doing'**
  String get studyHowYoureDoing;

  /// Heading above the next actions after practice.
  ///
  /// In en, this message translates to:
  /// **'Next steps'**
  String get studyNextSteps;

  /// Count of terms left unstudied in a practice session.
  ///
  /// In en, this message translates to:
  /// **'Terms left'**
  String get studyTermsLeft;

  /// Button that restarts the session in Quiz mode.
  ///
  /// In en, this message translates to:
  /// **'Practice with questions'**
  String get studyPracticeWithQuestions;

  /// Button that restarts the session in Flashcard mode.
  ///
  /// In en, this message translates to:
  /// **'Restart Flashcards'**
  String get studyRestartFlashcards;

  /// Summary of words that moved from one level to another in a practice session.
  ///
  /// In en, this message translates to:
  /// **'Lv.{from} → Lv.{to}'**
  String studyLevelMove(int from, int to);

  /// Summary of new words that reached a level in a practice session.
  ///
  /// In en, this message translates to:
  /// **'New → Lv.{to}'**
  String studyLevelMoveFromNew(int to);

  /// Progress sentence on a recent vocabulary card.
  ///
  /// In en, this message translates to:
  /// **'The process is {percent}% complete.'**
  String progressComplete(int percent);

  /// Action on a recent vocabulary card.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// Heading above the suggested search chips on an empty home.
  ///
  /// In en, this message translates to:
  /// **'Hot search'**
  String get hotSearch;

  /// Heading above the suggested vocabulary sets on an empty home.
  ///
  /// In en, this message translates to:
  /// **'Suggested sets'**
  String get suggestedSets;

  /// Heading above the suggested practice rows on an empty home.
  ///
  /// In en, this message translates to:
  /// **'Suggested practice'**
  String get suggestedPractice;

  /// Action on the suggested word card.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveWord;

  /// How many times the suggested word has been saved.
  ///
  /// In en, this message translates to:
  /// **'{count} saves'**
  String saveCount(int count);

  /// Button that leaves the word editor.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get editorDone;

  /// Back control on the word editor.
  ///
  /// In en, this message translates to:
  /// **'All posts'**
  String get editorBack;

  /// Label for the word editor title field.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get editorTitle;

  /// Placeholder for the word editor title field.
  ///
  /// In en, this message translates to:
  /// **'Enter a title...'**
  String get editorTitleHint;

  /// Placeholder for the word editor description field.
  ///
  /// In en, this message translates to:
  /// **'Add a description...'**
  String get editorDescriptionHint;

  /// Import control on the word editor.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get editorImport;

  /// Label for the term field.
  ///
  /// In en, this message translates to:
  /// **'Term'**
  String get editorTerm;

  /// Placeholder for the term field.
  ///
  /// In en, this message translates to:
  /// **'Enter term'**
  String get editorTermHint;

  /// Label for the definition field.
  ///
  /// In en, this message translates to:
  /// **'Definition'**
  String get editorDefinition;

  /// Placeholder for the definition field.
  ///
  /// In en, this message translates to:
  /// **'Enter definition'**
  String get editorDefinitionHint;

  /// Label for the sentence field.
  ///
  /// In en, this message translates to:
  /// **'Sentence'**
  String get editorSentence;

  /// Placeholder for the sentence field.
  ///
  /// In en, this message translates to:
  /// **'Enter sentence'**
  String get editorSentenceHint;

  /// Heading above the detail fields on a word card.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get editorDetails;

  /// Label for the IPA field.
  ///
  /// In en, this message translates to:
  /// **'IPA'**
  String get editorIpa;

  /// Placeholder for the IPA field.
  ///
  /// In en, this message translates to:
  /// **'Enter IPA'**
  String get editorIpaHint;

  /// Label for the singular and plural field.
  ///
  /// In en, this message translates to:
  /// **'Singular - Plural'**
  String get editorSingularPlural;

  /// Placeholder for the singular and plural field.
  ///
  /// In en, this message translates to:
  /// **'Enter singular and plural'**
  String get editorSingularPluralHint;

  /// Label for the note field.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get editorNote;

  /// Placeholder for the note field.
  ///
  /// In en, this message translates to:
  /// **'Enter a note'**
  String get editorNoteHint;

  /// Label above the word type choices.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get editorType;

  /// Word type choice for a chunk.
  ///
  /// In en, this message translates to:
  /// **'Chunking'**
  String get editorChunking;

  /// Word type choice for a noun.
  ///
  /// In en, this message translates to:
  /// **'Noun'**
  String get editorNoun;

  /// Word type choice for a verb.
  ///
  /// In en, this message translates to:
  /// **'Verb'**
  String get editorVerb;

  /// Word type choice for an adjective.
  ///
  /// In en, this message translates to:
  /// **'Adj'**
  String get editorAdj;

  /// Placeholder for the image link field on a word card.
  ///
  /// In en, this message translates to:
  /// **'Enter image link'**
  String get editorImageLinkHint;

  /// Button that collapses the current word and opens a new empty card.
  ///
  /// In en, this message translates to:
  /// **'Add new word'**
  String get editorAddWord;

  /// Title and confirm button for adding a custom word type.
  ///
  /// In en, this message translates to:
  /// **'Add type'**
  String get editorAddType;

  /// Placeholder for the custom word type name.
  ///
  /// In en, this message translates to:
  /// **'Enter type'**
  String get editorTypeNameHint;

  /// Shown when a new word is saved without a term.
  ///
  /// In en, this message translates to:
  /// **'Enter a term'**
  String get termRequired;

  /// Shown when a new word is saved without a definition.
  ///
  /// In en, this message translates to:
  /// **'Enter a definition'**
  String get definitionRequired;

  /// Shown when Done is pressed without a set title.
  ///
  /// In en, this message translates to:
  /// **'Enter a title'**
  String get titleRequired;

  /// Switches the app to light mode.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Switches the app to dark mode.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Avatar menu item for achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get menuAchievements;

  /// Avatar menu item for settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// Avatar menu item that switches to light mode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get menuLightMode;

  /// Avatar menu item that switches to dark mode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get menuDarkMode;

  /// Avatar menu item for logging out.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get menuLogOut;

  /// Avatar menu item for the privacy policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get menuPrivacy;

  /// Avatar menu item for help and feedback.
  ///
  /// In en, this message translates to:
  /// **'Help and feedback'**
  String get menuHelp;

  /// Avatar menu item for upgrading.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get menuUpgrade;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
