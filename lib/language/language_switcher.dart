import 'package:flutter/material.dart';
import 'package:lang/l10n/app_localizations.dart';
import 'package:lang/language/app_language.dart';
import 'package:lang/language/app_language_scope.dart';
import 'package:lang/theme/app_theme_mode.dart';
import 'package:lang/theme/app_theme_scope.dart';
import 'package:lang/theme/home_palette.dart';
import 'package:lang/theme/home_text.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final languageController = AppLanguageScope.of(context);
    final themeController = AppThemeScope.maybeOf(context);
    final localizations = AppLocalizations.of(context);
    final colors = HomePalette.of(context);
    return PopupMenuButton<Object>(
      key: const Key('avatar-menu'),
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      color: colors.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.border),
      ),
      icon: child == null ? Icon(Icons.language, color: colors.ink) : null,
      onSelected: (value) {
        switch (value) {
          case final AppLanguage language:
            languageController.select(language);
          case final AppThemeMode mode:
            themeController?.select(mode);
        }
      },
      itemBuilder: (context) {
        final active = languageController.language;
        final dark = themeController?.mode == AppThemeMode.dark;
        return [
          const PopupMenuItem<Object>(
            enabled: false,
            height: 72,
            child: _AccountHeader(),
          ),
          PopupMenuItem<Object>(
            value: _AccountAction.achievements,
            child: _IconLabel(
              icon: Icons.emoji_events_outlined,
              label: localizations.menuAchievements,
            ),
          ),
          PopupMenuItem<Object>(
            value: _AccountAction.settings,
            child: _IconLabel(
              icon: Icons.settings_outlined,
              label: localizations.menuSettings,
            ),
          ),
          if (themeController != null)
            PopupMenuItem<Object>(
              value: dark ? AppThemeMode.light : AppThemeMode.dark,
              child: _IconLabel(
                icon: dark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                label: dark
                    ? localizations.menuLightMode
                    : localizations.menuDarkMode,
              ),
            ),
          const PopupMenuDivider(),
          PopupMenuItem<Object>(
            value: _AccountAction.logOut,
            child: _PlainLabel(label: localizations.menuLogOut),
          ),
          const PopupMenuDivider(),
          PopupMenuItem<Object>(
            value: _AccountAction.privacy,
            child: _PlainLabel(label: localizations.menuPrivacy),
          ),
          PopupMenuItem<Object>(
            value: _AccountAction.help,
            child: _PlainLabel(label: localizations.menuHelp),
          ),
          PopupMenuItem<Object>(
            value: _AccountAction.upgrade,
            child: _PlainLabel(label: localizations.menuUpgrade),
          ),
          const PopupMenuDivider(),
          for (final language in AppLanguage.values)
            PopupMenuItem<Object>(
              value: language,
              child: _MenuLabel(
                label: language.endonym,
                selected: language == active,
              ),
            ),
        ];
      },
      child: child,
    );
  }
}

enum _AccountAction { achievements, settings, logOut, privacy, help, upgrade }

const _menuWidth = 240.0;

class _AccountHeader extends StatelessWidget {
  const _AccountHeader();

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final text = HomeText.of(context);
    return SizedBox(
      width: _menuWidth,
      child: Row(
        children: [
          ClipOval(
            child: Image.asset(
              'assets/images/avatar.jpg',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'in4techit',
                  style: text.subtitle.copyWith(
                    color: colors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'in4tech.it@gmail.com',
                  style: text.caption.copyWith(color: colors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconLabel extends StatelessWidget {
  const _IconLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final text = HomeText.of(context);
    return SizedBox(
      width: _menuWidth,
      child: Row(
        children: [
          Icon(icon, size: 22, color: colors.text),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: text.subtitle.copyWith(color: colors.text),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlainLabel extends StatelessWidget {
  const _PlainLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final text = HomeText.of(context);
    return SizedBox(
      width: _menuWidth,
      child: Text(label, style: text.subtitle.copyWith(color: colors.text)),
    );
  }
}

class _MenuLabel extends StatelessWidget {
  const _MenuLabel({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final text = HomeText.of(context);
    return SizedBox(
      width: _menuWidth,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: text.subtitle.copyWith(
                color: selected ? colors.selected : colors.text,
              ),
            ),
          ),
          if (selected)
            Icon(Icons.check, size: 18, color: colors.selected)
          else
            const SizedBox(width: 18),
        ],
      ),
    );
  }
}
