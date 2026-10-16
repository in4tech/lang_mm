# home-screen Specification

## Purpose

Shows the vocabulary dashboard as the web home, with the sample sets, statistics, and today's words from the desktop design. Other platforms keep the counter.

## Requirements

### Requirement: Web opens on the vocabulary home
On web, the app SHALL open on the vocabulary home. The counter and its increment control SHALL be absent.

#### Scenario: Fresh web launch
- **WHEN** the app opens on web
- **THEN** the vocabulary home is shown
- **AND** no counter value and no increment control are shown

### Requirement: Other platforms keep the counter
On any platform other than web, the app SHALL open on the counter home. The vocabulary dashboard SHALL be absent.

#### Scenario: Fresh non-web launch
- **WHEN** the app opens on a platform other than web
- **THEN** the counter home is shown
- **AND** the vocabulary dashboard is not shown

### Requirement: Header shows search, new vocab, and avatar
In English, the vocabulary home header SHALL show a menu control, the lang mark, a search field whose placeholder is "Find your vocab...", a "New vocab" button, and an avatar.

#### Scenario: English header
- **WHEN** the vocabulary home is shown in English
- **THEN** the header shows the lang mark, "Find your vocab...", "New vocab", and an avatar

### Requirement: Sidebar shows the pictured selection
In English, the sidebar SHALL show Homepage selected, Library, Notification, the "Your vocabulary set" section, and "Set of words". It SHALL show each loaded folder name and the set names under that folder. An empty library SHALL show no folder name and no set name. On a viewport at least 1440 wide, that sidebar is beside the main area. On a narrower viewport, those items are shown only while the menu overlay is open.

#### Scenario: English sidebar
- **WHEN** the vocabulary home is shown in English at a viewport at least 1440 wide and the loaded library has no folders
- **THEN** Homepage is the selected navigation item
- **AND** the sidebar shows Library, Notification, "Your vocabulary set", and "Set of words"
- **AND** the sidebar shows no folder name and no set name

#### Scenario: Narrow sidebar shows the same items when open
- **WHEN** the vocabulary home is shown in English at a viewport narrower than 1440, the loaded library has no folders, and the menu overlay is open
- **THEN** Homepage is the selected navigation item
- **AND** the sidebar shows Library, Notification, "Your vocabulary set", and "Set of words"
- **AND** the sidebar shows no folder name and no set name

### Requirement: Statistics show the German A1 sample
When the loaded library has folders and the signed-in user has no stored word mark, the statistics region SHALL show "Your vocabulary statistics" as 0/0 and 0%, with no set name and no bar labels. Every level in the legend SHALL be 0%. The captions "Words learned" and "Words not yet learned" SHALL be shown, and the All control SHALL be on. An empty library SHALL NOT show this region.

#### Scenario: English statistics
- **WHEN** the vocabulary home is shown in English and the loaded library has a folder and the user has no stored word mark
- **THEN** the statistics region shows "0/0", "0%", "Words learned", and "Words not yet learned"
- **AND** it does not show a set name, "5/20", "25%", or bar labels "3" and "2"
- **AND** the legend shows "Lv.6 - Mastered" 0%, "Lv.5 - Good" 0%, "Lv.4 - Familiar" 0%, "Lv.3 - Learning" 0%, "Lv.2 - Hard" 0%, and "Lv.1 - Forgot" 0%
- **AND** the All control is on

### Requirement: Today's vocabulary lists the sample pairs
When the loaded library has folders and the loaded sets contain no words, "Today's vocabulary" SHALL show no vocabulary rows and SHALL show a "Practice" action. An empty library SHALL NOT show "Today's vocabulary".

#### Scenario: English today's vocabulary
- **WHEN** the vocabulary home is shown in English and the loaded library has a folder and the loaded sets contain no words
- **THEN** "Today's vocabulary" shows no "das Auto fahren" and no "die Frage verstehen"
- **AND** "Practice" is shown

### Requirement: Recent sets show sample progress
When the loaded library has folders and the user has no stored word mark, Recent SHALL show its title and no set cards. An empty library SHALL NOT show Recent.

#### Scenario: English recent sets
- **WHEN** the vocabulary home is shown in English and the loaded library has a folder and the user has no stored word mark
- **THEN** Recent shows no "Continue"
- **AND** Recent does not show "The process is 25% complete.", "The process is 50% complete.", or "The process is 93% complete."

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

### Requirement: Avatar opens the language component
Activating the avatar SHALL open the language component on the vocabulary home.

#### Scenario: Open languages from the avatar
- **WHEN** the user activates the avatar
- **THEN** the language component is open
- **AND** the vocabulary home is still the current screen

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

### Requirement: Empty home shows the suggestion columns
When the loaded library has no folders, the main area SHALL show a left suggestion column and a right suggestion column. It SHALL NOT show "Your vocabulary statistics", "Today's vocabulary", Recent, "0/0", or "Practice". On a viewport at least 1440 wide, the columns sit side by side. On a narrower viewport, the left column's content is above the right column's content.

#### Scenario: English empty home hides the dashboard
- **WHEN** the vocabulary home is shown in English and the loaded library has no folders
- **THEN** "Hot search", "Suggested sets", "student", "Save", and "Suggested practice" are shown
- **AND** "Your vocabulary statistics", "Today's vocabulary", "Recent", "0/0", and "Practice" are not shown

#### Scenario: Wide empty home places the columns side by side
- **WHEN** the empty vocabulary home is shown in English at a viewport at least 1440 wide
- **THEN** "Hot search" and "Suggested practice" are side by side

#### Scenario: Narrow empty home stacks the columns
- **WHEN** the empty vocabulary home is shown in English at a viewport narrower than 1440
- **THEN** "Hot search" is above "Suggested sets"
- **AND** "Suggested sets" is above "Suggested practice"

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

### Requirement: Wide home stays at the design width
When the vocabulary home viewport is at least 1440 wide, the header SHALL fill that width and the sidebar SHALL sit on the left. The main content SHALL keep the width it has in the 1440 design, centered on the viewport. Collapsing or opening the sidebar SHALL NOT change that width or that position, and the sidebar SHALL keep its open width. That content SHALL NOT scale to the viewport. Width beyond the content SHALL be empty on its left and right, with no advertisement.

#### Scenario: Window wider than the design
- **WHEN** the vocabulary home is shown in a viewport wider than 1440
- **THEN** the header fills the viewport width
- **AND** the sidebar's left edge is the viewport's left edge
- **AND** the main content is centered on the viewport
- **AND** neither side of that content shows an advertisement

#### Scenario: Window exactly the design width
- **WHEN** the vocabulary home is shown in a viewport 1440 wide
- **THEN** the header fills the viewport width
- **AND** the sidebar sits on the left
- **AND** the main content is centered on the viewport

#### Scenario: Closing the sidebar keeps the content width
- **WHEN** the vocabulary home is shown at a viewport at least 1440 wide and the user collapses the sidebar
- **THEN** the main content width is unchanged
- **AND** the main content stays in the same horizontal position

### Requirement: Wide header keeps one row
When the vocabulary home viewport is at least 1440 wide, the menu, the lang mark, the search field, New vocab, and the avatar SHALL sit on one header row.

#### Scenario: English wide header is one row
- **WHEN** the vocabulary home is shown in English at a viewport at least 1440 wide
- **THEN** "Find your vocab...", "New vocab", and the avatar are on the same row as the lang mark

### Requirement: Wide dashboard keeps statistics beside today
When the vocabulary home viewport is at least 1440 wide and the loaded library has folders, statistics and Today's vocabulary SHALL sit side by side, with Recent below both.

#### Scenario: English wide dashboard
- **WHEN** the vocabulary home is shown in English at a viewport at least 1440 wide and the loaded library has a folder
- **THEN** "Your vocabulary statistics" and "Today's vocabulary" are side by side
- **AND** "Recent" is below both

### Requirement: Narrow home is a single column
When the vocabulary home viewport is narrower than 1440, the home SHALL fill that width as one column. It SHALL NOT show the 1440 layout scaled down to fit.

#### Scenario: Narrow window fills the width
- **WHEN** the vocabulary home is shown in a viewport narrower than 1440
- **THEN** the home content fills the viewport width
- **AND** there is no empty side region

### Requirement: Narrow header stacks search and New vocab
When the vocabulary home viewport is narrower than 1440, the header SHALL show the menu, the lang mark, and the avatar on the first row, the search field on the next row, and New vocab on the row after that.

#### Scenario: English narrow header
- **WHEN** the vocabulary home is shown in English in a viewport narrower than 1440
- **THEN** the menu, the lang mark, and the avatar are on the first row
- **AND** "Find your vocab..." is on the next row
- **AND** "New vocab" is on the row after that

### Requirement: Narrow menu covers the page with the sidebar
When the vocabulary home viewport is narrower than 1440, the sidebar SHALL stay hidden until the user activates the menu. Activating the menu SHALL show the sidebar over the page. Activating the menu again, or tapping outside the sidebar, SHALL hide it.

#### Scenario: Narrow sidebar starts hidden
- **WHEN** the vocabulary home is shown in a viewport narrower than 1440
- **THEN** the sidebar is not shown

#### Scenario: Menu opens the sidebar over the page
- **WHEN** the user activates the menu on the vocabulary home in a viewport narrower than 1440
- **THEN** the sidebar is shown over the page

#### Scenario: Tap outside closes the sidebar
- **WHEN** the sidebar is open over the page and the user taps outside it
- **THEN** the sidebar is hidden

#### Scenario: Menu closes an open sidebar
- **WHEN** the sidebar is open over the page and the user activates the menu
- **THEN** the sidebar is hidden

### Requirement: Narrow dashboard stacks the panels
When the vocabulary home viewport is narrower than 1440 and the loaded library has folders, statistics SHALL be above Today's vocabulary, and Today's vocabulary SHALL be above Recent. Recent SHALL stay within the column width.

#### Scenario: English narrow dashboard order
- **WHEN** the vocabulary home is shown in English in a viewport narrower than 1440 and the loaded library has a folder
- **THEN** "Your vocabulary statistics" is above "Today's vocabulary"
- **AND** "Today's vocabulary" is above "Recent"
- **AND** "Recent" is within the viewport width

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
