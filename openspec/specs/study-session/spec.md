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
In Quiz and Typing, a tap SHALL NOT flip the card, and no card SHALL peek from behind. The previous and next controls SHALL change the word without a slide. Entering Flashcard from either mode SHALL show the term face.

#### Scenario: Quiz does not flip
- **WHEN** Quiz is showing the definition "child"
- **AND** the user taps the card
- **THEN** the card still shows "child"

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
In Random, Quiz, and Typing, Hard, Familiar, Easy, and the two new-word swipes SHALL be absent. Changing the word in those modes SHALL NOT change a level or a reminder time.

#### Scenario: Quiz has no rating controls
- **WHEN** Quiz is showing "Kind" at level 1
- **THEN** Hard, Familiar, and Easy are not shown
- **AND** the level of "Kind" stays 1

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
