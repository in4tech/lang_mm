# Spec Delta

## ADDED Requirements

### Requirement: Suggestion chrome exists in every language
"Hot search", "Suggested sets", "Suggested practice", "Save", and the saves count SHALL have copy in Vietnamese, English, and German. The suggestion template words SHALL stay English in every language.

#### Scenario: English suggestion chrome
- **WHEN** the empty vocabulary home is shown in English
- **THEN** it shows "Hot search", "Suggested sets", "Suggested practice", "Save", and "80 saves"
- **AND** it shows "student" and "Love vocabulary"

#### Scenario: German suggestion chrome
- **WHEN** the empty vocabulary home is shown in German
- **THEN** it shows "Beliebte Suche", "Vorgeschlagene Sets", "Vorgeschlagenes Üben", "Speichern", and "80 Mal gespeichert"
- **AND** it shows "student" and "Love vocabulary"

#### Scenario: Vietnamese suggestion chrome
- **WHEN** the empty vocabulary home is shown in Vietnamese
- **THEN** it shows "Tìm kiếm nổi bật", "Bộ từ gợi ý", "Luyện tập gợi ý", "Lưu từ", and "80 Lượt lưu"
- **AND** it shows "student" and "Love vocabulary"

## MODIFIED Requirements

### Requirement: Switching language keeps the home sample
Changing language SHALL NOT reset the vocabulary home already on screen. Folder and set names from the loaded library SHALL stay as stored. Suggestion template words SHALL stay in English. The home SHALL NOT gain sample folders, sample sets, sample words, or sample progress figures.

#### Scenario: Sample home survives a language change
- **WHEN** the vocabulary home shows an empty library and the user selects German
- **THEN** the sidebar still has no folder name
- **AND** "student", "love", and "Love vocabulary" are still shown
- **AND** "German A1 vocabulary" and "das Auto fahren" are not shown
- **AND** "0/0" is not shown
- **AND** the home shows "Beliebte Suche"

#### Scenario: Saved library survives a language change
- **WHEN** the vocabulary home shows folder "My vocab" with set "German A1 vocabulary" and the user selects Vietnamese
- **THEN** "My vocab" and "German A1 vocabulary" are still shown
- **AND** the statistics still show 0/0 and 0%
- **AND** "das Auto fahren" is not shown
- **AND** "Hot search" is not shown
- **AND** the vocabulary home chrome is Vietnamese
