import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lang/library/vocabulary_set.dart';
import 'package:lang/l10n/app_localizations.dart';
import 'package:lang/theme/home_palette.dart';
import 'package:lang/theme/home_text.dart';

Future<void> showLearnedWordsDialog({
  required BuildContext context,
  required String title,
  required List<VocabularyWord> words,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _LearnedWordsDialog(title: title, words: words),
  );
}

class _LearnedWordsDialog extends StatefulWidget {
  const _LearnedWordsDialog({required this.title, required this.words});

  final String title;
  final List<VocabularyWord> words;

  @override
  State<_LearnedWordsDialog> createState() => _LearnedWordsDialogState();
}

class _LearnedWordsDialogState extends State<_LearnedWordsDialog> {
  static const int _pageSize = 20;

  final _search = TextEditingController();
  int _limit = _pageSize;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<VocabularyWord> get _filtered {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) {
      return widget.words;
    }
    return <VocabularyWord>[
      for (final word in widget.words)
        if (word.term.toLowerCase().contains(query) ||
            word.definition.toLowerCase().contains(query) ||
            word.sentence.toLowerCase().contains(query) ||
            word.ipa.toLowerCase().contains(query) ||
            (word.type ?? '').toLowerCase().contains(query))
          word,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final text = HomeText.of(context);
    final localizations = AppLocalizations.of(context);
    final size = MediaQuery.sizeOf(context);
    final dialogWidth = size.width < 720 ? size.width - 32 : 640.0;
    final dialogHeight = size.height < 720 ? size.height - 48 : 640.0;
    final filtered = _filtered;
    final words = filtered.length <= _limit
        ? filtered
        : filtered.sublist(0, _limit);
    final hasMore = filtered.length > _limit;
    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        key: const Key('learned-words-dialog'),
        width: dialogWidth,
        height: dialogHeight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${widget.title} (${widget.words.length})',
                      style: text.heading,
                    ),
                  ),
                  IconButton(
                    key: const Key('learned-words-close'),
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
              TextField(
                key: const Key('learned-words-search'),
                controller: _search,
                onChanged: (_) => setState(() => _limit = _pageSize),
                style: text.subtitle,
                decoration: InputDecoration(
                  hintText: localizations.wordSearch,
                  hintStyle: text.subtitle.copyWith(color: colors.placeholder),
                  prefixIcon: Icon(Icons.search, color: colors.placeholder),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.border, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: filtered.isEmpty
                    ? Text(
                        localizations.libraryEmpty,
                        style: text.body.copyWith(color: colors.muted),
                      )
                    : ListView.separated(
                        itemCount: words.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) =>
                            _WordCard(word: words[index]),
                      ),
              ),
              if (hasMore) ...[
                const SizedBox(height: 8),
                TextButton(
                  key: const Key('learned-words-load-more'),
                  onPressed: () => setState(() => _limit += _pageSize),
                  style: TextButton.styleFrom(
                    foregroundColor: colors.selected,
                    textStyle: text.subtitle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text(localizations.loadMore),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WordCard extends StatelessWidget {
  const _WordCard({required this.word});

  final VocabularyWord word;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final text = HomeText.of(context);
    final type = word.type?.trim() ?? '';
    final ipa = word.ipa.trim();
    final sentence = word.sentence.trim();
    final image = word.imageUrl?.trim() ?? '';
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image.startsWith('http')) ...[
              _Thumb(url: image),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        word.term,
                        style: text.subtitle.copyWith(
                          color: colors.selected,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (type.isNotEmpty)
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.selectedFill,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            child: Text(
                              type,
                              style: text.caption.copyWith(
                                color: colors.selected,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (ipa.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            ipa,
                            style: text.body.copyWith(color: colors.text),
                          ),
                        ),
                        _SpeakButton(term: word.term),
                      ],
                    ),
                  ],
                  if (sentence.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.folderFill,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Text(
                          sentence,
                          style: text.body.copyWith(color: colors.text),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: 72,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      ),
    );
  }
}

class _SpeakButton extends StatelessWidget {
  const _SpeakButton({required this.term});

  final String term;

  Future<void> _speak() async {
    final spoken = term.trim();
    if (spoken.isEmpty) {
      return;
    }
    try {
      final speech = FlutterTts();
      await speech.setSpeechRate(0.45);
      await speech.speak(spoken);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _speak,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      icon: Icon(
        Icons.volume_up_outlined,
        size: 16,
        color: HomePalette.of(context).text,
      ),
    );
  }
}
