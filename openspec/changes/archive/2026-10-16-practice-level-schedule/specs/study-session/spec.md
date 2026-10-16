# Spec Delta

## MODIFIED Requirements

### Requirement: A rating opens the next term
In Flashcard, when Track progress is on and the current word's level is 1 through 6, Hard, Familiar, and Easy SHALL be shown. Activating one SHALL record that rating and show the next remaining word's term face. On the last remaining word, the same control SHALL record the rating and leave that word on its term face. A new word SHALL NOT show Hard, Familiar, or Easy.

#### Scenario: Easy moves from Kind to Haus
- **WHEN** Flashcard is showing "Kind" at level 1, Track progress is on, and the next remaining word's term is "Haus"
- **AND** the user activates Easy
- **THEN** the card shows "Haus"
- **AND** the card does not show the definition of "Haus"

#### Scenario: Easy on the last word stays there
- **WHEN** Flashcard is showing the meaning face of the last remaining word, "Haus", at level 2, and Track progress is on
- **AND** the user activates Easy
- **THEN** the card shows the term "Haus"

#### Scenario: A new word hides the three ratings
- **WHEN** Flashcard is showing the new word "Kind" and Track progress is on
- **THEN** Hard, Familiar, and Easy are not shown

## ADDED Requirements

### Requirement: Today practice opens the set queue
Today practice on a set SHALL open Flashcard on the first word of that set's practice queue. When that queue is empty, Today practice SHALL leave the set page showing and SHALL NOT open a card.

#### Scenario: Today practice opens Kind
- **WHEN** the set queue begins with "Kind" and the user activates Today practice
- **THEN** Flashcard shows the term "Kind"

#### Scenario: An empty queue stays on the set page
- **WHEN** the set queue is empty and the user activates Today practice
- **THEN** the set page remains
- **AND** no flashcard is shown

### Requirement: Practice shows the session position
While practice is open, the screen SHALL show the active mode, the current word's set name, a close control, and the session position as the 1-based index, the count of words in the session when it opened, and a bar filled to that share.

#### Scenario: The second of four words
- **WHEN** practice opened on four words and is showing the second
- **THEN** the screen shows "2 / 4" and that word's set name

#### Scenario: Close leaves practice
- **WHEN** the user activates the close control during practice
- **THEN** practice is closed
- **AND** the set page is shown

### Requirement: The mode menu lists four modes
The mode control SHALL show the active mode. Activating it SHALL show Random, Flashcard, Quiz, and Typing in that order, with the active mode selected. Choosing one SHALL close the menu and use that mode. Today practice SHALL start in Flashcard.

#### Scenario: The menu shows four modes
- **WHEN** the user activates the mode control during Flashcard
- **THEN** Random, Flashcard, Quiz, and Typing are shown
- **AND** Flashcard is selected

#### Scenario: Quiz becomes the active mode
- **WHEN** the user chooses Quiz from the mode menu
- **THEN** the mode control shows Quiz
- **AND** the menu is closed

### Requirement: Track progress hides the counts and the ratings
Track progress SHALL start on. While it is on, the screen SHALL show Still learning as the count of that set's words at levels 1 through 5, and Know as the count at level 6. While it is off, those two counts, Hard, Familiar, Easy, and the two new-word swipes SHALL be hidden, and a rating SHALL NOT change a level or a reminder time.

#### Scenario: Counts follow the set
- **WHEN** the current set has one word at level 2 and one word at level 6, and Track progress is on
- **THEN** Still learning shows 1
- **AND** Know shows 1

#### Scenario: Switching off hides the ratings
- **WHEN** Flashcard is showing "Kind" at level 1 and the user turns Track progress off
- **THEN** Still learning, Know, Hard, Familiar, and Easy are not shown
- **AND** the level of "Kind" stays 1

### Requirement: A new word has two swipes
In Flashcard, when Track progress is on, a new word SHALL offer a left swipe labeled as not yet studied and a right swipe labeled as studied. The left swipe SHALL leave the word new and show the next remaining word. The right swipe SHALL record the word as studied and show the next remaining word. On the last remaining word, either swipe SHALL leave that word showing. A word swiped in the session SHALL NOT appear again in that session.

#### Scenario: A left swipe keeps Kind new
- **WHEN** Flashcard is showing the new word "Kind", Track progress is on, and the next remaining word is "Haus"
- **AND** the user swipes left
- **THEN** "Kind" stays new
- **AND** the card shows "Haus"
- **AND** "Kind" is not shown again in that session

#### Scenario: A right swipe studies Kind
- **WHEN** Flashcard is showing the new word "Kind" and Track progress is on
- **AND** the user swipes right
- **THEN** "Kind" is recorded as studied

### Requirement: Space flips the flashcard
In Flashcard, Space SHALL flip the card the same way a tap does.

#### Scenario: Space reveals the meaning
- **WHEN** Flashcard is showing the term face for "Kind"
- **AND** the user presses Space
- **THEN** the card shows the meaning face of "Kind"

### Requirement: Other modes leave the level unchanged
In Random, Quiz, and Typing, Hard, Familiar, Easy, and the two new-word swipes SHALL be absent. Changing the word in those modes SHALL NOT change a level or a reminder time.

#### Scenario: Quiz has no rating controls
- **WHEN** Quiz is showing "Kind" at level 1 and Track progress is on
- **THEN** Hard, Familiar, and Easy are not shown
- **AND** the level of "Kind" stays 1
