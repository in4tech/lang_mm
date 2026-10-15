import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lang/features/home/sample/home_sample.dart';
import 'package:lang/l10n/app_localizations.dart';
import 'package:lang/library/study_progress.dart';
import 'package:lang/library/vocabulary_set.dart';
import 'package:lang/theme/home_palette.dart';
import 'package:lang/theme/home_text.dart';

enum _PracticeMode { random, flashcard, quiz, typing }

enum _ListFilter { all, learning, mastered }

class SetStudyPage extends StatefulWidget {
  const SetStudyPage({
    super.key,
    required this.set,
    required this.onEdit,
    this.narrow = false,
    this.progress,
    this.initialMarks = const <int, StudyMark>{},
    this.cues,
  });

  final VocabularySet set;
  final VoidCallback onEdit;
  final bool narrow;
  final StudyProgressStore? progress;
  final Map<int, StudyMark> initialMarks;
  final List<StudyCue>? cues;

  @override
  State<SetStudyPage> createState() => _SetStudyPageState();
}

class _SetStudyPageState extends State<SetStudyPage> {
  final _typing = TextEditingController();
  var _mode = _PracticeMode.flashcard;
  var _practicing = false;
  var _filter = _ListFilter.all;
  var _cursor = 0;
  var _faceToken = 0;
  late List<StudyCue> _order = _sessionOf(widget);
  late final Map<int, StudyMark> _marks = Map<int, StudyMark>.from(
    widget.initialMarks,
  );

  @override
  void initState() {
    super.initState();
    _practicing = widget.cues != null;
    _loadMarks();
  }

  @override
  void dispose() {
    _typing.dispose();
    super.dispose();
  }

  static List<StudyCue> _sessionOf(SetStudyPage widget) {
    final cues = widget.cues;
    if (cues != null) {
      return List<StudyCue>.from(cues);
    }
    return <StudyCue>[
      for (var index = 0; index < widget.set.words.length; index++)
        StudyCue(
          word: widget.set.words[index],
          setId: widget.set.id,
          index: index,
        ),
    ];
  }

  StudyCue? get _current {
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

  Future<void> _loadMarks() async {
    final store = widget.progress;
    final id = widget.set.id;
    if (store == null || id == null) {
      return;
    }
    try {
      final stored = await store.marksFor(id);
      if (!mounted || stored.isEmpty) {
        return;
      }
      setState(() => _marks.addAll(stored));
    } catch (_) {}
  }

  void _step(int delta) {
    if (_order.length < 2) {
      return;
    }
    setState(() {
      _cursor = (_cursor + delta) % _order.length;
      if (_cursor < 0) {
        _cursor += _order.length;
      }
      _typing.clear();
      _faceToken += 1;
    });
  }

  void _selectMode(_PracticeMode mode) {
    setState(() {
      _mode = mode;
      _typing.clear();
      _faceToken += 1;
      if (mode == _PracticeMode.flashcard) {
        _order = _sessionOf(widget);
        if (_order.isEmpty) {
          _cursor = 0;
        } else if (_cursor >= _order.length) {
          _cursor = _order.length - 1;
        }
      }
    });
  }

  void _mark(StudyMark mark) {
    final cue = _current;
    if (cue == null) {
      return;
    }
    final advance =
        _mode == _PracticeMode.flashcard && _cursor < _order.length - 1;
    setState(() {
      _marks[cue.index] = mark;
      _faceToken += 1;
      if (advance) {
        _cursor += 1;
      }
      _typing.clear();
    });
    final id = cue.setId;
    final store = widget.progress;
    if (id != null && store != null) {
      store.rate(setId: id, index: cue.index, mark: mark);
    }
  }

  void _show(int index) {
    final position = _order.indexWhere((cue) => cue.index == index);
    if (position < 0) {
      return;
    }
    setState(() {
      _cursor = position;
      _typing.clear();
      _faceToken += 1;
    });
  }

  bool _visible(int index) {
    final mark = _marks[index];
    return switch (_filter) {
      _ListFilter.all => true,
      _ListFilter.learning => mark != StudyMark.easy,
      _ListFilter.mastered => mark == StudyMark.easy,
    };
  }

  @override
  Widget build(BuildContext context) {
    final cue = _current;
    VocabularyWord? peek;
    VocabularyWord? previous;
    if (_order.length > 1) {
      peek = _order[(_cursor + 1) % _order.length].word;
      final back = _cursor - 1;
      previous = _order[back < 0 ? back + _order.length : back].word;
    }
    final practice = _PracticeColumn(
      set: widget.set,
      mode: _mode,
      filter: _filter,
      current: cue,
      peek: peek,
      previous: previous,
      faceToken: _faceToken,
      marks: _marks,
      typing: _typing,
      visible: _visible,
      practicing: _practicing,
      onEdit: widget.onEdit,
      onPractice: () {
        setState(() {
          _practicing = true;
          _mode = _PracticeMode.flashcard;
          _faceToken += 1;
        });
      },
      onLeavePractice: () => setState(() => _practicing = false),
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
    required this.peek,
    required this.previous,
    required this.faceToken,
    required this.marks,
    required this.typing,
    required this.visible,
    required this.practicing,
    required this.onEdit,
    required this.onPractice,
    required this.onLeavePractice,
    required this.onMode,
    required this.onStep,
    required this.onMark,
    required this.onFilter,
    required this.onShow,
  });

  final VocabularySet set;
  final _PracticeMode mode;
  final _ListFilter filter;
  final StudyCue? current;
  final VocabularyWord? peek;
  final VocabularyWord? previous;
  final int faceToken;
  final Map<int, StudyMark> marks;
  final TextEditingController typing;
  final bool Function(int index) visible;
  final bool practicing;
  final VoidCallback onEdit;
  final VoidCallback onPractice;
  final VoidCallback onLeavePractice;
  final ValueChanged<_PracticeMode> onMode;
  final ValueChanged<int> onStep;
  final ValueChanged<StudyMark> onMark;
  final ValueChanged<_ListFilter> onFilter;
  final ValueChanged<int> onShow;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colors = HomePalette.of(context);
    final word = current?.word;
    final cue = current;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (practicing) ...[
          Row(
            children: [
              IconButton(
                key: const Key('set-study-practice-back'),
                onPressed: onLeavePractice,
                icon: Icon(Icons.arrow_back, color: colors.ink),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  set.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: HomeText.of(context).title,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
            ],
          ),
          const SizedBox(height: 32),
          _FlashcardStage(
            word: word,
            peek: peek,
            mode: mode,
            typing: typing,
            onStep: onStep,
            faceToken: faceToken,
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RatingButton(
                buttonKey: const Key('set-study-hard'),
                icon: Icons.sentiment_dissatisfied,
                label: localizations.studyHard,
                color: HomeSample.forgot,
                selected: cue != null && marks[cue.index] == StudyMark.hard,
                onPressed: () => onMark(StudyMark.hard),
              ),
              const SizedBox(width: 60),
              _RatingButton(
                buttonKey: const Key('set-study-familiar'),
                icon: Icons.sentiment_neutral,
                label: localizations.studyFamiliar,
                color: HomeSample.learning,
                selected:
                    cue != null && marks[cue.index] == StudyMark.familiar,
                onPressed: () => onMark(StudyMark.familiar),
              ),
              const SizedBox(width: 60),
              _RatingButton(
                buttonKey: const Key('set-study-easy'),
                icon: Icons.sentiment_satisfied,
                label: localizations.studyEasy,
                color: HomeSample.familiar,
                selected: cue != null && marks[cue.index] == StudyMark.easy,
                onPressed: () => onMark(StudyMark.easy),
              ),
            ],
          ),
        ] else ...[
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
                  buttonKey: const Key('set-study-today-practice'),
                  label: localizations.studyTodayPractice,
                  filled: true,
                  onPressed: onPractice,
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
          const SizedBox(height: 60),
          _WordPreview(
            word: word,
            nextWord: peek,
            previousWord: previous,
            onStep: onStep,
            onEdit: onEdit,
          ),
          const SizedBox(height: 100),
        ],
        if (!practicing) ...[
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
      ],
    );
  }
}

class _WordPreview extends StatefulWidget {
  const _WordPreview({
    required this.word,
    required this.nextWord,
    required this.previousWord,
    required this.onStep,
    required this.onEdit,
  });

  final VocabularyWord? word;
  final VocabularyWord? nextWord;
  final VocabularyWord? previousWord;
  final ValueChanged<int> onStep;
  final VoidCallback onEdit;

  static const _termColor = Color(0xFF1D4ED8);
  static const _sentenceColor = Color(0xFFC47B4A);
  static const _peekColor = Color(0xFFD7E6FB);
  static const _nearColor = Color(0xFF90B8E9);
  static const _nearDegrees = -3.5;
  static const _farDegrees = -6.5;
  static const _nearDrop = 16.0;
  static const _nearShift = 9.0;
  static const _farDrop = 28.0;
  static const _farShift = 15.0;

  @override
  State<_WordPreview> createState() => _WordPreviewState();
}

class _WordPreviewState extends State<_WordPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  var _direction = 0;
  VocabularyWord? _from;
  VocabularyWord? _to;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  Future<void> _go(int delta) async {
    if (_direction != 0) {
      return;
    }
    final incoming = delta > 0 ? widget.nextWord : widget.previousWord;
    if (incoming == null || MediaQuery.disableAnimationsOf(context)) {
      widget.onStep(delta);
      return;
    }
    setState(() {
      _direction = delta;
      _from = widget.word;
      _to = incoming;
    });
    await _motion.forward(from: 0);
    if (!mounted) {
      return;
    }
    _direction = 0;
    _from = null;
    _to = null;
    _motion.value = 0;
    widget.onStep(delta);
  }

  double _mix(double from, double to, double t) => from + (to - from) * t;

  Widget _posed({
    required Widget child,
    required double degrees,
    required double shift,
    required double drop,
  }) {
    return Transform.translate(
      offset: Offset(shift, drop),
      child: Transform.rotate(
        angle: degrees * math.pi / 180,
        alignment: Alignment.bottomLeft,
        child: child,
      ),
    );
  }

  Widget _tumble(Widget child, double t) {
    final flip = Curves.easeIn.transform(t);
    final drop = Curves.easeIn.transform(t) * 280;
    final opacity = t < 0.55 ? 1.0 : (1 - (t - 0.55) / 0.45).clamp(0.0, 1.0);
    return Opacity(
      opacity: opacity,
      child: Transform(
        alignment: Alignment.topCenter,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0015)
          ..translate(t * 18, drop)
          ..rotateZ(t * 0.18)
          ..rotateX(-flip * 1.4),
        child: child,
      ),
    );
  }

  Widget _face({
    required VocabularyWord? word,
    required HomeText text,
    required HomePalette colors,
    required bool keyed,
  }) {
    return _PreviewFace(
      word: word,
      image: word?.imageUrl?.trim() ?? '',
      text: text,
      colors: colors,
      onEdit: widget.onEdit,
      keyed: keyed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final text = HomeText.of(context);
    final hasPeek = widget.nextWord != null;
    return Row(
      children: [
        IconButton(
          key: const Key('set-study-prev'),
          onPressed: () => _go(-1),
          icon: Icon(Icons.chevron_left, color: colors.ink, size: 32),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: hasPeek ? 20 : 0,
              top: hasPeek ? 12 : 0,
              right: hasPeek ? 8 : 0,
            ),
            child: AnimatedBuilder(
              animation: _motion,
              builder: (context, _) {
                final moving = _direction != 0;
                final t = Curves.easeInOut.transform(
                  moving ? _motion.value : 0,
                );
                final reveal = Curves.easeOut.transform(
                  ((t - 0.2) / 0.8).clamp(0.0, 1.0),
                );
                final current = moving ? _from : widget.word;
                final front = _face(
                  word: current,
                  text: text,
                  colors: colors,
                  keyed: true,
                );
                final incoming = _to == null
                    ? null
                    : IgnorePointer(
                        child: _face(
                          word: _to,
                          text: text,
                          colors: colors,
                          keyed: false,
                        ),
                      );
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (hasPeek && !moving) ...[
                      const Positioned.fill(
                        child: _FannedSheet(
                          degrees: _WordPreview._farDegrees,
                          color: _WordPreview._peekColor,
                          drop: _WordPreview._farDrop,
                          shift: _WordPreview._farShift,
                        ),
                      ),
                      const Positioned.fill(
                        key: Key('set-study-peek'),
                        child: _FannedSheet(
                          degrees: _WordPreview._nearDegrees,
                          color: _WordPreview._nearColor,
                          drop: _WordPreview._nearDrop,
                          shift: _WordPreview._nearShift,
                        ),
                      ),
                    ],
                    if (hasPeek && moving)
                      Positioned.fill(
                        child: _FannedSheet(
                          degrees: _mix(
                            _WordPreview._farDegrees,
                            _WordPreview._nearDegrees,
                            _direction > 0 ? reveal : 1 - reveal,
                          ),
                          color: _WordPreview._peekColor,
                          drop: _mix(
                            _WordPreview._farDrop,
                            _WordPreview._nearDrop,
                            _direction > 0 ? reveal : 1 - reveal,
                          ),
                          shift: _mix(
                            _WordPreview._farShift,
                            _WordPreview._nearShift,
                            _direction > 0 ? reveal : 1 - reveal,
                          ),
                        ),
                      ),
                    if (_direction > 0 && incoming != null)
                      Positioned.fill(
                        child: _posed(
                          degrees: _mix(_WordPreview._nearDegrees, 0, reveal),
                          shift: _mix(_WordPreview._nearShift, 0, reveal),
                          drop: _mix(_WordPreview._nearDrop, 0, reveal),
                          child: incoming,
                        ),
                      ),
                    if (_direction > 0)
                      _tumble(IgnorePointer(child: front), t)
                    else if (_direction < 0)
                      _posed(
                        degrees: _mix(0, _WordPreview._nearDegrees, reveal),
                        shift: _mix(0, _WordPreview._nearShift, reveal),
                        drop: _mix(0, _WordPreview._nearDrop, reveal),
                        child: IgnorePointer(child: front),
                      )
                    else
                      front,
                    if (_direction < 0 && incoming != null)
                      Positioned.fill(child: _tumble(incoming, 1 - t)),
                  ],
                );
              },
            ),
          ),
        ),
        IconButton(
          key: const Key('set-study-next'),
          onPressed: () => _go(1),
          icon: Icon(Icons.chevron_right, color: colors.ink, size: 32),
        ),
      ],
    );
  }
}

class _PreviewTool extends StatelessWidget {
  const _PreviewTool({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed ?? () {},
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      icon: Icon(
        icon,
        size: _SpeakButton.iconSize,
        color: HomePalette.of(context).muted,
      ),
    );
  }
}

class _FannedSheet extends StatelessWidget {
  const _FannedSheet({
    required this.degrees,
    required this.color,
    this.drop = 0,
    this.shift = 0,
  });

  final double degrees;
  final Color color;
  final double drop;
  final double shift;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(shift, drop),
      child: Transform.rotate(
        angle: degrees * math.pi / 180,
        alignment: Alignment.bottomLeft,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _PreviewTypeBox extends StatelessWidget {
  const _PreviewTypeBox({required this.type, required this.label});

  final String type;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final Color fill;
    final Color ink;
    final Color border;
    switch (type) {
      case 'chunking':
        fill = dark ? const Color(0xFF3B2764) : const Color(0xFFF4EBFF);
        ink = dark ? const Color(0xFFD6BBFB) : const Color(0xFF6941C6);
        border = ink;
      case 'noun':
        fill = dark ? const Color(0xFF0B3A5B) : const Color(0xFFE0F2FE);
        ink = dark ? const Color(0xFF7CD4FD) : const Color(0xFF026AA2);
        border = ink;
      case 'verb':
        fill = dark ? const Color(0xFF053321) : const Color(0xFFDCFAE6);
        ink = dark ? const Color(0xFF75E0A7) : const Color(0xFF067647);
        border = ink;
      case 'adj':
        fill = dark ? const Color(0xFF4A1224) : const Color(0xFFFFE4E8);
        ink = dark ? const Color(0xFFFEA3B4) : const Color(0xFFC01048);
        border = ink;
      default:
        fill = colors.surface;
        ink = colors.text;
        border = colors.border;
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          label,
          style: HomeText.of(context).caption.copyWith(color: ink),
        ),
      ),
    );
  }
}

String? _previewTypeLabel(AppLocalizations text, String? type) {
  final value = type?.trim() ?? '';
  if (value.isEmpty) {
    return null;
  }
  return switch (value) {
    'chunking' => text.editorChunking,
    'noun' => text.editorNoun,
    'verb' => text.editorVerb,
    'adj' => text.editorAdj,
    _ => value,
  };
}

class _PreviewFace extends StatelessWidget {
  const _PreviewFace({
    required this.word,
    required this.image,
    required this.text,
    required this.colors,
    required this.onEdit,
    this.keyed = true,
  });

  final VocabularyWord? word;
  final String image;
  final HomeText text;
  final HomePalette colors;
  final VoidCallback onEdit;
  final bool keyed;

  @override
  Widget build(BuildContext context) {
    final current = word;
    final typeValue = current?.type?.trim() ?? '';
    final typeLabel = _previewTypeLabel(
      AppLocalizations.of(context),
      current?.type,
    );
    final ipa = current?.ipa.trim() ?? '';
    final lines = <Widget>[
      if (current == null)
        Text(
          AppLocalizations.of(context).libraryEmpty,
          textAlign: TextAlign.center,
          style: text.title,
        )
      else ...[
        Text(
          current.term,
          textAlign: TextAlign.center,
          style: text.title.copyWith(
            color: _WordPreview._termColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (typeLabel != null || ipa.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (typeLabel != null) ...[
                _PreviewTypeBox(type: typeValue, label: typeLabel),
                if (ipa.isNotEmpty) const SizedBox(width: 8),
              ],
              if (ipa.isNotEmpty)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.folderFill,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    child: Text(
                      ipa,
                      style: text.caption.copyWith(color: colors.muted),
                    ),
                  ),
                ),
            ],
          ),
        ],
        if (current.singularPlural.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            current.singularPlural.trim(),
            textAlign: TextAlign.center,
            style: text.subtitle.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
        if (current.sentence.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            current.sentence.trim(),
            textAlign: TextAlign.center,
            style: text.body.copyWith(color: _WordPreview._sentenceColor),
          ),
        ],
        if (current.definition.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            current.definition.trim(),
            textAlign: TextAlign.center,
            style: text.body.copyWith(
              color: colors.muted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        if (current.note.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            current.note.trim().startsWith('*')
                ? current.note.trim()
                : '*${current.note.trim()}',
            textAlign: TextAlign.center,
            style: text.caption.copyWith(color: colors.muted),
          ),
        ],
      ],
    ];
    return Container(
      key: const Key('set-study-card'),
      constraints: const BoxConstraints(minHeight: 230),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A101828),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _PreviewTool(icon: Icons.edit_outlined, onPressed: onEdit),
              const Spacer(),
              if (current != null && current.term.trim().isNotEmpty)
                _SpeakButton(term: current.term, keyed: keyed),
              const _PreviewTool(icon: Icons.star_border),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: lines,
                ),
              ),
              if (image.isNotEmpty) ...[
                const SizedBox(width: 16),
                _CardPhoto(image: image, fill: colors.folderFill),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _FlashcardStage extends StatefulWidget {
  const _FlashcardStage({
    required this.word,
    required this.peek,
    required this.mode,
    required this.typing,
    required this.onStep,
    required this.faceToken,
  });

  final VocabularyWord? word;
  final VocabularyWord? peek;
  final _PracticeMode mode;
  final TextEditingController typing;
  final ValueChanged<int> onStep;
  final int faceToken;

  @override
  State<_FlashcardStage> createState() => _FlashcardStageState();
}

class _FlashcardStageState extends State<_FlashcardStage>
    with TickerProviderStateMixin {
  late final AnimationController _flip;
  late final AnimationController _slide;
  var _slideSign = 1.0;

  @override
  void initState() {
    super.initState();
    _flip = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _slide = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
  }

  @override
  void didUpdateWidget(_FlashcardStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.word != widget.word ||
        oldWidget.mode != widget.mode ||
        oldWidget.faceToken != widget.faceToken) {
      _flip.value = 0;
    }
  }

  @override
  void dispose() {
    _flip.dispose();
    _slide.dispose();
    super.dispose();
  }

  bool get _reduced => MediaQuery.disableAnimationsOf(context);

  Future<void> _go(int delta) async {
    if (widget.mode == _PracticeMode.flashcard) {
      return;
    }
    if (widget.mode != _PracticeMode.random || widget.peek == null) {
      widget.onStep(delta);
      return;
    }
    if (_reduced) {
      widget.onStep(delta);
      return;
    }
    setState(() => _slideSign = delta.toDouble());
    await _slide.forward(from: 0);
    widget.onStep(delta);
    if (mounted) {
      _slide.value = 0;
    }
  }

  void _flipCard() {
    if (widget.mode != _PracticeMode.flashcard || widget.word == null) {
      return;
    }
    if (_reduced) {
      _flip.value = _flip.value < 0.5 ? 1 : 0;
      return;
    }
    if (_flip.value < 0.5) {
      _flip.forward();
    } else {
      _flip.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final showArrows = widget.mode != _PracticeMode.flashcard;
    return Row(
      children: [
        if (showArrows)
          IconButton(
            key: const Key('set-study-prev'),
            onPressed: () => _go(-1),
            icon: Icon(Icons.chevron_left, color: colors.ink),
          ),
        Expanded(
          child: GestureDetector(
            key: const Key('set-study-card-tap'),
            onTap: _flipCard,
            child: AnimatedBuilder(
              animation: Listenable.merge(<Listenable>[_flip, _slide]),
              builder: (context, child) {
                final angle = _flip.value * math.pi;
                final showMeaning =
                    widget.mode == _PracticeMode.flashcard &&
                    _flip.value >= 0.5;
                final turn = showMeaning ? angle - math.pi : angle;
                final slideX = _slide.value * _slideSign * 72;
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(turn),
                  child: Transform.translate(
                    offset: Offset(slideX, 0),
                    child: _CardStack(
                      word: widget.word,
                      peek: widget.mode == _PracticeMode.random
                          ? widget.peek
                          : null,
                      mode: widget.mode,
                      typing: widget.typing,
                      meaning: showMeaning,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (showArrows)
          IconButton(
            key: const Key('set-study-next'),
            onPressed: () => _go(1),
            icon: Icon(Icons.chevron_right, color: colors.ink),
          ),
      ],
    );
  }
}

List<String> _cardLines({
  required VocabularyWord? word,
  required _PracticeMode mode,
  required bool meaning,
  required String emptyLabel,
}) {
  if (word == null) {
    return <String>[emptyLabel];
  }
  List<String> present(List<String> values) {
    return <String>[
      for (final value in values)
        if (value.trim().isNotEmpty) value.trim(),
    ];
  }

  if (mode == _PracticeMode.flashcard && meaning) {
    return present(<String>[word.definition, word.sentence, word.note]);
  }
  if (mode == _PracticeMode.flashcard) {
    return present(<String>[word.term, word.ipa]);
  }
  if (mode == _PracticeMode.random) {
    return present(<String>[
      word.term,
      word.ipa,
      word.singularPlural,
      word.sentence,
      word.definition,
      word.note,
    ]);
  }
  if (mode == _PracticeMode.quiz) {
    return present(<String>[word.definition]);
  }
  return present(<String>[word.term, word.sentence]);
}

class _CardStack extends StatelessWidget {
  const _CardStack({
    required this.word,
    required this.peek,
    required this.mode,
    required this.typing,
    required this.meaning,
  });

  final VocabularyWord? word;
  final VocabularyWord? peek;
  final _PracticeMode mode;
  final TextEditingController typing;
  final bool meaning;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (peek != null)
          const Positioned(
            key: Key('set-study-peek'),
            left: 18,
            right: 0,
            top: 10,
            child: _PeekCard(),
          ),
        Padding(
          padding: EdgeInsets.only(bottom: peek == null ? 0 : 12),
          child: _Flashcard(
            word: word,
            mode: mode,
            typing: typing,
            meaning: meaning,
          ),
        ),
      ],
    );
  }
}

class _PeekCard extends StatelessWidget {
  const _PeekCard();

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    return Container(
      height: 168,
      decoration: BoxDecoration(
        color: colors.folderFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
    );
  }
}

class _Flashcard extends StatelessWidget {
  const _Flashcard({
    required this.word,
    required this.mode,
    required this.typing,
    required this.meaning,
  });

  final VocabularyWord? word;
  final _PracticeMode mode;
  final TextEditingController typing;
  final bool meaning;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final text = HomeText.of(context);
    final localizations = AppLocalizations.of(context);
    final current = word;
    final image = current?.imageUrl?.trim() ?? '';
    final showImage =
        image.isNotEmpty &&
        (mode == _PracticeMode.random ||
            (mode == _PracticeMode.flashcard && !meaning));
    final lines = _cardLines(
      word: current,
      mode: mode,
      meaning: meaning,
      emptyLabel: localizations.libraryEmpty,
    );
    final centered = mode == _PracticeMode.flashcard;
    final term = current?.term.trim() ?? '';
    return Container(
      key: const Key('set-study-card'),
      alignment: null,
      constraints: BoxConstraints(minHeight: centered ? 300 : 180),
      padding: centered
          ? EdgeInsets.zero
          : const EdgeInsets.fromLTRB(24, 20, 24, 20),
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
      child: centered
          ? SizedBox(
              height: 300,
              width: double.infinity,
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (showImage) ...[
                                _CardPhoto(
                                  image: image,
                                  fill: colors.folderFill,
                                ),
                                const SizedBox(height: 16),
                              ],
                              _CardLines(lines: lines, centered: true),
                            ],
                          ),
                        ),
                        if (term.isNotEmpty)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: _SpeakButton(term: term),
                          ),
                      ],
                    ),
                  ),
                  if (!meaning) const _MeaningHint(),
                ],
              ),
            )
          : SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _CardLines(lines: lines, centered: false),
                      ),
                      if (showImage) ...[
                        const SizedBox(width: 16),
                        _CardPhoto(image: image, fill: colors.folderFill),
                      ],
                    ],
                  ),
                  if (mode == _PracticeMode.typing && current != null) ...[
                    const SizedBox(height: 16),
                    TextField(
                      key: const Key('set-study-typing'),
                      controller: typing,
                      style: text.subtitle,
                      decoration: InputDecoration(
                        hintText: localizations.editorDefinitionHint,
                        hintStyle: text.subtitle.copyWith(
                          color: colors.placeholder,
                        ),
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
            ),
    );
  }
}

class _MeaningHint extends StatelessWidget {
  const _MeaningHint();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? const Color(0xFFF5F8FF) : const Color(0xFF1D2939);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: DecoratedBox(
        key: const Key('set-study-meaning-hint'),
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF243056) : const Color(0xFFE4E7FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5C451),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.touch_app,
                  size: 14,
                  color: Color(0xFF7A5410),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                localizations.studyShortcut,
                style: HomeText.of(context).body.copyWith(
                  color: ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  localizations.studyTapForMeaning,
                  textAlign: TextAlign.center,
                  style: HomeText.of(context).body.copyWith(color: ink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardLines extends StatelessWidget {
  const _CardLines({required this.lines, required this.centered});

  final List<String> lines;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final text = HomeText.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < lines.length; index++) ...[
          if (index > 0) const SizedBox(height: 8),
          Text(
            lines[index],
            textAlign: centered ? TextAlign.center : TextAlign.start,
            style: index == 0
                ? text.title.copyWith(fontWeight: FontWeight.w600)
                : text.body.copyWith(color: colors.muted),
          ),
        ],
      ],
    );
  }
}

class _CardPhoto extends StatelessWidget {
  const _CardPhoto({required this.image, required this.fill});

  final String image;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        image,
        key: const Key('set-study-photo'),
        width: 140,
        height: 96,
        fit: BoxFit.cover,
        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
        errorBuilder: (context, error, stackTrace) {
          return Container(width: 140, height: 96, color: fill);
        },
      ),
    );
  }
}

class _SpeakButton extends StatelessWidget {
  const _SpeakButton({required this.term, this.keyed = true});

  static const iconSize = 18.0;

  final String term;
  final bool keyed;

  Future<void> _speak() async {
    final spoken = term.trim();
    if (spoken.isEmpty) {
      return;
    }
    try {
      final speech = FlutterTts();
      final available = await speech.isLanguageAvailable('de-DE');
      if (available == true || available == 1) {
        await speech.setLanguage('de-DE');
      }
      await speech.setSpeechRate(0.45);
      await speech.speak(spoken);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: keyed ? const Key('set-study-speak') : null,
      onPressed: _speak,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      icon: Icon(
        Icons.volume_up_outlined,
        color: HomePalette.of(context).muted,
        size: iconSize,
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
  final Map<int, StudyMark> marks;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colors = HomePalette.of(context);
    final learned = marks.values.where((mark) => mark == StudyMark.easy).length;
    final counts = <StudyMark?, int>{
      StudyMark.hard: 0,
      StudyMark.familiar: 0,
      StudyMark.easy: 0,
      null: 0,
    };
    for (var index = 0; index < words.length; index++) {
      final mark = marks[index];
      counts[mark] = (counts[mark] ?? 0) + 1;
    }
    final bars = <HomeBar>[
      HomeBar(
        color: HomeSample.forgot,
        height: counts[StudyMark.hard]!.toDouble(),
      ),
      HomeBar(
        color: HomeSample.learning,
        height: counts[StudyMark.familiar]!.toDouble(),
      ),
      HomeBar(
        color: HomeSample.familiar,
        height: counts[StudyMark.easy]!.toDouble(),
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
    this.buttonKey,
    required this.label,
    required this.filled,
    required this.onPressed,
  });

  final Key? buttonKey;
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
      key: buttonKey,
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
