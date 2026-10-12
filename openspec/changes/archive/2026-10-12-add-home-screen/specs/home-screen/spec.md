# Spec Delta

## Purpose

Shows the vocabulary dashboard as the web home, with the sample sets, statistics, and today's words from the desktop design. Other platforms keep the counter.

## ADDED Requirements

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
In English, the sidebar SHALL show Homepage selected, Library, Notification, the "Your vocabulary set" section, "Set of words", an expanded "My vocab" containing "German A1 vocabulary" and "A2 vocabulary", and a collapsed "My vocab 2".

#### Scenario: English sidebar
- **WHEN** the vocabulary home is shown in English
- **THEN** Homepage is the selected navigation item
- **AND** "My vocab" is expanded and lists "German A1 vocabulary" and "A2 vocabulary"
- **AND** "My vocab 2" is collapsed

### Requirement: Statistics show the German A1 sample
In English, the statistics region SHALL show "Your vocabulary statistics" for "German A1 vocabulary" as 5/20 and 25%, bar labels 3 and 2, the level legend below, and the captions "Words learned" and "Words not yet learned". The All control SHALL be on.

#### Scenario: English statistics
- **WHEN** the vocabulary home is shown in English
- **THEN** the statistics region shows "German A1 vocabulary", "5/20", "25%", bar labels "3" and "2", "Words learned", and "Words not yet learned"
- **AND** the legend shows "Lv.6 - Mastered" 0%, "Lv.5 - Good" 0%, "Lv.4 - Familiar" 0%, "Lv.3 - Learning" 0%, "Lv.2 - Hard" 25%, and "Lv.1 - Forgot" 75%

### Requirement: Today's vocabulary lists the sample pairs
In English, "Today's vocabulary" SHALL list four rows. Each row SHALL contain "das Auto fahren" with "das, -s" and "die Frage verstehen" with "die, -n". A "Practice" action SHALL be shown.

#### Scenario: English today's vocabulary
- **WHEN** the vocabulary home is shown in English
- **THEN** "Today's vocabulary" shows four rows of "das Auto fahren", "das, -s", "die Frage verstehen", and "die, -n"
- **AND** "Practice" is shown

### Requirement: Recent sets show sample progress
In English, Recent SHALL show "German A1 vocabulary" at 25% complete, "A2 vocabulary" at 50% complete, and "German B1 vocabulary" at 93% complete, each with a "Continue" action, and a further card partly visible.

#### Scenario: English recent sets
- **WHEN** the vocabulary home is shown in English
- **THEN** Recent shows "The process is 25% complete.", "The process is 50% complete.", and "The process is 93% complete."
- **AND** each of those cards shows "Continue"
- **AND** another recent card is partly visible

### Requirement: Sample content is not translated
Set names "My vocab", "My vocab 2", "German A1 vocabulary", "A2 vocabulary", and "German B1 vocabulary", the vocabulary entries, and the sample numbers SHALL stay as shown in the design when the language changes.

#### Scenario: German UI keeps the sample words
- **WHEN** the vocabulary home is shown and the active language is German
- **THEN** the vocabulary home still shows "German A1 vocabulary", "das Auto fahren", "5/20", and "25%"

### Requirement: Home actions stay on the home screen
Activating search, New vocab, Practice, Continue, Library, Notification, the All control, or the Recent next control SHALL leave the user on the vocabulary home with the same sample numbers and the same sidebar selection.

#### Scenario: Practice does not leave home
- **WHEN** the user activates Practice on the vocabulary home
- **THEN** the vocabulary home remains
- **AND** the statistics still show 5/20 and 25%

### Requirement: Avatar opens the language component
Activating the avatar SHALL open the language component on the vocabulary home.

#### Scenario: Open languages from the avatar
- **WHEN** the user activates the avatar
- **THEN** the language component is open
- **AND** the vocabulary home is still the current screen
