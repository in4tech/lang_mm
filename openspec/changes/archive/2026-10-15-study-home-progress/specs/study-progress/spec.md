# Spec Delta

## Purpose

Remembers the latest mark on each studied word, and the words chosen for practice on a calendar day, in Cloud Firestore for the signed-in user.

## ADDED Requirements

### Requirement: A rating stores the latest mark
When a signed-in user activates Hard, Familiar, or Easy on a word whose set has a Firestore id, the system SHALL store one mark in Cloud Firestore project `langmm-ca0d0` for that user, that set, and that word's position. The stored value SHALL be `hard`, `familiar`, or `easy`. A later rating of the same word SHALL replace the stored value. The set document SHALL NOT gain a mark.

#### Scenario: Easy replaces hard
- **WHEN** the signed-in user marks position 0 of set `setA` as Hard and then as Easy
- **THEN** the stored mark for that user, `setA`, and position 0 is `easy`
- **AND** the set document for `setA` has no mark

#### Scenario: Familiar is stored as familiar
- **WHEN** the signed-in user activates Familiar on position 1 of set `setA`
- **THEN** the stored mark for that user, `setA`, and position 1 is `familiar`

### Requirement: A rating without an id writes nothing
When the open set has no Firestore id, or no user is signed in, Hard, Familiar, and Easy SHALL keep the mark on screen for the session and SHALL NOT write a mark to Cloud Firestore.

#### Scenario: No Firestore id
- **WHEN** the user activates Easy on a set that has no Firestore id
- **THEN** no mark is written to Cloud Firestore
- **AND** Easy is shown as selected for that word

### Requirement: Opening a set shows the stored mark
When the study page opens a set, the system SHALL select Hard, Familiar, or Easy for each word that has a stored mark. The study learned count SHALL be the number of `easy` marks in that set.

#### Scenario: A stored easy mark is selected
- **WHEN** position 0 of the open set has stored mark `easy` and the study page opens
- **THEN** Easy is selected for that word
- **AND** the study learned count counts that word

### Requirement: The device library does not store marks
Storing a mark or a day list SHALL NOT add a learned count or a today list to the on-device vocabulary library.

#### Scenario: A stored easy mark stays out of the library
- **WHEN** the signed-in user activates Easy on a word and the app starts again from the on-device library
- **THEN** the on-device library has no learned count and no today list

### Requirement: The home stores a day list
When the vocabulary home opens and the signed-in user has no day list for the device's local date, the system SHALL store one list in Cloud Firestore project `langmm-ca0d0` for that user and that date.

#### Scenario: The first open of the date stores a list
- **WHEN** the signed-in user has no list for the local date and the vocabulary home opens
- **THEN** one list for that user and that date is stored in Cloud Firestore project `langmm-ca0d0`

### Requirement: The day list holds words that are not easy
A day list SHALL contain at most eight words that are not `easy`, chosen from the user's loaded sets. Within each mark, words stay in set order. `hard` words come first, then `familiar` words, then words with no mark. Each entry SHALL store the set id and the word position.

#### Scenario: Hard is chosen before an unmarked word
- **WHEN** the user has no list for the local date, set `setA` has "Kind" at position 0 with mark `hard` and "Haus" at position 1 with no mark, and the home opens
- **THEN** the stored list for that date begins with `setA` position 0 and then `setA` position 1
- **AND** the list does not contain the word text

### Requirement: A non-empty day list stays for that date
Opening the home again on the same local date SHALL leave a non-empty day list unchanged.

#### Scenario: A later rating keeps the list
- **WHEN** the local date already has a stored list whose first word is "Kind"
- **AND** the user marks "Kind" as Easy and opens the home again that same date
- **THEN** the stored list still begins with "Kind"

### Requirement: An empty day list can be filled
When the day's list is empty and a word that is not `easy` exists, opening the home SHALL store that word in the list.

#### Scenario: An empty list is filled the same day
- **WHEN** the local date has an empty stored list and the user then has a word that is not `easy`
- **AND** the home opens again that date
- **THEN** the stored list contains that word

### Requirement: The next local date stores a new list
The next local date SHALL store its day list separately from the previous date.

#### Scenario: The next date starts over
- **WHEN** yesterday's list begins with "Kind" and the home opens on the next local date
- **THEN** the list for the new date is stored separately from yesterday's list

### Requirement: Another user cannot read the stored study
A signed-in user SHALL be able to read and write only the marks and day lists stored for that same user. The system SHALL NOT allow a different signed-in user to read or write them.

#### Scenario: A different user is refused
- **WHEN** a different signed-in user reads the mark stored for position 0 of set `setA`
- **THEN** that read is refused
