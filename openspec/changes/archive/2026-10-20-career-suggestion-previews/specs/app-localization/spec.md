# Spec Delta

## MODIFIED Requirements

### Requirement: Switching language keeps the home sample
Changing language SHALL NOT reset the vocabulary home already on screen. Folder and set names from the loaded library SHALL stay as stored. Suggestion template words SHALL stay in English. The home SHALL NOT gain sample folders, sample sets, sample words, or sample progress figures.

#### Scenario: Sample home survives a language change
- **WHEN** the vocabulary home shows an empty library and the user selects German
- **THEN** the sidebar still has no folder name
- **AND** "diagnosis", "deploy", and "Healthcare" are still shown
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

### Requirement: Suggestion chrome exists in every language
"Hot search", "Suggested sets", and "Suggested practice" SHALL have copy in Vietnamese, English, and German. The suggestion template words SHALL stay English in every language. The empty-home suggestion preview SHALL NOT require Save or saves-count chrome.

#### Scenario: English suggestion chrome
- **WHEN** the empty vocabulary home is shown in English
- **THEN** it shows "Hot search", "Suggested sets", and "Suggested practice"
- **AND** it shows "diagnosis" and "Healthcare"
- **AND** Save is not shown

#### Scenario: German suggestion chrome
- **WHEN** the empty vocabulary home is shown in German
- **THEN** it shows "Beliebte Suche", "Vorgeschlagene Sets", and "Vorgeschlagenes Üben"
- **AND** it shows "diagnosis" and "Healthcare"
- **AND** "Speichern" is not shown on the suggestion preview

#### Scenario: Vietnamese suggestion chrome
- **WHEN** the empty vocabulary home is shown in Vietnamese
- **THEN** it shows "Tìm kiếm nổi bật", "Bộ từ gợi ý", and "Luyện tập gợi ý"
- **AND** it shows "diagnosis" and "Healthcare"
- **AND** "Lưu từ" is not shown on the suggestion preview
