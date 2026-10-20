# Spec Delta

## MODIFIED Requirements

### Requirement: Quiz option copy exists in every language
"Choose an answer", "Don't know?", "No sweat, you're still learning!", and "Give this one a try later!" SHALL have copy in Vietnamese, English, and German. The Quiz card SHALL use the existing Term label. Typing SHALL reuse "Don't know?", "No sweat, you're still learning!", and "Give this one a try later!".

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

#### Scenario: English Typing reuses Quiz result copy
- **WHEN** a wrong Typing Check is revealed in English
- **THEN** the card shows "No sweat, you're still learning!"
- **AND** Don't know is labeled "Don't know?"

#### Scenario: Vietnamese Typing reuses Quiz result copy
- **WHEN** Don't know on Typing is revealed in Vietnamese
- **THEN** the card shows "Hãy thử từ này sau!"
- **AND** Don't know is labeled "Không biết?"

#### Scenario: German Typing reuses Quiz result copy
- **WHEN** a wrong Typing Check is revealed in German
- **THEN** the card shows "Kein Problem, du lernst noch!"
- **AND** Don't know is labeled "Weiß nicht?"

## ADDED Requirements

### Requirement: Typing answer copy exists in every language
"Your answer", the type-the-term field hint, and "Next" SHALL have copy in Vietnamese, English, and German.

#### Scenario: English Typing prompt
- **WHEN** Typing is asking for a term in English
- **THEN** the card shows "Your answer", the hint "Type the term", and "Next"

#### Scenario: Vietnamese Typing prompt
- **WHEN** Typing is asking for a term in Vietnamese
- **THEN** the card shows "Câu trả lời của bạn", the hint "Gõ từ", and "Kiểm tra"

#### Scenario: German Typing prompt
- **WHEN** Typing is asking for a term in German
- **THEN** the card shows "Deine Antwort", the hint "Begriff eingeben", and "Prüfen"
