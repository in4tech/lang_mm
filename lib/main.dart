import 'package:flutter/widgets.dart';
import 'package:lang/app/lang_app.dart';
import 'package:lang/language/app_language_controller.dart';
import 'package:lang/library/vocabulary_library_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = await loadAppLanguageController();
  final library = await loadVocabularyLibrary();
  runApp(LangApp(controller: controller, library: library));
}
