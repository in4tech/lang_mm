# Spec Delta

## ADDED Requirements

### Requirement: Quiz option copy exists in every language
"Choose an answer", "Don't know?", "No sweat, you're still learning!", and "Give this one a try later!" SHALL have copy in Vietnamese, English, and German. The Quiz card SHALL use the existing Term label.

#### Scenario: English prompt
- **WHEN** Quiz is asking for a term in English
- **THEN** the card shows "Term", "Choose an answer", and "Don't know?"

#### Scenario: English correct praise
- **WHEN** a correct choice is revealed in English
- **THEN** the praise can show "Nice!", "Great job!", "Awesome!", "You got it!", and "Brilliant!"

#### Scenario: English wrong result
- **WHEN** a wrong choice is revealed in English
- **THEN** the card shows "No sweat, you're still learning!"

#### Scenario: English Don't know result
- **WHEN** Don't know is revealed in English
- **THEN** the card shows "Give this one a try later!"

#### Scenario: Vietnamese prompt
- **WHEN** Quiz is asking for a term in Vietnamese
- **THEN** the card shows "Từ", "Chọn một đáp án", and "Không biết?"

#### Scenario: Vietnamese correct praise
- **WHEN** a correct choice is revealed in Vietnamese
- **THEN** the praise can show "Tuyệt!", "Giỏi lắm!", "Xuất sắc!", "Đúng rồi!", and "Quá đỉnh!"

#### Scenario: Vietnamese wrong result
- **WHEN** a wrong choice is revealed in Vietnamese
- **THEN** the card shows "Không sao, bạn vẫn đang học!"

#### Scenario: Vietnamese Don't know result
- **WHEN** Don't know is revealed in Vietnamese
- **THEN** the card shows "Hãy thử từ này sau!"

#### Scenario: German prompt
- **WHEN** Quiz is asking for a term in German
- **THEN** the card shows "Begriff", "Wähle eine Antwort", and "Weiß nicht?"

#### Scenario: German correct praise
- **WHEN** a correct choice is revealed in German
- **THEN** the praise can show "Super!", "Gut gemacht!", "Stark!", "Richtig!", and "Brillant!"

#### Scenario: German wrong result
- **WHEN** a wrong choice is revealed in German
- **THEN** the card shows "Kein Problem, du lernst noch!"

#### Scenario: German Don't know result
- **WHEN** Don't know is revealed in German
- **THEN** the card shows "Versuch es später noch einmal!"
