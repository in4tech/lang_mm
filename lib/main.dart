import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:lang/app/lang_app.dart';
import 'package:lang/firebase_options.dart';
import 'package:lang/language/app_language_controller.dart';
import 'package:lang/library/device_library.dart';
import 'package:lang/library/firestore_vocabulary_set_store.dart';
import 'package:lang/library/study_progress.dart';
import 'package:lang/library/vocabulary_library.dart';
import 'package:lang/library/vocabulary_library_store.dart';
import 'package:lang/library/vocabulary_set.dart';
import 'package:lang/theme/app_theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final controller = await loadAppLanguageController();
  final themeController = await loadAppThemeController();
  final local = await loadVocabularyLibrary();
  final opened = await _openDeviceLibrary(local);
  runApp(
    LangApp(
      controller: controller,
      themeController: themeController,
      library: opened.library,
      setStore: opened.store,
      studyProgress: opened.studyProgress,
    ),
  );
}

class _OpenedLibrary {
  const _OpenedLibrary({
    required this.library,
    required this.store,
    this.studyProgress,
  });

  final VocabularyLibrary library;
  final VocabularySetStore? store;
  final StudyProgressStore? studyProgress;
}

Future<_OpenedLibrary> _openDeviceLibrary(VocabularyLibrary local) async {
  try {
    final auth = FirebaseAuth.instance;
    final restored = await auth.authStateChanges().first.timeout(
      const Duration(seconds: 15),
    );
    final user = restored ?? (await auth.signInAnonymously()).user;
    final ownerId = user?.uid;
    if (ownerId == null) {
      return _OpenedLibrary(library: local, store: null);
    }
    final libraryOwner = ownerIdForLibraryRead(
      debugMode: kDebugMode,
      signedInOwnerId: ownerId,
    );
    final cloudStore = FirestoreVocabularySetStore(
      ownerId: ownerId,
      readOwnerId: libraryOwner,
    );
    final library = await libraryForDevice(
      local: local,
      readCloud: cloudStore.loadLibrary,
      store: cloudStore,
    );
    if (!identical(library, local)) {
      final preferences = await SharedPreferences.getInstance();
      await SharedPreferencesVocabularyLibraryStore(preferences).write(library);
    }
    return _OpenedLibrary(
      library: library,
      store: cloudStore,
      studyProgress: FirestoreStudyProgressStore(ownerId: libraryOwner),
    );
  } catch (_) {
    return _OpenedLibrary(library: local, store: null);
  }
}
