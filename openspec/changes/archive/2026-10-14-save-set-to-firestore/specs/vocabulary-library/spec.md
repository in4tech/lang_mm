# Spec Delta

## MODIFIED Requirements

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

## ADDED Requirements

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
