import 'package:flutter/foundation.dart';
import 'package:lang/theme/app_theme_mode.dart';
import 'package:lang/theme/app_theme_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeController extends ChangeNotifier {
  AppThemeController(
    this._store, {
    AppThemeMode initial = AppThemeMode.dark,
  }) : mode = initial;

  final AppThemeStore _store;

  AppThemeMode mode;

  static Future<AppThemeController> load(AppThemeStore store) async {
    try {
      final code = await store.read();
      return AppThemeController(store, initial: AppThemeMode.fromCode(code));
    } catch (_) {
      return AppThemeController(store);
    }
  }

  Future<void> select(AppThemeMode next) async {
    mode = next;
    notifyListeners();
    try {
      await _store.write(next.storageCode);
    } catch (_) {
      // The in-memory choice stays for this session. The next launch uses
      // the last successful write, or light when none exists.
    }
  }
}

Future<AppThemeController> loadAppThemeController() async {
  try {
    final preferences = await SharedPreferences.getInstance();
    return await AppThemeController.load(
      SharedPreferencesAppThemeStore(preferences),
    );
  } catch (_) {
    return AppThemeController(const UnavailableAppThemeStore());
  }
}
