import 'package:flutter/material.dart';
import 'package:lang/library/vocabulary_library.dart';
import 'package:lang/library/vocabulary_set.dart';
import 'package:lang/l10n/app_localizations.dart';
import 'package:lang/theme/home_palette.dart';
import 'package:lang/theme/home_text.dart';

Future<void> showAddSetsDialog({
  required BuildContext context,
  required VocabularyFolder folder,
  required List<VocabularyFolder> folders,
  required ValueChanged<VocabularySet> onAdd,
  VoidCallback? onCreate,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _AddSetsDialog(
      folder: folder,
      folders: folders,
      onAdd: onAdd,
      onCreate: onCreate,
    ),
  );
}

class _PickerSet {
  const _PickerSet({
    required this.folderName,
    required this.index,
    required this.set,
  });

  final String folderName;
  final int index;
  final VocabularySet set;
}

class _AddSetsDialog extends StatefulWidget {
  const _AddSetsDialog({
    required this.folder,
    required this.folders,
    required this.onAdd,
    this.onCreate,
  });

  final VocabularyFolder folder;
  final List<VocabularyFolder> folders;
  final ValueChanged<VocabularySet> onAdd;
  final VoidCallback? onCreate;

  @override
  State<_AddSetsDialog> createState() => _AddSetsDialogState();
}

class _AddSetsDialogState extends State<_AddSetsDialog> {
  var _recents = true;
  late final Set<String> _added = <String>{
    for (var index = 0; index < widget.folder.sets.length; index++)
      _mark(
        widget.folder.contentAt(index) ??
            VocabularySet(
              title: widget.folder.sets[index],
              description: '',
              words: const <VocabularyWord>[],
            ),
      ),
  };

  List<_PickerSet> get _sets {
    final items = <_PickerSet>[
      for (final folder in widget.folders)
        for (var index = 0; index < folder.sets.length; index++)
          _PickerSet(
            folderName: folder.name,
            index: index,
            set:
                folder.contentAt(index) ??
                VocabularySet(
                  title: folder.sets[index],
                  description: '',
                  words: const <VocabularyWord>[],
                ),
          ),
    ];
    if (_recents) {
      return items.reversed.toList();
    }
    return items;
  }

  String _mark(VocabularySet set) {
    final id = set.id;
    if (id != null && id.isNotEmpty) {
      return id;
    }
    return set.title;
  }

  void _add(_PickerSet item) {
    final mark = _mark(item.set);
    if (_added.contains(mark)) {
      return;
    }
    setState(() => _added.add(mark));
    widget.onAdd(item.set);
  }

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final text = HomeText.of(context);
    final localizations = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final dialogWidth = width < 600 ? width - 32 : 520.0;
    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        key: const Key('add-materials-dialog'),
        width: dialogWidth,
        height: 600,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      localizations.addStudyMaterials,
                      style: text.title,
                    ),
                  ),
                  IconButton(
                    key: const Key('add-materials-close'),
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: colors.folderFill,
                      foregroundColor: colors.ink,
                      fixedSize: const Size(36, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _Choice(
                    chipKey: const Key('add-materials-recents'),
                    label: localizations.addMaterialsRecents,
                    selected: _recents,
                    onTap: () => setState(() => _recents = true),
                  ),
                  const SizedBox(width: 8),
                  _Choice(
                    chipKey: const Key('add-materials-library'),
                    label: localizations.libraryTitle,
                    selected: !_recents,
                    onTap: () => setState(() => _recents = false),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    localizations.librarySets,
                    style: text.subtitle.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    key: const Key('add-materials-create'),
                    onPressed: widget.onCreate == null
                        ? null
                        : () {
                            Navigator.of(context).pop();
                            widget.onCreate!.call();
                          },
                    style: TextButton.styleFrom(
                      foregroundColor: colors.selected,
                      textStyle: text.subtitle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(localizations.createNew),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _sets.isEmpty
                    ? Text(
                        localizations.libraryEmpty,
                        style: text.body.copyWith(color: colors.muted),
                      )
                    : ListView.separated(
                        itemCount: _sets.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = _sets[index];
                          final added = _added.contains(_mark(item.set));
                          return _SetRow(
                            item: item,
                            added: added,
                            onAdd: () => _add(item),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  key: const Key('add-materials-done'),
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.newVocab,
                    foregroundColor: colors.onAccent,
                    minimumSize: const Size(96, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: text.subtitle.copyWith(
                      color: colors.onAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text(localizations.editorDone),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({
    required this.item,
    required this.added,
    required this.onAdd,
  });

  final _PickerSet item;
  final bool added;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final text = HomeText.of(context);
    final localizations = AppLocalizations.of(context);
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.folderFill,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.style_outlined,
                size: 20,
                color: colors.selected,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.set.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.subtitle.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${localizations.librarySets} · ${localizations.libraryTermCount(item.set.words.length)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.body.copyWith(color: colors.muted),
                  ),
                ],
              ),
            ),
            IconButton(
              key: Key('add-materials-add-${item.folderName}-${item.index}'),
              onPressed: added ? null : onAdd,
              style: IconButton.styleFrom(
                backgroundColor: colors.folderFill,
                foregroundColor: added ? colors.selected : colors.ink,
                disabledForegroundColor: colors.selected,
                fixedSize: const Size(36, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: Icon(added ? Icons.check : Icons.add, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
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
            style: HomeText.of(context).body.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
