# study-session Specification

## Purpose

Lets a learner move through a set on the study page, with Random showing the whole word and Flashcard hiding the meaning until a tap.

## Requirements

### Requirement: Random shows the whole word
In Random, the current card SHALL show the word's term, IPA, singular and plural, sentence, definition, note, and image on one face. An empty text field SHALL be omitted. A missing image SHALL be omitted. A tap SHALL leave that face showing.

#### Scenario: Kind shows its meaning on the same face
- **WHEN** Random is showing a word whose term is "Kind", definition is "child", sentence is "Das Kind", IPA is "kɪnt", singular and plural is "das, -er", and note is "noun"
- **THEN** the card shows "Kind", "child", "Das Kind", "kɪnt", "das, -er", and "noun" together

#### Scenario: A tap keeps the same face
- **WHEN** the user taps the Random card for "Kind"
- **THEN** the card still shows "Kind" and "child"

### Requirement: Random slides to another word
In Random, the next control SHALL slide to the following word and the previous control SHALL slide to the preceding word. The word that leaves SHALL move in the direction of that control. The card behind the current word SHALL stay partly visible while another word remains in the order. With one word, either control SHALL leave that word in place.

#### Scenario: Next reveals Haus
- **WHEN** Random is showing "Kind" and the following word's term is "Haus"
- **THEN** a card behind the current card is partly visible
- **AND** activating the next control shows "Haus"

#### Scenario: Previous returns to Kind
- **WHEN** Random is showing "Haus" and the preceding word's term is "Kind"
- **AND** the user activates the previous control
- **THEN** the card shows "Kind"

#### Scenario: A single word stays put
- **WHEN** Random is showing the only word, "Kind"
- **AND** the user activates the next control
- **THEN** the card still shows "Kind"

### Requirement: Flashcard opens on the term
In Flashcard, the card SHALL open on the term face. That face SHALL show the term, the IPA, and the image. It SHALL NOT show the definition, the sentence, or the note. The previous and next controls SHALL be absent.

#### Scenario: Kind opens without its meaning
- **WHEN** the user opens Flashcard on a word whose term is "Kind", IPA is "kɪnt", and definition is "child"
- **THEN** the card shows "Kind" and "kɪnt"
- **AND** the card does not show "child"

### Requirement: A tap flips the same word
In Flashcard, a tap SHALL flip the card on a vertical axis to the meaning face. That face SHALL show the definition, the sentence, and the note, and SHALL NOT show the term. A tap on the meaning face SHALL flip back to the term face of the same word.

#### Scenario: A tap reveals child
- **WHEN** Flashcard is showing the term face for "Kind" and the definition is "child"
- **AND** the user taps the card
- **THEN** the card shows "child"
- **AND** the card does not show "Kind"

#### Scenario: A second tap returns to Kind
- **WHEN** Flashcard is showing the meaning face for "Kind"
- **AND** the user taps the card
- **THEN** the card shows "Kind"
- **AND** the card does not show "child"

### Requirement: A rating opens the next term
In Flashcard, Hard, Familiar, and Easy SHALL record the current word and show the next word's term face. On the last word, the same control SHALL record the mark and leave that word on its term face.

#### Scenario: Easy moves from Kind to Haus
- **WHEN** Flashcard is showing "Kind" and the next word's term is "Haus"
- **AND** the user activates Easy
- **THEN** the card shows "Haus"
- **AND** the card does not show the definition of "Haus"

#### Scenario: Easy on the last word stays there
- **WHEN** Flashcard is showing the meaning face of the last word, "Haus"
- **AND** the user activates Easy
- **THEN** the card shows the term "Haus"

### Requirement: Quiz and Typing stay flat
In Quiz and Typing, a tap SHALL NOT flip the card, and no card SHALL peek from behind. The previous and next controls SHALL change the word without a slide. Entering Flashcard from either mode SHALL show the term face.

#### Scenario: Quiz does not flip
- **WHEN** Quiz is showing the definition "child"
- **AND** the user taps the card
- **THEN** the card still shows "child"
