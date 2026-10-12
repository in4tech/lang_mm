# Proposal

## Why

The app still opens on the Flutter counter, so there is no vocabulary home to match the desktop design. The first screen on web should be that dashboard, with the language choice still available on it.

## What Changes

- On web, open the desktop vocabulary dashboard from the design: header, sidebar, statistics, today's vocabulary, and recent sets.
- On every other platform, keep the counter home, its copy, and the app-bar language menu.
- Show the sample content from the screenshot, including the pictured selection (Homepage selected, My vocab expanded, My vocab 2 collapsed).
- Localize the new web home chrome in Vietnamese, English, and German. Sample set names and vocabulary entries stay as drawn. The counter strings stay in the catalogs.

Assumptions:

- This slice is a faithful 1440-wide picture of the screenshot, and only the web build shows it. Where the exported CSS and the screenshot disagree, the screenshot wins: the button reads "Continue", the All knob sits on the right, the statistics copy says 5/20 and 25%, the B1 card says 93% complete, and the bars are labeled 3 and 2 beside the drawn legend percents.
- Search, New vocab, Practice, Continue, sidebar destinations, the All switch, and the Recent chevron are visible and do not navigate or change data.
- Viewports narrower than 1440 scroll this same layout. A separate phone layout is out of scope.
- At rest the web header matches the picture. The avatar opens the existing language menu, so language can still be changed without leaving the web home.

## Capabilities

### New Capabilities

- `home-screen`: The desktop vocabulary home on web, its regions, and the sample content and selection shown in the design. Other platforms keep the counter.

### Modified Capabilities

- `app-localization`: Web home chrome exists in Vietnamese, English, and German. Switching language on that home updates the chrome and leaves the pictured sample in place. Counter copy and the counter language scenarios stay for every other platform.

## Impact

- `lib/main.dart`, which chooses the web home or the existing counter and puts `LanguageSwitcher` in the counter app bar.
- `lib/l10n/app_en.arb`, `app_vi.arb`, and `app_de.arb`: add the web home chrome keys. `homeTitle`, `counterMessage`, and `incrementAction` stay.
- `test/widget_test.dart` and the language tests keep covering the counter. New tests opt into the web home, because the VM test surface is not web.
- New home widgets, the attached logo asset, and the Poppins font. No vocabulary backend, no new routes, and no chart package.
