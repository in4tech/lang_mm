# Design

## Context

See proposal.md for why the home stops scaling with the window. `VocabularyHome.designWidth` is 1440. `_HomeFrame` measures the viewport in a `LayoutBuilder`, then a `FittedBox` with `BoxFit.fitWidth` scales a 1440-wide column to that width. `HomeHeader` is a single row fixed at 1440. The menu toggles `HomeSidebar` between 288 and 72 inside that column. Statistics sit beside `TodayPanel` (fixed 302 by 372). `RecentPanel` is a horizontal strip fixed at 1074. `SuggestionColumns` is a row of two cards. Home widget tests already set the surface to 1600 by 1200. `test/widget_test.dart` does not, so its surface is narrower than 1440.

## Goals / Non-Goals

**Goals:**

- Choose the wide frame or the phone column from the viewport width against 1440.
- Keep the wide frame's collapse-in-place sidebar, one-row header, and side-by-side main area.
- Give the phone column its own header, overlay sidebar, and stacked main area.

**Non-Goals:**

- An advertisement, an ad slot, or a background color for the side space.
- A tablet layout between the phone column and the 1440 frame.
- New copy, or any change to which words the empty home and the loaded library show.
- Restoring the non-web counter.

## Decisions

### Two frames, chosen once per width

In `_HomeFrame`, when `constraints.maxWidth` is at least 1440, the header fills the viewport and the sidebar stays at the left edge. The main content keeps `VocabularyHome.designWidth` minus the open sidebar width, centered in the space beside the sidebar, inside that area's vertical scroll view. Collapsing the sidebar does not change that width. Remove the `FittedBox`. A non-finite width uses this same wide frame, which is what the home does today when the incoming width is unbounded.

Below 1440, build a different column that is as wide as the viewport. Do not scale the 1440 column down.

Keeping one tree and letting rows wrap was considered. The header, today card, and recent strip are fixed to the desktop frame, so a second composition is the smaller change. The empty home and the loaded-library home already swap the main area the same way.

### Wide sidebar collapse stays; the phone sidebar is a separate overlay

The wide frame keeps `_collapsed`. The sidebar column stays at `HomeSidebar.width` when it collapses, so the main content width does not change. Labels still hide.

The phone frame keeps its own open flag. The menu toggles it. While it is open, a barrier behind `HomeSidebar` covers the page, and a tap on that barrier closes the sidebar. The sidebar is the same widget, at `HomeSidebar.width`, drawn over the column rather than beside it. The phone frame does not use the collapsed 72-wide state.

Crossing 1440 does not copy one flag onto the other. At 1440 or wider the overlay is not built, and below 1440 the in-column sidebar is not built.

`Scaffold.drawer` was considered. An overlay in the phone body keeps the wide frame free of a drawer and leaves the debug toggle on the scaffold.

### The phone header is the same controls, in three rows

`HomeHeader` takes a flag for the narrow frame. The wide frame keeps the current 1440-wide row: menu, lang mark, search, New vocab, avatar.

The narrow frame uses the column width. First row: menu, lang mark, avatar. Second row: the search field. Third row: New vocab, stretched to that row. Reuse the existing search field, button, avatar, and language switcher.

### The phone main area stacks what the wide frame places side by side

`SuggestionColumns` takes the same flag. Wide stays a row: Hot search and Suggested sets, then the word and Suggested practice. Narrow is a column in that same order.

`_Dashboard` takes the same flag. Wide stays statistics beside today, then Recent. Narrow is statistics, then today, then Recent. On the narrow frame, `TodayPanel` and the recent strip take the column width instead of 302 and 1074. Recent cards keep their width and the existing horizontal scroll.

The narrow column uses 16px of horizontal padding so the cards do not sit on the viewport edge.

## Risks / Trade-offs

- [At 1600 the frame used to be scaled up to the window, and it will now sit centered at 1440] → The home tests at 1600 by 1200 assert layout sizes inside the frame, which stay 1440-based. Re-check any assertion that assumes the frame starts at the left edge of the surface.
- [Today and Recent overflow the phone column if their fixed widths remain] → The narrow frame passes the column width into those two panels.
- [`test/widget_test.dart` pumps `LangApp` on the default surface, which is under 1440] → That test becomes a phone-column check. It still expects Hot search, the search hint, and student, which the stacked column shows.
- [A 1200-wide window gets the phone column, with long lines and a hidden sidebar] → Accepted. The proposal has one cut, at 1440.

## Migration Plan

No stored data. Shipping this build centers the 1440 frame and uses the phone column below that width. Rolling back restores the scaled frame. Nothing in preferences changes.
