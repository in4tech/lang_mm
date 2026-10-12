import 'package:flutter/foundation.dart';
import 'package:lang/localization/app_language.dart';
import 'package:lang/localization/app_language_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguageController extends ChangeNotifier {
  AppLanguageController(
    this._store, {
    AppLanguage initial = AppLanguage.english,
  }) : language = initial;

  final AppLanguageStore _store;

  AppLanguage language;

  static Future<AppLanguageController> load(AppLanguageStore store) async {
    try {
      final code = await store.read();
      return AppLanguageController(store, initial: AppLanguage.fromCode(code));
    } catch (_) {
      return AppLanguageController(store);
    }
  }

  Future<void> select(AppLanguage next) async {
    language = next;
    notifyListeners();
    try {
      await _store.write(next.storageCode);
    } catch (_) {
      // The in-memory choice stays for this session. The next launch uses
      // the last successful write, or English when none exists.
    }
  }
}

Future<AppLanguageController> loadAppLanguageController() async {
  try {
    final preferences = await SharedPreferences.getInstance();
    return await AppLanguageController.load(
      SharedPreferencesAppLanguageStore(preferences),
    );
  } catch (_) {
    return AppLanguageController(const UnavailableAppLanguageStore());
  }
}
