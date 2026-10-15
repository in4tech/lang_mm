# Spec Delta

## MODIFIED Requirements

### Requirement: Statistics show the German A1 sample
When the loaded library has folders and the signed-in user has no stored word mark, the statistics region SHALL show "Your vocabulary statistics" as 0/0 and 0%, with no set name and no bar labels. Every level in the legend SHALL be 0%. The captions "Words learned" and "Words not yet learned" SHALL be shown, and the All control SHALL be on. An empty library SHALL NOT show this region.

#### Scenario: English statistics
- **WHEN** the vocabulary home is shown in English and the loaded library has a folder and the user has no stored word mark
- **THEN** the statistics region shows "0/0", "0%", "Words learned", and "Words not yet learned"
- **AND** it does not show a set name, "5/20", "25%", or bar labels "3" and "2"
- **AND** the legend shows "Lv.6 - Mastered" 0%, "Lv.5 - Good" 0%, "Lv.4 - Familiar" 0%, "Lv.3 - Learning" 0%, "Lv.2 - Hard" 0%, and "Lv.1 - Forgot" 0%
- **AND** the All control is on

### Requirement: Today's vocabulary lists the sample pairs
When the loaded library has folders and the user has no day list, "Today's vocabulary" SHALL show no vocabulary rows and SHALL show a "Practice" action. An empty library SHALL NOT show "Today's vocabulary".

#### Scenario: English today's vocabulary
- **WHEN** the vocabulary home is shown in English and the loaded library has a folder and the user has no day list
- **THEN** "Today's vocabulary" shows no "das Auto fahren" and no "die Frage verstehen"
- **AND** "Practice" is shown

### Requirement: Recent sets show sample progress
When the loaded library has folders and the user has no stored word mark, Recent SHALL show its title and no set cards. An empty library SHALL NOT show Recent.

#### Scenario: English recent sets
- **WHEN** the vocabulary home is shown in English and the loaded library has a folder and the user has no stored word mark
- **THEN** Recent shows no "Continue"
- **AND** Recent does not show "The process is 25% complete.", "The process is 50% complete.", or "The process is 93% complete."

### Requirement: Home actions stay on the home screen
Activating search, Library, Notification, All, a hot-search chip, Save, or a suggestion row SHALL leave the user on the vocabulary home, SHALL keep Homepage selected, and SHALL NOT add or remove folders, sets, or words. When the day list is empty, activating Practice SHALL do the same. Activating New vocab SHALL open the word editor.

#### Scenario: Practice does not leave home
- **WHEN** the user activates Practice on the vocabulary home, the loaded library has a folder, and the day list is empty
- **THEN** the vocabulary home remains
- **AND** Homepage stays selected
- **AND** the statistics still show 0/0 and 0%
- **AND** the sidebar still shows that folder

#### Scenario: New vocab opens the word editor
- **WHEN** the user activates New vocab on the vocabulary home and the loaded library has no folders
- **THEN** the word editor is shown in the center
- **AND** the header and the sidebar remain
- **AND** "Add new word" and "Enter term" are shown
- **AND** "Find your vocab..." and "Homepage" are shown
- **AND** "Hot search" and "student" are not shown

#### Scenario: New vocab does not create a set
- **WHEN** the user activates New vocab on the vocabulary home, the loaded library has no folders, and the user activates Done
- **THEN** the vocabulary home is shown
- **AND** Homepage stays selected
- **AND** the sidebar still shows no folder name and no set name
- **AND** "Hot search" and "student" are still shown
- **AND** the library still has no folders

#### Scenario: Save does not store the suggested word
- **WHEN** the user activates Save on the empty vocabulary home
- **THEN** the vocabulary home remains
- **AND** the library still has no folders
- **AND** "student" is still shown

### Requirement: Home shows the loaded library
When the loaded library has folders, the sidebar SHALL show each folder name and the set names under it. When the user has no stored word mark, statistics SHALL show 0/0 and 0% with no set name and no bar labels. When the user has no day list, Today's list SHALL have no rows. When the user has no stored word mark, Recent SHALL show no cards. The suggestion columns SHALL be absent. On a viewport narrower than 1440, the folder and set names are shown when the menu overlay is open.

#### Scenario: Saved folder and set
- **WHEN** the loaded library contains folder "My vocab" with set "German A1 vocabulary" and the vocabulary home is shown in English at a viewport at least 1440 wide, and the user has no stored word mark and no day list
- **THEN** the sidebar shows "My vocab" and "German A1 vocabulary"
- **AND** the statistics show "0/0" and "0%" and do not show a set name
- **AND** "das Auto fahren" is not shown
- **AND** Recent shows no "Continue"
- **AND** "Hot search" is not shown

#### Scenario: Narrow home shows the folder inside the menu
- **WHEN** the loaded library contains folder "My vocab" with set "German A1 vocabulary" and the vocabulary home is shown in English at a viewport narrower than 1440, and the user has no stored word mark
- **THEN** "My vocab" is not shown while the menu overlay is closed
- **AND** opening the menu shows "My vocab" and "German A1 vocabulary"
- **AND** the statistics show "0/0" and "0%"
- **AND** "Hot search" is not shown

#### Scenario: Unreadable library shows the empty home
- **WHEN** the saved vocabulary library cannot be read and the vocabulary home is shown in English
- **THEN** the sidebar shows no folder name
- **AND** "Hot search" and "student" are shown
- **AND** "0/0" is not shown

## ADDED Requirements

### Requirement: Statistics follow stored marks
When the loaded library has folders and the user has a stored mark, statistics SHALL show the easy count, the word count in scope, and the nearest whole-number percent of easy words. All on counts every loaded set. All off counts the set whose mark was stored last. Lv.6 Mastered is the easy share, Lv.4 Familiar the familiar share, Lv.2 Hard the hard share, and Lv.1 Forgot the unmarked share. Lv.5 Good and Lv.3 Learning are 0%. A level with a count above zero shows that count on its bar.

#### Scenario: Four words fill four levels
- **WHEN** the only loaded set has four words, one `easy`, one `familiar`, one `hard`, and one unmarked, and the vocabulary home is shown in English with All on
- **THEN** statistics shows "1/4" and "25%"
- **AND** the legend shows "Lv.6 - Mastered" 25%, "Lv.5 - Good" 0%, "Lv.4 - Familiar" 25%, "Lv.3 - Learning" 0%, "Lv.2 - Hard" 25%, and "Lv.1 - Forgot" 25%
- **AND** the bars for those four non-zero levels show "1"

#### Scenario: All off uses the latest set
- **WHEN** set "Animals" was marked after set "German A1 vocabulary", "Animals" has one `easy` word of two, and the user turns All off
- **THEN** statistics shows "1/2" and "50%"
- **AND** statistics shows "Animals"

### Requirement: Today's vocabulary shows the day list
When the user has a non-empty day list, Today's vocabulary SHALL show each word's term and singular and plural, in list order, two words on a row. It SHALL show Practice.

#### Scenario: Kind and Haus share the first row
- **WHEN** the day list is "Kind" with singular and plural "das, -er", then "Haus" with singular and plural "das, -er"
- **THEN** "Today's vocabulary" shows "Kind", "das, -er", and "Haus" on the first row
- **AND** "Practice" is shown

### Requirement: Practice opens the day list
When the day list has at least one word, Practice SHALL open Flashcard on the first listed word's term face. Practice SHALL NOT add or remove folders, sets, or words.

#### Scenario: Practice opens Kind
- **WHEN** the day list begins with "Kind" and the user activates Practice
- **THEN** Flashcard shows the term "Kind"
- **AND** the loaded folders and sets are unchanged

### Requirement: Recent shows studied sets
When the user has a stored mark, Recent SHALL show one card per marked set, newest mark first. Each card SHALL show the set name, the nearest whole-number easy percent, and Continue. The bar uses the Forgot color below 50%, the Learning color from 50% until 90%, and the progress green from 90%.

#### Scenario: A newer set is shown first
- **WHEN** "German A1 vocabulary" has easy progress 25% and was marked before "Animals", which has easy progress 50%
- **THEN** the first Recent card is "Animals" and the second is "German A1 vocabulary"
- **AND** "Animals" shows "The process is 50% complete." with the Learning color
- **AND** "German A1 vocabulary" shows "The process is 25% complete." with the Forgot color

#### Scenario: Ninety percent is green
- **WHEN** a marked set has easy progress 93%
- **THEN** its Recent card shows "The process is 93% complete." with the progress green

### Requirement: Continue opens the studied set
Continue on a Recent card SHALL open that set's study page. Continue SHALL NOT add or remove folders, sets, or words.

#### Scenario: Continue opens Animals
- **WHEN** the user activates Continue on the Recent card "Animals"
- **THEN** the study page shows "Animals"
- **AND** the loaded folders and sets are unchanged
