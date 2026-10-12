import 'package:flutter/widgets.dart';

enum AppLanguage {
  english('en', 'English'),
  vietnamese('vi', 'Tiếng Việt'),
  german('de', 'Deutsch');

  const AppLanguage(this.storageCode, this.endonym);

  final String storageCode;
  final String endonym;

  static const storageKey = 'app_language';

  Locale get locale => Locale(storageCode);

  static AppLanguage fromCode(String? code) {
    for (final language in AppLanguage.values) {
      if (language.storageCode == code) {
        return language;
      }
    }
    return AppLanguage.english;
  }
}
