# Spec Delta

## MODIFIED Requirements

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

## ADDED Requirements

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
