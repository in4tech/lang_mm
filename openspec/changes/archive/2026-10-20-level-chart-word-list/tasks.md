# Tasks

## 1. Level word filter

- [x] 1.1 Add a `statisticsWordsAtLevel` helper (or equivalent) next to `statisticsWords` that returns words at a given level 1–6 in the same All on/off scope, omitting words with no level. Verify unit tests for level 1 vs level 6 filtering and an empty level.

## 2. Chart bar taps

- [x] 2.1 Make each statistics chart bar tappable with keys for levels 1–6 left to right, open `showLearnedWordsDialog` titled with that level's legend label and the filtered list, and leave the legend non-interactive. Wire lists from the home dashboard using the helper. Verify widget tests: leftmost bar opens "Lv.1 - Forgot (1)" with Kind, rightmost opens "Lv.6 - Mastered (1)" with Haus, empty level 3 opens "(0)", and activating a legend row does not open a dialog.

## Workflow follow-up

- Archive the change after implementation and review.
- Sync the home-screen delta into main specs on archive (or `/opsx-sync`).
