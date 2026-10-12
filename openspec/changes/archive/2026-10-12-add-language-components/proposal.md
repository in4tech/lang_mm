# Proposal

## Why

The app is still the stock Flutter counter and has no way to present itself in more than one language. Vietnamese, English, and German need to be first-class from the start, with English as the language the app uses until the user chooses otherwise.

## What Changes

- Add an in-app language component that offers exactly Vietnamese (`vi`), English (`en`), and German (`de`), and shows which one is active.
- Start every fresh install in English, including when the device language is Vietnamese or German. A later choice replaces that default and is kept across restarts.
- Resolve UI copy from the active language. A missing translation falls back to English.
- Localize the current home screen (title, counter message, and increment action) so switching language changes what the user sees without leaving the screen.
- Apply the active locale to the app shell so framework-provided Material and Cupertino strings follow the same language.

Assumptions:

- "Default is English" means the initial language is English, not "match the device when it is one of the three."
- The component set is the language switcher plus the localized copy the shell reads. It is not a broader design system.
- Only these three languages are in scope.

## Capabilities

### New Capabilities

- `app-localization`: Supported languages, English as the initial and fallback language, a persisted in-app language choice, and UI copy that follows the active language.

### Modified Capabilities

- None. The project has no existing specs.

## Impact

- `lib/main.dart` and the home screen, which today hard-code English strings.
- `pubspec.yaml`, to enable Flutter localizations and code generation. No remote translation service.
- `test/widget_test.dart`, which pumps `MyApp` and asserts on the counter. It must keep passing once copy is localized, and new tests should cover language switching.
- New localization resources and a small set of widgets under `lib/`. No platform store listings, no additional languages, and no right-to-left layout work.
