# word-editor Specification

## Purpose

Lets the user type words for a new vocabulary set, starting from one empty card, and drop that draft when they return to the vocabulary home.

## Requirements

### Requirement: Editor opens on one empty card
The word editor SHALL open with an empty title, an empty description, and one expanded word card numbered 1. That card's term, definition, sentence, IPA, singular and plural, and note SHALL be empty, and no type SHALL be selected.

#### Scenario: First view is one empty card
- **WHEN** the word editor opens
- **THEN** the title and the description are empty
- **AND** one expanded card numbered 1 is shown
- **AND** that card's term, definition, sentence, IPA, singular and plural, and note are empty
- **AND** no type is selected
- **AND** no collapsed card is shown
- **AND** "ein Kind haben" and "have a child" are not shown

### Requirement: Title sits inside a filled field
The title field and the description field SHALL use a filled background. The title label SHALL sit inside the title field, above the title text. The description field SHALL NOT show that label.

#### Scenario: Title is inside the filled field
- **WHEN** the word editor opens in English
- **THEN** the title field and the description field are filled
- **AND** "Title" is inside the title field
- **AND** "Title" is not inside the description field

### Requirement: English editor shows the word form
In English, the word editor SHALL show "All posts", "Done", "Title", "Enter a title...", "Add a description...", "Import", "Term", "Enter term", "Definition", "Enter definition", "Sentence", "Enter sentence", "Details", "IPA", "Enter IPA", "Singular - Plural", "Enter singular and plural", "Note", "Enter a note", "Type", "Chunking", "Noun", "Verb", "Adj", and "Add new word".

#### Scenario: English empty editor
- **WHEN** the word editor is shown in English
- **THEN** it shows "All posts", "Done", "Title", "Enter a title...", "Add a description...", "Import", "Term", "Enter term", "Definition", "Enter definition", "Sentence", "Enter sentence", "Details", "IPA", "Enter IPA", "Singular - Plural", "Enter singular and plural", "Note", "Enter a note", "Type", "Chunking", "Noun", "Verb", "Adj", and "Add new word"
- **AND** it does not show "Enter your project title..." or "Add a discription..."

### Requirement: Details fold up and down
The expanded card SHALL show the detail fields at first. Activating the Details arrow SHALL hide those fields. Activating it again SHALL show them, including text already entered.

#### Scenario: The arrow hides and shows the detail fields
- **WHEN** the word editor is open and the user enters "/kaɪnd/" as the IPA and activates the Details arrow
- **THEN** "Enter IPA", "Enter singular and plural", and "Enter a note" are not shown
- **AND** "/kaɪnd/" is not shown
- **AND** "Details" is shown
- **WHEN** the user activates the Details arrow again
- **THEN** "/kaɪnd/", "Enter singular and plural", and "Enter a note" are shown

### Requirement: One word type can be selected
The expanded card SHALL start with no type selected. Activating Chunking, Noun, Verb, or Adj SHALL select that type and clear any other. Activating the selected type SHALL clear the selection. Activating the type add control SHALL NOT add a type.

#### Scenario: Select Noun
- **WHEN** the user activates Noun on the empty card
- **THEN** Noun is selected
- **AND** Chunking, Verb, and Adj are not selected

#### Scenario: Switch the selected type
- **WHEN** Noun is selected and the user activates Verb
- **THEN** Verb is selected
- **AND** Noun is not selected

#### Scenario: Clear the selected type
- **WHEN** Noun is selected and the user activates Noun
- **THEN** no type is selected

#### Scenario: Type add control adds no type
- **WHEN** the user activates the type add control
- **THEN** the only types are Chunking, Noun, Verb, and Adj

### Requirement: Add new word stacks a summary above an empty card
Activating Add new word SHALL collapse the expanded card into a summary row and open a new empty expanded card above it. The new card SHALL be numbered one higher. The summary row SHALL show that card's term on the left and its definition on the right.

#### Scenario: A typed word becomes the summary row
- **WHEN** the user enters "Animals" as the title, "ein Kind haben" as the term, and "have a child" as the definition, and activates Add new word
- **THEN** the title shows "Animals"
- **AND** a collapsed card numbered 1 shows "ein Kind haben" and "have a child"
- **AND** "ein Kind haben" is left of "have a child"
- **AND** an expanded card numbered 2 is above that collapsed card
- **AND** the expanded card's term and definition are empty

#### Scenario: The newest card stays on top
- **WHEN** the user activates Add new word twice on the empty editor
- **THEN** the expanded card is numbered 3 and is above the other cards
- **AND** a collapsed card numbered 2 is below it
- **AND** a collapsed card numbered 1 is below that

#### Scenario: A collapsed card hides the word form
- **WHEN** a card has the sentence "Das Kind" and Noun selected, and the user activates Add new word
- **THEN** the collapsed card does not show "Enter sentence", "Noun", or "Add new word"
- **AND** the expanded card shows "Add new word"

### Requirement: Leaving the editor drops the draft
Activating Done or the back control SHALL return to the vocabulary home and discard the draft. The saved library SHALL be unchanged. Opening the editor again SHALL show one empty card.

#### Scenario: Done returns without a saved word
- **WHEN** the loaded library has no folders and the user enters "German A1" as the title and "Kind" as the term, then activates Done
- **THEN** the vocabulary home is shown
- **AND** the word editor is not shown
- **AND** the sidebar shows no folder name and no set name
- **AND** the saved library has no folders

#### Scenario: Back returns without a saved word
- **WHEN** the user enters "Kind" as the term and activates the back control
- **THEN** the vocabulary home is shown
- **AND** the word editor is not shown

#### Scenario: The next visit is empty
- **WHEN** the user enters "Kind" as the term, activates Done, and activates New vocab
- **THEN** the word editor shows one empty card numbered 1
- **AND** "Kind" is not shown

### Requirement: Idle controls keep the current cards
Activating Import, the editor search control, the header add control, or a control on a collapsed card SHALL leave the editor open and SHALL NOT add, remove, or change a card.

#### Scenario: Import leaves the empty card
- **WHEN** the word editor is showing one empty card and the user activates Import
- **THEN** the word editor remains
- **AND** one expanded card numbered 1 remains
- **AND** no collapsed card is shown

#### Scenario: A collapsed card's control leaves it collapsed
- **WHEN** a collapsed card shows "ein Kind haben" and the user activates a control on that card
- **THEN** that card still shows "ein Kind haben"
- **AND** that card stays collapsed
