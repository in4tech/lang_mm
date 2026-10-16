# study-progress Specification

## Purpose

Remembers the latest mark on each studied word, and the words chosen for practice on a calendar day, in Cloud Firestore for the signed-in user.

## Requirements

### Requirement: A rating without an id writes nothing
When the open set has no Firestore id, or no user is signed in, a rating SHALL keep the level on screen for the session and SHALL NOT write a level or a reminder time to Cloud Firestore.

#### Scenario: No Firestore id
- **WHEN** the user activates Easy on a set that has no Firestore id
- **THEN** no level is written to Cloud Firestore
- **AND** the word's level is shown for that session

### Requirement: The device library does not store marks
Storing a level or a reminder time SHALL NOT add a learned count or a today list to the on-device vocabulary library.

#### Scenario: A stored easy mark stays out of the library
- **WHEN** the signed-in user activates Easy on a word and the app starts again from the on-device library
- **THEN** the on-device library has no learned count and no today list

### Requirement: Another user cannot read the stored study
A signed-in user SHALL be able to read and write only the levels and reminder times stored for that same user. The system SHALL NOT allow a different signed-in user to read or write them.

#### Scenario: A different user is refused
- **WHEN** a different signed-in user reads the level stored for position 0 of set `setA`
- **THEN** that read is refused

### Requirement: A rating stores the level and the reminder
When a signed-in user rates a word whose set has a Firestore id, the system SHALL store that word's level and reminder time in Cloud Firestore project `langmm-ca0d0` for that user, that set, and that word's position. A later rating of the same word SHALL replace both. The set document SHALL NOT gain a level or a reminder time.

#### Scenario: A studied word stays off the set document
- **WHEN** the signed-in user studies position 0 of set `setA`
- **THEN** the stored level for that user, `setA`, and position 0 is 1
- **AND** a reminder time is stored for that word
- **AND** the set document for `setA` has no level

### Requirement: Easy raises the level by one
Easy on a word at level 1, 2, 3, 4, or 5 SHALL store the next level. The reminder time SHALL be the rating time plus the delay of the level just stored.

#### Scenario: Level 1 becomes level 2
- **WHEN** position 0 is level 1 and the user activates Easy
- **THEN** the stored level is 2
- **AND** the reminder time is 1 day after the rating

#### Scenario: Level 2 becomes level 3
- **WHEN** position 0 is level 2 and the user activates Easy
- **THEN** the stored level is 3
- **AND** the reminder time is 3 days after the rating

#### Scenario: Level 4 becomes level 5
- **WHEN** position 0 is level 4 and the user activates Easy
- **THEN** the stored level is 5
- **AND** the reminder time is 15 days after the rating

### Requirement: Familiar keeps the level
Familiar SHALL store the same level. The reminder time SHALL be the rating time plus the delay of that level.

#### Scenario: Level 4 stays level 4
- **WHEN** position 0 is level 4 and the user activates Familiar
- **THEN** the stored level is 4
- **AND** the reminder time is 7 days after the rating

### Requirement: Hard returns to level 1
Hard SHALL store level 1, whatever the previous level was. The reminder time SHALL be 1 hour after the rating.

#### Scenario: Level 4 falls to level 1
- **WHEN** position 0 is level 4 and the user activates Hard
- **THEN** the stored level is 1
- **AND** the reminder time is 1 hour after the rating

### Requirement: Studying a new word sets level 1
The studied swipe SHALL store level 1. The reminder time SHALL be 1 hour after that swipe.

#### Scenario: A new word becomes level 1
- **WHEN** position 0 has no level and the user uses the studied swipe
- **THEN** the stored level is 1
- **AND** the reminder time is 1 hour after the swipe

### Requirement: Skipping a new word stores nothing
The not-yet-studied swipe SHALL NOT store a level or a reminder time for that word.

#### Scenario: A skipped word stays new
- **WHEN** position 0 has no level and the user uses the not-yet-studied swipe
- **THEN** no level is stored for position 0

### Requirement: Level 6 stays at 6
Easy on level 6 SHALL store level 6. The reminder time SHALL be 30 days after the rating.

#### Scenario: Easy on the top level
- **WHEN** position 0 is level 6 and the user activates Easy
- **THEN** the stored level is 6
- **AND** the reminder time is 30 days after the rating

### Requirement: The practice queue lists due words, then new words
For a scope of loaded sets, the practice queue SHALL list every word whose reminder time is at or before the current time, soonest reminder first, and then at most eight words that have no level. Within one reminder time, and among new words, words stay in loaded-set order and then word index. A word due later SHALL be omitted. The queue SHALL NOT be stored.

#### Scenario: A due word precedes a new word
- **WHEN** set `setA` position 0 is level 2 and due, and position 1 has no level
- **THEN** the queue for `setA` begins with position 0 and then position 1

#### Scenario: A future word is omitted
- **WHEN** position 0 is level 2 and its reminder time is after the current time, and position 1 has no level
- **THEN** the queue contains position 1
- **AND** the queue does not contain position 0

#### Scenario: New words stop at eight
- **WHEN** a set has ten words with no level and no word is due
- **THEN** that set's queue contains eight words

#### Scenario: The home queue crosses sets
- **WHEN** set `setA` has no due word and set `setB` position 0 is due
- **THEN** the queue for both sets begins with `setB` position 0

### Requirement: A stored mark is read as a level
A stored `hard` mark SHALL be read as level 2, `familiar` as level 4, and `easy` as level 6. Each of those words SHALL be due at the time it is read. A word with no mark and no level SHALL stay new.

#### Scenario: Easy is read as level 6
- **WHEN** position 0 has stored mark `easy` and no level
- **THEN** the word is read as level 6
- **AND** the word is due at the time it is read

### Requirement: Opening a set shows the stored level
When the study page opens a set, the system SHALL use the stored level of each word that has one. The study learned count SHALL be the number of level 6 words in that set.

#### Scenario: A stored level 6 is counted
- **WHEN** position 0 of the open set is level 6 and the study page opens
- **THEN** the study learned count counts that word
