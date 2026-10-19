# Spec Delta

## ADDED Requirements

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
