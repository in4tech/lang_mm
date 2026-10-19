# word-editor Specification

## Purpose

Lets the user type words for a new vocabulary set, starting from one empty card, and drop that draft when they return to the vocabulary home.

## Requirements

### Requirement: Editor opens on one empty card
The word editor SHALL open with an empty title, an empty description, and one expanded word card numbered 1. That card's term, definition, and sentence SHALL be empty, and no type SHALL be selected. Details SHALL start closed, so IPA, singular and plural, note, and Type are hidden until the user opens Details.

#### Scenario: First view is one empty card
- **WHEN** the word editor opens
- **THEN** the title and the description are empty
- **AND** one expanded card numbered 1 is shown
- **AND** that card's term, definition, and sentence are empty
- **AND** Details is closed
- **AND** IPA, singular and plural, note, and Type are not shown
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

#### Scenario: A listed word opens its own form
- **WHEN** the user activates the edit control on a word in a set
- **THEN** that word's form is shown with its term
- **AND** the new-set title field and "Add new word" are not shown

#### Scenario: Title dropdown lists existing sets
- **WHEN** the user opens a new set and activates the title dropdown
- **THEN** the titles of sets already created are shown
- **AND** choosing one of those titles puts it in the title field

### Requirement: English editor shows the word form
In English, the word editor SHALL show "All posts", "Done", "Title", "Enter a title...", "Add a description...", "Import", "Term", "Enter term", "Definition", "Enter definition", "Sentence", "Enter sentence", "Details", "IPA", "Enter IPA", "Singular - Plural", "Enter singular and plural", "Note", "Enter a note", "Type", "Chunking", "Noun", "Verb", "Adj", and "Add new word".

#### Scenario: English empty editor
- **WHEN** the word editor is shown in English
- **THEN** it shows "All posts", "Done", "Title", "Enter a title...", "Add a description...", "Import", "Term", "Enter term", "Definition", "Enter definition", "Sentence", "Enter sentence", "Details", "IPA", "Enter IPA", "Singular - Plural", "Enter singular and plural", "Note", "Enter a note", "Type", "Chunking", "Noun", "Verb", "Adj", and "Add new word"
- **AND** it does not show "Enter your project title..." or "Add a discription..."

### Requirement: Details fold up and down
The expanded card SHALL keep Details closed at first. Type SHALL sit inside Details, with IPA, singular and plural, and note. Activating the Details arrow SHALL show those fields. Activating it again SHALL hide them. Opening Details again SHALL show text already entered.

#### Scenario: The arrow hides and shows the detail fields
- **WHEN** the word editor opens
- **THEN** "Enter IPA", "Type", and "Noun" are not shown
- **AND** "Details" is shown
- **WHEN** the user opens Details, enters "/kaɪnd/" as the IPA, and activates the Details arrow
- **THEN** "Enter IPA", "Enter singular and plural", "Enter a note", "Type", and "Noun" are not shown
- **AND** "/kaɪnd/" is not shown
- **AND** "Details" is shown
- **WHEN** the user activates the Details arrow again
- **THEN** "/kaɪnd/", "Enter singular and plural", "Enter a note", and "Type" are shown

### Requirement: One word type can be selected
The expanded card SHALL start with no type selected. Activating Chunking, Noun, Verb, or Adj SHALL select that type and clear any other. Activating the selected type SHALL clear the selection. Activating the type add control SHALL ask for a name and add that name as a selected type.

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

#### Scenario: Type add control adds a type
- **WHEN** the user opens Details, activates the type add control, enters "Phrase", and confirms
- **THEN** Phrase is shown and selected
- **AND** Chunking, Noun, Verb, and Adj remain

### Requirement: Add new word stacks a summary above an empty card
Add new word SHALL sit centered below the cards. It SHALL be a pill with a plus icon, sized to its label. Activating it SHALL collapse the expanded card into a summary row and open a new empty expanded card above it. The new card SHALL be numbered one higher. The summary row SHALL show that card's term on the left and its definition on the right.

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
- **AND** the expanded card does not show "Add new word"
- **AND** "Add new word" is shown below the cards

### Requirement: Done with a term leaves the editor
When at least one card has a term and the set is stored, Done SHALL return to the vocabulary home and discard the draft. Opening the editor again SHALL show one empty card.

#### Scenario: Done leaves after a word
- **WHEN** the user enters "Kind" as the term, activates Done, and the set is stored
- **THEN** the vocabulary home is shown
- **AND** the word editor is not shown

#### Scenario: The next visit is empty
- **WHEN** the user enters "Kind" as the term, activates Done, the set is stored, and the user activates New vocab
- **THEN** the word editor shows one empty card numbered 1
- **AND** "Kind" is not shown

### Requirement: Done with no term leaves the library unchanged
When no card has a term, Done SHALL return to the vocabulary home and discard the draft. The saved library SHALL be unchanged.

#### Scenario: Done on an empty editor
- **WHEN** the loaded library has no folders and the user activates Done on the empty editor
- **THEN** the vocabulary home is shown
- **AND** the word editor is not shown
- **AND** the sidebar shows no folder name and no set name
- **AND** the saved library has no folders

### Requirement: Back drops the draft
Activating the back control SHALL return to the vocabulary home and discard the draft. The saved library SHALL be unchanged. Opening the editor again SHALL show one empty card.

#### Scenario: Back returns without a saved word
- **WHEN** the user enters "Kind" as the term and activates the back control
- **THEN** the vocabulary home is shown
- **AND** the word editor is not shown
- **AND** the saved library is unchanged

#### Scenario: The next visit after back is empty
- **WHEN** the user enters "Kind" as the term, activates the back control, and activates New vocab
- **THEN** the word editor shows one empty card numbered 1
- **AND** "Kind" is not shown

### Requirement: A failed store keeps the editor open
When storing the set fails, Done SHALL leave the editor open and SHALL keep the draft. The saved library SHALL be unchanged.

#### Scenario: Done stays on the failed store
- **WHEN** the user enters "Kind" as the term, activates Done, and storing the set fails
- **THEN** the word editor remains
- **AND** the term shows "Kind"
- **AND** the saved library is unchanged

### Requirement: The editor header stays in place
While the word form scrolls, the back control and Done SHALL stay at the top of the editor.

#### Scenario: Scrolling the form leaves the header in place
- **WHEN** the word editor is open and the user scrolls the form down
- **THEN** the back control stays at the same vertical position
- **AND** the term field moves up

### Requirement: Sentence text can be formatted
The sentence field SHALL offer bold, italic, underline, a bullet list, a numbered list, and text color. Formatting SHALL be stored with the sentence and SHALL read back as the same plain sentence.

#### Scenario: Bold, a list, and a color apply to the sentence
- **WHEN** the user enters "Das Kind", bolds "Das", applies a numbered list, and colors the sentence
- **THEN** "Das" is bold
- **AND** the sentence text is "1. Das Kind"
- **AND** the stored sentence is not the plain text alone

### Requirement: Idle controls keep the current cards
Activating Import, the editor search control, or a control on a collapsed card SHALL leave the editor open and SHALL NOT add, remove, or change a card. The editor SHALL NOT show a header add control.

#### Scenario: Import leaves the empty card
- **WHEN** the word editor is showing one empty card and the user activates Import
- **THEN** the word editor remains
- **AND** one expanded card numbered 1 remains
- **AND** no collapsed card is shown

#### Scenario: A collapsed card's control leaves it collapsed
- **WHEN** a collapsed card shows "ein Kind haben" and the user activates a control on that card
- **THEN** that card still shows "ein Kind haben"
- **AND** that card stays collapsed
