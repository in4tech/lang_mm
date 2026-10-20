# Spec Delta

## ADDED Requirements

### Requirement: A career set opens a preview
On the empty home, activating a Suggested sets row SHALL select that career pack and show its preview on the right: the pack name, every term in pack order, and the featured word card for the first term of that pack. The library SHALL stay empty. The user SHALL stay on the vocabulary home with Home selected.

#### Scenario: Healthcare preview
- **WHEN** the empty vocabulary home is shown and the user activates "Healthcare"
- **THEN** the right column shows "Healthcare"
- **AND** it shows the Healthcare terms including "diagnosis" and "prescription"
- **AND** the featured word shows "diagnosis"
- **AND** the library still has no folders

### Requirement: A hot-search chip previews its pack
On the empty home, activating a hot-search chip SHALL select the career pack that owns that chip's term, show that pack's preview, and set the featured word to that term. The library SHALL stay empty.

#### Scenario: deploy chip opens Software Engineering
- **WHEN** the empty vocabulary home is shown and the user activates the "deploy" chip
- **THEN** the right column shows "Software Engineering"
- **AND** the featured word shows "deploy"
- **AND** the library still has no folders

### Requirement: Suggested practice previews its pack
On the empty home, activating a Suggested practice row SHALL select the career pack that owns that practice term, show that pack's preview, and set the featured word to that term. The library SHALL stay empty.

#### Scenario: Practice diagnosis opens Healthcare
- **WHEN** the empty vocabulary home is shown and the user activates Practice "diagnosis"
- **THEN** the right column shows "Healthcare"
- **AND** the featured word shows "diagnosis"
- **AND** the library still has no folders

### Requirement: A preview term becomes the featured word
While a career pack preview is showing, activating a listed term SHALL set the featured word card to that term's IPA lines, gloss, and saves count, and SHALL NOT change the library.

#### Scenario: Select prescription in Healthcare
- **WHEN** the empty home is previewing Healthcare and the user activates "prescription"
- **THEN** the featured word shows "prescription"
- **AND** the library still has no folders

## MODIFIED Requirements

### Requirement: Home actions stay on the home screen
Activating search, Notification, All, a hot-search chip, a Suggested sets row, a Suggested practice row, or the featured-word speak control SHALL leave the user on the vocabulary home, SHALL keep Home selected, and SHALL NOT add or remove folders, sets, or words. A chip or suggestion row MAY change only the empty-home preview. When the practice queue is empty, activating Practice SHALL leave the user on the vocabulary home without writing the library. Activating New vocab SHALL open the word editor. Activating Library in the sidebar SHALL open the library page.

#### Scenario: Practice does not leave home
- **WHEN** the user activates Practice on the vocabulary home, the loaded library has a folder, the practice queue is empty, and the user has no stored level
- **THEN** the vocabulary home remains
- **AND** Home stays selected
- **AND** the statistics still show 0/0 and 0%
- **AND** the sidebar still shows that folder

#### Scenario: New vocab opens the word editor
- **WHEN** the user activates New vocab on the vocabulary home and the loaded library has no folders
- **THEN** the word editor is shown in the center
- **AND** the header and the sidebar remain
- **AND** "Add new word" and "Enter term" are shown
- **AND** "Find your vocab..." and "Home" are shown
- **AND** "Hot search" and "diagnosis" are not shown

#### Scenario: New vocab does not create a set
- **WHEN** the user activates New vocab on the vocabulary home, the loaded library has no folders, and the user activates Done
- **THEN** the vocabulary home is shown
- **AND** Home stays selected
- **AND** the sidebar still shows no folder name and no set name
- **AND** "Hot search" and "diagnosis" are still shown
- **AND** the library still has no folders

### Requirement: Empty home shows the suggestion columns
When the loaded library has no folders, the main area SHALL show a left suggestion column and a right suggestion column. It SHALL NOT show "Your vocabulary statistics", "Today's vocabulary", Recent, "0/0", or "Practice". On a viewport at least 1440 wide, the columns sit side by side. On a narrower viewport, the left column's content is above the right column's content. The empty home SHALL open with Healthcare selected and "diagnosis" as the featured word.

#### Scenario: English empty home hides the dashboard
- **WHEN** the vocabulary home is shown in English and the loaded library has no folders
- **THEN** "Hot search", "Suggested sets", "Healthcare", "diagnosis", and "Suggested practice" are shown
- **AND** the featured-word speak control is shown
- **AND** Save is not shown
- **AND** "Your vocabulary statistics", "Today's vocabulary", "Recent", "0/0", and "Practice" are not shown

#### Scenario: Wide empty home places the columns side by side
- **WHEN** the empty vocabulary home is shown in English at a viewport at least 1440 wide
- **THEN** "Hot search" and "Suggested practice" are side by side

#### Scenario: Narrow empty home stacks the columns
- **WHEN** the empty vocabulary home is shown in English at a viewport narrower than 1440
- **THEN** "Hot search" is above "Suggested sets"
- **AND** "Suggested sets" is above "Suggested practice"

### Requirement: Hot search lists the fixed chips
The empty home SHALL show these chips in order: diagnosis, deploy, invoice, check-in, conversion, curriculum, liability, shipment, wireframe, ticket.

#### Scenario: English hot-search chips
- **WHEN** the empty vocabulary home is shown in English
- **THEN** those chips are shown in that order

### Requirement: Suggested sets list the fixed rows
Under "Suggested sets", the empty home SHALL show these rows in order: Healthcare, Software Engineering, Finance & Banking, Hospitality & Tourism, Marketing & Sales, Education & Teaching, Law & Legal, Logistics & Supply Chain, Design & Creative, Customer Support. Each row SHALL show that pack's word count.

#### Scenario: English suggested sets
- **WHEN** the empty vocabulary home is shown in English
- **THEN** those ten rows are shown in that order
- **AND** each row shows a word count

### Requirement: Suggested word shows student
The empty home SHALL show the featured word's term, a speak control for that term, UK IPA line, US IPA line, and gloss. It SHALL NOT show Save or a saves count. The default featured word SHALL be diagnosis with UK IPA, US IPA, and gloss "the identification of an illness or problem".

#### Scenario: English suggested word
- **WHEN** the empty vocabulary home is shown in English
- **THEN** diagnosis, its UK IPA, its US IPA, that gloss, and the speak control are shown
- **AND** Save is not shown

### Requirement: Suggested practice lists the fixed rows
Under "Suggested practice", the empty home SHALL show these rows in order: Practice "diagnosis", Practice "deploy", Practice "invoice", Practice "check-in", Practice "conversion", Practice "curriculum", Practice "liability", Practice "shipment", Practice "wireframe", Practice "ticket".

#### Scenario: English suggested practice
- **WHEN** the empty vocabulary home is shown in English
- **THEN** those ten rows are shown in that order

### Requirement: Home shows the loaded library
When the loaded library has pinned folders, the sidebar SHALL show each pinned folder name and the set names under it. An unpinned folder SHALL NOT appear in the sidebar. When the user has no stored level, statistics SHALL show 0/0 and 0% with no set name and no bar labels. When no loaded word is due and no loaded word is new, Today's list SHALL have no rows. When the user has no stored level, Recent SHALL show no cards. The suggestion columns SHALL be absent. On a viewport narrower than 1440, the folder and set names are shown when the menu overlay is open.

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
- **AND** "Hot search" and "diagnosis" are shown
- **AND** "0/0" is not shown
