# Spec Delta

## Purpose

Stores a finished vocabulary set in Cloud Firestore when Done leaves the editor with at least one word, without attaching that set to an account.

## ADDED Requirements

### Requirement: Done stores a finished set
When Done is activated and at least one card has a term, the system SHALL store one set in Cloud Firestore project `langmm-ca0d0`. The set SHALL include the title, the description, and each kept word's term, definition, sentence, IPA, singular and plural, note, and selected type.

#### Scenario: A filled card is stored
- **WHEN** the user enters "German A1" as the title, "Basics" as the description, "Kind" as the term, "child" as the definition, "Das Kind" as the sentence, "kɪnt" as the IPA, "Kind - Kinder" as the singular and plural, and "noun" as the note, selects Noun, and activates Done
- **THEN** one set is stored in Cloud Firestore project `langmm-ca0d0`
- **AND** that set's title is "German A1" and its description is "Basics"
- **AND** that set contains one word whose term is "Kind", definition is "child", sentence is "Das Kind", IPA is "kɪnt", singular and plural is "Kind - Kinder", note is "noun", and type is "noun"

#### Scenario: The expanded card is kept
- **WHEN** the user enters "Kind" as the term on the expanded card and activates Done without activating Add new word
- **THEN** the stored set contains a word whose term is "Kind"

#### Scenario: Words stay in card number order
- **WHEN** the user enters "Kind" as the term, activates Add new word, enters "Haus" as the term on the new card, and activates Done
- **THEN** the stored set's first word has the term "Kind"
- **AND** the stored set's second word has the term "Haus"

### Requirement: A card with no term is left out
A card whose term is empty SHALL NOT be stored as a word. A term that is only whitespace SHALL count as empty.

#### Scenario: Add new word leaves a blank card
- **WHEN** the user enters "Kind" as the term, activates Add new word, and activates Done
- **THEN** the stored set contains one word
- **AND** that word's term is "Kind"

#### Scenario: A whitespace term is empty
- **WHEN** the user enters only spaces as the term and activates Done
- **THEN** no set is stored

### Requirement: An empty title uses the first term
When the title is empty, the stored title SHALL be the first kept word's term. A title that is only whitespace SHALL count as empty.

#### Scenario: The title is blank
- **WHEN** the user leaves the title empty, enters "Kind" as the term, and activates Done
- **THEN** the stored set's title is "Kind"

#### Scenario: The title is whitespace
- **WHEN** the user enters only spaces as the title, enters "Kind" as the term, and activates Done
- **THEN** the stored set's title is "Kind"

### Requirement: A word with no type stores no type
When no type is selected, the stored word SHALL NOT record a type.

#### Scenario: No type is selected
- **WHEN** the user enters "Kind" as the term, selects no type, and activates Done
- **THEN** the stored word records no type

### Requirement: Done with no term stores nothing
When no card has a term, Done SHALL NOT store a set.

#### Scenario: The empty editor
- **WHEN** the editor is showing one empty card and the user activates Done
- **THEN** no set is stored

### Requirement: Add new word stores nothing
Activating Add new word SHALL NOT store a set.

#### Scenario: A typed word stays unstored
- **WHEN** the user enters "Kind" as the term and activates Add new word
- **THEN** no set is stored

### Requirement: Back stores nothing
Activating the back control SHALL NOT store a set.

#### Scenario: Back drops the typed word
- **WHEN** the user enters "Kind" as the term and activates the back control
- **THEN** no set is stored

### Requirement: A stored set has no owner
The stored set SHALL NOT name an owner. The system SHALL NOT ask the user to sign in before storing the set.

#### Scenario: Store without an account
- **WHEN** the user enters "Kind" as the term and activates Done
- **THEN** the stored set names no owner
- **AND** the user is not asked to sign in

### Requirement: A failed store writes nothing
When storing the set fails, the system SHALL NOT store that set.

#### Scenario: The store fails
- **WHEN** the user enters "Kind" as the term, activates Done, and storing the set fails
- **THEN** no set is stored

### Requirement: The same title can be stored twice
Each successful Done SHALL store its own set, including when the title matches a set stored earlier.

#### Scenario: Two sets named Animals
- **WHEN** a set titled "Animals" has been stored and the user stores another set titled "Animals"
- **THEN** two sets titled "Animals" are stored
