import 'package:flutter_test/flutter_test.dart';
import 'package:lang/localization/app_language.dart';
import 'package:lang/localization/app_language_controller.dart';
import 'package:lang/localization/app_language_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<AppLanguage> loadStored(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    final controller = await loadAppLanguageController();
    return controller.language;
  }

  test('empty store resolves to English', () async {
    expect(await loadStored(<String, Object>{}), AppLanguage.english);
  });

  test('stored de resolves to German', () async {
    expect(
      await loadStored(<String, Object>{AppLanguage.storageKey: 'de'}),
      AppLanguage.german,
    );
  });

  test('stored vi resolves to Vietnamese', () async {
    expect(
      await loadStored(<String, Object>{AppLanguage.storageKey: 'vi'}),
      AppLanguage.vietnamese,
    );
  });

  test('unsupported stored code resolves to English', () async {
    expect(
      await loadStored(<String, Object>{AppLanguage.storageKey: 'fr'}),
      AppLanguage.english,
    );
  });

  test('a throwing read resolves to English', () async {
    final controller = await AppLanguageController.load(
      const _ThrowingReadStore(),
    );

    expect(controller.language, AppLanguage.english);
  });

  test('select notifies listeners before it saves', () async {
    final store = _RecordingStore();
    final controller = AppLanguageController(store);
    var notifiedBeforeWrite = false;
    controller.addListener(() {
      notifiedBeforeWrite =
          controller.language == AppLanguage.german && store.savedCode == null;
    });

    await controller.select(AppLanguage.german);

    expect(notifiedBeforeWrite, isTrue);
    expect(controller.language, AppLanguage.german);
    expect(store.savedCode, 'de');
  });

  test('a failed write keeps the selected language', () async {
    final controller = AppLanguageController(const _ThrowingWriteStore());

    await controller.select(AppLanguage.vietnamese);

    expect(controller.language, AppLanguage.vietnamese);
  });
}

class _ThrowingReadStore implements AppLanguageStore {
  const _ThrowingReadStore();

  @override
  Future<String?> read() async {
    throw StateError('read failed');
  }

  @override
  Future<void> write(String code) async {}
}

class _ThrowingWriteStore implements AppLanguageStore {
  const _ThrowingWriteStore();

  @override
  Future<String?> read() async => null;

  @override
  Future<void> write(String code) async {
    throw StateError('write failed');
  }
}

class _RecordingStore implements AppLanguageStore {
  String? savedCode;

  @override
  Future<String?> read() async => savedCode;

  @override
  Future<void> write(String code) async {
    savedCode = code;
  }
}
