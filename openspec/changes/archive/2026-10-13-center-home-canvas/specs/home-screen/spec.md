# Spec Delta

## ADDED Requirements

### Requirement: Wide home stays at the design width
When the vocabulary home viewport is at least 1440 wide, the header SHALL fill that width and the sidebar SHALL sit on the left. The main content SHALL keep the width it has in the 1440 design, centered in the space beside the sidebar. Collapsing the sidebar SHALL NOT change that width, and the sidebar SHALL keep its open width. That content SHALL NOT scale to the viewport. Width beyond the content SHALL be empty on its left and right, with no advertisement.

#### Scenario: Window wider than the design
- **WHEN** the vocabulary home is shown in a viewport wider than 1440
- **THEN** the header fills the viewport width
- **AND** the sidebar's left edge is the viewport's left edge
- **AND** the main content is centered in the space to the right of the sidebar
- **AND** the empty space left of that content equals the empty space right of it
- **AND** neither space shows an advertisement

#### Scenario: Window exactly the design width
- **WHEN** the vocabulary home is shown in a viewport 1440 wide
- **THEN** the header fills the viewport width
- **AND** the sidebar sits on the left
- **AND** the main content fills the space beside the sidebar
- **AND** there is no empty side region beside the content

#### Scenario: Closing the sidebar keeps the content width
- **WHEN** the vocabulary home is shown at a viewport at least 1440 wide and the user collapses the sidebar
- **THEN** the main content width is unchanged

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

## MODIFIED Requirements

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

### Requirement: Home shows the loaded library
When the loaded library has folders, the sidebar SHALL show each folder name and the set names under it. Statistics SHALL show 0/0 and 0% with no set name and no bar labels. Today's list SHALL have no rows. Recent SHALL show no cards. The suggestion columns SHALL be absent. On a viewport narrower than 1440, the folder and set names are shown when the menu overlay is open.

#### Scenario: Saved folder and set
- **WHEN** the loaded library contains folder "My vocab" with set "German A1 vocabulary" and the vocabulary home is shown in English at a viewport at least 1440 wide
- **THEN** the sidebar shows "My vocab" and "German A1 vocabulary"
- **AND** the statistics show "0/0" and "0%" and do not show a set name
- **AND** "das Auto fahren" is not shown
- **AND** Recent shows no "Continue"
- **AND** "Hot search" is not shown

#### Scenario: Narrow home shows the folder inside the menu
- **WHEN** the loaded library contains folder "My vocab" with set "German A1 vocabulary" and the vocabulary home is shown in English at a viewport narrower than 1440
- **THEN** "My vocab" is not shown while the menu overlay is closed
- **AND** opening the menu shows "My vocab" and "German A1 vocabulary"
- **AND** the statistics show "0/0" and "0%"
- **AND** "Hot search" is not shown

#### Scenario: Unreadable library shows the empty home
- **WHEN** the saved vocabulary library cannot be read and the vocabulary home is shown in English
- **THEN** the sidebar shows no folder name
- **AND** "Hot search" and "student" are shown
- **AND** "0/0" is not shown
