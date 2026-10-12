import 'package:flutter/material.dart';
import 'package:lang/features/home/sample/home_sample.dart';
import 'package:lang/theme/home_colors.dart';
import 'package:lang/theme/home_text.dart';
import 'package:lang/l10n/app_localizations.dart';

class HomeSidebar extends StatelessWidget {
  const HomeSidebar({super.key, required this.sample});

  final HomeSample sample;

  static const width = 288.0;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _NavRow(
              key: const Key('nav-home'),
              icon: Icons.home_outlined,
              label: localizations.navHome,
              selected: sample.homepageSelected,
            ),
            _NavRow(
              icon: Icons.folder_open_outlined,
              label: localizations.navLibrary,
              onTap: () {},
            ),
            _NavRow(
              icon: Icons.notifications_none,
              label: localizations.navNotification,
              onTap: () {},
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: HomeColors.border),
            const SizedBox(height: 8),
            _SectionLabel(label: localizations.vocabularySet),
            const SizedBox(height: 8),
            const Divider(height: 1, color: HomeColors.border),
            const SizedBox(height: 8),
            _SectionAction(label: localizations.setOfWords),
            for (final folder in sample.folders) ...[
              const SizedBox(height: 8),
              _FolderRow(folder: folder),
              if (folder.expanded)
                for (final setName in folder.sets) _SetRow(name: setName),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    super.key,
    required this.icon,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? HomeColors.selected : HomeColors.text;
    return Semantics(
      selected: selected,
      button: onTap != null,
      child: Material(
        color: selected ? HomeColors.selectedFill : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: HomeText.subtitle.copyWith(color: color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: HomeText.subtitle)),
          const Icon(Icons.search, size: 18, color: HomeColors.text),
        ],
      ),
    );
  }
}

class _SectionAction extends StatelessWidget {
  const _SectionAction({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: HomeText.body.copyWith(color: HomeColors.text),
            ),
          ),
          const Icon(
            Icons.add_outlined,
            size: 14,
            color: HomeColors.placeholder,
          ),
        ],
      ),
    );
  }
}

class _FolderRow extends StatelessWidget {
  const _FolderRow({required this.folder});

  final VocabFolder folder;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      expanded: folder.expanded,
      child: Container(
        key: Key('folder-${folder.name}'),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: HomeColors.folderFill,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.folder_outlined, size: 18, color: HomeColors.ink),
            const SizedBox(width: 8),
            Expanded(child: Text(folder.name, style: HomeText.subtitle)),
            Icon(
              folder.expanded ? Icons.expand_less : Icons.expand_more,
              size: 18,
              color: const Color(0xFF98A2B3),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const Icon(Icons.menu_book_outlined, size: 18, color: HomeColors.ink),
          const SizedBox(width: 8),
          Expanded(child: Text(name, style: HomeText.subtitle)),
        ],
      ),
    );
  }
}
