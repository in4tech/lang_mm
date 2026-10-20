import 'package:flutter/material.dart';
import 'package:lang/features/home/widgets/add_sets_dialog.dart';
import 'package:lang/library/vocabulary_library.dart';
import 'package:lang/library/vocabulary_set.dart';
import 'package:lang/l10n/app_localizations.dart';
import 'package:lang/theme/home_palette.dart';
import 'package:lang/theme/home_text.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({
    super.key,
    required this.folders,
    required this.onOpenSet,
    this.openFolder,
    this.onOpenFolder,
    this.onRenameFolder,
    this.onDeleteFolder,
    this.onPinFolder,
    this.onAddSet,
    this.onCreateSet,
    this.onRemoveSet,
    this.narrow = false,
  });

  final List<VocabularyFolder> folders;
  final void Function(String folderName, int setIndex) onOpenSet;
  final String? openFolder;
  final ValueChanged<String?>? onOpenFolder;
  final ValueChanged<String>? onRenameFolder;
  final Future<void> Function(String name)? onDeleteFolder;
  final void Function(String name, bool pinned)? onPinFolder;
  final void Function(String folderName, VocabularySet set)? onAddSet;
  final ValueChanged<String>? onCreateSet;
  final void Function(String folderName, int setIndex)? onRemoveSet;
  final bool narrow;

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

enum _LibrarySort { created, recent, studied }

class _LibraryPageState extends State<LibraryPage> {
  final _search = TextEditingController();
  var _setsSelected = true;
  var _sort = _LibrarySort.recent;
  String? _openFolderName;

  @override
  void initState() {
    super.initState();
    _openFolderName = widget.openFolder;
  }

  @override
  void didUpdateWidget(LibraryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.openFolder != oldWidget.openFolder) {
      _search.clear();
      _openFolderName = widget.openFolder;
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colors = HomePalette.of(context);
    final query = _search.text.trim().toLowerCase();
    final sets =
        _ordered(<_LibrarySet>[
          for (final folder in widget.folders)
            for (var index = 0; index < folder.sets.length; index++)
              _LibrarySet(
                folderName: folder.name,
                index: index,
                title: folder.sets[index],
                termCount: folder.contentAt(index)?.words.length,
              ),
        ]).where((set) {
          return query.isEmpty || set.title.toLowerCase().contains(query);
        }).toList();
    final folders = _ordered(
      widget.folders.where((folder) {
        return query.isEmpty || folder.name.toLowerCase().contains(query);
      }),
    );
    final openFolder = _openFolder();
    if (openFolder != null) {
      return _folderPage(context, openFolder, query);
    }

    return Column(
      key: const Key('library-page'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(localizations.libraryTitle, style: HomeText.of(context).title),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _FilterChip(
              chipKey: const Key('library-chip-sets'),
              label: localizations.librarySets,
              selected: _setsSelected,
              onTap: () => setState(() => _setsSelected = true),
            ),
            _FilterChip(
              chipKey: const Key('library-chip-folders'),
              label: localizations.libraryFolders,
              selected: !_setsSelected,
              onTap: () => setState(() => _setsSelected = false),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (widget.narrow) ...[
          _RecentMenu(
            sort: _sort,
            onSelected: (sort) => setState(() => _sort = sort),
          ),
          const SizedBox(height: 12),
          _SearchField(controller: _search, onChanged: () => setState(() {})),
        ] else
          Row(
            children: [
              _RecentMenu(
                sort: _sort,
                onSelected: (sort) => setState(() => _sort = sort),
              ),
              const Spacer(),
              SizedBox(
                width: 320,
                child: _SearchField(
                  controller: _search,
                  onChanged: () => setState(() {}),
                ),
              ),
            ],
          ),
        const SizedBox(height: 20),
        Divider(height: 1, color: colors.border),
        const SizedBox(height: 12),
        if ((_setsSelected && sets.isEmpty) ||
            (!_setsSelected && folders.isEmpty))
          Text(
            localizations.libraryEmpty,
            style: HomeText.of(context).body.copyWith(color: colors.muted),
          )
        else if (_setsSelected)
          for (final set in sets) ...[
            _LibraryCard(
              cardKey: Key('library-set-${set.folderName}-${set.index}'),
              title: set.title,
              meta: set.termCount == null
                  ? set.folderName
                  : '${localizations.libraryTermCount(set.termCount!)} · ${set.folderName}',
              onTap: () => widget.onOpenSet(set.folderName, set.index),
            ),
            const SizedBox(height: 12),
          ]
        else
          for (final folder in folders) ...[
            _LibraryCard(
              cardKey: Key('library-folder-${folder.name}'),
              title: folder.name,
              meta: localizations.librarySetCount(folder.sets.length),
              onTap: () {
                _search.clear();
                setState(() => _openFolderName = folder.name);
                widget.onOpenFolder?.call(folder.name);
              },
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }

  VocabularyFolder? _openFolder() {
    final name = _openFolderName;
    if (name == null) {
      return null;
    }
    for (final folder in widget.folders) {
      if (folder.name == name) {
        return folder;
      }
    }
    return null;
  }

  Widget _folderPage(
    BuildContext context,
    VocabularyFolder folder,
    String query,
  ) {
    final localizations = AppLocalizations.of(context);
    final colors = HomePalette.of(context);
    final sets = _ordered(<_LibrarySet>[
      for (var index = 0; index < folder.sets.length; index++)
        _LibrarySet(
          folderName: folder.name,
          index: index,
          title: folder.sets[index],
          termCount: folder.contentAt(index)?.words.length,
        ),
    ]).where((set) {
      return query.isEmpty || set.title.toLowerCase().contains(query);
    }).toList();
    return Column(
      key: const Key('library-folder-page'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.folderFill,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.folder_outlined, color: colors.ink),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(folder.name, style: HomeText.of(context).title),
            ),
            const SizedBox(width: 12),
            IconButton(
              key: const Key('library-folder-add-sets'),
              onPressed: () => _openAddSets(folder),
              tooltip: localizations.libraryAddSets,
              style: IconButton.styleFrom(
                backgroundColor: colors.folderFill,
                foregroundColor: colors.ink,
                fixedSize: const Size(36, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.add),
            ),
            const SizedBox(width: 8),
            _FolderMoreButton(
              pinned: folder.pinned,
              onEdit: () => widget.onRenameFolder?.call(folder.name),
              onDelete: () async {
                await widget.onDeleteFolder?.call(folder.name);
              },
              onTogglePin: () =>
                  widget.onPinFolder?.call(folder.name, !folder.pinned),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: _FilterChip(
            chipKey: const Key('library-folder-all'),
            label: localizations.allLabel,
            selected: true,
            onTap: () {},
          ),
        ),
        const SizedBox(height: 20),
        if (widget.narrow) ...[
          _RecentMenu(
            sort: _sort,
            onSelected: (sort) => setState(() => _sort = sort),
          ),
          const SizedBox(height: 12),
          _SearchField(
            controller: _search,
            hint: localizations.librarySearchFolder,
            onChanged: () => setState(() {}),
          ),
        ] else
          Row(
            children: [
              _RecentMenu(
                sort: _sort,
                onSelected: (sort) => setState(() => _sort = sort),
              ),
              const Spacer(),
              SizedBox(
                width: 320,
                child: _SearchField(
                  controller: _search,
                  hint: localizations.librarySearchFolder,
                  onChanged: () => setState(() {}),
                ),
              ),
            ],
          ),
        const SizedBox(height: 20),
        Divider(height: 1, color: colors.border),
        const SizedBox(height: 12),
        if (folder.sets.isEmpty)
          _FolderEmpty(onAdd: () => _openAddSets(folder))
        else if (sets.isEmpty)
          Text(
            localizations.libraryEmpty,
            style: HomeText.of(context).body.copyWith(color: colors.muted),
          )
        else
          for (final set in sets) ...[
            _LibraryCard(
              cardKey: Key('library-set-${set.folderName}-${set.index}'),
              title: set.title,
              meta: set.termCount == null
                  ? localizations.librarySets
                  : '${localizations.librarySets} · ${localizations.libraryTermCount(set.termCount!)}',
              titleFirst: true,
              leading: Icon(Icons.style_outlined, color: colors.selected),
              trailing: _SetMoreButton(
                setKey: 'library-set-${set.folderName}-${set.index}',
                onRemove: () =>
                    widget.onRemoveSet?.call(set.folderName, set.index),
              ),
              onTap: () => widget.onOpenSet(set.folderName, set.index),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }

  Future<void> _openAddSets(VocabularyFolder folder) {
    return showAddSetsDialog(
      context: context,
      folder: folder,
      folders: widget.folders,
      onAdd: (set) => widget.onAddSet?.call(folder.name, set),
      onCreate: widget.onCreateSet == null
          ? null
          : () => widget.onCreateSet!.call(folder.name),
    );
  }

  List<T> _ordered<T>(Iterable<T> items) {
    final list = items.toList();
    if (_sort == _LibrarySort.created) {
      return list;
    }
    return list.reversed.toList();
  }
}

class _LibrarySet {
  const _LibrarySet({
    required this.folderName,
    required this.index,
    required this.title,
    required this.termCount,
  });

  final String folderName;
  final int index;
  final String title;
  final int? termCount;
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.chipKey,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Key chipKey;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final color = selected ? colors.selected : colors.text;
    return Material(
      key: chipKey,
      color: selected ? colors.selectedFill : colors.surface,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? colors.selected : colors.border),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: HomeText.of(context).body
                .copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _FolderMoreButton extends StatelessWidget {
  const _FolderMoreButton({
    required this.pinned,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePin,
  });

  final bool pinned;
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;
  final VoidCallback onTogglePin;

  static const _delete = Color(0xFFFF5A6A);

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final localizations = AppLocalizations.of(context);
    final label = HomeText.of(context).subtitle.copyWith(color: colors.ink);
    return MenuAnchor(
      alignmentOffset: const Offset(0, 8),
      style: MenuStyle(
        alignment: AlignmentDirectional.bottomEnd,
        backgroundColor: WidgetStatePropertyAll(colors.surface),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(8),
        shadowColor: const WidgetStatePropertyAll(Color(0x33101828)),
        side: WidgetStatePropertyAll(BorderSide(color: colors.border)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 8),
        ),
      ),
      menuChildren: [
        _item(
          itemKey: const Key('library-folder-add-tag'),
          icon: Icons.sell_outlined,
          label: localizations.folderAddTag,
          color: colors.ink,
          style: label,
        ),
        _item(
          itemKey: const Key('library-folder-edit'),
          icon: Icons.edit_outlined,
          label: localizations.folderEdit,
          color: colors.ink,
          style: label,
          onPressed: onEdit,
        ),
        _item(
          itemKey: const Key('library-folder-share'),
          icon: Icons.ios_share,
          label: localizations.folderShare,
          color: colors.ink,
          style: label,
        ),
        _item(
          itemKey: const Key('library-folder-pin'),
          icon: pinned ? Icons.push_pin : Icons.push_pin_outlined,
          label: pinned ? localizations.folderUnpin : localizations.folderPin,
          color: colors.ink,
          style: label,
          onPressed: onTogglePin,
        ),
        _item(
          itemKey: const Key('library-folder-delete'),
          icon: Icons.delete_outline,
          label: localizations.folderDelete,
          color: _delete,
          style: label.copyWith(color: _delete),
          onPressed: () {
            _confirmDelete(context);
          },
        ),
      ],
      builder: (context, controller, child) {
        return IconButton(
          key: const Key('library-folder-more'),
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          style: IconButton.styleFrom(
            backgroundColor: colors.folderFill,
            foregroundColor: colors.ink,
            fixedSize: const Size(36, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: const Icon(Icons.more_horiz),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => _DeleteFolderDialog(onDelete: onDelete),
    );
  }

  Widget _item({
    required Key itemKey,
    required IconData icon,
    required String label,
    required Color color,
    required TextStyle style,
    VoidCallback? onPressed,
  }) {
    return MenuItemButton(
      key: itemKey,
      onPressed: onPressed ?? () {},
      style: const ButtonStyle(
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      leadingIcon: Icon(icon, size: 20, color: color),
      child: Text(label, style: style),
    );
  }
}

class _DeleteFolderDialog extends StatefulWidget {
  const _DeleteFolderDialog({required this.onDelete});

  final Future<void> Function() onDelete;

  @override
  State<_DeleteFolderDialog> createState() => _DeleteFolderDialogState();
}

class _DeleteFolderDialogState extends State<_DeleteFolderDialog> {
  static const _danger = Color(0xFFFF5A6A);
  var _deleting = false;
  var _failed = false;

  Future<void> _confirm() async {
    setState(() {
      _deleting = true;
      _failed = false;
    });
    try {
      await widget.onDelete();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _deleting = false;
          _failed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final text = HomeText.of(context);
    final localizations = AppLocalizations.of(context);
    return PopScope(
      canPop: !_deleting,
      child: Dialog(
        key: const Key('folder-delete-dialog'),
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(localizations.folderDeleteTitle, style: text.heading),
                const SizedBox(height: 12),
                Text(
                  localizations.folderDeleteBody,
                  style: text.body.copyWith(color: colors.muted),
                ),
                if (_failed) ...[
                  const SizedBox(height: 12),
                  Text(
                    key: const Key('folder-delete-error'),
                    localizations.folderDeleteFailed,
                    style: text.body.copyWith(color: _danger),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      key: const Key('folder-delete-cancel'),
                      onPressed: _deleting
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.text,
                        side: BorderSide(color: colors.border),
                        minimumSize: const Size(96, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: text.subtitle,
                      ),
                      child: Text(localizations.cancelAction),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      key: const Key('folder-delete-confirm'),
                      onPressed: _deleting ? null : _confirm,
                      style: FilledButton.styleFrom(
                        backgroundColor: _danger,
                        disabledBackgroundColor: _danger,
                        foregroundColor: colors.onAccent,
                        disabledForegroundColor: colors.onAccent,
                        minimumSize: const Size(132, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: text.subtitle.copyWith(
                          color: colors.onAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: _deleting
                          ? const SizedBox(
                              key: Key('folder-delete-progress'),
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(localizations.folderDeleteConfirm),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentMenu extends StatelessWidget {
  const _RecentMenu({required this.sort, required this.onSelected});

  final _LibrarySort sort;
  final ValueChanged<_LibrarySort> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final localizations = AppLocalizations.of(context);
    final label = switch (sort) {
      _LibrarySort.created => localizations.librarySortCreated,
      _LibrarySort.recent => localizations.recent,
      _LibrarySort.studied => localizations.librarySortStudied,
    };
    return MenuAnchor(
      alignmentOffset: const Offset(0, 8),
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(colors.surface),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(8),
        shadowColor: const WidgetStatePropertyAll(Color(0x33101828)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 8),
        ),
      ),
      menuChildren: [
        _sortItem(
          context,
          itemKey: const Key('library-sort-created'),
          label: localizations.librarySortCreated,
          sort: _LibrarySort.created,
        ),
        _sortItem(
          context,
          itemKey: const Key('library-sort-recent'),
          label: localizations.recent,
          sort: _LibrarySort.recent,
        ),
        _sortItem(
          context,
          itemKey: const Key('library-sort-studied'),
          label: localizations.librarySortStudied,
          sort: _LibrarySort.studied,
        ),
      ],
      builder: (context, controller, child) {
        return Material(
          key: const Key('library-recent'),
          color: colors.surface,
          shape: StadiumBorder(side: BorderSide(color: colors.border)),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: HomeText.of(context).body),
                  const SizedBox(width: 4),
                  Icon(Icons.expand_more, size: 18, color: colors.text),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sortItem(
    BuildContext context, {
    required Key itemKey,
    required String label,
    required _LibrarySort sort,
  }) {
    return MenuItemButton(
      key: itemKey,
      onPressed: () => onSelected(sort),
      style: const ButtonStyle(
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      child: Text(
        label,
        style: HomeText.of(context).subtitle
            .copyWith(color: HomePalette.of(context).ink),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    this.hint,
  });

  final TextEditingController controller;
  final VoidCallback onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final text = HomeText.of(context);
    return TextField(
      key: const Key('library-search'),
      controller: controller,
      onChanged: (_) => onChanged(),
      style: text.subtitle,
      decoration: InputDecoration(
        hintText: hint ?? AppLocalizations.of(context).librarySearchHint,
        hintStyle: text.subtitle.copyWith(color: colors.placeholder),
        suffixIcon: Icon(Icons.search, color: colors.text),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border, width: 2),
        ),
      ),
    );
  }
}

class _FolderEmpty extends StatelessWidget {
  const _FolderEmpty({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final text = HomeText.of(context);
    final localizations = AppLocalizations.of(context);
    return Padding(
      key: const Key('library-folder-empty'),
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.folderFill,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.style_outlined,
              size: 32,
              color: colors.selected,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            localizations.libraryEmpty,
            textAlign: TextAlign.center,
            style: text.heading,
          ),
          const SizedBox(height: 8),
          Text(
            localizations.libraryFolderEmpty,
            textAlign: TextAlign.center,
            style: text.body.copyWith(color: colors.muted),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            key: const Key('library-folder-add-sets-label'),
            onPressed: onAdd,
            style: FilledButton.styleFrom(
              backgroundColor: colors.newVocab,
              foregroundColor: colors.onAccent,
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: text.subtitle.copyWith(
                color: colors.onAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: Text(localizations.addFlashcardSets),
          ),
        ],
      ),
    );
  }
}

class _SetMoreButton extends StatelessWidget {
  const _SetMoreButton({required this.setKey, required this.onRemove});

  final String setKey;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final localizations = AppLocalizations.of(context);
    final label = HomeText.of(context).subtitle.copyWith(color: colors.ink);
    return MenuAnchor(
      alignmentOffset: const Offset(0, 8),
      style: MenuStyle(
        alignment: AlignmentDirectional.bottomEnd,
        backgroundColor: WidgetStatePropertyAll(colors.surface),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(8),
        shadowColor: const WidgetStatePropertyAll(Color(0x33101828)),
        side: WidgetStatePropertyAll(BorderSide(color: colors.border)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 8),
        ),
      ),
      menuChildren: [
        MenuItemButton(
          key: Key('$setKey-add-tags'),
          onPressed: () {},
          style: const ButtonStyle(
            padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          leadingIcon: Icon(Icons.sell_outlined, size: 20, color: colors.ink),
          child: Text(localizations.setAddOrRemoveTags, style: label),
        ),
        MenuItemButton(
          key: Key('$setKey-remove'),
          onPressed: onRemove,
          style: const ButtonStyle(
            padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          leadingIcon: Icon(Icons.remove, size: 20, color: colors.ink),
          child: Text(localizations.setRemoveFromFolder, style: label),
        ),
      ],
      builder: (context, controller, child) {
        return IconButton(
          key: Key('$setKey-more'),
          tooltip: localizations.moreOption,
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          style: IconButton.styleFrom(
            foregroundColor: colors.ink,
            fixedSize: const Size(36, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: const Icon(Icons.more_horiz),
        );
      },
    );
  }
}

class _LibraryCard extends StatelessWidget {
  const _LibraryCard({
    required this.cardKey,
    required this.title,
    required this.meta,
    this.leading,
    this.trailing,
    this.titleFirst = false,
    this.onTap,
  });

  final Key cardKey;
  final String title;
  final String meta;
  final Widget? leading;
  final Widget? trailing;
  final bool titleFirst;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    return Material(
      key: cardKey,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 14, trailing == null ? 16 : 8, 14),
          child: Row(
            children: [
              if (leading != null) ...[
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.folderFill,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: leading,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleFirst ? title : meta,
                      style: titleFirst
                          ? HomeText.of(context).subtitle
                              .copyWith(fontWeight: FontWeight.w700)
                          : HomeText.of(context).body
                              .copyWith(color: colors.muted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      titleFirst ? meta : title,
                      style: titleFirst
                          ? HomeText.of(context).body
                              .copyWith(color: colors.muted)
                          : HomeText.of(context).subtitle
                              .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
