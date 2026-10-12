import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lang/l10n/app_localizations.dart';
import 'package:lang/localization/app_language_controller.dart';
import 'package:lang/localization/app_language_scope.dart';
import 'package:lang/localization/language_switcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = await loadAppLanguageController();
  runApp(LangApp(controller: controller));
}

class LangApp extends StatefulWidget {
  const LangApp({super.key, required this.controller});

  final AppLanguageController controller;

  @override
  State<LangApp> createState() => _LangAppState();
}

class _LangAppState extends State<LangApp> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onLanguageChanged);
  }

  @override
  void didUpdateWidget(LangApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onLanguageChanged);
      widget.controller.addListener(_onLanguageChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final language = widget.controller.language;
    return AppLanguageScope(
      controller: widget.controller,
      child: MaterialApp(
        title: lookupAppLocalizations(language.locale).homeTitle,
        locale: language.locale,
        supportedLocales: const [Locale('en'), Locale('vi'), Locale('de')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(localizations.homeTitle),
        actions: const [LanguageSwitcher()],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(localizations.counterMessage),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: localizations.incrementAction,
        child: const Icon(Icons.add),
      ),
    );
  }
}
