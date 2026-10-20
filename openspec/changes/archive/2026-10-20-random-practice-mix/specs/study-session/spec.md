# Spec Delta

## ADDED Requirements

### Requirement: Random mixes the three exercise types
While practice is open in Random, each current word SHALL use exactly one of Flashcard, Quiz, or Typing for that word. The choice SHALL be drawn uniformly at random among those three when the word becomes current under Random. The mode control SHALL still show Random.

#### Scenario: Random can present Quiz for Kind
- **WHEN** the learner is in Random and the draw for "Kind" is Quiz
- **THEN** Quiz asks for "Kind"
- **AND** the mode control shows Random

#### Scenario: Random can present Typing for Kind
- **WHEN** the learner is in Random and the draw for "Kind" is Typing
- **THEN** Typing shows the cue for "Kind"
- **AND** the mode control shows Random

#### Scenario: Random can present Flashcard for Kind
- **WHEN** the learner is in Random and the draw for "Kind" is Flashcard
- **THEN** Flashcard shows the term face for "Kind"
- **AND** the mode control shows Random

### Requirement: Random redraws on the next word
When the learner advances from one remaining word to the next while Random stays selected, the next word SHALL get a new independent draw among Flashcard, Quiz, and Typing.

#### Scenario: Next word can differ in type
- **WHEN** Random showed Flashcard for "Kind" and the learner advances to "Haus" under Random
- **AND** the draw for "Haus" is Quiz
- **THEN** Quiz asks for "Haus"

### Requirement: Random follows the drawn mode's rules
While Random is selected, the current word SHALL follow the requirements of the drawn exercise type for flipping, options, typing, ratings, new-word controls, sounds, and exit motion. Advancing after a rating or new-word control SHALL remove that word from the session the same way the drawn type does.

#### Scenario: Easy under Random Flashcard advances
- **WHEN** Random drew Flashcard for "Kind" at level 1 and the next remaining word is "Haus"
- **AND** the user activates Easy
- **THEN** the session advances to "Haus" under a new Random draw

#### Scenario: A Quiz rating under Random advances
- **WHEN** Random drew Quiz for "Kind", a result has settled, and "Kind" is at level 1
- **AND** the next remaining word is "Haus"
- **AND** the user activates Easy
- **THEN** the session advances to "Haus" under a new Random draw

### Requirement: Choosing a fixed mode leaves the mix
Choosing Flashcard, Quiz, or Typing from the mode menu SHALL end Random mixing and SHALL show that fixed mode for the current word. Choosing Random again SHALL draw a type for the current word.

#### Scenario: Quiz from the menu is fixed Quiz
- **WHEN** the learner is in Random on "Kind" and chooses Quiz from the mode menu
- **THEN** the mode control shows Quiz
- **AND** Quiz asks for "Kind"

## REMOVED Requirements

### Requirement: Random shows the whole word
**Reason**: Random no longer browses a full-word face; it mixes Flashcard, Quiz, and Typing.
**Migration**: Use Flashcard, Quiz, or Typing directly, or Random’s mixed draws.

### Requirement: Random slides to another word
**Reason**: Prev/next sliding belonged to the browse Random card and conflicts with graded exercise advance.
**Migration**: Advance through ratings (or new-word controls) under the drawn exercise type.

## MODIFIED Requirements

### Requirement: Other modes leave the level unchanged
Showing Quiz or Typing before a result SHALL NOT show Hard, Familiar, Easy, or the two new-word controls and SHALL NOT itself change a level or a reminder time. When Random’s draw is Quiz or Typing before a result, the same rule applies. When Random’s draw is Flashcard, rating and new-word controls follow Flashcard rules.

#### Scenario: Quiz has no rating controls
- **WHEN** Quiz is showing "Kind" at level 1 and no result yet
- **THEN** Hard, Familiar, and Easy are not shown
- **AND** the level of "Kind" stays 1

#### Scenario: Typing has no rating controls
- **WHEN** Typing is showing the cue for "Kind" at level 1 and no result yet
- **THEN** Hard, Familiar, and Easy are not shown
- **AND** the level of "Kind" stays 1

#### Scenario: Random has no rating controls
- **WHEN** Random drew Quiz for "Kind" at level 1 and no result yet
- **THEN** Hard, Familiar, and Easy are not shown
- **AND** the level of "Kind" stays 1

### Requirement: Quiz and Typing stay flat
In Typing and Quiz, a tap SHALL NOT flip the card, and no card SHALL peek from behind. Typing and Quiz SHALL NOT show the previous and next controls. The same SHALL hold when Random’s draw is Typing or Quiz. Entering Flashcard from Quiz, Typing, or Random SHALL show the term face.

#### Scenario: Typing does not flip
- **WHEN** Typing is showing the cue for "Kind"
- **AND** the user taps the card
- **THEN** the card still shows that cue
- **AND** the card does not show the term face flip

#### Scenario: Quiz does not flip
- **WHEN** Quiz is showing the term "Kind"
- **AND** the user taps the term
- **THEN** the card still shows "Kind"

#### Scenario: Quiz has no previous or next control
- **WHEN** Quiz is showing "Kind"
- **THEN** the previous and next controls are not shown

#### Scenario: Typing has no previous or next control
- **WHEN** Typing is showing the cue for "Kind"
- **THEN** the previous and next controls are not shown

#### Scenario: Random Quiz has no previous or next control
- **WHEN** Random drew Quiz for "Kind"
- **THEN** the previous and next controls are not shown

#### Scenario: Flashcard opens on the term from Quiz
- **WHEN** the user enters Flashcard from Quiz on "Kind"
- **THEN** the card shows the term face of "Kind"

#### Scenario: Flashcard opens on the term from Typing
- **WHEN** the user enters Flashcard from Typing on "Kind"
- **THEN** the card shows the term face of "Kind"

#### Scenario: Flashcard opens on the term from Random
- **WHEN** the user enters Flashcard from Random on "Kind"
- **THEN** the card shows the term face of "Kind"
