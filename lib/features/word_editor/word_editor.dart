import 'package:flutter/material.dart';
import 'package:lang/library/vocabulary_set.dart';
import 'package:lang/l10n/app_localizations.dart';
import 'package:lang/theme/home_palette.dart';
import 'package:lang/theme/home_text.dart';

const _requiredColor = Color(0xFFD92D20);

class WordEditor extends StatefulWidget {
  const WordEditor({super.key, this.onClose, this.setStore, this.initialSet});

  final VoidCallback? onClose;
  final VocabularySetStore? setStore;
  final VocabularySet? initialSet;

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
  final imageUrl = TextEditingController();
  String? type;
  bool detailsOpen = true;
  bool imageLinkOpen = false;
  bool termInvalid = false;
  bool definitionInvalid = false;
  bool sentenceInvalid = false;

  void dispose() {
    term.dispose();
    definition.dispose();
    sentence.dispose();
    ipa.dispose();
    singularPlural.dispose();
    note.dispose();
    imageUrl.dispose();
  }
}

class _WordEditorState extends State<WordEditor> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _drafts = <_Draft>[_Draft()];
  bool _titleInvalid = false;
  bool _descriptionInvalid = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialSet;
    if (initial == null) {
      return;
    }
    _title.text = initial.title;
    _description.text = initial.description;
    for (final draft in _drafts) {
      draft.dispose();
    }
    _drafts.clear();
    if (initial.words.isEmpty) {
      return;
    }
    _drafts.addAll(initial.words.map(_draftFromWord));
  }

  _Draft _draftFromWord(VocabularyWord word) {
    final draft = _Draft();
    draft.term.text = word.term;
    draft.definition.text = word.definition;
    draft.sentence.text = word.sentence;
    draft.ipa.text = word.ipa;
    draft.singularPlural.text = word.singularPlural;
    draft.note.text = word.note;
    draft.imageUrl.text = word.imageUrl ?? '';
    draft.type = word.type;
    return draft;
  }

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
    final draft = _drafts.last;
    final termMissing = draft.term.text.trim().isEmpty;
    final definitionMissing = draft.definition.text.trim().isEmpty;
    final sentenceMissing = draft.sentence.text.trim().isEmpty;
    if (termMissing || definitionMissing || sentenceMissing) {
      setState(() {
        draft.termInvalid = termMissing;
        draft.definitionInvalid = definitionMissing;
        draft.sentenceInvalid = sentenceMissing;
      });
      return;
    }
    setState(() {
      draft.termInvalid = false;
      draft.definitionInvalid = false;
      draft.sentenceInvalid = false;
      _drafts.add(_Draft());
    });
  }

  void _selectType(_Draft draft, String type) {
    setState(() {
      draft.type = draft.type == type ? null : type;
    });
  }

  void _toggleDetails(_Draft draft) {
    setState(() => draft.detailsOpen = !draft.detailsOpen);
  }

  void _toggleImageLink(_Draft draft) {
    setState(() => draft.imageLinkOpen = !draft.imageLinkOpen);
  }

  void _close() {
    final onClose = widget.onClose;
    if (onClose != null) {
      onClose();
      return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _save() async {
    final titleMissing = _title.text.trim().isEmpty;
    final descriptionMissing = _description.text.trim().isEmpty;
    if (titleMissing || descriptionMissing) {
      setState(() {
        _titleInvalid = titleMissing;
        _descriptionInvalid = descriptionMissing;
      });
      return;
    }
    final set = buildVocabularySet(
      title: _title.text,
      description: _description.text,
      cards: <VocabularyCardDraft>[
        for (final draft in _drafts)
          VocabularyCardDraft(
            term: draft.term.text,
            definition: draft.definition.text,
            sentence: draft.sentence.text,
            ipa: draft.ipa.text,
            singularPlural: draft.singularPlural.text,
            note: draft.note.text,
            type: draft.type,
            imageUrl: draft.imageUrl.text,
          ),
      ],
    );
    if (set == null) {
      _close();
      return;
    }
    final store = widget.setStore;
    if (store == null) {
      return;
    }
    try {
      await store.save(set);
    } catch (_) {
      return;
    }
    if (!mounted) {
      return;
    }
    _close();
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
                errorText: _titleInvalid && _title.text.trim().isEmpty
                    ? localizations.requiredField
                    : null,
                onChanged: _titleInvalid ? (_) => setState(() {}) : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _SetField(
                fillKey: const Key('word-editor-description-fill'),
                fieldKey: const Key('word-editor-description'),
                controller: _description,
                hint: localizations.editorDescriptionHint,
                errorText:
                    _descriptionInvalid && _description.text.trim().isEmpty
                    ? localizations.requiredField
                    : null,
                onChanged: _descriptionInvalid ? (_) => setState(() {}) : null,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: HomeText.of(context).subtitle
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    localizations.editorImport,
                    style: HomeText.of(context).subtitle
                        .copyWith(fontWeight: FontWeight.w700),
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
              expanded:
                  widget.initialSet == null && index == _drafts.length - 1,
              localizations: localizations,
              onAddWord: _addWord,
              onSelectType: (type) => _selectType(_drafts[index], type),
              onToggleDetails: () => _toggleDetails(_drafts[index]),
              onToggleImageLink: () => _toggleImageLink(_drafts[index]),
              onImageEdited: () => setState(() {}),
            ),
          ),
      ],
    );
    final header = _Header(
      localizations: localizations,
      onClose: _close,
      onDone: _save,
    );
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
  const _Header({
    required this.localizations,
    required this.onClose,
    required this.onDone,
  });

  final AppLocalizations localizations;
  final VoidCallback onClose;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final text = HomeText.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
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
            onPressed: onDone,
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
              textStyle: HomeText.of(context).subtitle
                  .copyWith(color: HomePalette.of(context).onAccent),
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
    required this.onToggleImageLink,
    required this.onImageEdited,
  });

  final _Draft draft;
  final int number;
  final bool expanded;
  final AppLocalizations localizations;
  final VoidCallback onAddWord;
  final ValueChanged<String> onSelectType;
  final VoidCallback onToggleDetails;
  final VoidCallback onToggleImageLink;
  final VoidCallback onImageEdited;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('word-card-$number'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HomePalette.of(context).surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HomePalette.of(context).border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A101828),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: expanded ? _expanded(context) : _collapsed(context),
    );
  }

  Widget _toolIcon(
    BuildContext context, {
    required Key buttonKey,
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return IconButton(
      key: buttonKey,
      onPressed: onPressed ?? () {},
      visualDensity: VisualDensity.compact,
      icon: Icon(icon, size: 22, color: HomePalette.of(context).muted),
    );
  }

  Widget _cardTools(
    BuildContext context, {
    VoidCallback? onImage,
    Color? numberColor,
  }) {
    return Row(
      children: [
        Text(
          '$number',
          style: HomeText.of(context).heading.copyWith(color: numberColor),
        ),
        const Spacer(),
        _toolIcon(
          context,
          buttonKey: Key('word-card-image-$number'),
          icon: Icons.add_photo_alternate_outlined,
          onPressed: onImage,
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
    );
  }

  Widget _photo(BuildContext context, String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        key: Key('word-card-photo-$number'),
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            key: Key('word-card-photo-$number'),
            width: 72,
            height: 72,
            color: HomePalette.of(context).folderFill,
          );
        },
      ),
    );
  }

  Widget _termLine(BuildContext context) {
    return Text(
      draft.term.text,
      style: HomeText.of(context).subtitle
          .copyWith(fontWeight: FontWeight.w700),
    );
  }

  Widget _collapsed(BuildContext context) {
    final image = draft.imageUrl.text.trim();
    final extras = <String>[
      draft.sentence.text.trim(),
    ].where((value) => value.isNotEmpty);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _cardTools(context, numberColor: HomePalette.of(context).selected),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  key: Key('word-card-term-column-$number'),
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (image.isNotEmpty) ...[
                      _photo(context, image),
                      const SizedBox(width: 12),
                    ],
                    Flexible(child: _termLine(context)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(width: 1, color: HomePalette.of(context).border),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: Align(
                  key: Key('word-card-definition-column-$number'),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    draft.definition.text,
                    style: HomeText.of(context).subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
        for (final extra in extras) ...[
          const SizedBox(height: 8),
          Text(extra, style: HomeText.of(context).body),
        ],
      ],
    );
  }

  Widget _expanded(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _cardTools(context, onImage: onToggleImageLink),
        if (draft.imageLinkOpen) ...[
          const SizedBox(height: 12),
          TextField(
            key: Key('word-image-link-$number'),
            controller: draft.imageUrl,
            onChanged: (_) => onImageEdited(),
            style: HomeText.of(context).subtitle,
            decoration: InputDecoration(
              hintText: localizations.editorImageLinkHint,
              hintStyle: HomeText.of(context).subtitle
                  .copyWith(color: HomePalette.of(context).placeholder),
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
        if (draft.imageUrl.text.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: _photo(context, draft.imageUrl.text.trim()),
          ),
        ],
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
                errorText: draft.termInvalid && draft.term.text.trim().isEmpty
                    ? localizations.requiredField
                    : null,
                onChanged: draft.termInvalid ? (_) => onImageEdited() : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _LabeledField(
                label: localizations.editorDefinition,
                fieldKey: const Key('word-definition'),
                controller: draft.definition,
                hint: localizations.editorDefinitionHint,
                errorText:
                    draft.definitionInvalid &&
                        draft.definition.text.trim().isEmpty
                    ? localizations.requiredField
                    : null,
                onChanged: draft.definitionInvalid
                    ? (_) => onImageEdited()
                    : null,
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
          errorText: draft.sentenceInvalid && draft.sentence.text.trim().isEmpty
              ? localizations.requiredField
              : null,
          onChanged: draft.sentenceInvalid ? (_) => onImageEdited() : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              localizations.editorDetails,
              style: HomeText.of(context).heading,
            ),
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
              tone: _typeTone(context, 'chunking'),
              selected: draft.type == 'chunking',
              onPressed: () => onSelectType('chunking'),
            ),
            _TypeChip(
              chipKey: const Key('word-type-noun'),
              label: localizations.editorNoun,
              tone: _typeTone(context, 'noun'),
              selected: draft.type == 'noun',
              onPressed: () => onSelectType('noun'),
            ),
            _TypeChip(
              chipKey: const Key('word-type-verb'),
              label: localizations.editorVerb,
              tone: _typeTone(context, 'verb'),
              selected: draft.type == 'verb',
              onPressed: () => onSelectType('verb'),
            ),
            _TypeChip(
              chipKey: const Key('word-type-adj'),
              label: localizations.editorAdj,
              tone: _typeTone(context, 'adj'),
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
              textStyle: HomeText.of(context).subtitle
                  .copyWith(color: HomePalette.of(context).onAccent),
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
    this.errorText,
    this.onChanged,
  });

  final Key fillKey;
  final Key fieldKey;
  final TextEditingController controller;
  final String hint;
  final String? label;
  final String? errorText;
  final ValueChanged<String>? onChanged;

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
        onChanged: onChanged,
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
    final errorText = this.errorText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          key: fillKey,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colors.selectedFill,
            borderRadius: BorderRadius.circular(12),
            border: errorText == null
                ? null
                : Border.all(color: _requiredColor),
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
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(errorText, style: text.body.copyWith(color: _requiredColor)),
        ],
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.fieldKey,
    required this.controller,
    required this.hint,
    this.errorText,
    this.onChanged,
  });

  final String label;
  final Key fieldKey;
  final TextEditingController controller;
  final String hint;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final errorText = this.errorText;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: errorText == null
          ? BorderSide.none
          : const BorderSide(color: _requiredColor),
    );
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
          onChanged: onChanged,
          style: HomeText.of(context).subtitle,
          minLines: 1,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: HomeText.of(context).subtitle
                .copyWith(color: HomePalette.of(context).placeholder),
            filled: true,
            fillColor: HomePalette.of(context).folderFill,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: border,
            enabledBorder: border,
            focusedBorder: border,
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText,
            style: HomeText.of(context).body.copyWith(color: _requiredColor),
          ),
        ],
      ],
    );
  }
}

class _TypeTone {
  const _TypeTone({required this.fill, required this.ink});

  final Color fill;
  final Color ink;
}

_TypeTone? _typeTone(BuildContext context, String? type) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return switch (type) {
    'chunking' =>
      dark
          ? const _TypeTone(fill: Color(0xFF3B2764), ink: Color(0xFFD6BBFB))
          : const _TypeTone(fill: Color(0xFFF4EBFF), ink: Color(0xFF6941C6)),
    'noun' =>
      dark
          ? const _TypeTone(fill: Color(0xFF0B3A5B), ink: Color(0xFF7CD4FD))
          : const _TypeTone(fill: Color(0xFFE0F2FE), ink: Color(0xFF026AA2)),
    'verb' =>
      dark
          ? const _TypeTone(fill: Color(0xFF053321), ink: Color(0xFF75E0A7))
          : const _TypeTone(fill: Color(0xFFDCFAE6), ink: Color(0xFF067647)),
    'adj' =>
      dark
          ? const _TypeTone(fill: Color(0xFF4A1224), ink: Color(0xFFFEA3B4))
          : const _TypeTone(fill: Color(0xFFFFE4E8), ink: Color(0xFFC01048)),
    _ => null,
  };
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.chipKey,
    required this.label,
    required this.selected,
    required this.onPressed,
    this.tone,
  });

  final Key chipKey;
  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final _TypeTone? tone;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final tone = this.tone;
    final Color fill;
    final Color ink;
    final Color border;
    if (tone == null) {
      fill = selected ? colors.selectedFill : colors.surface;
      ink = selected ? colors.selected : colors.text;
      border = selected ? colors.selected : colors.border;
    } else if (selected) {
      final dark = Theme.of(context).brightness == Brightness.dark;
      fill = tone.ink;
      ink = dark ? tone.fill : colors.onAccent;
      border = tone.ink;
    } else {
      fill = tone.fill;
      ink = tone.ink;
      border = tone.ink;
    }
    return Material(
      key: chipKey,
      color: fill,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: border),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: HomeText.of(context).body.copyWith(color: ink),
          ),
        ),
      ),
    );
  }
}
