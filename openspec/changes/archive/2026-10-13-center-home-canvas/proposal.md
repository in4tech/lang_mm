# Proposal

## Why

The vocabulary home is drawn at a 1440-wide design and then scaled to whatever width the window has. On a wide screen the type and cards grow. On a narrow screen the same desktop frame shrinks until the header, sidebar, and two-column main area are too small to use.

## What Changes

- **BREAKING** for how the web home fills the window. At a viewport of 1440 or wider, the header fills the viewport width and the sidebar stays on the left. Only the main content keeps its design width, centered in the space beside the sidebar. The home no longer scales that content up or down to the window width. Width past the content is empty space on its left and on its right. That space is not an advertisement.
- Below 1440 there is one full-width column, not a scaled copy of the 1440 frame and not a tablet layout. The first header row is the menu, the lang mark, and the avatar. Search is the next row. New vocab is the next row. The sidebar is hidden until the menu opens it over the page. Tapping outside that overlay, or tapping the menu again, closes it.
- An empty library stacks the current suggestion columns: Hot search and Suggested sets, then the suggested word and Suggested practice. A library with folders stacks statistics, then Today's vocabulary, then Recent. Recent cards still scroll sideways inside the column.
- At 1440 or wider, the menu still collapses the sidebar in place. The same words, counts, and actions stay on screen in both layouts. Non-web builds are unchanged by this change.

Assumptions:

- The cut is the viewport width, at 1440. A window of 800 or 1200 uses the same phone column.
- The side space is the page background. This change does not reserve an ad slot or draw an ad.
- The durable `home-screen` spec still says non-web builds open the counter. The app no longer has that counter and always opens the vocabulary home. This change does not restore the counter and does not edit that requirement.

## Capabilities

### New Capabilities

### Modified Capabilities

- `home-screen`: At 1440 or wider the header fills the width, the sidebar stays on the left, and the main content keeps its design width, centered, with empty side space. Below 1440 it is one column, with the sidebar in a menu overlay and the main area stacked.

## Impact

- `lib/features/home/vocabulary_home.dart`, which wraps the 1440 frame in a `FittedBox` and lays statistics beside Today's vocabulary.
- `lib/features/home/widgets/home_header.dart`, whose header is a single 1440-wide row.
- `lib/features/home/widgets/suggestion_columns.dart`, `today_panel.dart`, and `recent_panel.dart`, which use fixed widths from the desktop frame.
- `test/features/home/vocabulary_home_test.dart` and the other home tests, which already open the home at 1600 by 1200 and so stay on the wide layout. `test/widget_test.dart` uses the default test surface, which is narrower than 1440, so it will exercise the phone column.
