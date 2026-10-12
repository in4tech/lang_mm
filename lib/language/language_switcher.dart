import 'package:flutter/material.dart';
import 'package:lang/language/app_language.dart';
import 'package:lang/language/app_language_scope.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final controller = AppLanguageScope.of(context);
    return PopupMenuButton<AppLanguage>(
      icon: child == null ? const Icon(Icons.language) : null,
      onSelected: controller.select,
      itemBuilder: (context) {
        final active = controller.language;
        return [
          for (final language in AppLanguage.values)
            PopupMenuItem<AppLanguage>(
              value: language,
              child: Row(
                children: [
                  Expanded(child: Text(language.endonym)),
                  if (language == active) const Icon(Icons.check),
                ],
              ),
            ),
        ];
      },
      child: child,
    );
  }
}
