# Design

## Context

See proposal.md for why. `StatisticsPanel` already opens `showLearnedWordsDialog` from the learned / not-learned footer. Chart bars are painted in `_BarChart` without hit targets. `statisticsWords` filters only mastered vs not. Bars are built left-to-right as levels 1–6 in `_LevelCounts.bars()`; legend rows are levels 6–1.

## Goals / Non-Goals

**Goals:**

- Tap a bar → same dialog UX as learned words, filtered to that level and the current All scope.
- Keep legend inert.

**Non-Goals:**

- Making legend rows tappable.
- A new dialog layout or practice launch from the list.
- Showing words with no stored level on any bar (they already sit outside bar counts).

## Decisions

### Reuse `showLearnedWordsDialog`

Pass title = localized legend label for that level (same strings as `_Legend`) and the filtered word list. Count in the title stays the full list size while search filters cards — existing dialog behavior.

Alternative: a dedicated level dialog. Rejected — identical cards and search.

### Filter helper beside `statisticsWords`

Add something like `statisticsWordsAtLevel(..., level: n)` that walks the same set scope as `statisticsWords` / dashboard All on-off, including only words whose stored level equals `n`. Words with no level are omitted.

### Wire taps on the bar column

Wrap each bar column (or the colored bar) in a `GestureDetector` / `InkWell` with a stable key such as `statistics-bar-1` … `statistics-bar-6`. Map bar index `i` → level `i + 1`. Call the dialog from `StatisticsPanel` with lists supplied by the home dashboard (precomputed map or callback), matching how learned/not-learned lists are passed today.

Alternative: compute lists inside the panel. Rejected — panel already receives word lists from `vocabulary_home` / `home_from_library`.

### Hover shows level label and color

Wrap each bar in a `Tooltip` with `richMessage`: a colored circle matching the bar plus the legend label for that level. Short wait duration so desktop hover feels immediate.

## Risks / Trade-offs

- [Bar index confused with legend order] → Spec and keys use left-to-right level 1–6 explicitly; do not index into the legend list.
- [Empty bars look untappable] → Still open the empty dialog so behavior matches every bar.

## Migration Plan

No data migration. Rollback is reverting the panel taps and the level filter helper.

## Open Questions

None.
