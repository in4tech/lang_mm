# Spec Delta

## MODIFIED Requirements

### Requirement: Home actions stay on the home screen
Activating search, Practice, Library, Notification, All, a hot-search chip, Save, or a suggestion row SHALL leave the user on the vocabulary home, SHALL keep Homepage selected, and SHALL NOT add or remove folders, sets, or words. Activating New vocab SHALL open the word editor.

#### Scenario: Practice does not leave home
- **WHEN** the user activates Practice on the vocabulary home and the loaded library has a folder
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
