# Spec Delta

## MODIFIED Requirements

### Requirement: Today's vocabulary lists the sample pairs
When the loaded library has folders and the loaded sets contain no words, "Today's vocabulary" SHALL show no vocabulary rows and SHALL show a "Practice" action. An empty library SHALL NOT show "Today's vocabulary".

#### Scenario: English today's vocabulary
- **WHEN** the vocabulary home is shown in English and the loaded library has a folder and the loaded sets contain no words
- **THEN** "Today's vocabulary" shows no "das Auto fahren" and no "die Frage verstehen"
- **AND** "Practice" is shown

### Requirement: Home actions stay on the home screen
Activating search, Library, Notification, All, a hot-search chip, Save, or a suggestion row SHALL leave the user on the vocabulary home, SHALL keep Homepage selected, and SHALL NOT add or remove folders, sets, or words. When the practice queue is empty, activating Practice SHALL do the same. Activating New vocab SHALL open the word editor.

#### Scenario: Practice does not leave home
- **WHEN** the user activates Practice on the vocabulary home, the loaded library has a folder, the practice queue is empty, and the user has no stored level
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
When the loaded library has folders, the sidebar SHALL show each folder name and the set names under it. When the user has no stored level, statistics SHALL show 0/0 and 0% with no set name and no bar labels. When no loaded word is due and no loaded word is new, Today's list SHALL have no rows. When the user has no stored level, Recent SHALL show no cards. The suggestion columns SHALL be absent. On a viewport narrower than 1440, the folder and set names are shown when the menu overlay is open.

#### Scenario: Saved folder and set
- **WHEN** the loaded library contains folder "My vocab" with set "German A1 vocabulary" and the vocabulary home is shown in English at a viewport at least 1440 wide, and the user has no stored level and the loaded sets contain no words
- **THEN** the sidebar shows "My vocab" and "German A1 vocabulary"
- **AND** the statistics show "0/0" and "0%" and do not show a set name
- **AND** "das Auto fahren" is not shown
- **AND** Recent shows no "Continue"
- **AND** "Hot search" is not shown

#### Scenario: Narrow home shows the folder inside the menu
- **WHEN** the loaded library contains folder "My vocab" with set "German A1 vocabulary" and the vocabulary home is shown in English at a viewport narrower than 1440, and the user has no stored level
- **THEN** "My vocab" is not shown while the menu overlay is closed
- **AND** opening the menu shows "My vocab" and "German A1 vocabulary"
- **AND** the statistics show "0/0" and "0%"
- **AND** "Hot search" is not shown

#### Scenario: Unreadable library shows the empty home
- **WHEN** the saved vocabulary library cannot be read and the vocabulary home is shown in English
- **THEN** the sidebar shows no folder name
- **AND** "Hot search" and "student" are shown
- **AND** "0/0" is not shown

### Requirement: Statistics follow stored marks
When the loaded library has folders and the user has a stored level, statistics SHALL show the level 6 count, the word count in scope, and the nearest whole-number percent of level 6 words. All on counts every loaded set. All off counts the set whose level was stored last. Each legend percent is that level's count over the same word count. A new word is not counted in a level. A level with a count above zero shows that count on its bar.

#### Scenario: Four words fill four levels
- **WHEN** the only loaded set has four words, one at level 6, one at level 4, one at level 2, and one new, and the vocabulary home is shown in English with All on
- **THEN** statistics shows "1/4" and "25%"
- **AND** the legend shows "Lv.6 - Mastered" 25%, "Lv.5 - Good" 0%, "Lv.4 - Familiar" 25%, "Lv.3 - Learning" 0%, "Lv.2 - Hard" 25%, and "Lv.1 - Forgot" 0%
- **AND** the bars for those three non-zero levels show "1"

#### Scenario: Levels 1, 3, and 5 have counts
- **WHEN** the only loaded set has four words, one at level 1, one at level 3, one at level 5, and one new, and the vocabulary home is shown in English with All on
- **THEN** statistics shows "0/4" and "0%"
- **AND** the legend shows "Lv.1 - Forgot" 25%, "Lv.3 - Learning" 25%, and "Lv.5 - Good" 25%
- **AND** the bars for those three levels show "1"

#### Scenario: All off uses the latest set
- **WHEN** set "Animals" had a level stored after set "German A1 vocabulary", "Animals" has one level 6 word of two, and the user turns All off
- **THEN** statistics shows "1/2" and "50%"
- **AND** statistics shows "Animals"

### Requirement: Today's vocabulary shows the day list
When the practice queue has at least one word, Today's vocabulary SHALL show each word's term and singular and plural, in queue order, two words on a row. It SHALL show Practice.

#### Scenario: Kind and Haus share the first row
- **WHEN** the practice queue is "Kind" with singular and plural "das, -er", then "Haus" with singular and plural "das, -er"
- **THEN** "Today's vocabulary" shows "Kind", "das, -er", and "Haus" on the first row
- **AND** "Practice" is shown

#### Scenario: A future word is absent
- **WHEN** "Kind" is due and "Haus" is due later
- **THEN** "Today's vocabulary" shows "Kind"
- **AND** "Today's vocabulary" does not show "Haus"

### Requirement: Practice opens the day list
When the practice queue has at least one word, Practice SHALL open Flashcard on the first queued word's term face. Practice SHALL NOT add or remove folders, sets, or words.

#### Scenario: Practice opens Kind
- **WHEN** the practice queue begins with "Kind" and the user activates Practice
- **THEN** Flashcard shows the term "Kind"
- **AND** the loaded folders and sets are unchanged

### Requirement: Recent shows studied sets
When the user has a stored level, Recent SHALL show one card per set that has a stored level, newest stored level first. Each card SHALL show the set name, the nearest whole-number level 6 percent, and Continue. The bar uses the Forgot color below 50%, the Learning color from 50% until 90%, and the progress green from 90%.

#### Scenario: A newer set is shown first
- **WHEN** "German A1 vocabulary" has a level 6 share of 25% and was stored before "Animals", which has a level 6 share of 50%
- **THEN** the first Recent card is "Animals" and the second is "German A1 vocabulary"
- **AND** "Animals" shows "The process is 50% complete." with the Learning color
- **AND** "German A1 vocabulary" shows "The process is 25% complete." with the Forgot color

#### Scenario: Ninety percent is green
- **WHEN** a set with a stored level has a level 6 share of 93%
- **THEN** its Recent card shows "The process is 93% complete." with the progress green

### Requirement: Continue opens the studied set
Continue on a Recent card SHALL open Flashcard on the first word of that set's practice queue. When that queue is empty, Continue SHALL open that set's study page and SHALL NOT open a card. Continue SHALL NOT add or remove folders, sets, or words.

#### Scenario: Continue opens Animals
- **WHEN** the user activates Continue on the Recent card "Animals" and that set's queue begins with "Kind"
- **THEN** the study page shows "Animals"
- **AND** Flashcard shows the term "Kind"
- **AND** the loaded folders and sets are unchanged
