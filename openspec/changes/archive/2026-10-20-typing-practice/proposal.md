# Proposal

## Why

Typing exists as a practice mode but is only a shell: it shows the term (spoiling the answer), has a borrowed editor hint, never checks input, and never updates study levels. Learners need productive recall—see meaning cues, type the term, get feedback, then rate—matching the depth Quiz already has for recognition.

## What Changes

- Replace the Typing card with a meaning-cue layout: IPA, type, definition, and example sentence with the term blanked as `---`; omit empty fields
- Add a typed-answer field, Check (and Enter), and Don't know
- Check answers with trim + lowercase comparison against the term
- After Check or Don't know, lock the field, show wrong / skip feedback when needed (reuse Quiz tones and copy; no praise text on correct), then show Hard / Familiar / Easy or the new-word controls
- Rating advances like Quiz (including congratulations on the last word); leaving before a rating keeps the level
- Remove previous / next controls in Typing (same as Quiz)
- Add Typing-specific localization for answer labels and hints; reuse existing Quiz result copy where shared

## Capabilities

### New Capabilities

- (none)

### Modified Capabilities

- `study-session`: Define Typing prompt, answer check, Don't know, feedback, level controls, and advance; replace the current “Typing leaves level unchanged / no ratings” rules
- `app-localization`: Add Typing answer / hint / check copy in Vietnamese, English, and German; clarify shared Quiz result strings also apply on Typing

## Impact

- `lib/features/home/widgets/set_study_page.dart` — Typing card and session flow
- Likely a dedicated Typing card widget (parallel to `quiz_card.dart`) and shared check / blank helpers
- `lib/features/home/quiz_tone.dart` — reuse for Typing feedback tones
- `lib/l10n/app_*.arb` — new Typing strings
- New widget tests modeled on `test/features/home/quiz_practice_test.dart`
- OpenSpec main specs for `study-session` and `app-localization` after archive/sync
