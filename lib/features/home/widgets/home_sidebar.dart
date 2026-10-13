import 'package:flutter/material.dart';
import 'package:lang/features/home/sample/home_sample.dart';
import 'package:lang/theme/home_palette.dart';
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
        width: width,
        padding: EdgeInsets.symmetric(
          horizontal: 20,
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
            _SidebarDivider(collapsed: collapsed),
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
                    Divider(height: 1, color: HomePalette.of(context).border),
                    const SizedBox(height: 8),
                    _SectionAction(label: localizations.setOfWords),
                  ],
                ),
              ),
            ),
            if (collapsed) ...[
              const SizedBox(height: 8),
              const _SidebarDivider(
                collapsed: true,
                dividerKey: Key('collapsed-folder-divider'),
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

class _SidebarDivider extends StatelessWidget {
  const _SidebarDivider({required this.collapsed, this.dividerKey});

  final bool collapsed;
  final Key? dividerKey;

  @override
  Widget build(BuildContext context) {
    final line = Divider(
      key: dividerKey,
      height: 1,
      color: HomePalette.of(context).border,
    );
    if (!collapsed) {
      return line;
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(width: HomeSidebar.collapsedSlot, child: line),
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
    final color = selected ? HomePalette.of(context).selected : HomePalette.of(context).text;
    final icon = Icon(this.icon, size: 18, color: color);
    final background = selected ? HomePalette.of(context).selectedFill : Colors.transparent;
    return Semantics(
      selected: selected,
      button: onTap != null,
      child: collapsed
          ? Align(
              alignment: Alignment.centerLeft,
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
                          style: HomeText.of(context).subtitle.copyWith(color: color),
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
    final icon = Icon(
      Icons.search,
      size: 18,
      color: HomePalette.of(context).text,
    );
    if (collapsed) {
      return Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: HomeSidebar.collapsedSlot,
          height: HomeSidebar.collapsedSlot,
          child: icon,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: HomeText.of(context).subtitle)),
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
              style: HomeText.of(context).body.copyWith(color: HomePalette.of(context).text),
            ),
          ),
          Icon(
            Icons.add_outlined,
            size: 20,
            color: HomePalette.of(context).placeholder,
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
    final icon = Icon(
      Icons.folder_outlined,
      size: 18,
      color: HomePalette.of(context).ink,
    );
    if (collapsed) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          key: Key('folder-${folder.name}'),
          width: HomeSidebar.collapsedSlot,
          height: HomeSidebar.collapsedSlot,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: HomePalette.of(context).folderFill,
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
          color: HomePalette.of(context).folderFill,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 8),
            Expanded(child: Text(folder.name, style: HomeText.of(context).subtitle)),
            Icon(
              folder.expanded ? Icons.expand_less : Icons.expand_more,
              size: 18,
              color: HomePalette.of(context).muted,
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
          Icon(
            Icons.menu_book_outlined,
            size: 18,
            color: HomePalette.of(context).ink,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(name, style: HomeText.of(context).subtitle)),
        ],
      ),
    );
  }
}
