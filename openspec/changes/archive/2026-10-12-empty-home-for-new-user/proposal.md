# Proposal

## Why

A fresh launch paints the German A1 sample as if it were the user's vocabulary. There is no library to load, so a new user cannot see an empty home, and a later "New vocab" action would have nowhere to put a real set.

## What Changes

- Add a local vocabulary library that the app loads before showing the home. A missing or unreadable library is empty. The app does not seed German A1, or any other sample, into it.
- **BREAKING** for the home's launch content: with an empty library, the sidebar has no folders, and the main area shows suggestion templates instead of statistics, Today's vocabulary, and Recent. Header and sidebar chrome stay.
- The empty main area is two columns in the current card frame. The left column is Hot search chips, then Suggested sets. The right column is one suggested word card, then Suggested practice. The chips, the word, and both lists are fixed templates. They are not written into the library.
- When a library is already stored, the templates leave. The home shows that library's folder and set names, statistics at 0/0 and 0%, an empty today list, and no Recent cards, because this change does not store learning state or a today queue.
- New vocab, Practice, search, Library, Notification, All, a hot-search chip, Save, and a template row stay on the home. They do not create or edit vocabulary.
- Changing language translates the suggestion headings and leaves the template words in English. It does not fill or clear the library.

Assumptions:

- "New user" means this device has no saved vocabulary library. There are no accounts and no sync.
- Creating, editing, and deleting sets or words is a later change. This change only loads a library and renders it.
- `HomeSample.current` may remain a widget fixture. It is not the launch default and it is not written into the library.
- The durable `home-screen` spec still says non-web builds open the counter. The app no longer has that counter and always opens the vocabulary home. This change does not restore the counter and does not edit that requirement.

## Capabilities

### New Capabilities

- `vocabulary-library`: A device-local vocabulary library that starts empty, is loaded at launch, and is not seeded with sample sets.

### Modified Capabilities

- `home-screen`: The vocabulary home shows the loaded library. An empty library shows suggestion templates in the main area and no folders in the sidebar. A stored library shows folder and set names, with progress, today, and Recent empty.
- `app-localization`: Switching language keeps the loaded library and the suggestion templates on screen. Suggestion headings change language. Template words stay English. The German A1 sample is not restored.

## Impact

- `lib/main.dart` and `lib/app/lang_app.dart`, which today open `VocabularyHome` on `HomeSample.current`.
- A new library model and store next to the existing `SharedPreferences` language store. No new dependency.
- `lib/features/home/`, whose panels already render a `HomeSample` and have no empty library.
- `test/features/home/vocabulary_home_test.dart`, which expects the pictured sample from a fresh `LangApp`. Language tests that only switch chrome stay, except where they assume the sample survives a language change.
- `lib/l10n/app_en.arb`, `app_vi.arb`, and `app_de.arb`, for Hot search, Suggested sets, Suggested practice, Save, and the saves count.
