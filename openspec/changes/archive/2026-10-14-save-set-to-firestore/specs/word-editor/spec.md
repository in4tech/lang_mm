# Spec Delta

## REMOVED Requirements

### Requirement: Leaving the editor drops the draft
**Reason**: Done with a term now stores the set before it leaves. Back still drops the draft, and Done with no term still leaves the library unchanged.
**Migration**: Use "Done with a term leaves the editor", "Done with no term leaves the library unchanged", "Back drops the draft", and "A failed store keeps the editor open".

## ADDED Requirements

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
