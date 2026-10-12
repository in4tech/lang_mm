# Spec Delta

## MODIFIED Requirements

### Requirement: Sidebar shows the pictured selection
In English, the sidebar SHALL show Homepage selected, Library, Notification, the "Your vocabulary set" section, and "Set of words". It SHALL show each loaded folder name and the set names under that folder. An empty library SHALL show no folder name and no set name.

#### Scenario: English sidebar
- **WHEN** the vocabulary home is shown in English and the loaded library has no folders
- **THEN** Homepage is the selected navigation item
- **AND** the sidebar shows Library, Notification, "Your vocabulary set", and "Set of words"
- **AND** the sidebar shows no folder name and no set name

### Requirement: Statistics show the German A1 sample
When the loaded library has folders, the statistics region SHALL show "Your vocabulary statistics" as 0/0 and 0%, with no set name and no bar labels. Every level in the legend SHALL be 0%. The captions "Words learned" and "Words not yet learned" SHALL be shown, and the All control SHALL be on. An empty library SHALL NOT show this region.

#### Scenario: English statistics
- **WHEN** the vocabulary home is shown in English and the loaded library has a folder
- **THEN** the statistics region shows "0/0", "0%", "Words learned", and "Words not yet learned"
- **AND** it does not show a set name, "5/20", "25%", or bar labels "3" and "2"
- **AND** the legend shows "Lv.6 - Mastered" 0%, "Lv.5 - Good" 0%, "Lv.4 - Familiar" 0%, "Lv.3 - Learning" 0%, "Lv.2 - Hard" 0%, and "Lv.1 - Forgot" 0%
- **AND** the All control is on

### Requirement: Today's vocabulary lists the sample pairs
When the loaded library has folders, "Today's vocabulary" SHALL show no vocabulary rows and SHALL show a "Practice" action. An empty library SHALL NOT show "Today's vocabulary".

#### Scenario: English today's vocabulary
- **WHEN** the vocabulary home is shown in English and the loaded library has a folder
- **THEN** "Today's vocabulary" shows no "das Auto fahren" and no "die Frage verstehen"
- **AND** "Practice" is shown

### Requirement: Recent sets show sample progress
When the loaded library has folders, Recent SHALL show its title and no set cards. An empty library SHALL NOT show Recent.

#### Scenario: English recent sets
- **WHEN** the vocabulary home is shown in English and the loaded library has a folder
- **THEN** Recent shows no "Continue"
- **AND** Recent does not show "The process is 25% complete.", "The process is 50% complete.", or "The process is 93% complete."

### Requirement: Home actions stay on the home screen
Activating search, New vocab, Practice, Library, Notification, All, a hot-search chip, Save, or a suggestion row SHALL leave the user on the vocabulary home, SHALL keep Homepage selected, and SHALL NOT add or remove folders, sets, or words.

#### Scenario: Practice does not leave home
- **WHEN** the user activates Practice on the vocabulary home and the loaded library has a folder
- **THEN** the vocabulary home remains
- **AND** Homepage stays selected
- **AND** the statistics still show 0/0 and 0%
- **AND** the sidebar still shows that folder

#### Scenario: New vocab does not create a set
- **WHEN** the user activates New vocab on the vocabulary home and the loaded library has no folders
- **THEN** the vocabulary home remains
- **AND** the sidebar still shows no folder name and no set name
- **AND** "Hot search" and "student" are still shown

#### Scenario: Save does not store the suggested word
- **WHEN** the user activates Save on the empty vocabulary home
- **THEN** the vocabulary home remains
- **AND** the library still has no folders
- **AND** "student" is still shown

## ADDED Requirements

### Requirement: Home shows the loaded library
When the loaded library has folders, the sidebar SHALL show each folder name and the set names under it. Statistics SHALL show 0/0 and 0% with no set name and no bar labels. Today's list SHALL have no rows. Recent SHALL show no cards. The suggestion columns SHALL be absent.

#### Scenario: Saved folder and set
- **WHEN** the loaded library contains folder "My vocab" with set "German A1 vocabulary" and the vocabulary home is shown in English
- **THEN** the sidebar shows "My vocab" and "German A1 vocabulary"
- **AND** the statistics show "0/0" and "0%" and do not show a set name
- **AND** "das Auto fahren" is not shown
- **AND** Recent shows no "Continue"
- **AND** "Hot search" is not shown

#### Scenario: Unreadable library shows the empty home
- **WHEN** the saved vocabulary library cannot be read and the vocabulary home is shown in English
- **THEN** the sidebar shows no folder name
- **AND** "Hot search" and "student" are shown
- **AND** "0/0" is not shown

### Requirement: Empty home shows the suggestion columns
When the loaded library has no folders, the main area SHALL show a left suggestion column and a right suggestion column. It SHALL NOT show "Your vocabulary statistics", "Today's vocabulary", Recent, "0/0", or "Practice".

#### Scenario: English empty home hides the dashboard
- **WHEN** the vocabulary home is shown in English and the loaded library has no folders
- **THEN** "Hot search", "Suggested sets", "student", "Save", and "Suggested practice" are shown
- **AND** "Your vocabulary statistics", "Today's vocabulary", "Recent", "0/0", and "Practice" are not shown

### Requirement: Hot search lists the fixed chips
The empty home SHALL show these chips in order: love, study, work, student, counterrevolutionaries, synchronization, internationalization.

#### Scenario: English hot-search chips
- **WHEN** the empty vocabulary home is shown in English
- **THEN** those chips are shown in that order

### Requirement: Suggested sets list the fixed rows
Under "Suggested sets", the empty home SHALL show these rows in order: Love vocabulary, Study vocabulary, Work vocabulary, Student vocabulary, Daily vocabulary.

#### Scenario: English suggested sets
- **WHEN** the empty vocabulary home is shown in English
- **THEN** those five rows are shown in that order

### Requirement: Suggested word shows student
The empty home SHALL show student, "UK /ˈstjuːdnt/", "US /ˈstuːdnt/", "a person who is studying at a university or college", 80, and Save.

#### Scenario: English suggested word
- **WHEN** the empty vocabulary home is shown in English
- **THEN** student, "/ˈstjuːdnt/", "/ˈstuːdnt/", that gloss, 80, and Save are shown

### Requirement: Suggested practice lists the fixed rows
Under "Suggested practice", the empty home SHALL show these rows in order: Practice "love", Practice "study", Practice "work", Practice "student", Practice "synchronization".

#### Scenario: English suggested practice
- **WHEN** the empty vocabulary home is shown in English
- **THEN** those five rows are shown in that order

## REMOVED Requirements

### Requirement: Sample content is not translated
**Reason**: The vocabulary home no longer shows the German A1 sample. Folder and set names are stored library data, and suggestion template words stay English when the language changes.
**Migration**: Assert that changing language keeps the loaded library and the English template words, and does not show "German A1 vocabulary" or "das Auto fahren" unless those names were saved.
