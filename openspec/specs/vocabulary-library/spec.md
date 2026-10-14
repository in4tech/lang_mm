# vocabulary-library Specification

## Purpose

Keeps this device's vocabulary folders and set names, starting empty, so a new user is not given the sample sets.

## Requirements

### Requirement: A missing library is empty
The system SHALL load an empty vocabulary library when none is saved. An empty library has no folders and no sets.

#### Scenario: First launch
- **WHEN** the app starts and no vocabulary library is saved
- **THEN** the loaded library has no folders and no sets

### Requirement: A saved library is restored
The system SHALL restore each saved folder name and the set names in that folder the next time the app starts.

#### Scenario: Relaunch with two folders
- **WHEN** a library containing folder "My vocab" with set "German A1 vocabulary" and folder "Travel" with no sets has been saved, and the app starts again
- **THEN** the loaded library contains "My vocab", "German A1 vocabulary", and "Travel"

### Requirement: An unreadable library loads as empty
If the saved vocabulary library cannot be read, the system SHALL load an empty library and SHALL leave the saved value in place.

#### Scenario: Saved value cannot be read
- **WHEN** the app starts and the saved vocabulary library cannot be read
- **THEN** the loaded library has no folders and no sets
- **AND** the saved value is unchanged

### Requirement: The library is not seeded
The system SHALL NOT add folders, sets, or words that were not saved in the library.

#### Scenario: First launch has no sample vocabulary
- **WHEN** the app starts and no vocabulary library is saved
- **THEN** the loaded library does not contain "My vocab", "My vocab 2", "German A1 vocabulary", "A2 vocabulary", "German B1 vocabulary", or "das Auto fahren"

#### Scenario: Suggestion templates are not saved
- **WHEN** the app starts and no vocabulary library is saved
- **THEN** the loaded library does not contain "student", "Love vocabulary", or "Practice \"love\""

### Requirement: The library stores names only
The vocabulary library SHALL store folder names and set names, and SHALL NOT store words, learned counts, or a today list.

#### Scenario: A saved set has no words
- **WHEN** a library containing set "German A1 vocabulary" is saved and the app starts again
- **THEN** that set name is loaded
- **AND** no word and no learned count is loaded with it

#### Scenario: A set saved from the editor stores its name only
- **WHEN** a set named "German A1" whose word term is "Kind" has been saved and the app starts again
- **THEN** "German A1" is loaded
- **AND** "Kind" is not loaded with it

### Requirement: The first save creates the editor folder
When a set is saved and the library has no editor folder, the system SHALL create a folder and put the set name in it. That folder's name SHALL be "Your vocabulary set" in English, "Bộ từ vựng của bạn" in Vietnamese, or "Dein Vokabelset" in German, matching the language active at that save.

#### Scenario: English first save
- **WHEN** the language is English, the library has no editor folder, and a set named "German A1" is saved
- **THEN** the library contains folder "Your vocabulary set" with set "German A1"

#### Scenario: Vietnamese first save
- **WHEN** the language is Vietnamese, the library has no editor folder, and a set named "German A1" is saved
- **THEN** the library contains folder "Bộ từ vựng của bạn" with set "German A1"

#### Scenario: German first save
- **WHEN** the language is German, the library has no editor folder, and a set named "German A1" is saved
- **THEN** the library contains folder "Dein Vokabelset" with set "German A1"

### Requirement: Later saves use the same editor folder
The system SHALL add a later set name to the existing editor folder. A language change SHALL NOT create a second editor folder. The system SHALL NOT add the set name to any other folder.

#### Scenario: A language change keeps the folder
- **WHEN** the editor folder is "Bộ từ vựng của bạn", the language is English, and a set named "Animals" is saved
- **THEN** "Animals" is in "Bộ từ vựng của bạn"
- **AND** no folder is named "Your vocabulary set"

#### Scenario: An existing folder is not the destination
- **WHEN** the library contains folder "My vocab" with set "German A1 vocabulary", the library has no editor folder, the language is English, and a set named "Animals" is saved
- **THEN** "My vocab" still contains "German A1 vocabulary"
- **AND** "My vocab" does not contain "Animals"
- **AND** "Your vocabulary set" contains "Animals"

#### Scenario: The editor folder is restored
- **WHEN** a library whose editor folder is "Bộ từ vựng của bạn" has been saved, the app starts again, and a set named "Animals" is saved in English
- **THEN** "Animals" is in "Bộ từ vựng của bạn"

### Requirement: The same set name can be listed twice
The editor folder SHALL list a set name again when that name is saved again.

#### Scenario: Animals is saved twice
- **WHEN** the editor folder already contains "Animals" and a set named "Animals" is saved
- **THEN** the editor folder lists "Animals" twice

### Requirement: A failed save leaves the library unchanged
When storing the set fails, the vocabulary library SHALL remain unchanged.

#### Scenario: Failure adds no folder
- **WHEN** the loaded library has no folders, the user enters "Kind" as the term, and storing the set fails
- **THEN** the saved library has no folders
