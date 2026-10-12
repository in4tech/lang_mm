import 'package:flutter_test/flutter_test.dart';
import 'package:lang/language/app_language_controller.dart';
import 'package:lang/app/lang_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('the app opens on the vocabulary home', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final controller = await loadAppLanguageController();
    await tester.pumpWidget(LangApp(controller: controller));

    expect(find.text('Your vocabulary statistics'), findsOneWidget);
    expect(find.text('Find your vocab...'), findsOneWidget);
    expect(find.text('5/20'), findsOneWidget);
    expect(
      find.text('You have pushed the button this many times:'),
      findsNothing,
    );
  });
}
