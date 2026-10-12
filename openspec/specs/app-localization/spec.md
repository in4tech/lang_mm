# app-localization Specification

## Purpose

Lets the app present its interface in Vietnamese, English, or German, starting in English until the user chooses another language.

## Requirements

### Requirement: Supported languages
The language component SHALL offer exactly Vietnamese, English, and German.

#### Scenario: Open the language component
- **WHEN** the user opens the language component
- **THEN** the only choices are Vietnamese, English, and German

### Requirement: Language names stay recognizable
Each language choice SHALL be labeled in that language itself: "Tiếng Việt", "English", and "Deutsch".

#### Scenario: Labels while English is active
- **WHEN** the active language is English and the user opens the language component
- **THEN** the choices are labeled "Tiếng Việt", "English", and "Deutsch"

### Requirement: Active language is indicated
The language component SHALL mark exactly one language as active.

#### Scenario: English is active
- **WHEN** the active language is English and the user opens the language component
- **THEN** English is marked active
- **AND** Vietnamese and German are not marked active

### Requirement: English is the initial language
Before the user has chosen a language, the system SHALL present the app in English, including when the device language is Vietnamese or German.

#### Scenario: First launch on a Vietnamese device
- **WHEN** the app starts for the first time and the device language is Vietnamese
- **THEN** visible UI copy is English

#### Scenario: First launch on a German device
- **WHEN** the app starts for the first time and the device language is German
- **THEN** visible UI copy is English

### Requirement: User can switch language
The user SHALL be able to select one supported language, and visible UI copy SHALL change to that language without leaving the current screen.

#### Scenario: Switch to Vietnamese
- **WHEN** the user selects Vietnamese on a platform other than web
- **THEN** the home screen title, counter message, and increment action appear in Vietnamese
- **AND** Vietnamese is marked active

#### Scenario: Switch to German
- **WHEN** the user selects German on a platform other than web
- **THEN** the home screen title, counter message, and increment action appear in German
- **AND** German is marked active

#### Scenario: Switch back to English
- **WHEN** the active language is not English and the user selects English on a platform other than web
- **THEN** the home screen title, counter message, and increment action appear in English
- **AND** English is marked active

### Requirement: Home screen copy exists in every language
The home screen title, counter message, and increment action SHALL have copy in Vietnamese, English, and German.

#### Scenario: Home screen in each language
- **WHEN** the active language is Vietnamese, English, or German and the platform is not web
- **THEN** the home screen shows its title, counter message, and increment action in that language

### Requirement: Switching language keeps screen state
Changing language SHALL NOT reset state already on the current screen.

#### Scenario: Counter survives a language change
- **WHEN** the counter shows a non-zero value on a platform other than web and the user selects another language
- **THEN** the counter still shows that same value

### Requirement: Language choice persists
The system SHALL restore the last language the user selected the next time the app starts.

#### Scenario: Relaunch after German
- **WHEN** the user selects German and then starts the app again
- **THEN** the app opens in German

#### Scenario: Relaunch after Vietnamese
- **WHEN** the user selects Vietnamese and then starts the app again
- **THEN** the app opens in Vietnamese

### Requirement: Unknown stored language uses English
If no language is stored, or the stored value is not Vietnamese, English, or German, the system SHALL use English.

#### Scenario: Stored value is unsupported
- **WHEN** the app starts and the stored language is not one of the three supported languages
- **THEN** the app opens in English

### Requirement: Missing translation uses English
When the active language has no translation for a piece of UI copy, the system SHALL show the English text for that copy only.

#### Scenario: One German string is missing
- **WHEN** the active language is German and one string has no German translation
- **THEN** that string is shown in English
- **AND** strings that have a German translation stay in German

### Requirement: Shell language matches the selection
Framework-provided interface text SHALL use the same language as the user's selection.

#### Scenario: Vietnamese shell
- **WHEN** the active language is Vietnamese
- **THEN** framework-provided interface text is Vietnamese

### Requirement: Web home chrome exists in every language
The vocabulary home title and chrome SHALL have copy in Vietnamese, English, and German. Chrome is the search placeholder, New vocab, Homepage, Library, Notification, Your vocabulary set, Set of words, the statistics heading, All, Words learned, Words not yet learned, the six level names, Today's vocabulary, Practice, Recent, the progress sentence, and Continue.

#### Scenario: Web home in each language
- **WHEN** the vocabulary home is shown and the active language is Vietnamese, English, or German
- **THEN** the vocabulary home shows its title and chrome in that language

### Requirement: Web language switch updates chrome
On the vocabulary home, the user SHALL be able to select one supported language, and the vocabulary home title and chrome SHALL change to that language without leaving that home.

#### Scenario: Switch to Vietnamese on the vocabulary home
- **WHEN** the user selects Vietnamese on the vocabulary home
- **THEN** the vocabulary home title and chrome appear in Vietnamese
- **AND** Vietnamese is marked active

#### Scenario: Switch to German on the vocabulary home
- **WHEN** the user selects German on the vocabulary home
- **THEN** the vocabulary home title and chrome appear in German
- **AND** German is marked active

#### Scenario: Switch back to English on the vocabulary home
- **WHEN** the active language is not English and the user selects English on the vocabulary home
- **THEN** the vocabulary home title and chrome appear in English
- **AND** English is marked active

### Requirement: Switching language keeps the home sample
Changing language SHALL NOT reset the vocabulary home already on screen.

#### Scenario: Sample home survives a language change
- **WHEN** the vocabulary home shows the German A1 sample and the user selects another language
- **THEN** the sample numbers, set names, vocabulary entries, Homepage selection, and My vocab expansion stay as they were
