import 'package:flutter/material.dart';
import 'package:lang/features/home/sample/home_sample.dart';
import 'package:lang/theme/home_palette.dart';
import 'package:lang/theme/home_text.dart';
import 'package:lang/l10n/app_localizations.dart';

class HomeSidebar extends StatefulWidget {
  const HomeSidebar({
    super.key,
    required this.sample,
    required this.collapsed,
    this.onOpenSet,
    this.onOpenFolder,
    this.onHome,
    this.onLibrary,
    this.onAddFolder,
    this.librarySelected = false,
    this.focusedFolder,
    this.focusedSetIndex,
    this.practiceLocked = false,
    this.onPracticeLocked,
  });

  final HomeSample sample;
  final bool collapsed;
  final void Function(String folderName, int setIndex)? onOpenSet;
  final ValueChanged<String>? onOpenFolder;
  final VoidCallback? onHome;
  final VoidCallback? onLibrary;
  final VoidCallback? onAddFolder;
  final bool librarySelected;
  final String? focusedFolder;
  final int? focusedSetIndex;
  final bool practiceLocked;
  final void Function(VoidCallback? action)? onPracticeLocked;

  static const width = 288.0;
  static const collapsedWidth = 72.0;
  static const collapsedSlot = 32.0;
  static const animationDuration = Duration(milliseconds: 280);
  static const animationCurve = Curves.easeOutCubic;

  @override
  State<HomeSidebar> createState() => _HomeSidebarState();
}

class _HomeSidebarState extends State<HomeSidebar> {
  final _expanded = <String, bool>{};

  @override
  void initState() {
    super.initState();
    for (final folder in widget.sample.folders) {
      _expanded[folder.name] = false;
    }
    final focus = widget.focusedFolder;
    if (focus != null) {
      _expanded[focus] = true;
    }
  }

  @override
  void didUpdateWidget(HomeSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (final folder in widget.sample.folders) {
      _expanded.putIfAbsent(folder.name, () => false);
    }
    final focus = widget.focusedFolder;
    if (focus != null && focus != oldWidget.focusedFolder) {
      _expanded[focus] = true;
    }
  }

  void _tap(VoidCallback? action) {
    if (widget.practiceLocked) {
      widget.onPracticeLocked?.call(action);
      return;
    }
    action?.call();
  }

  bool _isExpanded(VocabFolder folder) {
    return _expanded[folder.name] ?? folder.expanded;
  }

  @override
  Widget build(BuildContext context) {
    final sample = widget.sample;
    final collapsed = widget.collapsed;
    final localizations = AppLocalizations.of(context);
    return ClipRect(
      child: AnimatedContainer(
        duration: HomeSidebar.animationDuration,
        curve: HomeSidebar.animationCurve,
        width: HomeSidebar.width,
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
              selected:
                  sample.homepageSelected &&
                  !widget.librarySelected &&
                  widget.focusedFolder == null,
              collapsed: collapsed,
              labelKey: const Key('nav-home-label'),
              onTap: () => _tap(widget.onHome),
            ),
            const SizedBox(height: 4),
            _NavRow(
              key: const Key('nav-library'),
              icon: Icons.folder_open_outlined,
              label: localizations.navLibrary,
              collapsed: collapsed,
              selected: widget.librarySelected,
              onTap: () => _tap(widget.onLibrary),
            ),
            const SizedBox(height: 4),
            _NavRow(
              icon: Icons.notifications_none,
              label: localizations.navNotification,
              collapsed: collapsed,
              onTap: () => _tap(null),
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
                duration: HomeSidebar.animationDuration,
                curve: HomeSidebar.animationCurve,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Divider(height: 1, color: HomePalette.of(context).border),
                    const SizedBox(height: 8),
                    _SectionAction(
                      label: localizations.setOfWords,
                      onAdd: collapsed
                          ? null
                          : () => _tap(widget.onAddFolder),
                    ),
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
              _FolderRow(
                folder: folder,
                collapsed: collapsed,
                expanded: _isExpanded(folder),
                selected: folder.name == widget.focusedFolder,
                onTap: () => _tap(
                  () => widget.onOpenFolder?.call(folder.name),
                ),
                onToggle: () => _tap(() {
                  setState(() {
                    _expanded[folder.name] = !_isExpanded(folder);
                  });
                }),
              ),
              if (!collapsed && _isExpanded(folder))
                for (var index = 0; index < folder.sets.length; index++) ...[
                  const SizedBox(height: 4),
                  _SetRow(
                    name: folder.sets[index],
                    rowKey: Key('vocab-set-${folder.name}-$index'),
                    selected:
                        folder.name == widget.focusedFolder &&
                        index == widget.focusedSetIndex,
                    onTap: () => _tap(
                      () => widget.onOpenSet?.call(folder.name, index),
                    ),
                  ),
                ],
            ],
            if (collapsed) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  key: const Key('sidebar-add-folder'),
                  onPressed: () => _tap(widget.onAddFolder),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.center,
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.center,
                  ),
                  constraints: const BoxConstraints.tightFor(
                    width: HomeSidebar.collapsedSlot,
                    height: HomeSidebar.collapsedSlot,
                  ),
                  icon: Icon(
                    Icons.add_outlined,
                    size: 20,
                    color: HomePalette.of(context).text,
                  ),
                ),
              ),
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
    final color = selected
        ? HomePalette.of(context).selected
        : HomePalette.of(context).text;
    final icon = Icon(this.icon, size: 18, color: color);
    final background = selected
        ? HomePalette.of(context).selectedFill
        : Colors.transparent;
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
                          style: HomeText.of(context).subtitle
                              .copyWith(color: color),
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
  const _SectionAction({required this.label, this.onAdd});

  final String label;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: HomeText.of(context).body
                  .copyWith(color: HomePalette.of(context).text),
            ),
          ),
          if (onAdd != null)
            IconButton(
              key: const Key('sidebar-add-folder'),
              onPressed: onAdd,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              icon: Icon(
                Icons.add_outlined,
                size: 22,
                color: HomePalette.of(context).text,
              ),
            ),
        ],
      ),
    );
  }
}

class _FolderRow extends StatelessWidget {
  const _FolderRow({
    required this.folder,
    required this.collapsed,
    required this.expanded,
    required this.selected,
    required this.onTap,
    required this.onToggle,
  });

  final VocabFolder folder;
  final bool collapsed;
  final bool expanded;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final color = selected ? colors.selected : colors.ink;
    final icon = Icon(Icons.folder_outlined, size: 18, color: color);
    final fill = selected ? colors.selectedFill : colors.folderFill;
    if (collapsed) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Material(
          key: Key('folder-${folder.name}'),
          color: fill,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: HomeSidebar.collapsedSlot,
              height: HomeSidebar.collapsedSlot,
              child: icon,
            ),
          ),
        ),
      );
    }
    return Semantics(
      button: true,
      expanded: expanded,
      child: Material(
        key: Key('folder-${folder.name}'),
        color: fill,
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
                    folder.name,
                    style: HomeText.of(context).subtitle.copyWith(color: color),
                  ),
                ),
                IconButton(
                  key: Key('folder-toggle-${folder.name}'),
                  onPressed: onToggle,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  icon: Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: HomePalette.of(context).muted,
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

class _SetRow extends StatelessWidget {
  const _SetRow({
    required this.name,
    required this.rowKey,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final Key rowKey;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final color = selected ? colors.selected : colors.ink;
    return Material(
      color: selected ? colors.selectedSetFill : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        key: rowKey,
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: Row(
            children: [
              Icon(Icons.menu_book_outlined, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: HomeText.of(context).subtitle.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
