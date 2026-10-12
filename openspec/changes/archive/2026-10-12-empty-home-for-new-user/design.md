# Design

## Context

See proposal.md for why a new user does not see the German A1 sample. `main` loads `AppLanguageController` from `SharedPreferences` and `LangApp` always shows `VocabularyHome`. `VocabularyHome` defaults to `HomeSample.current`. The panels only know how to paint a `HomeSample`. The empty main area now has to show suggestion templates in that same frame: header and sidebar stay, and the statistics / today / Recent row is replaced while the library has no folders.

## Goals / Non-Goals

**Goals:**

- Load a name-only library before the first home frame, using the same preferences store as language.
- When that library has no folders, paint the fixed suggestion templates in the main column.
- When it has folders, paint the existing panels with those names and with progress, today, and Recent empty.
- Leave a write path the next change can call. This change's widgets do not call it.

**Non-Goals:**

- Accounts, sync, or a new storage package.
- Words, learned counts, a today queue, recent order, or which set the statistics card names.
- Persisting folder expansion. Stored folders are shown expanded so their set names are visible.
- A video banner, news articles, or video recommendations.
- Saving a chip, Save, or a template row into the library.
- Editing the stale non-web counter requirement.

## Decisions

### One JSON document beside the language key

Store a string at `vocabulary_library` in the same `SharedPreferences` instance the language store uses. Shape:

```json
{"folders":[{"name":"My vocab","sets":["German A1 vocabulary"]}]}
```

A missing key loads `VocabularyLibrary.empty`. A present value that is not this shape loads empty and is not written back. Unknown keys are ignored, so a later change can add fields without this build treating the document as corrupt. If any folder lacks a string `name` or a string array `sets`, the whole document is unreadable. No partial library.

A separate file or database was considered. The proposal forbids a new dependency, and the language store already shows how this app reads preferences before `runApp`.

### Templates are constants, not library rows

Put the chips, the student card, and both lists in `lib/features/home/suggestions/suggestion_templates.dart`. They are not encoded into `vocabulary_library` and `write` never receives them.

Chips, in order: love, study, work, student, counterrevolutionaries, synchronization, internationalization.

Suggested sets, in order: Love vocabulary, Study vocabulary, Work vocabulary, Student vocabulary, Daily vocabulary.

Word card: student, `UK /ˈstjuːdnt/`, `US /ˈstuːdnt/`, "a person who is studying at a university or college", 80.

Suggested practice, in order: Practice "love", Practice "study", Practice "work", Practice "student", Practice "synchronization".

Putting the templates in the JSON document was considered. A missing library would then have to be seeded, which the library spec forbids.

### Empty library swaps the main column

`VocabularyHome` takes an optional `HomeSample` and a `VocabularyLibrary`. A caller that passes `sample` gets that fixture, which keeps `HomeSample.current` paintable. `LangApp` does not pass `sample`. It passes the loaded library.

With no `sample` and no folders, the widget keeps `HomeHeader` and `HomeSidebar` and replaces the statistics heading, `StatisticsPanel`, `TodayPanel`, and `RecentPanel` with two cards in that row. The left card is Hot search, then Suggested sets. The right card is the word, then Suggested practice. Cards use `HomeColors.border`, a 12px radius, and `HomeText`. Chip, Save, and row taps are empty callbacks.

With no `sample` and at least one folder, map the library through `homeSampleFromLibrary`: folders expanded, blank statistics name, 0/0, 0%, no bars, six legend levels at 0%, no today rows, no recent cards, Homepage selected. The suggestion columns are not built.

`VocabularyHome()` with neither argument shows the suggestions, so the old default of `HomeSample.current` cannot leak back.

### Suggestion chrome is generated copy

Add these ARB keys and run `flutter gen-l10n`. `saveCount` takes the count.

| Key | English | Vietnamese | German |
| --- | --- | --- | --- |
| hotSearch | Hot search | Tìm kiếm nổi bật | Beliebte Suche |
| suggestedSets | Suggested sets | Bộ từ gợi ý | Vorgeschlagene Sets |
| suggestedPractice | Suggested practice | Luyện tập gợi ý | Vorgeschlagenes Üben |
| saveWord | Save | Lưu từ | Speichern |
| saveCount | {count} saves | {count} Lượt lưu | {count} Mal gespeichert |

Template words stay literal. They are not ARB entries.

### Map and load at the app shell

`loadVocabularyLibrary()` reads preferences in `main`, next to `loadAppLanguageController()`. If preferences cannot be opened, the library is empty. `LangApp` takes the library and passes it to `VocabularyHome`.

Loading inside `VocabularyHome` was considered. Language is already loaded before the first frame, and an async load in the widget would paint the wrong home first.

### Write exists, the home does not use it

The store can replace the document with a library of names. New vocab, Practice, search, Library, Notification, All, chips, Save, and template rows do not call the store. Tests and the next change use `write`. The All switch may still flip locally on the stored-library dashboard. That flip is not saved.

## Risks / Trade-offs

- [The suggestion columns are a second layout beside the dashboard] → Accepted. The empty library and a stored library are different screens, and the panels have no place to draw chips.
- [A corrupt document stays on disk and every launch shows the suggestions] → Accepted. Leaving the bytes in place avoids deleting a future document this build cannot read.
- [The durable home spec still requires a non-web counter the app does not have] → Leave that requirement untouched, as the proposal says.
- [`widget_test`, `vocabulary_home_test`, and `vocabulary_home_language_test` assert 5/20 and German A1 on a fresh `LangApp`] → Those launch assertions move to the suggestion templates. `HomeSample.current` stays covered as a fixture, not as what `LangApp` opens on.

## Migration Plan

No existing library key. Installing this build shows the suggestion templates. Rolling back ignores `vocabulary_library` and shows the German A1 sample again. Saved names remain in preferences, unused, until a build that reads them returns.
