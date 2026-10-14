import 'package:flutter/material.dart';
import 'package:lang/features/home/sample/home_sample.dart';
import 'package:lang/l10n/app_localizations.dart';
import 'package:lang/library/vocabulary_set.dart';
import 'package:lang/theme/home_palette.dart';
import 'package:lang/theme/home_text.dart';

enum _PracticeMode { random, flashcard, quiz, typing }

enum _WordMark { hard, familiar, easy }

enum _ListFilter { all, learning, mastered }

class SetStudyPage extends StatefulWidget {
  const SetStudyPage({
    super.key,
    required this.set,
    required this.onEdit,
    this.narrow = false,
  });

  final VocabularySet set;
  final VoidCallback onEdit;
  final bool narrow;

  @override
  State<SetStudyPage> createState() => _SetStudyPageState();
}

class _SetStudyPageState extends State<SetStudyPage> {
  final _typing = TextEditingController();
  var _mode = _PracticeMode.flashcard;
  var _filter = _ListFilter.all;
  var _cursor = 0;
  late List<int> _order = [
    for (var index = 0; index < widget.set.words.length; index++) index,
  ];
  final _marks = <int, _WordMark>{};

  @override
  void dispose() {
    _typing.dispose();
    super.dispose();
  }

  int? get _current {
    if (_order.isEmpty) {
      return null;
    }
    final index = _cursor < 0
        ? 0
        : _cursor >= _order.length
        ? _order.length - 1
        : _cursor;
    return _order[index];
  }

  void _step(int delta) {
    if (_order.isEmpty) {
      return;
    }
    setState(() {
      _cursor = (_cursor + delta) % _order.length;
      if (_cursor < 0) {
        _cursor += _order.length;
      }
      _typing.clear();
    });
  }

  void _selectMode(_PracticeMode mode) {
    setState(() {
      _mode = mode;
      _typing.clear();
      if (mode == _PracticeMode.random && _order.length > 1) {
        _order.shuffle();
        _cursor = 0;
      }
      if (mode == _PracticeMode.flashcard) {
        _order = [
          for (var index = 0; index < widget.set.words.length; index++) index,
        ];
        if (_order.isEmpty) {
          _cursor = 0;
        } else if (_cursor >= _order.length) {
          _cursor = _order.length - 1;
        }
      }
    });
  }

  void _mark(_WordMark mark) {
    final index = _current;
    if (index == null) {
      return;
    }
    setState(() => _marks[index] = mark);
  }

  void _show(int index) {
    final position = _order.indexOf(index);
    if (position < 0) {
      return;
    }
    setState(() {
      _cursor = position;
      _typing.clear();
    });
  }

  bool _visible(int index) {
    final mark = _marks[index];
    return switch (_filter) {
      _ListFilter.all => true,
      _ListFilter.learning => mark != _WordMark.easy,
      _ListFilter.mastered => mark == _WordMark.easy,
    };
  }

  @override
  Widget build(BuildContext context) {
    final practice = _PracticeColumn(
      set: widget.set,
      mode: _mode,
      filter: _filter,
      current: _current,
      marks: _marks,
      typing: _typing,
      visible: _visible,
      onEdit: widget.onEdit,
      onMode: _selectMode,
      onStep: _step,
      onMark: _mark,
      onFilter: (filter) => setState(() => _filter = filter),
      onShow: _show,
    );
    final stats = _StudyStats(words: widget.set.words, marks: _marks);
    if (widget.narrow) {
      return Column(
        key: const Key('set-study-page'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          practice,
          const SizedBox(height: 28),
          stats,
        ],
      );
    }
    return Row(
      key: const Key('set-study-page'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: practice),
        const SizedBox(width: 24),
        SizedBox(width: 300, child: stats),
      ],
    );
  }
}

class _PracticeColumn extends StatelessWidget {
  const _PracticeColumn({
    required this.set,
    required this.mode,
    required this.filter,
    required this.current,
    required this.marks,
    required this.typing,
    required this.visible,
    required this.onEdit,
    required this.onMode,
    required this.onStep,
    required this.onMark,
    required this.onFilter,
    required this.onShow,
  });

  final VocabularySet set;
  final _PracticeMode mode;
  final _ListFilter filter;
  final int? current;
  final Map<int, _WordMark> marks;
  final TextEditingController typing;
  final bool Function(int index) visible;
  final VoidCallback onEdit;
  final ValueChanged<_PracticeMode> onMode;
  final ValueChanged<int> onStep;
  final ValueChanged<_WordMark> onMark;
  final ValueChanged<_ListFilter> onFilter;
  final ValueChanged<int> onShow;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colors = HomePalette.of(context);
    final word = current == null ? null : set.words[current!];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.menu_book_outlined, size: 20, color: colors.ink),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                set.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: HomeText.of(context).title,
              ),
            ),
            IconButton(
              key: const Key('set-study-add'),
              onPressed: onEdit,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              icon: Icon(Icons.add, color: colors.ink),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: localizations.studyTodayPractice,
                filled: true,
                onPressed: () => onMode(_PracticeMode.flashcard),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                label: localizations.studyLearnNew,
                filled: false,
                onPressed: onEdit,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ModeChip(
              chipKey: const Key('set-study-mode-random'),
              icon: Icons.shuffle,
              label: localizations.studyRandom,
              selected: mode == _PracticeMode.random,
              onTap: () => onMode(_PracticeMode.random),
            ),
            _ModeChip(
              chipKey: const Key('set-study-mode-flashcard'),
              icon: Icons.style_outlined,
              label: localizations.studyFlashcard,
              selected: mode == _PracticeMode.flashcard,
              onTap: () => onMode(_PracticeMode.flashcard),
            ),
            _ModeChip(
              chipKey: const Key('set-study-mode-quiz'),
              icon: Icons.quiz_outlined,
              label: localizations.studyQuiz,
              selected: mode == _PracticeMode.quiz,
              onTap: () => onMode(_PracticeMode.quiz),
            ),
            _ModeChip(
              chipKey: const Key('set-study-mode-typing'),
              icon: Icons.keyboard_outlined,
              label: localizations.studyTyping,
              selected: mode == _PracticeMode.typing,
              onTap: () => onMode(_PracticeMode.typing),
            ),
          ],
        ),
        const SizedBox(height: 80),
        _FlashcardStage(
          word: word,
          mode: mode,
          typing: typing,
          onStep: onStep,
        ),
        const SizedBox(height: 80),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RatingButton(
              buttonKey: const Key('set-study-hard'),
              icon: Icons.sentiment_dissatisfied,
              label: localizations.studyHard,
              color: HomeSample.forgot,
              selected: current != null && marks[current] == _WordMark.hard,
              onPressed: () => onMark(_WordMark.hard),
            ),
            const SizedBox(width: 60),
            _RatingButton(
              buttonKey: const Key('set-study-familiar'),
              icon: Icons.sentiment_neutral,
              label: localizations.studyFamiliar,
              color: HomeSample.learning,
              selected:
                  current != null && marks[current] == _WordMark.familiar,
              onPressed: () => onMark(_WordMark.familiar),
            ),
            const SizedBox(width: 60),
            _RatingButton(
              buttonKey: const Key('set-study-easy'),
              icon: Icons.sentiment_satisfied,
              label: localizations.studyEasy,
              color: HomeSample.familiar,
              selected: current != null && marks[current] == _WordMark.easy,
              onPressed: () => onMark(_WordMark.easy),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: Text(
                localizations.studyList,
                style: HomeText.of(context).heading,
              ),
            ),
            IconButton(
              key: const Key('set-study-list-add'),
              onPressed: onEdit,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              icon: Icon(Icons.add, color: colors.ink),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ModeChip(
              chipKey: const Key('set-study-filter-all'),
              icon: Icons.grid_view,
              label: localizations.allLabel,
              selected: filter == _ListFilter.all,
              onTap: () => onFilter(_ListFilter.all),
            ),
            _ModeChip(
              chipKey: const Key('set-study-filter-learning'),
              icon: Icons.timelapse,
              label: localizations.studyStillLearning,
              selected: filter == _ListFilter.learning,
              onTap: () => onFilter(_ListFilter.learning),
            ),
            _ModeChip(
              chipKey: const Key('set-study-filter-mastered'),
              icon: Icons.verified_outlined,
              label: localizations.studyMastered,
              selected: filter == _ListFilter.mastered,
              onTap: () => onFilter(_ListFilter.mastered),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (!List<int>.generate(set.words.length, (index) => index).any(visible))
          Text(
            localizations.libraryEmpty,
            style: HomeText.of(context).body.copyWith(color: colors.muted),
          )
        else
          for (var index = 0; index < set.words.length; index++)
            if (visible(index)) ...[
              _StudyWordCard(
                index: index,
                word: set.words[index],
                onTap: () => onShow(index),
                onEdit: onEdit,
              ),
              const SizedBox(height: 16),
            ],
      ],
    );
  }
}

class _FlashcardStage extends StatelessWidget {
  const _FlashcardStage({
    required this.word,
    required this.mode,
    required this.typing,
    required this.onStep,
  });

  final VocabularyWord? word;
  final _PracticeMode mode;
  final TextEditingController typing;
  final ValueChanged<int> onStep;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    return Row(
      children: [
        IconButton(
          key: const Key('set-study-prev'),
          onPressed: () => onStep(-1),
          icon: Icon(Icons.chevron_left, color: colors.ink),
        ),
        Expanded(
          child: _Flashcard(word: word, mode: mode, typing: typing),
        ),
        IconButton(
          key: const Key('set-study-next'),
          onPressed: () => onStep(1),
          icon: Icon(Icons.chevron_right, color: colors.ink),
        ),
      ],
    );
  }
}

class _Flashcard extends StatelessWidget {
  const _Flashcard({
    required this.word,
    required this.mode,
    required this.typing,
  });

  final VocabularyWord? word;
  final _PracticeMode mode;
  final TextEditingController typing;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final text = HomeText.of(context);
    final localizations = AppLocalizations.of(context);
    final current = word;
    final prompt = current == null
        ? localizations.libraryEmpty
        : mode == _PracticeMode.quiz
        ? current.definition
        : current.term;
    final image = current?.imageUrl?.trim() ?? '';
    return Container(
      key: const Key('set-study-card'),
      constraints: const BoxConstraints(minHeight: 180),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A101828),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  prompt,
                  style: text.title.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (image.isNotEmpty) ...[
                const SizedBox(width: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    image,
                    key: const Key('set-study-photo'),
                    width: 140,
                    height: 96,
                    fit: BoxFit.cover,
                    webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 140,
                        height: 96,
                        color: colors.folderFill,
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
          if (current != null &&
              mode != _PracticeMode.quiz &&
              current.sentence.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              current.sentence,
              style: text.body.copyWith(color: colors.muted),
            ),
          ],
          if (mode == _PracticeMode.typing && current != null) ...[
            const SizedBox(height: 16),
            TextField(
              key: const Key('set-study-typing'),
              controller: typing,
              style: text.subtitle,
              decoration: InputDecoration(
                hintText: localizations.editorDefinitionHint,
                hintStyle: text.subtitle.copyWith(color: colors.placeholder),
                filled: true,
                fillColor: colors.folderFill,
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
        ],
      ),
    );
  }
}

class _StudyWordCard extends StatelessWidget {
  const _StudyWordCard({
    required this.index,
    required this.word,
    required this.onTap,
    required this.onEdit,
  });

  final int index;
  final VocabularyWord word;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final image = word.imageUrl?.trim() ?? '';
    return Material(
      key: Key('set-study-word-$index'),
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _WordToolIcon(icon: Icons.volume_up_outlined),
                  const SizedBox(width: 8),
                  _WordToolIcon(icon: Icons.star_border),
                  const Spacer(),
                  _WordToolIcon(
                    icon: Icons.edit_outlined,
                    onPressed: onEdit,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          if (image.isNotEmpty) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                image,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                webHtmlElementStrategy:
                                    WebHtmlElementStrategy.prefer,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Flexible(
                            child: Text(
                              word.term,
                              style: HomeText.of(context).subtitle
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(width: 1, color: colors.border),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          word.definition,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: HomeText.of(context).subtitle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WordToolIcon extends StatelessWidget {
  const _WordToolIcon({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed ?? () {},
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      icon: Icon(icon, size: 18, color: HomePalette.of(context).muted),
    );
  }
}

class _StudyStats extends StatelessWidget {
  const _StudyStats({required this.words, required this.marks});

  final List<VocabularyWord> words;
  final Map<int, _WordMark> marks;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colors = HomePalette.of(context);
    final learned = marks.values.where((mark) => mark == _WordMark.easy).length;
    final counts = <_WordMark?, int>{
      _WordMark.hard: 0,
      _WordMark.familiar: 0,
      _WordMark.easy: 0,
      null: 0,
    };
    for (var index = 0; index < words.length; index++) {
      final mark = marks[index];
      counts[mark] = (counts[mark] ?? 0) + 1;
    }
    final bars = <HomeBar>[
      HomeBar(color: HomeSample.forgot, height: counts[_WordMark.hard]!.toDouble()),
      HomeBar(
        color: HomeSample.learning,
        height: counts[_WordMark.familiar]!.toDouble(),
      ),
      HomeBar(
        color: HomeSample.familiar,
        height: counts[_WordMark.easy]!.toDouble(),
      ),
      HomeBar(color: HomeSample.mastered, height: counts[null]!.toDouble()),
    ];
    final peak = bars.fold<double>(1, (peak, bar) {
      return bar.height > peak ? bar.height : peak;
    });
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.statisticsHeading,
              style: HomeText.of(context).heading,
            ),
            const SizedBox(height: 12),
            Text.rich(
              TextSpan(
                style: HomeText.of(context).title,
                children: [
                  TextSpan(text: '$learned'),
                  TextSpan(
                    text: '/${words.length}',
                    style: HomeText.of(context).subtitle.copyWith(
                      color: colors.ink,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final bar in bars)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (bar.height > 0)
                              Text(
                                '${bar.height.round()}',
                                style: HomeText.of(context).caption,
                              ),
                            const SizedBox(height: 4),
                            Container(
                              height: 8 + (88 * bar.height / peak),
                              decoration: BoxDecoration(
                                color: bar.color,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    localizations.wordsLearned,
                    textAlign: TextAlign.center,
                    style: HomeText.of(context).body.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colors.ink,
                    ),
                  ),
                ),
                Container(width: 1, height: 20, color: colors.scrollTrack),
                Expanded(
                  child: Text(
                    localizations.wordsNotLearned,
                    textAlign: TextAlign.center,
                    style: HomeText.of(context).body.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colors.ink,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.filled,
    required this.onPressed,
  });

  final String label;
  final bool filled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final style = FilledButton.styleFrom(
      backgroundColor: filled ? colors.practice : colors.surface,
      foregroundColor: filled ? colors.onAccent : colors.practice,
      minimumSize: const Size(double.infinity, 44),
      padding: const EdgeInsets.symmetric(horizontal: 22),
      side: filled ? null : BorderSide(color: colors.practice),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
    );
    return FilledButton(
      onPressed: onPressed,
      style: style,
      child: Text(label),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.chipKey,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Key chipKey;
  final IconData icon;
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: HomeText.of(context).body.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RatingButton extends StatelessWidget {
  const _RatingButton({
    required this.buttonKey,
    required this.icon,
    required this.label,
    required this.color,
    required this.selected,
    required this.onPressed,
  });

  final Key buttonKey;
  final IconData icon;
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          key: buttonKey,
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white, size: 28),
          style: IconButton.styleFrom(
            backgroundColor: color,
            fixedSize: const Size(56, 56),
            shape: const CircleBorder(),
            side: selected
                ? BorderSide(color: HomePalette.of(context).ink, width: 2)
                : null,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: HomeText.of(context).body.copyWith(color: color),
        ),
      ],
    );
  }
}
