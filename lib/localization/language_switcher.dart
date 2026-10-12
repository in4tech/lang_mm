import 'package:flutter/material.dart';
import 'package:lang/localization/app_language.dart';
import 'package:lang/localization/app_language_scope.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppLanguageScope.of(context);
    return PopupMenuButton<AppLanguage>(
      icon: const Icon(Icons.language),
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
    );
  }
}
