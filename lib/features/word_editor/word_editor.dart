import 'package:flutter/material.dart';
import 'package:lang/l10n/app_localizations.dart';
import 'package:lang/theme/home_palette.dart';
import 'package:lang/theme/home_text.dart';

class WordEditor extends StatefulWidget {
  const WordEditor({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  State<WordEditor> createState() => _WordEditorState();
}

class _Draft {
  final term = TextEditingController();
  final definition = TextEditingController();
  final sentence = TextEditingController();
  final ipa = TextEditingController();
  final singularPlural = TextEditingController();
  final note = TextEditingController();
  String? type;
  bool detailsOpen = true;

  void dispose() {
    term.dispose();
    definition.dispose();
    sentence.dispose();
    ipa.dispose();
    singularPlural.dispose();
    note.dispose();
  }
}

class _WordEditorState extends State<WordEditor> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _drafts = <_Draft>[_Draft()];

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    for (final draft in _drafts) {
      draft.dispose();
    }
    super.dispose();
  }

  void _addWord() {
    setState(() => _drafts.add(_Draft()));
  }

  void _selectType(_Draft draft, String type) {
    setState(() {
      draft.type = draft.type == type ? null : type;
    });
  }

  void _toggleDetails(_Draft draft) {
    setState(() => draft.detailsOpen = !draft.detailsOpen);
  }

  void _close() {
    final onClose = widget.onClose;
    if (onClose != null) {
      onClose();
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final fields = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Expanded(
                child: _SetField(
                  fillKey: const Key('word-editor-title-fill'),
                  fieldKey: const Key('word-editor-title'),
                  label: localizations.editorTitle,
                  controller: _title,
                  hint: localizations.editorTitleHint,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SetField(
                  fillKey: const Key('word-editor-description-fill'),
                  fieldKey: const Key('word-editor-description'),
                  controller: _description,
                  hint: localizations.editorDescriptionHint,
                ),
              ),
            ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            OutlinedButton(
              key: const Key('word-editor-import'),
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: HomePalette.of(context).text,
                side: BorderSide(color: HomePalette.of(context).border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: HomeText.of(context).subtitle.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    localizations.editorImport,
                    style: HomeText.of(context).subtitle.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            _RoundIconButton(
              buttonKey: const Key('word-editor-search'),
              icon: Icons.search,
            ),
            const SizedBox(width: 8),
            _RoundIconButton(
              buttonKey: const Key('word-editor-add'),
              icon: Icons.add,
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (var index = _drafts.length - 1; index >= 0; index--)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _WordCard(
              draft: _drafts[index],
              number: index + 1,
              expanded: index == _drafts.length - 1,
              localizations: localizations,
              onAddWord: _addWord,
              onSelectType: (type) => _selectType(_drafts[index], type),
              onToggleDetails: () => _toggleDetails(_drafts[index]),
            ),
          ),
      ],
    );
    final header = _Header(localizations: localizations, onClose: _close);
    if (widget.onClose != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [header, fields],
      );
    }
    return Scaffold(
      backgroundColor: HomePalette.of(context).folderFill,
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            children: [
              header,
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  child: fields,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.localizations, required this.onClose});

  final AppLocalizations localizations;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final text = HomeText.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextButton(
            key: const Key('word-editor-back'),
            onPressed: onClose,
            style: TextButton.styleFrom(
              foregroundColor: colors.text,
              padding: const EdgeInsets.fromLTRB(0, 8, 4, 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              alignment: Alignment.center,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.chevron_left, size: 28),
                const SizedBox(width: 2),
                Text(
                  localizations.editorBack,
                  style: text.subtitle.copyWith(height: 1),
                ),
              ],
            ),
          ),
          const Spacer(),
          FilledButton(
            onPressed: onClose,
            style: FilledButton.styleFrom(
              backgroundColor: HomePalette.of(context).newVocab,
              foregroundColor: HomePalette.of(context).onAccent,
              minimumSize: const Size(0, 44),
              maximumSize: const Size(double.infinity, 44),
              padding: const EdgeInsets.symmetric(horizontal: 23),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle: HomeText.of(context).subtitle.copyWith(
                color: HomePalette.of(context).onAccent,
              ),
            ),
            child: Text(localizations.editorDone),
          ),
        ],
      ),
    );
  }
}

class _WordCard extends StatelessWidget {
  const _WordCard({
    required this.draft,
    required this.number,
    required this.expanded,
    required this.localizations,
    required this.onAddWord,
    required this.onSelectType,
    required this.onToggleDetails,
  });

  final _Draft draft;
  final int number;
  final bool expanded;
  final AppLocalizations localizations;
  final VoidCallback onAddWord;
  final ValueChanged<String> onSelectType;
  final VoidCallback onToggleDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('word-card-$number'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HomePalette.of(context).surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HomePalette.of(context).border),
        boxShadow: expanded
            ? const [
                BoxShadow(
                  color: Color(0x1A101828),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: expanded ? _expanded(context) : _collapsed(context),
    );
  }

  Widget _toolIcon(
    BuildContext context, {
    required Key buttonKey,
    required IconData icon,
  }) {
    return IconButton(
      key: buttonKey,
      onPressed: () {},
      visualDensity: VisualDensity.compact,
      icon: Icon(icon, size: 22, color: HomePalette.of(context).muted),
    );
  }

  Widget _collapsed(BuildContext context) {
    return Row(
      children: [
        Text('$number', style: HomeText.of(context).heading),
        const SizedBox(width: 16),
        Expanded(child: Text(draft.term.text, style: HomeText.of(context).subtitle)),
        const SizedBox(width: 16),
        Expanded(child: Text(draft.definition.text, style: HomeText.of(context).subtitle)),
        IconButton(
          key: Key('word-card-copy-$number'),
          onPressed: () {},
          icon: const Icon(Icons.copy_outlined),
          color: HomePalette.of(context).text,
        ),
        IconButton(
          key: Key('word-card-delete-$number'),
          onPressed: () {},
          icon: const Icon(Icons.delete_outline),
          color: HomePalette.of(context).text,
        ),
      ],
    );
  }

  Widget _expanded(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text('$number', style: HomeText.of(context).heading),
            const Spacer(),
            _toolIcon(
              context,
              buttonKey: Key('word-card-image-$number'),
              icon: Icons.add_photo_alternate_outlined,
            ),
            _toolIcon(
              context,
              buttonKey: Key('word-card-edit-$number'),
              icon: Icons.edit_outlined,
            ),
            _toolIcon(
              context,
              buttonKey: Key('word-card-trash-$number'),
              icon: Icons.delete_outline,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _LabeledField(
                label: localizations.editorTerm,
                fieldKey: const Key('word-term'),
                controller: draft.term,
                hint: localizations.editorTermHint,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _LabeledField(
                label: localizations.editorDefinition,
                fieldKey: const Key('word-definition'),
                controller: draft.definition,
                hint: localizations.editorDefinitionHint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _LabeledField(
          label: localizations.editorSentence,
          fieldKey: const Key('word-sentence'),
          controller: draft.sentence,
          hint: localizations.editorSentenceHint,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(localizations.editorDetails, style: HomeText.of(context).heading),
            const Spacer(),
            IconButton(
              key: const Key('word-details-toggle'),
              onPressed: onToggleDetails,
              icon: Icon(
                draft.detailsOpen
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: HomePalette.of(context).text,
              ),
            ),
          ],
        ),
        if (draft.detailsOpen) ...[
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LabeledField(
                  label: localizations.editorIpa,
                  fieldKey: const Key('word-ipa'),
                  controller: draft.ipa,
                  hint: localizations.editorIpaHint,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LabeledField(
                  label: localizations.editorSingularPlural,
                  fieldKey: const Key('word-singular-plural'),
                  controller: draft.singularPlural,
                  hint: localizations.editorSingularPluralHint,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LabeledField(
                  label: localizations.editorNote,
                  fieldKey: const Key('word-note'),
                  controller: draft.note,
                  hint: localizations.editorNoteHint,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 20),
        Divider(
          key: const Key('word-details-divider'),
          height: 1,
          thickness: 1,
          color: HomePalette.of(context).border,
        ),
        const SizedBox(height: 16),
        Text(localizations.editorType, style: HomeText.of(context).subtitle),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _TypeChip(
              chipKey: const Key('word-type-chunking'),
              label: localizations.editorChunking,
              selected: draft.type == 'chunking',
              onPressed: () => onSelectType('chunking'),
            ),
            _TypeChip(
              chipKey: const Key('word-type-noun'),
              label: localizations.editorNoun,
              selected: draft.type == 'noun',
              onPressed: () => onSelectType('noun'),
            ),
            _TypeChip(
              chipKey: const Key('word-type-verb'),
              label: localizations.editorVerb,
              selected: draft.type == 'verb',
              onPressed: () => onSelectType('verb'),
            ),
            _TypeChip(
              chipKey: const Key('word-type-adj'),
              label: localizations.editorAdj,
              selected: draft.type == 'adj',
              onPressed: () => onSelectType('adj'),
            ),
            _TypeChip(
              chipKey: const Key('word-editor-type-add'),
              label: '+',
              selected: false,
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: onAddWord,
            style: FilledButton.styleFrom(
              backgroundColor: HomePalette.of(context).newVocab,
              foregroundColor: HomePalette.of(context).onAccent,
              minimumSize: const Size(0, 44),
              maximumSize: const Size(double.infinity, 44),
              padding: const EdgeInsets.symmetric(horizontal: 23),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: HomeText.of(context).subtitle.copyWith(
                color: HomePalette.of(context).onAccent,
              ),
            ),
            child: Text(localizations.editorAddWord),
          ),
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.buttonKey, required this.icon});

  final Key buttonKey;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    return IconButton(
      key: buttonKey,
      onPressed: () {},
      icon: Icon(icon, size: 22),
      style: IconButton.styleFrom(
        backgroundColor: colors.selectedFill,
        foregroundColor: colors.text,
        fixedSize: const Size(40, 40),
        padding: EdgeInsets.zero,
        shape: const CircleBorder(),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class _SetField extends StatelessWidget {
  const _SetField({
    required this.fillKey,
    required this.fieldKey,
    required this.controller,
    required this.hint,
    this.label,
  });

  final Key fillKey;
  final Key fieldKey;
  final TextEditingController controller;
  final String hint;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final text = HomeText.of(context);
    final lineHeight = (text.body.fontSize ?? 14) * (text.body.height ?? 1);
    final field = ConstrainedBox(
      constraints: BoxConstraints(minHeight: lineHeight),
      child: TextField(
        key: fieldKey,
        controller: controller,
        style: text.body,
        minLines: 1,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          isCollapsed: true,
          isDense: true,
          hintText: hint,
          hintStyle: text.body.copyWith(color: colors.placeholder),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
    return Container(
      key: fillKey,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.selectedFill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: label == null
          ? ConstrainedBox(
              constraints: BoxConstraints(minHeight: lineHeight * 2),
              child: Align(alignment: Alignment.centerLeft, child: field),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label!,
                  style: text.body.copyWith(
                    color: colors.selected,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                field,
              ],
            ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.fieldKey,
    required this.controller,
    required this.hint,
  });

  final String label;
  final Key fieldKey;
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Text(label, style: HomeText.of(context).body)
        else
          const SizedBox(height: 20),
        const SizedBox(height: 6),
        TextField(
          key: fieldKey,
          controller: controller,
          style: HomeText.of(context).subtitle,
          minLines: 1,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: HomeText.of(context).subtitle.copyWith(
              color: HomePalette.of(context).placeholder,
            ),
            filled: true,
            fillColor: HomePalette.of(context).folderFill,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.chipKey,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final Key chipKey;
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: chipKey,
      color: selected
          ? HomePalette.of(context).selectedFill
          : HomePalette.of(context).surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? HomePalette.of(context).selected : HomePalette.of(context).border,
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: HomeText.of(context).body.copyWith(
              color: selected ? HomePalette.of(context).selected : HomePalette.of(context).text,
            ),
          ),
        ),
      ),
    );
  }
}
