# study-session Specification

## Purpose

Lets a learner move through a set on the study page, with Random mixing Flashcard, Quiz, and Typing per word, and Flashcard hiding the meaning until a tap.

## Requirements

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
In Flashcard, when the current word's level is 1 through 6, Hard, Familiar, and Easy SHALL be shown. Activating one SHALL record that rating and show the next remaining word's term face. On the last remaining word, the same control SHALL record the rating and show a congratulations page with that session's counts and the set statistics. A new word SHALL NOT show Hard, Familiar, or Easy. The practice screen SHALL NOT show a Track progress control.

#### Scenario: Easy moves from Kind to Haus
- **WHEN** Flashcard is showing "Kind" at level 1 and the next remaining word's term is "Haus"
- **AND** the user activates Easy
- **THEN** the card shows "Haus"
- **AND** the card does not show the definition of "Haus"

#### Scenario: Easy on the last word shows the summary
- **WHEN** Flashcard is showing the meaning face of the last remaining word, "Haus", at level 2
- **AND** the user activates Easy
- **THEN** a congratulations message is shown
- **AND** the set statistics are shown
- **AND** the card for "Haus" is not shown

#### Scenario: A new word hides the three ratings
- **WHEN** Flashcard is showing the new word "Kind"
- **THEN** Hard, Familiar, and Easy are not shown

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

### Requirement: Today practice reviews words due today
Today practice on a set SHALL open Flashcard on the first word whose study time is due now, in set order. A word with no level, and a word whose study time is still ahead, SHALL stay out of that session. When no word is due now, Today practice SHALL leave the set page showing and SHALL NOT open a card.

#### Scenario: A new word stays out of Today practice
- **WHEN** "Kind" has no level and the user activates Today practice
- **THEN** the set page remains
- **AND** no flashcard is shown

#### Scenario: Today practice opens a due word
- **WHEN** "Kind" is due now and the user activates Today practice
- **THEN** Flashcard shows the term "Kind"

#### Scenario: An empty queue stays on the set page
- **WHEN** no word is due now and the user activates Today practice
- **THEN** the set page remains
- **AND** no flashcard is shown

### Requirement: Learn new vocab reviews new words
Learn new vocab SHALL open the same Flashcard practice as Today practice, on words that have no level, in set order. A word that is due now SHALL stay out of that session. When the set has no new word, Learn new vocab SHALL leave the set page showing and SHALL NOT open a card.

#### Scenario: Learn new vocab opens Kind
- **WHEN** "Kind" has no level and the user activates Learn new vocab
- **THEN** Flashcard shows the term "Kind"

#### Scenario: A due word stays out of Learn new vocab
- **WHEN** "Kind" is due now and the user activates Learn new vocab
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

### Requirement: A new word has two swipes
In Flashcard, a new word SHALL offer a left swipe labeled as not yet studied and a right swipe labeled as studied. The left swipe SHALL leave the word new and show the next remaining word. The right swipe SHALL record the word as studied and show the next remaining word. On the last remaining word, either swipe SHALL show the congratulations page. A word swiped in the session SHALL NOT appear again in that session.

#### Scenario: A left swipe keeps Kind new
- **WHEN** Flashcard is showing the new word "Kind" and the next remaining word is "Haus"
- **AND** the user swipes left
- **THEN** "Kind" stays new
- **AND** the card shows "Haus"
- **AND** "Kind" is not shown again in that session

#### Scenario: A right swipe studies Kind
- **WHEN** Flashcard is showing the new word "Kind"
- **AND** the user swipes right
- **THEN** "Kind" is recorded as studied

### Requirement: Space flips the flashcard
In Flashcard, Space SHALL flip the card the same way a tap does.

#### Scenario: Space reveals the meaning
- **WHEN** Flashcard is showing the term face for "Kind"
- **AND** the user presses Space
- **THEN** the card shows the meaning face of "Kind"

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

### Requirement: Easy and Hard turn the card aside
While practice is open in Flashcard, Easy SHALL turn the current card on a vertical axis as the card moves right, and Hard SHALL turn it the same way as the card moves left. The face showing when the control is pressed SHALL stay on the leaving card, and the turn SHALL NOT reveal the other face.

#### Scenario: Easy leaves toward the right
- **WHEN** Flashcard practice is showing the term face for "Kind" and the user activates Easy
- **THEN** the card turns on a vertical axis as it moves right
- **AND** the term face stays on that card

#### Scenario: Hard leaves toward the left from the meaning face
- **WHEN** Flashcard practice is showing the meaning face for "Kind" and the user activates Hard
- **THEN** the card turns on a vertical axis as it moves left
- **AND** the meaning face stays on that card

### Requirement: Familiar slides the card up
While practice is open in Flashcard, Familiar SHALL slide the current card straight up and SHALL NOT turn it.

#### Scenario: Familiar leaves upward
- **WHEN** Flashcard practice is showing "Kind" and the user activates Familiar
- **THEN** the card slides straight up
- **AND** the card does not turn

### Requirement: The next term waits under the leaving card
While practice is open in Flashcard and another word remains, the next word's term face SHALL sit underneath the leaving card. When the motion ends, that term face SHALL be the card shown.

#### Scenario: Haus waits under Kind
- **WHEN** Flashcard practice is showing "Kind" and the next remaining word's term is "Haus"
- **AND** the user activates Easy
- **THEN** the term face of "Haus" sits underneath the leaving card
- **AND** that face does not show the definition of "Haus"

### Requirement: The last card leaves before the summary
While practice is open in Flashcard, a rating on the last remaining word SHALL leave the current card and SHALL show the congratulations page when the motion ends.

#### Scenario: Easy on the last word leaves before the summary
- **WHEN** Flashcard practice is showing the last remaining word, "Haus"
- **AND** the user activates Easy
- **THEN** the card for "Haus" leaves
- **AND** the congratulations page is shown when that motion ends

### Requirement: A second rating during the motion does nothing
While the card is leaving, a further Hard, Familiar, or Easy press SHALL NOT record another rating and SHALL NOT change which word comes next.

#### Scenario: A second Easy is ignored
- **WHEN** the user has activated Easy and the card is still leaving
- **AND** the user activates Easy again
- **THEN** only the first rating is recorded

### Requirement: Closing practice keeps the rating
While the card is leaving, closing practice SHALL keep the rating already recorded and SHALL show the set page.

#### Scenario: Close during the Easy motion
- **WHEN** the user has activated Easy and the card is still leaving
- **AND** the user closes practice
- **THEN** the rating is recorded
- **AND** the set page is shown

### Requirement: Disabled animations show the next term at once
When animations are disabled, activating Hard, Familiar, or Easy during Flashcard practice SHALL show the next remaining word's term face, or the congratulations page on the last word, at once.

#### Scenario: Easy shows Haus at once
- **WHEN** animations are disabled, Flashcard practice is showing "Kind", and the next remaining word's term is "Haus"
- **AND** the user activates Easy
- **THEN** the card shows "Haus"
