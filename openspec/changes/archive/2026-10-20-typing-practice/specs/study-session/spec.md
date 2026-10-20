# Spec Delta

## MODIFIED Requirements

### Requirement: Quiz and Typing stay flat
In Typing and Quiz, a tap SHALL NOT flip the card, and no card SHALL peek from behind. Typing and Quiz SHALL NOT show the previous and next controls. Entering Flashcard from either mode SHALL show the term face.

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

#### Scenario: Flashcard opens on the term from Quiz
- **WHEN** the user enters Flashcard from Quiz on "Kind"
- **THEN** the card shows the term face of "Kind"

#### Scenario: Flashcard opens on the term from Typing
- **WHEN** the user enters Flashcard from Typing on "Kind"
- **THEN** the card shows the term face of "Kind"

### Requirement: Other modes leave the level unchanged
In Random, Hard, Familiar, Easy, and the two new-word controls SHALL be absent. Changing the word in Random SHALL NOT change a level or a reminder time. Showing Quiz or Typing before a result SHALL NOT show those controls and SHALL NOT itself change a level or a reminder time.

#### Scenario: Quiz has no rating controls
- **WHEN** Quiz is showing "Kind" at level 1 and no result yet
- **THEN** Hard, Familiar, and Easy are not shown
- **AND** the level of "Kind" stays 1

#### Scenario: Typing has no rating controls
- **WHEN** Typing is showing the cue for "Kind" at level 1 and no result yet
- **THEN** Hard, Familiar, and Easy are not shown
- **AND** the level of "Kind" stays 1

#### Scenario: Random has no rating controls
- **WHEN** Random is showing "Kind" at level 1
- **THEN** Hard, Familiar, and Easy are not shown
- **AND** the level of "Kind" stays 1

## ADDED Requirements

### Requirement: Typing shows the meaning cue
Typing SHALL show the current word's IPA, stored type, definition, and sentence with each whole-word match of the term replaced by "---", and SHALL omit any of those that are empty. Typing SHALL NOT show the term on the cue before a result.

#### Scenario: Kind cue hides the term
- **WHEN** Typing is showing the word whose term is "Kind", IPA is "kɪnt", type is "noun", definition is "child", and sentence is "Das Kind schläft"
- **THEN** the card shows "kɪnt", "noun", "child", and "Das --- schläft"
- **AND** the card does not show "Kind" as the cue term

#### Scenario: An empty definition is omitted
- **WHEN** Typing is showing a word whose definition is empty and whose IPA is "kɪnt"
- **THEN** the card shows "kɪnt"
- **AND** the card does not show an empty definition line

#### Scenario: A sentence without the term stays whole
- **WHEN** Typing is showing a word whose term is "Kind" and whose sentence is "Guten Tag"
- **THEN** the card shows "Guten Tag"

### Requirement: Typing asks for a typed term
Typing SHALL show a "Your answer" label, a text field with a type-the-term hint, Check, and Don't know before a result. Check SHALL be inactive when the field is empty.

#### Scenario: Empty field blocks Check
- **WHEN** Typing is showing the cue for "Kind" and the answer field is empty
- **THEN** Check does not accept activation
- **AND** Don't know is available

#### Scenario: Enter submits a non-empty answer
- **WHEN** Typing is showing the cue for "Kind" and the field holds "kind"
- **AND** the user presses Enter
- **THEN** the answer is checked the same way as Check

### Requirement: Typing Check compares trimmed lowercase text
Check SHALL trim leading and trailing spaces, compare the field to the term with both sides lowercased, and treat an equal result as correct.

#### Scenario: Lowercase Kind is correct
- **WHEN** Typing is asking for "Kind" and the field holds "kind"
- **AND** the user activates Check
- **THEN** the answer is treated as correct

#### Scenario: Spaced Kind is correct
- **WHEN** Typing is asking for "Kind" and the field holds " Kind "
- **AND** the user activates Check
- **THEN** the answer is treated as correct

### Requirement: A correct Typing Check marks the answer
A correct Check SHALL play a short high tone, lock the field, and reveal the term. Typing SHALL NOT show praise text after a correct Check.

#### Scenario: Kind is checked correctly
- **WHEN** Typing is asking for "Kind" and the field holds "kind"
- **AND** the user activates Check
- **THEN** a short high tone plays
- **AND** the field is locked
- **AND** the card shows "Kind"
- **AND** no praise line is shown

### Requirement: A wrong Typing answer reveals the term
A Check whose trimmed, lowercased text does not equal the lowercased term SHALL show "No sweat, you're still learning!", play a short low tone, lock the field, and reveal the term.

#### Scenario: Haus is typed for Kind
- **WHEN** Typing is asking for "Kind" and the field holds "Haus"
- **AND** the user activates Check
- **THEN** the card shows "No sweat, you're still learning!"
- **AND** a short low tone plays
- **AND** the field is locked
- **AND** the card shows "Kind"

### Requirement: Don't know on Typing reveals the term
Don't know on Typing SHALL show "Give this one a try later!", lock the field, reveal the term, show no wrong mark on the field, and play no tone.

#### Scenario: Don't know on Kind
- **WHEN** Typing is asking for "Kind" and the user activates Don't know
- **THEN** the card shows "Give this one a try later!"
- **AND** the field is locked
- **AND** the card shows "Kind"
- **AND** no tone plays

### Requirement: A Typing result locks the question
After Check or Don't know, another Check SHALL do nothing, Don't know SHALL dim and SHALL NOT accept activation, the field SHALL ignore edits, and the level SHALL stay unchanged until a level control is activated.

#### Scenario: A second Check does nothing
- **WHEN** Typing has revealed the answer for "Kind"
- **AND** the user activates Check again
- **THEN** the revealed result stays
- **AND** the level of "Kind" stays unchanged

### Requirement: Typing shows level controls after the result
After the result has settled, a word at level 1 through 6 SHALL show Hard, Familiar, and Easy, rising into place one after another. A control SHALL ignore activation until it has arrived. Before a result, those controls SHALL be absent.

#### Scenario: Levels rise after Kind
- **WHEN** Typing reveals the answer for "Kind" at level 1
- **THEN** Hard, Familiar, and Easy appear in that order
- **AND** Familiar ignores activation until it has arrived

### Requirement: A new Typing word shows the two study controls
After the result has settled, a new word SHALL show Not yet studied and Studied, rising into place one after another, and SHALL NOT show Hard, Familiar, or Easy.

#### Scenario: New Kind shows the two controls
- **WHEN** Typing reveals the answer for the new word "Kind"
- **THEN** Not yet studied and Studied are shown
- **AND** Hard, Familiar, and Easy are not shown

### Requirement: Disabled animations show the Typing result at once
When animations are disabled, the result and its level controls SHALL appear at once and SHALL accept activation immediately. A correct Check SHALL still play the high tone, and a wrong Check SHALL still play the low tone.

#### Scenario: Instant Typing result
- **WHEN** animations are disabled and Typing reveals a correct answer for "Kind" at level 1
- **THEN** Hard, Familiar, and Easy are shown at once
- **AND** each control accepts activation immediately
- **AND** the high tone still plays

### Requirement: A Typing rating advances like Flashcard
Activating Hard, Familiar, or Easy after a Typing result SHALL record that rating and show the next remaining word's cue. On the last remaining word, the same control SHALL record the rating and show the congratulations page. The rated word SHALL NOT appear again in that session.

#### Scenario: Easy opens the next Typing cue
- **WHEN** Typing has revealed "Kind" at level 1 and the next remaining word is "Haus"
- **AND** the user activates Easy
- **THEN** the rating for "Kind" is recorded
- **AND** Typing shows the cue for "Haus"

#### Scenario: Easy on the last Typing word shows the summary
- **WHEN** Typing has revealed the last remaining word, "Haus", at level 2
- **AND** the user activates Easy
- **THEN** a congratulations message is shown
- **AND** the set statistics are shown

### Requirement: A new Typing word advances like Flashcard
Activating Not yet studied SHALL leave the word new and show the next remaining word. Activating Studied SHALL record the word as studied and show the next remaining word. On the last remaining word, either control SHALL show the congratulations page. That word SHALL NOT appear again in that session.

#### Scenario: Not yet studied keeps Kind new
- **WHEN** Typing has revealed the new word "Kind" and the next remaining word is "Haus"
- **AND** the user activates Not yet studied
- **THEN** "Kind" stays new
- **AND** Typing shows the cue for "Haus"

#### Scenario: Studied records Kind
- **WHEN** Typing has revealed the new word "Kind"
- **AND** the user activates Studied
- **THEN** "Kind" is recorded as studied

### Requirement: Leaving Typing before a rating keeps the level
Closing practice, or leaving Typing, before a level control SHALL keep the current level and reminder time.

#### Scenario: Close after a Typing result keeps the level
- **WHEN** Typing has revealed the answer for "Kind" at level 1
- **AND** the user activates the close control before a level control
- **THEN** the level of "Kind" stays 1

#### Scenario: Leaving Typing after a result keeps the level
- **WHEN** Typing has revealed the answer for "Kind" at level 1
- **AND** the user chooses Flashcard before a level control
- **THEN** the level of "Kind" stays 1
