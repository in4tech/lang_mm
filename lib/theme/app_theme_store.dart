import 'package:lang/theme/app_theme_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AppThemeStore {
  Future<String?> read();

  Future<void> write(String code);
}

class SharedPreferencesAppThemeStore implements AppThemeStore {
  SharedPreferencesAppThemeStore(this._preferences);

  final SharedPreferences _preferences;

  @override
  Future<String?> read() async {
    return _preferences.getString(AppThemeMode.storageKey);
  }

  @override
  Future<void> write(String code) {
    return _preferences.setString(AppThemeMode.storageKey, code);
  }
}

class UnavailableAppThemeStore implements AppThemeStore {
  const UnavailableAppThemeStore();

  @override
  Future<String?> read() async => null;

  @override
  Future<void> write(String code) async {}
}
