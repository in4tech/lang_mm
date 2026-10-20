# Spec Delta

## MODIFIED Requirements

### Requirement: Quiz and Typing stay flat
In Typing, a tap SHALL NOT flip the card, and no card SHALL peek from behind. The previous and next controls SHALL change the word without a slide. In Quiz, a tap SHALL NOT flip the card, and no card SHALL peek from behind. Quiz SHALL NOT show the previous and next controls. Entering Flashcard from either mode SHALL show the term face.

#### Scenario: Typing does not flip
- **WHEN** Typing is showing the term "Kind"
- **AND** the user taps the card
- **THEN** the card still shows "Kind"

#### Scenario: Quiz does not flip
- **WHEN** Quiz is showing the term "Kind"
- **AND** the user taps the term
- **THEN** the card still shows "Kind"

#### Scenario: Quiz has no previous or next control
- **WHEN** Quiz is showing "Kind"
- **THEN** the previous and next controls are not shown

#### Scenario: Flashcard opens on the term from Quiz
- **WHEN** the user enters Flashcard from Quiz on "Kind"
- **THEN** the card shows the term face of "Kind"

### Requirement: Other modes leave the level unchanged
In Random and Typing, Hard, Familiar, Easy, and the two new-word controls SHALL be absent. Changing the word in those modes SHALL NOT change a level or a reminder time. Showing Quiz before a result SHALL NOT show those controls and SHALL NOT itself change a level or a reminder time.

#### Scenario: Quiz has no rating controls
- **WHEN** Quiz is showing "Kind" at level 1
- **THEN** Hard, Familiar, and Easy are not shown
- **AND** the level of "Kind" stays 1

#### Scenario: Typing has no rating controls
- **WHEN** Typing is showing "Kind" at level 1
- **THEN** Hard, Familiar, and Easy are not shown
- **AND** the level of "Kind" stays 1

## ADDED Requirements

### Requirement: Quiz asks for the current term
Quiz SHALL show the Term label, the speak control, the current word's term, and "Choose an answer".

#### Scenario: Kind is the prompt
- **WHEN** Quiz is showing the word whose term is "Kind" and whose definition is "child"
- **THEN** the card shows the Term label, "Kind", and "Choose an answer"
- **AND** the card does not show "child" as the prompt

### Requirement: Quiz choices come from the set
Quiz SHALL show the current word and up to three other words from the same set as options. When fewer than three other words exist, Quiz SHALL show only the words that exist.

#### Scenario: Four words produce four options
- **WHEN** the set contains "Kind", "Haus", "Auto", and "Baum" and Quiz is showing "Kind"
- **THEN** Quiz shows four options
- **AND** those options are the four words

#### Scenario: Two words produce two options
- **WHEN** the set contains "Kind" and "Haus" and Quiz is showing "Kind"
- **THEN** Quiz shows two options
- **AND** those options are "Kind" and "Haus"

### Requirement: A Quiz option shows the meaning
Each option SHALL show that word's IPA, stored type, definition, and sentence, and SHALL omit any of those that are empty.

#### Scenario: Kind shows its meaning
- **WHEN** an option is the word whose IPA is "kɪnt", type is "noun", definition is "child", and sentence is "Das Kind"
- **THEN** the option shows "kɪnt", "noun", "child", and "Das Kind"

#### Scenario: An empty IPA is omitted
- **WHEN** an option's IPA is empty and its definition is "child"
- **THEN** the option shows "child"
- **AND** the option does not show an IPA line

### Requirement: Quiz options start numbered
Before a result, each option SHALL show a number, starting at 1, and Don't know SHALL be available.

#### Scenario: Two options are numbered
- **WHEN** Quiz is showing "Kind" with one other word in the set and no result yet
- **THEN** the options show 1 and 2
- **AND** Don't know is shown

### Requirement: A correct Quiz choice marks that option
Choosing the current word's option SHALL give that option a solid green border and a check, dim the other options while they keep their numbers, and play a short high tone. The card SHALL replace the prompt with one praise line and icon for that answer. Consecutive correct answers SHALL raise the praise intensity from the lowest phrase up through the highest, then stay on the highest. A wrong choice or Don't know SHALL reset that streak. The praise icon color SHALL differ from the praise text color.

#### Scenario: Kind is chosen correctly
- **WHEN** Quiz is asking for "Kind" and the user chooses the "Kind" option
- **THEN** that option shows a solid green border and a check
- **AND** the other options stay numbered and dim
- **AND** a short high tone plays
- **AND** the prompt is replaced by one praise line with an icon whose color differs from the text

#### Scenario: A second correct answer raises praise
- **WHEN** the learner answers two Quiz words correctly in a row
- **THEN** the second praise is a higher intensity line than the first

### Requirement: A wrong Quiz choice reveals the answer
Choosing another word SHALL show "No sweat, you're still learning!", give the current word a dashed green border and a check, give the chosen option a solid orange border and an X, dim every other option while it keeps its number, and play a short low tone.

#### Scenario: Haus is chosen for Kind
- **WHEN** Quiz is asking for "Kind" and the user chooses "Haus"
- **THEN** the card shows "No sweat, you're still learning!"
- **AND** the "Kind" option shows a dashed green border and a check
- **AND** the "Haus" option shows a solid orange border and an X
- **AND** every other option stays numbered and dims
- **AND** a short low tone plays

### Requirement: Don't know reveals the answer
Don't know SHALL show "Give this one a try later!", give the current word a dashed green border and a check, dim every other option while it keeps its number, show no X, and play no tone.

#### Scenario: Don't know on Kind
- **WHEN** Quiz is asking for "Kind" and the user activates Don't know
- **THEN** the card shows "Give this one a try later!"
- **AND** the "Kind" option shows a dashed green border and a check
- **AND** every other option stays numbered and dims
- **AND** no option shows an X
- **AND** no tone plays

### Requirement: A Quiz result locks the question
After a choice or Don't know, another choice SHALL do nothing, Don't know SHALL dim and SHALL NOT accept activation, and the level SHALL stay unchanged until a level control is activated.

#### Scenario: A second choice does nothing
- **WHEN** the user has chosen an option for "Kind" at level 4
- **AND** the user chooses another option
- **THEN** the result stays as it was
- **AND** the level of "Kind" stays 4

#### Scenario: Don't know dims after a choice
- **WHEN** the user has chosen an option for "Kind"
- **THEN** Don't know is dimmed
- **AND** Don't know does not accept activation

### Requirement: Quiz shows level controls after the result
After the result has settled, a word at level 1 through 6 SHALL show Hard, Familiar, and Easy, rising into place one after another. A control SHALL ignore activation until it has arrived. Before a result, those controls SHALL be absent.

#### Scenario: Easy appears after the answer
- **WHEN** Quiz reveals the answer for "Kind" at level 1
- **THEN** Hard, Familiar, and Easy rise into place
- **AND** they were absent before the answer

#### Scenario: A press during the rise does nothing
- **WHEN** Hard is still rising after the answer for "Kind" at level 4
- **AND** the user activates Hard
- **THEN** the level of "Kind" stays 4

### Requirement: A new Quiz word shows the two study controls
After the result has settled, a new word SHALL show Not yet studied and Studied, rising into place one after another, and SHALL NOT show Hard, Familiar, or Easy.

#### Scenario: A new Kind hides the three ratings
- **WHEN** Quiz reveals the answer for the new word "Kind"
- **THEN** Not yet studied and Studied are shown
- **AND** Hard, Familiar, and Easy are not shown

### Requirement: Disabled animations show the Quiz result at once
When animations are disabled, the result and its level controls SHALL appear at once and SHALL accept activation immediately. A correct choice SHALL still play the high tone, and a wrong choice SHALL still play the low tone.

#### Scenario: Easy is ready at once
- **WHEN** animations are disabled and the user chooses the correct option for "Kind" at level 1
- **THEN** Hard, Familiar, and Easy are shown
- **AND** the high tone plays

### Requirement: A Quiz rating advances like Flashcard
Activating Hard, Familiar, or Easy after a Quiz result SHALL record that rating and show the next remaining word's term. On the last remaining word, the same control SHALL record the rating and show the congratulations page. The rated word SHALL NOT appear again in that session.

#### Scenario: Easy moves from Kind to Haus
- **WHEN** Quiz has revealed "Kind" at level 1 and the next remaining word is "Haus"
- **AND** the user activates Easy
- **THEN** the stored level of "Kind" is 2
- **AND** Quiz shows the term "Haus"

#### Scenario: Hard returns Kind to level 1
- **WHEN** Quiz has revealed "Kind" at level 4
- **AND** the user activates Hard
- **THEN** the stored level of "Kind" is 1

#### Scenario: Familiar keeps the level
- **WHEN** Quiz has revealed "Kind" at level 4
- **AND** the user activates Familiar
- **THEN** the stored level of "Kind" stays 4

#### Scenario: Easy on the last word shows the summary
- **WHEN** Quiz has revealed the last remaining word, "Haus", at level 2
- **AND** the user activates Easy
- **THEN** a congratulations message is shown
- **AND** "Haus" is not asked again

### Requirement: A new Quiz word advances like Flashcard
Activating Not yet studied SHALL leave the word new and show the next remaining word. Activating Studied SHALL record the word as studied and show the next remaining word. On the last remaining word, either control SHALL show the congratulations page. That word SHALL NOT appear again in that session.

#### Scenario: Not yet studied keeps Kind new
- **WHEN** Quiz has revealed the new word "Kind" and the next remaining word is "Haus"
- **AND** the user activates Not yet studied
- **THEN** "Kind" stays new
- **AND** Quiz shows the term "Haus"

#### Scenario: Studied records Kind
- **WHEN** Quiz has revealed the new word "Kind"
- **AND** the user activates Studied
- **THEN** "Kind" is stored at level 1

### Requirement: Leaving Quiz before a rating keeps the level
Closing practice, or leaving Quiz, before a level control SHALL keep the current level and reminder time.

#### Scenario: Close during the result
- **WHEN** Quiz has revealed the answer for "Kind" at level 1
- **AND** the user closes practice
- **THEN** the level of "Kind" stays 1
- **AND** the set page is shown

#### Scenario: Flashcard during the result
- **WHEN** Quiz has revealed the answer for "Kind" at level 1
- **AND** the user chooses Flashcard
- **THEN** the level of "Kind" stays 1
- **AND** Flashcard shows the term face of "Kind"
