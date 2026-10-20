# Spec Delta

## ADDED Requirements

### Requirement: A chart bar opens that level's word list
Activating a statistics chart bar SHALL open a dialog titled with that level's legend label and the count of words at that level in the statistics scope. The dialog SHALL use the same search field and word cards as "Words learned". The six bars, left to right, are levels 1 through 6. The legend SHALL NOT open a list. All on uses every loaded set. All off uses the set whose level was stored last, or no words when no set has a stored level.

#### Scenario: Level 1 bar opens Forgot words
- **WHEN** the only loaded set has "Kind" at level 1 and "Haus" at level 6, and the user activates the leftmost chart bar
- **THEN** a dialog titled "Lv.1 - Forgot (1)" shows "Kind"
- **AND** the dialog does not show "Haus"

#### Scenario: Level 6 bar opens Mastered words
- **WHEN** the user activates the rightmost chart bar for that set
- **THEN** a dialog titled "Lv.6 - Mastered (1)" shows "Haus"
- **AND** the dialog does not show "Kind"

#### Scenario: An empty level still opens
- **WHEN** no word is at level 3 and the user activates the third bar from the left
- **THEN** a dialog titled "Lv.3 - Learning (0)" is shown
- **AND** the dialog shows no word cards

#### Scenario: The legend does not open a list
- **WHEN** the user activates the "Lv.6 - Mastered" legend row
- **THEN** no word-list dialog is shown

### Requirement: Hovering a chart bar shows the level
While a pointer hovers a statistics chart bar, the screen SHALL show that level's legend label with a swatch in that bar's color.

#### Scenario: Hover shows Forgot
- **WHEN** the user hovers the leftmost chart bar
- **THEN** the hover label shows "Lv.1 - Forgot" with the level-1 color
