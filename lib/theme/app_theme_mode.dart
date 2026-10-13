enum AppThemeMode {
  light,
  dark;

  static const storageKey = 'theme_mode';

  static AppThemeMode fromCode(String? code) {
    return switch (code) {
      'light' => AppThemeMode.light,
      _ => AppThemeMode.dark,
    };
  }

  String get storageCode => switch (this) {
    AppThemeMode.light => 'light',
    AppThemeMode.dark => 'dark',
  };
}
