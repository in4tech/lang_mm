import 'package:flutter/widgets.dart';
import 'package:lang/app/lang_app.dart';
import 'package:lang/language/app_language_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = await loadAppLanguageController();
  runApp(LangApp(controller: controller));
}
