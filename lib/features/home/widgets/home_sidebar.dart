import 'package:flutter/material.dart';
import 'package:lang/features/home/sample/home_sample.dart';
import 'package:lang/theme/home_colors.dart';
import 'package:lang/theme/home_text.dart';
import 'package:lang/l10n/app_localizations.dart';

class HomeSidebar extends StatelessWidget {
  const HomeSidebar({super.key, required this.sample, required this.collapsed});

  final HomeSample sample;
  final bool collapsed;

  static const width = 288.0;
  static const collapsedWidth = 72.0;
  static const collapsedSlot = 32.0;
  static const animationDuration = Duration(milliseconds: 280);
  static const animationCurve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return ClipRect(
      child: AnimatedContainer(
        duration: animationDuration,
        curve: animationCurve,
        width: collapsed ? collapsedWidth : width,
        padding: EdgeInsets.symmetric(
          horizontal: collapsed ? 0 : 20,
          vertical: collapsed ? 12 : 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _NavRow(
              key: const Key('nav-home'),
              icon: Icons.home_outlined,
              label: localizations.navHome,
              selected: sample.homepageSelected,
              collapsed: collapsed,
              labelKey: const Key('nav-home-label'),
            ),
            const SizedBox(height: 4),
            _NavRow(
              icon: Icons.folder_open_outlined,
              label: localizations.navLibrary,
              collapsed: collapsed,
              onTap: () {},
            ),
            const SizedBox(height: 4),
            _NavRow(
              icon: Icons.notifications_none,
              label: localizations.navNotification,
              collapsed: collapsed,
              onTap: () {},
            ),
            const SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: collapsed ? 20 : 0),
              child: const Divider(height: 1, color: HomeColors.border),
            ),
            const SizedBox(height: 8),
            _SectionLabel(
              label: localizations.vocabularySet,
              collapsed: collapsed,
            ),
            ClipRect(
              child: AnimatedAlign(
                key: const Key('sidebar-extra'),
                alignment: Alignment.topCenter,
                heightFactor: collapsed ? 0 : 1,
                duration: animationDuration,
                curve: animationCurve,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    const Divider(height: 1, color: HomeColors.border),
                    const SizedBox(height: 8),
                    _SectionAction(label: localizations.setOfWords),
                  ],
                ),
              ),
            ),
            if (collapsed) ...[
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(
                  key: Key('collapsed-folder-divider'),
                  height: 1,
                  color: HomeColors.border,
                ),
              ),
              const SizedBox(height: 8),
            ],
            for (final folder in sample.folders) ...[
              const SizedBox(height: 8),
              _FolderRow(folder: folder, collapsed: collapsed),
              if (!collapsed && folder.expanded)
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
    required this.collapsed,
    this.selected = false,
    this.onTap,
    this.labelKey,
  });

  final IconData icon;
  final String label;
  final bool collapsed;
  final bool selected;
  final VoidCallback? onTap;
  final Key? labelKey;

  @override
  Widget build(BuildContext context) {
    final color = selected ? HomeColors.selected : HomeColors.text;
    final icon = Icon(this.icon, size: 18, color: color);
    final background = selected ? HomeColors.selectedFill : Colors.transparent;
    return Semantics(
      selected: selected,
      button: onTap != null,
      child: collapsed
          ? SizedBox(
              height: HomeSidebar.collapsedSlot,
              child: Center(
                child: Material(
                  color: background,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: HomeSidebar.collapsedSlot,
                      height: HomeSidebar.collapsedSlot,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          icon,
                          SizedBox(key: labelKey, width: 0, height: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          : Material(
              color: background,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      icon,
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          label,
                          key: labelKey,
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
  const _SectionLabel({required this.label, required this.collapsed});

  final String label;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    const icon = Icon(Icons.search, size: 18, color: HomeColors.text);
    if (collapsed) {
      return const SizedBox(
        height: HomeSidebar.collapsedSlot,
        child: Center(child: icon),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: HomeText.subtitle)),
          icon,
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
  const _FolderRow({required this.folder, required this.collapsed});

  final VocabFolder folder;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    const icon = Icon(Icons.folder_outlined, size: 18, color: HomeColors.ink);
    if (collapsed) {
      return Center(
        child: Container(
          key: Key('folder-${folder.name}'),
          width: HomeSidebar.collapsedSlot,
          height: HomeSidebar.collapsedSlot,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: HomeColors.folderFill,
            borderRadius: BorderRadius.circular(8),
          ),
          child: icon,
        ),
      );
    }
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
            icon,
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
