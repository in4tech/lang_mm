# Spec Delta

## ADDED Requirements

### Requirement: Practice chrome exists in every language
Still learning, Know, Track progress, Not yet studied, and Studied SHALL have copy in Vietnamese, English, and German.

#### Scenario: English practice labels
- **WHEN** practice is shown in English with Track progress on and the current word is new
- **THEN** the screen shows "Still learning", "Know", "Track progress", "Not yet studied", and "Studied"

#### Scenario: Vietnamese practice labels
- **WHEN** practice is shown in Vietnamese with Track progress on and the current word is new
- **THEN** the screen shows "Đang học", "Đã biết", "Theo dõi tiến độ", "Chưa học", and "Đã học"

#### Scenario: German practice labels
- **WHEN** practice is shown in German with Track progress on and the current word is new
- **THEN** the screen shows "Noch am Lernen", "Gewusst", "Fortschritt verfolgen", "Noch nicht gelernt", and "Gelernt"

### Requirement: The flip shortcut exists in every language
The Flashcard shortcut SHALL have copy in Vietnamese, English, and German. In English it SHALL say "Press Space or click the card to flip".

#### Scenario: English shortcut
- **WHEN** Flashcard is showing a term face in English
- **THEN** the card shows "Press Space or click the card to flip"

#### Scenario: Vietnamese shortcut
- **WHEN** Flashcard is showing a term face in Vietnamese
- **THEN** the card shows "Nhấn Space hoặc nhấn thẻ để lật"

#### Scenario: German shortcut
- **WHEN** Flashcard is showing a term face in German
- **THEN** the card shows "Leertaste drücken oder auf die Karte klicken zum Umdrehen"
