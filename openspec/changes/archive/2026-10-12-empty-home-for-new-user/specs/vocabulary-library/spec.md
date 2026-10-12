# Spec Delta

## Purpose

Keeps this device's vocabulary folders and set names, starting empty, so a new user is not given the sample sets.

## ADDED Requirements

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
