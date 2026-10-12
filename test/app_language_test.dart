import 'package:flutter_test/flutter_test.dart';
import 'package:lang/localization/app_language.dart';

void main() {
  test('fromCode maps stored codes and falls back to English', () {
    expect(AppLanguage.fromCode(null), AppLanguage.english);
    expect(AppLanguage.fromCode(''), AppLanguage.english);
    expect(AppLanguage.fromCode('fr'), AppLanguage.english);
    expect(AppLanguage.fromCode('en'), AppLanguage.english);
    expect(AppLanguage.fromCode('vi'), AppLanguage.vietnamese);
    expect(AppLanguage.fromCode('de'), AppLanguage.german);
  });

  test('each language exposes its storage code, locale, and endonym', () {
    expect(AppLanguage.english.storageCode, 'en');
    expect(AppLanguage.english.locale.languageCode, 'en');
    expect(AppLanguage.english.endonym, 'English');

    expect(AppLanguage.vietnamese.storageCode, 'vi');
    expect(AppLanguage.vietnamese.locale.languageCode, 'vi');
    expect(AppLanguage.vietnamese.endonym, 'Tiếng Việt');

    expect(AppLanguage.german.storageCode, 'de');
    expect(AppLanguage.german.locale.languageCode, 'de');
    expect(AppLanguage.german.endonym, 'Deutsch');
  });
}
