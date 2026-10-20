# Proposal

## Why

Home statistics already open word lists from the "Words learned" and "Words not yet learned" captions, but the level chart bars are inert. Learners cannot inspect which words sit at a specific level without leaving the dashboard.

## What Changes

- Make each statistics chart bar (column) activate a word-list dialog for that bar's level
- On hover, show that level's legend label with a swatch in the bar's color
- Reuse the existing learned-words dialog (search, cards, title with count)
- Title the dialog with that level's legend label and the count of matching words in the current statistics scope (All on/off)
- Leave the legend rows non-interactive
- Opening an empty level still shows the dialog with count 0

## Capabilities

### New Capabilities

- (none)

### Modified Capabilities

- `home-screen`: Add requirements for activating a chart bar to open the level word list; keep existing learned/not-learned captions as they are

## Impact

- `lib/features/home/widgets/statistics_panel.dart` — tap targets on bars
- `lib/features/home/home_from_library.dart` — helper to collect words for a given level in the statistics scope
- `lib/features/home/vocabulary_home.dart` — pass level word lists or a lookup into the panel
- Widget tests for home statistics / learned dialogs
