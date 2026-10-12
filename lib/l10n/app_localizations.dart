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

  /// Sidebar navigation label for the home screen.
  ///
  /// In en, this message translates to:
  /// **'Homepage'**
  String get navHome;

  /// Sidebar navigation label for the library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

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
