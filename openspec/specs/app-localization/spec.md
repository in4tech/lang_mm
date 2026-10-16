# app-localization Specification

## Purpose

Lets the app present its interface in Vietnamese, English, or German, starting in English until the user chooses another language.

## Requirements

### Requirement: Supported languages
The language component SHALL offer exactly Vietnamese, English, and German.

#### Scenario: Open the language component
- **WHEN** the user opens the language component
- **THEN** the only choices are Vietnamese, English, and German

### Requirement: Language names stay recognizable
Each language choice SHALL be labeled in that language itself: "Tiếng Việt", "English", and "Deutsch".

#### Scenario: Labels while English is active
- **WHEN** the active language is English and the user opens the language component
- **THEN** the choices are labeled "Tiếng Việt", "English", and "Deutsch"

### Requirement: Active language is indicated
The language component SHALL mark exactly one language as active.

#### Scenario: English is active
- **WHEN** the active language is English and the user opens the language component
- **THEN** English is marked active
- **AND** Vietnamese and German are not marked active

### Requirement: English is the initial language
Before the user has chosen a language, the system SHALL present the app in English, including when the device language is Vietnamese or German.

#### Scenario: First launch on a Vietnamese device
- **WHEN** the app starts for the first time and the device language is Vietnamese
- **THEN** visible UI copy is English

#### Scenario: First launch on a German device
- **WHEN** the app starts for the first time and the device language is German
- **THEN** visible UI copy is English

### Requirement: User can switch language
The user SHALL be able to select one supported language, and visible UI copy SHALL change to that language without leaving the current screen.

#### Scenario: Switch to Vietnamese
- **WHEN** the user selects Vietnamese on a platform other than web
- **THEN** the home screen title, counter message, and increment action appear in Vietnamese
- **AND** Vietnamese is marked active

#### Scenario: Switch to German
- **WHEN** the user selects German on a platform other than web
- **THEN** the home screen title, counter message, and increment action appear in German
- **AND** German is marked active

#### Scenario: Switch back to English
- **WHEN** the active language is not English and the user selects English on a platform other than web
- **THEN** the home screen title, counter message, and increment action appear in English
- **AND** English is marked active

### Requirement: Home screen copy exists in every language
The home screen title, counter message, and increment action SHALL have copy in Vietnamese, English, and German.

#### Scenario: Home screen in each language
- **WHEN** the active language is Vietnamese, English, or German and the platform is not web
- **THEN** the home screen shows its title, counter message, and increment action in that language

### Requirement: Switching language keeps screen state
Changing language SHALL NOT reset state already on the current screen.

#### Scenario: Counter survives a language change
- **WHEN** the counter shows a non-zero value on a platform other than web and the user selects another language
- **THEN** the counter still shows that same value

### Requirement: Language choice persists
The system SHALL restore the last language the user selected the next time the app starts.

#### Scenario: Relaunch after German
- **WHEN** the user selects German and then starts the app again
- **THEN** the app opens in German

#### Scenario: Relaunch after Vietnamese
- **WHEN** the user selects Vietnamese and then starts the app again
- **THEN** the app opens in Vietnamese

### Requirement: Unknown stored language uses English
If no language is stored, or the stored value is not Vietnamese, English, or German, the system SHALL use English.

#### Scenario: Stored value is unsupported
- **WHEN** the app starts and the stored language is not one of the three supported languages
- **THEN** the app opens in English

### Requirement: Missing translation uses English
When the active language has no translation for a piece of UI copy, the system SHALL show the English text for that copy only.

#### Scenario: One German string is missing
- **WHEN** the active language is German and one string has no German translation
- **THEN** that string is shown in English
- **AND** strings that have a German translation stay in German

### Requirement: Shell language matches the selection
Framework-provided interface text SHALL use the same language as the user's selection.

#### Scenario: Vietnamese shell
- **WHEN** the active language is Vietnamese
- **THEN** framework-provided interface text is Vietnamese

### Requirement: Web home chrome exists in every language
The vocabulary home title and chrome SHALL have copy in Vietnamese, English, and German. Chrome is the search placeholder, New vocab, Homepage, Library, Notification, Your vocabulary set, Set of words, the statistics heading, All, Words learned, Words not yet learned, the six level names, Today's vocabulary, Practice, Recent, the progress sentence, and Continue.

#### Scenario: Web home in each language
- **WHEN** the vocabulary home is shown and the active language is Vietnamese, English, or German
- **THEN** the vocabulary home shows its title and chrome in that language

### Requirement: Web language switch updates chrome
On the vocabulary home, the user SHALL be able to select one supported language, and the vocabulary home title and chrome SHALL change to that language without leaving that home.

#### Scenario: Switch to Vietnamese on the vocabulary home
- **WHEN** the user selects Vietnamese on the vocabulary home
- **THEN** the vocabulary home title and chrome appear in Vietnamese
- **AND** Vietnamese is marked active

#### Scenario: Switch to German on the vocabulary home
- **WHEN** the user selects German on the vocabulary home
- **THEN** the vocabulary home title and chrome appear in German
- **AND** German is marked active

#### Scenario: Switch back to English on the vocabulary home
- **WHEN** the active language is not English and the user selects English on the vocabulary home
- **THEN** the vocabulary home title and chrome appear in English
- **AND** English is marked active

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

### Requirement: Word editor chrome exists in every language
The word editor chrome SHALL have copy in Vietnamese, English, and German. Chrome is the back label, Done, the set title and description, Import, the word fields, Details, Type, Chunking, Noun, Verb, Adj, and Add new word. Chunking and IPA stay those words in every language.

#### Scenario: English word editor chrome
- **WHEN** the word editor is shown in English
- **THEN** it shows "All posts", "Done", "Title", "Enter a title...", "Add a description...", "Import", "Term", "Enter term", "Definition", "Enter definition", "Sentence", "Enter sentence", "Details", "IPA", "Enter IPA", "Singular - Plural", "Enter singular and plural", "Note", "Enter a note", "Type", "Chunking", "Noun", "Verb", "Adj", and "Add new word"

#### Scenario: German word editor chrome
- **WHEN** the word editor is shown in German
- **THEN** it shows "Alle Beiträge", "Fertig", "Titel", "Titel eingeben...", "Beschreibung hinzufügen...", "Importieren", "Begriff", "Begriff eingeben", "Definition", "Definition eingeben", "Satz", "Satz eingeben", "Details", "IPA", "IPA eingeben", "Singular - Plural", "Singular und Plural eingeben", "Notiz", "Notiz eingeben", "Typ", "Chunking", "Nomen", "Verb", "Adjektiv", and "Neues Wort hinzufügen"

#### Scenario: Vietnamese word editor chrome
- **WHEN** the word editor is shown in Vietnamese
- **THEN** it shows "Tất cả bài viết", "Xong", "Tiêu đề", "Nhập tiêu đề...", "Thêm mô tả...", "Nhập", "Từ", "Nhập từ", "Định nghĩa", "Nhập định nghĩa", "Câu", "Nhập câu", "Chi tiết", "IPA", "Nhập IPA", "Số ít - Số nhiều", "Nhập số ít và số nhiều", "Ghi chú", "Nhập ghi chú", "Loại", "Chunking", "Danh từ", "Động từ", "Tính từ", and "Thêm từ mới"

### Requirement: Practice chrome exists in every language
Still learning, Know, Not yet studied, and Studied SHALL have copy in Vietnamese, English, and German. The practice screen SHALL NOT show a Track progress control.

#### Scenario: English practice labels
- **WHEN** practice is shown in English and the current word is new
- **THEN** the screen shows "Not yet studied" and "Studied"
- **AND** the screen does not show "Track progress"

#### Scenario: Vietnamese practice labels
- **WHEN** practice is shown in Vietnamese and the current word is new
- **THEN** the screen shows "Chưa học" and "Đã học"
- **AND** the screen does not show "Theo dõi tiến độ"

#### Scenario: German practice labels
- **WHEN** practice is shown in German and the current word is new
- **THEN** the screen shows "Noch nicht gelernt" and "Gelernt"
- **AND** the screen does not show "Fortschritt verfolgen"

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
