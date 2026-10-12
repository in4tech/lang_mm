import 'package:lang/localization/app_language.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AppLanguageStore {
  Future<String?> read();

  Future<void> write(String code);
}

class SharedPreferencesAppLanguageStore implements AppLanguageStore {
  SharedPreferencesAppLanguageStore(this._preferences);

  final SharedPreferences _preferences;

  @override
  Future<String?> read() async {
    return _preferences.getString(AppLanguage.storageKey);
  }

  @override
  Future<void> write(String code) {
    return _preferences.setString(AppLanguage.storageKey, code);
  }
}

class UnavailableAppLanguageStore implements AppLanguageStore {
  const UnavailableAppLanguageStore();

  @override
  Future<String?> read() async => null;

  @override
  Future<void> write(String code) async {}
}
