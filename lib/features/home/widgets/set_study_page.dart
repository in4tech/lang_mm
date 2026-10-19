import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lang/features/home/home_from_library.dart';
import 'package:lang/features/home/quiz_tone.dart';
import 'package:lang/features/home/widgets/quiz_card.dart';
import 'package:lang/features/word_editor/sentence_format.dart';
import 'package:lang/features/home/sample/home_sample.dart';
import 'package:lang/l10n/app_localizations.dart';
import 'package:lang/library/study_progress.dart';
import 'package:lang/library/vocabulary_library.dart';
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
    this.onEditWord,
    this.narrow = false,
    this.progress,
    this.initialMarks = const <int, StudyMark>{},
    this.cues,
    this.onPracticing,
    this.onWordsChanged,
    this.statisticsLibrary,
    this.statisticsProgress = const <String, StudySetProgress>{},
    this.statisticsAll = true,
    this.endPractice = 0,
    this.quizTone,
  });

  final VocabularySet set;
  final VoidCallback onEdit;
  final ValueChanged<int>? onEditWord;
  final bool narrow;
  final StudyProgressStore? progress;
  final Map<int, StudyMark> initialMarks;
  final List<StudyCue>? cues;
  final ValueChanged<bool>? onPracticing;
  final ValueChanged<VocabularySet>? onWordsChanged;
  final VocabularyLibrary? statisticsLibrary;
  final Map<String, StudySetProgress> statisticsProgress;
  final bool statisticsAll;
  final int endPractice;
  final QuizTone? quizTone;

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
  var _place = 1;
  var _finished = false;
  var _sessionKnow = 0;
  var _sessionLearning = 0;
  var _sessionSkipped = 0;
  List<StudyCue>? _sessionCues;
  StudyAction? _exit;
  QuizMark? _quizResult;
  int? _quizChosen;
  var _quizSettled = false;
  var _quizCorrectStreak = 0;
  int? _quizFor;
  List<int>? _quizChoices;
  QuizTone? _quizTone;
  _StatsSnapshot? _statsBefore;
  late List<VocabularyWord> _words = List<VocabularyWord>.of(widget.set.words);
  late List<StudyCue> _order = _sessionOf(widget);
  List<StudyCue>? _browseOrder;
  var _browseCursor = 0;
  late int _sessionTotal = _order.length;
  late final Map<int, StudyWordState> _levels = <int, StudyWordState>{
    for (final entry in widget.initialMarks.entries)
      entry.key: levelFromStoredMark(entry.value, DateTime.now()),
  };
  late final Map<String, StudySetProgress> _homeProgress = {
    for (final entry in widget.statisticsProgress.entries)
      entry.key: StudySetProgress(
        marks: Map<int, StudyMark>.of(entry.value.marks),
        levels: Map<int, StudyWordState>.of(entry.value.levels),
        updatedAt: entry.value.updatedAt,
      ),
  };

  @override
  void initState() {
    super.initState();
    _practicing = widget.cues != null;
    final openId = widget.set.id;
    if (widget.statisticsLibrary != null && openId != null) {
      _levels.addAll(studyStates(_homeProgress[openId], DateTime.now()));
    }
    if (_practicing) {
      _sessionCues = List<StudyCue>.from(_order);
      _statsBefore = _statsSnapshot(words: _words, levels: _levels);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onPracticing?.call(true);
        }
      });
    }
    _loadMarks();
  }

  @override
  void didUpdateWidget(SetStudyPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.endPractice != oldWidget.endPractice) {
      _practicing = false;
      _finished = false;
      _exit = null;
      _clearQuiz();
      _restoreBrowse();
    }
    if (widget.set == oldWidget.set) {
      return;
    }
    _clearQuiz();
    _words = List<VocabularyWord>.of(widget.set.words);
    _order = <StudyCue>[
      for (final cue in _order)
        cue.index >= 0 && cue.index < _words.length
            ? StudyCue(
                word: _words[cue.index],
                setId: cue.setId,
                index: cue.index,
              )
            : cue,
    ];
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
      final marks = await store.marksFor(id);
      final levels = await store.levelsFor(id);
      if (!mounted) {
        return;
      }
      final now = DateTime.now();
      setState(() {
        for (final entry in marks.entries) {
          _levels.putIfAbsent(
            entry.key,
            () => levelFromStoredMark(entry.value, now),
          );
        }
        _levels.addAll(levels);
        if (widget.statisticsLibrary != null && levels.isNotEmpty) {
          _rememberHomeLevels(id, levels);
        }
      });
    } catch (_) {}
  }

  StudyWordState? _stateFor(StudyCue cue) {
    final id = cue.setId;
    if (widget.statisticsLibrary != null && id != null) {
      return studyStates(_homeProgress[id], DateTime.now())[cue.index];
    }
    return _levels[cue.index];
  }

  Map<int, StudyWordState> _cardLevels(StudyCue? cue) {
    if (cue == null || widget.statisticsLibrary == null) {
      return _levels;
    }
    final state = _stateFor(cue);
    if (state == null) {
      return const <int, StudyWordState>{};
    }
    return <int, StudyWordState>{cue.index: state};
  }

  void _rememberHomeLevel(String setId, int index, StudyWordState state) {
    if (widget.statisticsLibrary == null) {
      return;
    }
    final current = _homeProgress[setId];
    final levels = Map<int, StudyWordState>.of(
      current?.levels ?? const <int, StudyWordState>{},
    );
    levels[index] = state;
    _homeProgress[setId] = StudySetProgress(
      marks: current?.marks ?? const <int, StudyMark>{},
      levels: levels,
      updatedAt: DateTime.now(),
    );
  }

  void _rememberHomeLevels(String setId, Map<int, StudyWordState> levels) {
    for (final entry in levels.entries) {
      _rememberHomeLevel(setId, entry.key, entry.value);
    }
  }

  HomeSample? get _overview {
    final library = widget.statisticsLibrary;
    if (library == null) {
      return null;
    }
    return homeSampleFromLibrary(
      library,
      progress: _homeProgress,
      allSets: widget.statisticsAll,
    );
  }

  List<StudyCue> _cuesWhere(bool Function(int index) include) {
    return <StudyCue>[
      for (var index = 0; index < _words.length; index++)
        if (include(index))
          StudyCue(word: _words[index], setId: widget.set.id, index: index),
    ];
  }

  void _openSession(List<StudyCue> order) {
    if (order.isEmpty) {
      return;
    }
    setState(() => _begin(order));
    widget.onPracticing?.call(true);
  }

  List<StudyCue> _todayQueue() {
    final now = DateTime.now();
    return _cuesWhere((index) {
      final state = _levels[index];
      return state != null && !state.dueAt.isAfter(now);
    });
  }

  List<StudyCue> _newQueue() {
    return _cuesWhere((index) => _levels[index] == null);
  }

  VocabularySet get _shown {
    return VocabularySet(
      id: widget.set.id,
      title: widget.set.title,
      description: widget.set.description,
      folderId: widget.set.folderId,
      words: List<VocabularyWord>.unmodifiable(_words),
    );
  }

  void _toggleStar(int index) {
    if (index < 0 || index >= _words.length) {
      return;
    }
    final next = _words[index].copyWith(starred: !_words[index].starred);
    setState(() {
      _words[index] = next;
      _order = <StudyCue>[
        for (final cue in _order)
          cue.index == index
              ? StudyCue(word: next, setId: cue.setId, index: cue.index)
              : cue,
      ];
    });
    widget.onWordsChanged?.call(_shown);
  }

  void _begin(List<StudyCue> order) {
    if (_browseOrder == null) {
      _browseOrder = List<StudyCue>.from(_order);
      _browseCursor = _cursor;
    }
    _practicing = true;
    _mode = _PracticeMode.flashcard;
    _order = order;
    _cursor = 0;
    _place = 1;
    _sessionTotal = order.length;
    _finished = false;
    _sessionKnow = 0;
    _sessionLearning = 0;
    _sessionSkipped = 0;
    _sessionCues = List<StudyCue>.from(order);
    _exit = null;
    _quizCorrectStreak = 0;
    _statsBefore = _statsSnapshot(words: _words, levels: _levels);
    _clearQuiz();
    _faceToken += 1;
    _typing.clear();
  }

  void _restartSession(_PracticeMode mode) {
    final cues = _sessionCues;
    if (cues == null || cues.isEmpty) {
      return;
    }
    setState(() {
      _finished = false;
      _begin(List<StudyCue>.from(cues));
      _mode = mode;
    });
    widget.onPracticing?.call(true);
  }

  void _advance() {
    if (_cursor >= _order.length - 1) {
      _finished = true;
      return;
    }
    _order.removeAt(_cursor);
    _place += 1;
  }

  void _restoreBrowse() {
    final saved = _browseOrder;
    _browseOrder = null;
    if (saved != null) {
      _order = saved;
      _cursor = saved.isEmpty ? 0 : _browseCursor.clamp(0, saved.length - 1);
      return;
    }
    _order = <StudyCue>[
      for (var index = 0; index < _words.length; index++)
        StudyCue(word: _words[index], setId: widget.set.id, index: index),
    ];
    _cursor = _order.isEmpty ? 0 : _cursor.clamp(0, _order.length - 1);
  }

  void _leavePractice() {
    setState(() {
      _practicing = false;
      _finished = false;
      _exit = null;
      _clearQuiz();
      _restoreBrowse();
    });
    widget.onPracticing?.call(false);
  }

  QuizTone get _tones => widget.quizTone ?? (_quizTone ??= AssetQuizTone());

  void _clearQuiz() {
    _quizResult = null;
    _quizChosen = null;
    _quizSettled = false;
    _quizFor = null;
    _quizChoices = null;
  }

  void _syncQuiz() {
    if (_mode != _PracticeMode.quiz) {
      return;
    }
    final cue = _current;
    if (cue == null || (_quizFor == cue.index && _quizChoices != null)) {
      return;
    }
    _quizFor = cue.index;
    _quizChoices = _quizChoicesFor(cue.index);
    _quizResult = null;
    _quizChosen = null;
    _quizSettled = false;
  }

  List<int> _quizChoicesFor(int index) {
    final total = _words.length;
    if (total == 0) {
      return const <int>[];
    }
    final others = <int>[];
    for (var step = 1; step < total && others.length < 3; step++) {
      final next = (index + step) % total;
      if (next != index) {
        others.add(next);
      }
    }
    final choices = <int>[index, ...others];
    choices.shuffle(math.Random(index));
    return choices;
  }

  void _chooseQuiz(int index) {
    if (_quizResult != null) {
      return;
    }
    final cue = _current;
    if (cue == null) {
      return;
    }
    final correct = index == cue.index;
    final animate = !MediaQuery.disableAnimationsOf(context);
    setState(() {
      _quizChosen = index;
      if (correct) {
        _quizCorrectStreak += 1;
        _quizResult = QuizMark.correct;
      } else {
        _quizCorrectStreak = 0;
        _quizResult = QuizMark.wrong;
      }
      _quizSettled = !animate;
    });
    unawaited(_tones.play(correct ? QuizTonePitch.high : QuizTonePitch.low));
  }

  void _dontKnowQuiz() {
    if (_quizResult != null) {
      return;
    }
    final animate = !MediaQuery.disableAnimationsOf(context);
    setState(() {
      _quizChosen = null;
      _quizCorrectStreak = 0;
      _quizResult = QuizMark.skip;
      _quizSettled = !animate;
    });
  }

  void _finishQuizReveal() {
    if (_quizSettled || _quizResult == null || !mounted) {
      return;
    }
    setState(() => _quizSettled = true);
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
      if (_exit != null) {
        _exit = null;
        _advance();
        _typing.clear();
      }
      _clearQuiz();
      _mode = mode;
      _typing.clear();
      _faceToken += 1;
    });
  }

  void _finishExit() {
    if (!_practicing || _exit == null) {
      return;
    }
    setState(() {
      _exit = null;
      _faceToken += 1;
      _advance();
      _typing.clear();
    });
  }

  void _rate(StudyAction action) {
    final quiz = _mode == _PracticeMode.quiz;
    if (_mode != _PracticeMode.flashcard && !quiz) {
      return;
    }
    if (quiz && (_quizResult == null || !_quizSettled)) {
      return;
    }
    final cue = _current;
    if (cue == null || _exit != null) {
      return;
    }
    final next = levelAfter(
      action: action,
      level: _stateFor(cue)?.level,
      at: DateTime.now(),
    );
    if (next == null) {
      return;
    }
    final playExit = _practicing && !quiz && action != StudyAction.studied;
    setState(() {
      if (cue.setId == null || cue.setId == widget.set.id) {
        _levels[cue.index] = next;
      }
      if (cue.setId != null) {
        _rememberHomeLevel(cue.setId!, cue.index, next);
      }
      if (_practicing) {
        if (action == StudyAction.hard) {
          _sessionLearning += 1;
        } else {
          _sessionKnow += 1;
        }
      }
      if (quiz) {
        _clearQuiz();
      }
      if (playExit) {
        _exit = action;
      } else {
        _faceToken += 1;
        _advance();
        _typing.clear();
      }
    });
    final id = cue.setId;
    final store = widget.progress;
    if (id != null && store != null) {
      store.saveLevel(setId: id, index: cue.index, state: next);
    }
  }

  void _skipNew() {
    final quiz = _mode == _PracticeMode.quiz;
    if (_mode != _PracticeMode.flashcard && !quiz) {
      return;
    }
    if (quiz && (_quizResult == null || !_quizSettled)) {
      return;
    }
    final cue = _current;
    if (cue == null || _levels.containsKey(cue.index)) {
      return;
    }
    setState(() {
      if (quiz) {
        _clearQuiz();
      }
      _sessionSkipped += 1;
      _faceToken += 1;
      _advance();
      _typing.clear();
    });
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
    return switch (_filter) {
      _ListFilter.all => true,
      _ListFilter.learning => _levels[index]?.level != 6,
      _ListFilter.mastered => _levels[index]?.level == 6,
    };
  }

  @override
  Widget build(BuildContext context) {
    _syncQuiz();
    if (_finished) {
      final complete = SingleChildScrollView(
        child: _PracticeComplete(
          words: _words,
          levels: _levels,
          total: _sessionTotal,
          know: _sessionKnow,
          learning: _sessionLearning,
          left: _sessionSkipped,
          onDone: _leavePractice,
          onPracticeQuiz: () => _restartSession(_PracticeMode.quiz),
          onRestartFlashcards: () => _restartSession(_PracticeMode.flashcard),
          overview: _overview,
          fromStats: _statsBefore,
        ),
      );
      if (widget.narrow) {
        return KeyedSubtree(key: const Key('set-study-page'), child: complete);
      }
      return Row(
        key: const Key('set-study-page'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: complete),
          const SizedBox(width: 24),
          const SizedBox(width: 300),
        ],
      );
    }
    final cue = _current;
    VocabularyWord? peek;
    VocabularyWord? previous;
    if (_order.length > 1) {
      peek = _order[(_cursor + 1) % _order.length].word;
      final back = _cursor - 1;
      previous = _order[back < 0 ? back + _order.length : back].word;
    }
    final practice = _PracticeColumn(
      set: _shown,
      mode: _mode,
      filter: _filter,
      current: cue,
      peek: peek,
      previous: previous,
      faceToken: _faceToken,
      levels: _cardLevels(cue),
      typing: _typing,
      visible: _visible,
      practicing: _practicing,
      place: _place,
      sessionTotal: _sessionTotal,
      onEdit: widget.onEdit,
      onEditWord: widget.onEditWord,
      onLeavePractice: _leavePractice,
      onMode: _selectMode,
      onStep: _step,
      onRate: _rate,
      exit: _exit,
      onExitComplete: _finishExit,
      onSkip: _skipNew,
      onFilter: (filter) => setState(() => _filter = filter),
      onShow: _show,
      onToggleStar: _toggleStar,
      quizChoices: _quizChoices ?? const <int>[],
      quizMark: _quizResult,
      quizChosen: _quizChosen,
      quizSettled: _quizSettled,
      quizCorrectStreak: _quizCorrectStreak,
      onQuizChoose: _chooseQuiz,
      onQuizDontKnow: _dontKnowQuiz,
      onQuizSettled: _finishQuizReveal,
    );
    final stats = _StudyStats(
      words: _words,
      levels: _levels,
      overview: _overview,
    );
    final header = _practicing
        ? null
        : _BrowseHeader(
            title: _shown.title,
            onEdit: widget.onEdit,
            onPractice: () => _openSession(_todayQueue()),
            onLearnNew: () => _openSession(_newQueue()),
          );
    final scrolling = SingleChildScrollView(
      key: const Key('set-study-scroll'),
      child: widget.narrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                practice,
                if (!_practicing) ...[
                  const SizedBox(height: 28),
                  stats,
                ],
              ],
            )
          : practice,
    );
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null) header,
        Expanded(child: scrolling),
      ],
    );
    if (widget.narrow) {
      return KeyedSubtree(key: const Key('set-study-page'), child: body);
    }
    return Row(
      key: const Key('set-study-page'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: body),
        const SizedBox(width: 24),
        SizedBox(
          width: 300,
          child: _practicing ? null : SingleChildScrollView(child: stats),
        ),
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
    required this.levels,
    required this.typing,
    required this.visible,
    required this.practicing,
    required this.place,
    required this.sessionTotal,
    required this.onEdit,
    required this.onEditWord,
    required this.onLeavePractice,
    required this.onMode,
    required this.onStep,
    required this.onRate,
    required this.exit,
    required this.onExitComplete,
    required this.onSkip,
    required this.onFilter,
    required this.onShow,
    required this.onToggleStar,
    required this.quizChoices,
    required this.quizMark,
    required this.quizChosen,
    required this.quizSettled,
    required this.quizCorrectStreak,
    required this.onQuizChoose,
    required this.onQuizDontKnow,
    required this.onQuizSettled,
  });

  final VocabularySet set;
  final _PracticeMode mode;
  final _ListFilter filter;
  final StudyCue? current;
  final VocabularyWord? peek;
  final VocabularyWord? previous;
  final int faceToken;
  final Map<int, StudyWordState> levels;
  final TextEditingController typing;
  final bool Function(int index) visible;
  final bool practicing;
  final int place;
  final int sessionTotal;
  final VoidCallback onEdit;
  final ValueChanged<int>? onEditWord;
  final VoidCallback onLeavePractice;
  final ValueChanged<_PracticeMode> onMode;
  final ValueChanged<int> onStep;
  final ValueChanged<StudyAction> onRate;
  final StudyAction? exit;
  final VoidCallback onExitComplete;
  final VoidCallback onSkip;
  final ValueChanged<_ListFilter> onFilter;
  final ValueChanged<int> onShow;
  final ValueChanged<int> onToggleStar;
  final List<int> quizChoices;
  final QuizMark? quizMark;
  final int? quizChosen;
  final bool quizSettled;
  final int quizCorrectStreak;
  final ValueChanged<int> onQuizChoose;
  final VoidCallback onQuizDontKnow;
  final VoidCallback onQuizSettled;

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
          SizedBox(
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$place / $sessionTotal',
                      textAlign: TextAlign.center,
                      style: HomeText.of(context).title.copyWith(height: 1.15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      set.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: HomeText.of(context).caption
                          .copyWith(color: colors.muted),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    key: const Key('set-study-practice-back'),
                    onPressed: onLeavePractice,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.close, color: colors.ink),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 3,
              backgroundColor: colors.border,
              color: colors.selected,
              value: sessionTotal == 0 ? 0 : place / sessionTotal,
            ),
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
              _ModeChip(
                chipKey: const Key('set-study-mode-quiz'),
                icon: Icons.quiz_outlined,
                label: localizations.studyQuiz,
                selected: mode == _PracticeMode.quiz,
                onTap: () => onMode(_PracticeMode.quiz),
              ),
              _ModeChip(
                chipKey: const Key('set-study-mode-typing'),
                icon: Icons.text_fields,
                label: localizations.studyTyping,
                selected: mode == _PracticeMode.typing,
                onTap: () => onMode(_PracticeMode.typing),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (mode == _PracticeMode.quiz && cue != null)
            QuizCard(
              termLabel: localizations.editorTerm,
              term: cue.word.term,
              prompt: localizations.quizChooseAnswer,
              wrongSentence: localizations.quizWrongResult,
              skipSentence: localizations.quizTryLater,
              dontKnowLabel: localizations.quizDontKnow,
              speak: _SpeakButton(term: cue.word.term),
              choices: [
                for (var slot = 0; slot < quizChoices.length; slot++)
                  QuizChoice(
                    wordIndex: quizChoices[slot],
                    number: slot + 1,
                    line: quizOptionLine(set.words[quizChoices[slot]]),
                  ),
              ],
              mark: quizMark,
              currentIndex: cue.index,
              chosenIndex: quizChosen,
              correctStreak: quizCorrectStreak,
              onChoose: onQuizChoose,
              onDontKnow: onQuizDontKnow,
              onSettled: onQuizSettled,
            )
          else
            _FlashcardStage(
              word: word,
              peek: peek,
              mode: mode,
              typing: typing,
              onStep: onStep,
              faceToken: faceToken,
              newWord:
                  mode == _PracticeMode.flashcard &&
                  (cue == null || !levels.containsKey(cue.index)),
              onSkip: onSkip,
              onStudied: () => onRate(StudyAction.studied),
              exit: exit,
              onExitComplete: onExitComplete,
            ),
          const SizedBox(height: 24),
          if (mode == _PracticeMode.quiz && quizSettled && cue != null)
            if (levels.containsKey(cue.index))
              _QuizRatings(onRate: onRate, localizations: localizations)
            else
              _QuizNewWordActions(
                onSkip: onSkip,
                onStudied: () => onRate(StudyAction.studied),
                localizations: localizations,
              )
          else if (mode == _PracticeMode.flashcard &&
              cue != null &&
              levels.containsKey(cue.index))
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _RatingButton(
                  buttonKey: const Key('set-study-hard'),
                  icon: Icons.sentiment_dissatisfied,
                  label: localizations.studyHard,
                  color: HomeSample.forgot,
                  onPressed: () => onRate(StudyAction.hard),
                ),
                const SizedBox(width: 60),
                _RatingButton(
                  buttonKey: const Key('set-study-familiar'),
                  icon: Icons.sentiment_neutral,
                  label: localizations.studyFamiliar,
                  color: HomeSample.learning,
                  onPressed: () => onRate(StudyAction.familiar),
                ),
                const SizedBox(width: 60),
                _RatingButton(
                  buttonKey: const Key('set-study-easy'),
                  icon: Icons.sentiment_satisfied,
                  label: localizations.studyEasy,
                  color: HomeSample.familiar,
                  onPressed: () => onRate(StudyAction.easy),
                ),
              ],
            ),
        ] else ...[
          const SizedBox(height: 44),
          _WordPreview(
            word: word,
            nextWord: peek,
            previousWord: previous,
            onStep: onStep,
            onEdit: () {
              final index = cue?.index;
              if (index != null && onEditWord != null) {
                onEditWord!(index);
                return;
              }
              onEdit();
            },
            onToggleStar: cue == null ? null : () => onToggleStar(cue.index),
          ),
          if (cue != null) ...[
            const SizedBox(height: 80),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _RatingButton(
                  buttonKey: const Key('set-study-hard'),
                  icon: Icons.sentiment_dissatisfied,
                  label: localizations.studyHard,
                  color: HomeSample.forgot,
                  onPressed: () => onRate(StudyAction.hard),
                ),
                const SizedBox(width: 60),
                _RatingButton(
                  buttonKey: const Key('set-study-familiar'),
                  icon: Icons.sentiment_neutral,
                  label: localizations.studyFamiliar,
                  color: HomeSample.learning,
                  onPressed: () => onRate(StudyAction.familiar),
                ),
                const SizedBox(width: 60),
                _RatingButton(
                  buttonKey: const Key('set-study-easy'),
                  icon: Icons.sentiment_satisfied,
                  label: localizations.studyEasy,
                  color: HomeSample.familiar,
                  onPressed: () => onRate(StudyAction.easy),
                ),
              ],
            ),
          ],
          const SizedBox(height: 32),
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
          if (!List<int>.generate(
            set.words.length,
            (index) => index,
          ).any(visible))
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
                  onEdit: () {
                    final editWord = onEditWord;
                    if (editWord != null) {
                      editWord(index);
                      return;
                    }
                    onEdit();
                  },
                  onToggleStar: () => onToggleStar(index),
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
    this.onToggleStar,
  });

  final VocabularyWord? word;
  final VocabularyWord? nextWord;
  final VocabularyWord? previousWord;
  final ValueChanged<int> onStep;
  final VoidCallback onEdit;
  final VoidCallback? onToggleStar;

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
    with TickerProviderStateMixin {
  late final AnimationController _motion;
  late final AnimationController _flip;
  var _direction = 0;
  var _revealed = false;
  VocabularyWord? _from;
  VocabularyWord? _to;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _flip = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void didUpdateWidget(_WordPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_samePreviewWord(oldWidget.word, widget.word)) {
      _flip.value = 0;
      _revealed = false;
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    _flip.dispose();
    super.dispose();
  }

  Future<void> _go(int delta) async {
    if (_direction != 0) {
      return;
    }
    final incoming = delta > 0 ? widget.nextWord : widget.previousWord;
    if (incoming == null || MediaQuery.disableAnimationsOf(context)) {
      if (incoming != null) {
        _flip.value = 0;
        _revealed = false;
      }
      widget.onStep(delta);
      return;
    }
    setState(() {
      _direction = delta;
      _from = widget.word;
      _to = incoming;
      _revealed = _flip.value >= 0.5;
    });
    await _motion.forward(from: 0);
    if (!mounted) {
      return;
    }
    _direction = 0;
    _from = null;
    _to = null;
    _revealed = false;
    _motion.value = 0;
    _flip.value = 0;
    widget.onStep(delta);
  }

  void _flipCard() {
    if (_direction != 0 || widget.word == null) {
      return;
    }
    if (MediaQuery.disableAnimationsOf(context)) {
      _flip.value = _flip.value < 0.5 ? 1 : 0;
      return;
    }
    if (_flip.value < 0.5) {
      _flip.forward();
    } else {
      _flip.reverse();
    }
  }

  Widget _turned({
    required VocabularyWord? word,
    required HomeText text,
    required HomePalette colors,
  }) {
    final revealed = _flip.value >= 0.5;
    final angle = _flip.value * math.pi;
    final turn = revealed ? angle - math.pi : angle;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _flipCard,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(turn),
        child: _face(
          word: word,
          text: text,
          colors: colors,
          revealed: revealed,
          keyed: true,
        ),
      ),
    );
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
    required bool revealed,
    required bool keyed,
  }) {
    final image = word?.imageUrl?.trim() ?? '';
    if (!revealed) {
      return _PreviewCover(
        word: word,
        image: image,
        text: text,
        onEdit: widget.onEdit,
        onToggleStar: widget.onToggleStar,
        keyed: keyed,
      );
    }
    return _PreviewFace(
      word: word,
      image: image,
      text: text,
      colors: colors,
      onEdit: widget.onEdit,
      onToggleStar: widget.onToggleStar,
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
              animation: Listenable.merge(<Listenable>[_motion, _flip]),
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
                  revealed: moving && _revealed,
                  keyed: true,
                );
                final incoming = _to == null
                    ? null
                    : IgnorePointer(
                        child: _face(
                          word: _to,
                          text: text,
                          colors: colors,
                          revealed: false,
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
                      _turned(word: widget.word, text: text, colors: colors),
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
  const _PreviewTool({
    this.buttonKey,
    required this.icon,
    this.onPressed,
    this.size = _SpeakButton.iconSize,
    this.color,
  });

  final Key? buttonKey;
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: buttonKey,
      onPressed: onPressed ?? () {},
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      icon: Icon(
        icon,
        size: size,
        color: color ?? HomePalette.of(context).muted,
      ),
    );
  }
}

class _PreviewTools extends StatelessWidget {
  const _PreviewTools({
    required this.word,
    required this.onEdit,
    this.onToggleStar,
    this.keyed = true,
    this.foreground,
  });

  final VocabularyWord? word;
  final VoidCallback onEdit;
  final VoidCallback? onToggleStar;
  final bool keyed;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final term = word?.term.trim() ?? '';
    final starred = word?.starred == true;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
      child: Row(
        children: [
          _PreviewTool(
            buttonKey: keyed ? const Key('set-study-card-edit') : null,
            icon: Icons.edit_outlined,
            onPressed: onEdit,
            size: 16,
            color: foreground,
          ),
          const Spacer(),
          if (word != null && term.isNotEmpty)
            _SpeakButton(term: term, keyed: keyed, size: 16, color: foreground),
          _PreviewTool(
            icon: starred ? Icons.star : Icons.star_border,
            onPressed: word == null ? null : onToggleStar,
            size: 18,
            color: starred ? _starColor : foreground,
          ),
        ],
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
            borderRadius: BorderRadius.circular(16),
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
    final Color ink;
    final Color border;
    switch (type) {
      case 'chunking':
        ink = dark ? const Color(0xFFD6BBFB) : const Color(0xFF6941C6);
        border = ink;
      case 'noun':
        ink = dark ? const Color(0xFF7CD4FD) : const Color(0xFF026AA2);
        border = ink;
      case 'verb':
        ink = dark ? const Color(0xFF75E0A7) : const Color(0xFF067647);
        border = ink;
      case 'adj':
        ink = dark ? const Color(0xFFFEA3B4) : const Color(0xFFC01048);
        border = ink;
      default:
        ink = colors.text;
        border = colors.border;
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
        child: Text(
          label,
          style: HomeText.of(context).caption.copyWith(color: ink),
        ),
      ),
    );
  }
}

bool _samePreviewWord(VocabularyWord? a, VocabularyWord? b) {
  if (identical(a, b)) {
    return true;
  }
  if (a == null || b == null) {
    return false;
  }
  return a.term == b.term &&
      a.definition == b.definition &&
      a.sentence == b.sentence &&
      a.ipa == b.ipa &&
      a.singularPlural == b.singularPlural &&
      a.note == b.note &&
      a.type == b.type &&
      a.imageUrl == b.imageUrl;
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

class _PreviewCover extends StatelessWidget {
  const _PreviewCover({
    required this.word,
    required this.image,
    required this.text,
    required this.onEdit,
    this.onToggleStar,
    this.keyed = true,
  });

  final VocabularyWord? word;
  final String image;
  final HomeText text;
  final VoidCallback onEdit;
  final VoidCallback? onToggleStar;
  final bool keyed;

  @override
  Widget build(BuildContext context) {
    final current = word;
    final term = current?.term.trim() ?? '';
    final label = term.isEmpty
        ? AppLocalizations.of(context).libraryEmpty
        : term;
    final colors = HomePalette.of(context);
    final termColor = Theme.of(context).brightness == Brightness.dark
        ? colors.selected
        : _WordPreview._termColor;
    final background = Color.alphaBlend(
      termColor.withValues(alpha: 0.12),
      colors.surface,
    );
    return Container(
      key: keyed ? const Key('set-study-card') : null,
      height: 230,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
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
          _PreviewTools(
            word: current,
            onEdit: onEdit,
            onToggleStar: onToggleStar,
            keyed: keyed,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: text.title.copyWith(
                        color: termColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (image.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    _CardPhoto(
                      image: image,
                      fill: colors.folderFill,
                      keyed: keyed,
                      width: 168,
                      height: 120,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewFace extends StatelessWidget {
  const _PreviewFace({
    required this.word,
    required this.image,
    required this.text,
    required this.colors,
    required this.onEdit,
    this.onToggleStar,
    this.keyed = true,
  });

  final VocabularyWord? word;
  final String image;
  final HomeText text;
  final HomePalette colors;
  final VoidCallback onEdit;
  final VoidCallback? onToggleStar;
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
            color: Theme.of(context).brightness == Brightness.dark
                ? colors.selected
                : _WordPreview._termColor,
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
        if (sentencePlain(current.sentence).trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          FormattedSentence(
            stored: current.sentence,
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
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
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
          _PreviewTools(
            word: current,
            onEdit: onEdit,
            onToggleStar: onToggleStar,
            keyed: keyed,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: Column(children: lines)),
                if (image.isNotEmpty) ...[
                  const SizedBox(width: 16),
                  _CardPhoto(image: image, fill: colors.folderFill),
                ],
              ],
            ),
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
    required this.newWord,
    required this.onSkip,
    required this.onStudied,
    required this.exit,
    required this.onExitComplete,
  });

  final VocabularyWord? word;
  final VocabularyWord? peek;
  final _PracticeMode mode;
  final TextEditingController typing;
  final ValueChanged<int> onStep;
  final int faceToken;
  final bool newWord;
  final VoidCallback onSkip;
  final VoidCallback onStudied;
  final StudyAction? exit;
  final VoidCallback onExitComplete;

  @override
  State<_FlashcardStage> createState() => _FlashcardStageState();
}

class _FlashcardStageState extends State<_FlashcardStage>
    with TickerProviderStateMixin {
  static const _exitTurn = 75 * math.pi / 180;

  late final AnimationController _flip;
  late final AnimationController _slide;
  late final AnimationController _exitMotion;
  final _cardKey = GlobalKey();
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
    _exitMotion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didUpdateWidget(_FlashcardStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.exit == null &&
        (oldWidget.word != widget.word ||
            oldWidget.mode != widget.mode ||
            oldWidget.faceToken != widget.faceToken)) {
      _flip.value = 0;
    }
    if (widget.exit != null && oldWidget.exit == null) {
      _beginExit();
    } else if (widget.exit == null && oldWidget.exit != null) {
      _exitMotion.stop();
      _exitMotion.value = 0;
    }
  }

  @override
  void dispose() {
    _flip.dispose();
    _slide.dispose();
    _exitMotion.dispose();
    super.dispose();
  }

  void _beginExit() {
    if (!mounted || widget.exit == null) {
      return;
    }
    if (_reduced) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.exit != null) {
          widget.onExitComplete();
        }
      });
      return;
    }
    _exitMotion
        .forward(from: 0)
        .orCancel
        .then<void>(
          (_) {
            if (mounted && widget.exit != null) {
              widget.onExitComplete();
            }
          },
          onError: (Object error, StackTrace stack) {
            if (error is! TickerCanceled) {
              Error.throwWithStackTrace(error, stack);
            }
          },
        );
  }

  Size _cardSize() {
    final box = _cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null &&
        box.hasSize &&
        box.size.width > 0 &&
        box.size.height > 0) {
      return box.size;
    }
    return const Size(320, 420);
  }

  Matrix4 _exitMatrix(StudyAction action, double travel) {
    final size = _cardSize();
    final turn = _exitTurn * travel;
    final dx = switch (action) {
      StudyAction.easy => travel * size.width,
      StudyAction.hard => -travel * size.width,
      StudyAction.familiar || StudyAction.studied => 0.0,
    };
    final dy = action == StudyAction.familiar ? -travel * size.height : 0.0;
    final angle = switch (action) {
      StudyAction.easy => turn,
      StudyAction.hard => -turn,
      StudyAction.familiar || StudyAction.studied => 0.0,
    };
    return Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..translate(dx, dy)
      ..rotateY(angle);
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
    if (widget.exit != null ||
        widget.mode != _PracticeMode.flashcard ||
        widget.word == null) {
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
    final localizations = AppLocalizations.of(context);
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        SingleActivator(LogicalKeyboardKey.space): _flipCard,
      },
      child: Focus(
        autofocus: widget.mode == _PracticeMode.flashcard,
        child: Column(
          children: [
            Row(
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
                    onHorizontalDragEnd: (details) {
                      if (!widget.newWord) {
                        return;
                      }
                      final velocity = details.primaryVelocity ?? 0;
                      if (velocity <= -100) {
                        widget.onSkip();
                      } else if (velocity >= 100) {
                        widget.onStudied();
                      }
                    },
                    child: AnimatedBuilder(
                      animation: Listenable.merge(<Listenable>[
                        _flip,
                        _slide,
                        _exitMotion,
                      ]),
                      builder: (context, child) {
                        final angle = _flip.value * math.pi;
                        final showMeaning =
                            widget.mode == _PracticeMode.flashcard &&
                            _flip.value >= 0.5;
                        final turn = showMeaning ? angle - math.pi : angle;
                        final slideX = _slide.value * _slideSign * 72;
                        final face = KeyedSubtree(
                          key: _cardKey,
                          child: Transform(
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
                          ),
                        );
                        final exit = widget.exit;
                        if (exit == null) {
                          return face;
                        }
                        final travel = Curves.easeIn.transform(
                          _exitMotion.value,
                        );
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            if (widget.peek != null)
                              _CardStack(
                                word: widget.peek,
                                peek: null,
                                mode: widget.mode,
                                typing: widget.typing,
                                meaning: false,
                                keyed: false,
                              ),
                            Transform(
                              key: const Key('set-study-exit'),
                              alignment: Alignment.center,
                              transform: _exitMatrix(exit, travel),
                              child: face,
                            ),
                          ],
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
            ),
            if (widget.newWord) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: const Key('set-study-skip'),
                      onPressed: widget.onSkip,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.text,
                        side: BorderSide(color: colors.border),
                        minimumSize: const Size(0, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(localizations.studyNotYetStudied),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      key: const Key('set-study-studied'),
                      onPressed: widget.onStudied,
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.practice,
                        foregroundColor: colors.onAccent,
                        minimumSize: const Size(0, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(localizations.studyStudiedAction),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
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
    return present(<String>[
      word.definition,
      sentencePlain(word.sentence),
      word.note,
    ]);
  }
  if (mode == _PracticeMode.flashcard) {
    return present(<String>[word.term, word.ipa]);
  }
  if (mode == _PracticeMode.random) {
    return present(<String>[
      word.term,
      word.ipa,
      word.singularPlural,
      sentencePlain(word.sentence),
      word.definition,
      word.note,
    ]);
  }
  if (mode == _PracticeMode.quiz) {
    return present(<String>[word.definition]);
  }
  return present(<String>[word.term, sentencePlain(word.sentence)]);
}

class _CardStack extends StatelessWidget {
  const _CardStack({
    required this.word,
    required this.peek,
    required this.mode,
    required this.typing,
    required this.meaning,
    this.keyed = true,
  });

  final VocabularyWord? word;
  final VocabularyWord? peek;
  final _PracticeMode mode;
  final TextEditingController typing;
  final bool meaning;
  final bool keyed;

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
            keyed: keyed,
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
    this.keyed = true,
  });

  final VocabularyWord? word;
  final _PracticeMode mode;
  final TextEditingController typing;
  final bool meaning;
  final bool keyed;

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
      key: keyed
          ? const Key('set-study-card')
          : const Key('set-study-card-under'),
      alignment: null,
      constraints: BoxConstraints(minHeight: centered ? 420 : 180),
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
              height: 420,
              width: double.infinity,
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 28, 56, 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (showImage) ...[
                                _CardPhoto(
                                  image: image,
                                  fill: colors.folderFill,
                                  keyed: keyed,
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
                            child: _SpeakButton(term: term, keyed: keyed),
                          ),
                      ],
                    ),
                  ),
                  if (!meaning) _MeaningHint(keyed: keyed),
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
  const _MeaningHint({this.keyed = true});

  final bool keyed;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colors = HomePalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: DecoratedBox(
        key: keyed ? const Key('set-study-meaning-hint') : null,
        decoration: BoxDecoration(
          color: colors.folderFill,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                localizations.studyShortcut,
                style: HomeText.of(context).caption
                    .copyWith(color: colors.ink, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  localizations.studyFlipShortcut,
                  textAlign: TextAlign.center,
                  style: HomeText.of(context).caption
                      .copyWith(color: colors.text),
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
                ? text.title.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: centered ? 32 : null,
                    height: centered ? 1.2 : null,
                  )
                : text.body.copyWith(
                    color: colors.muted,
                    fontStyle: centered ? FontStyle.italic : null,
                  ),
          ),
        ],
      ],
    );
  }
}

class _CardPhoto extends StatelessWidget {
  const _CardPhoto({
    required this.image,
    required this.fill,
    this.keyed = true,
    this.width = 140,
    this.height = 96,
    this.radius = 12,
  });

  final String image;
  final Color fill;
  final bool keyed;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        image,
        key: keyed ? const Key('set-study-photo') : null,
        width: width,
        height: height,
        fit: BoxFit.cover,
        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
        errorBuilder: (context, error, stackTrace) {
          return Container(width: width, height: height, color: fill);
        },
      ),
    );
  }
}

class _SpeakButton extends StatelessWidget {
  const _SpeakButton({
    required this.term,
    this.keyed = true,
    this.size = iconSize,
    this.color,
  });

  static const iconSize = 18.0;

  final String term;
  final bool keyed;
  final double size;
  final Color? color;

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
        color: color ?? HomePalette.of(context).muted,
        size: size,
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
    required this.onToggleStar,
  });

  final int index;
  final VocabularyWord word;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onToggleStar;

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
                  _SpeakButton(term: word.term, keyed: false),
                  const SizedBox(width: 8),
                  _WordToolIcon(
                    icon: word.starred ? Icons.star : Icons.star_border,
                    color: word.starred ? _starColor : null,
                    onPressed: onToggleStar,
                  ),
                  const Spacer(),
                  _WordToolIcon(
                    buttonKey: Key('set-study-word-edit-$index'),
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

const _starColor = Color(0xFFF5B942);

class _StatsSnapshot {
  const _StatsSnapshot({
    required this.counts,
    required this.learned,
    required this.total,
    this.percent,
  });

  final List<int> counts;
  final int learned;
  final int total;
  final int? percent;
}

_StatsSnapshot _statsSnapshot({
  required List<VocabularyWord> words,
  required Map<int, StudyWordState> levels,
  HomeSample? overview,
}) {
  final counts = List<int>.filled(6, 0);
  if (overview == null) {
    for (var index = 0; index < words.length; index++) {
      final level = levels[index]?.level;
      if (level != null && level >= 1 && level <= 6) {
        counts[level - 1] += 1;
      }
    }
    final learned = counts[5];
    final total = words.length;
    return _StatsSnapshot(
      counts: counts,
      learned: learned,
      total: total,
      percent: studyPercent(learned, total),
    );
  }
  for (
    var index = 0;
    index < overview.bars.length && index < counts.length;
    index++
  ) {
    counts[index] = int.tryParse(overview.bars[index].label ?? '') ?? 0;
  }
  return _StatsSnapshot(
    counts: counts,
    learned: overview.learnedCount,
    total: overview.totalCount,
    percent: overview.percent,
  );
}

class _WordToolIcon extends StatelessWidget {
  const _WordToolIcon({
    this.buttonKey,
    required this.icon,
    this.onPressed,
    this.color,
  });

  final Key? buttonKey;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: buttonKey,
      onPressed: onPressed ?? () {},
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      icon: Icon(icon, size: 18, color: color ?? HomePalette.of(context).muted),
    );
  }
}

class _StudyStats extends StatefulWidget {
  const _StudyStats({
    required this.words,
    required this.levels,
    this.overview,
    this.from,
  });

  final List<VocabularyWord> words;
  final Map<int, StudyWordState> levels;
  final HomeSample? overview;
  final _StatsSnapshot? from;

  @override
  State<_StudyStats> createState() => _StudyStatsState();
}

class _StudyStatsState extends State<_StudyStats>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 900);
  // Match _PracticeComplete chart reveal (enter 900ms * start 0.4).
  static const _startDelay = Duration(milliseconds: 360);

  late final AnimationController _motion;
  var _started = false;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(vsync: this, duration: _duration);
    if (widget.from == null) {
      _motion.value = 1;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started || widget.from == null) {
      return;
    }
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _motion.value = 1;
      return;
    }
    Future<void>.delayed(_startDelay, () {
      if (!mounted) {
        return;
      }
      _motion.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colors = HomePalette.of(context);
    // When animating a session, always lerp live set levels — not overview —
    // so old → new reflects what changed during practice.
    final to = _statsSnapshot(
      words: widget.words,
      levels: widget.levels,
      overview: widget.from == null ? widget.overview : null,
    );
    final from = widget.from ?? to;
    final colorsForLevel = <Color>[
      HomeSample.forgot,
      HomeSample.hard,
      HomeSample.learning,
      HomeSample.familiar,
      HomeSample.good,
      HomeSample.mastered,
    ];
    final fromPeak = from.counts.fold<double>(1, (peak, count) {
      return count > peak ? count.toDouble() : peak;
    });
    final toPeak = to.counts.fold<double>(1, (peak, count) {
      return count > peak ? count.toDouble() : peak;
    });
    final peak = fromPeak > toPeak ? fromPeak : toPeak;
    final showPercent = widget.overview != null || widget.from != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: AnimatedBuilder(
          animation: _motion,
          builder: (context, _) {
            final t = Curves.easeOutCubic.transform(_motion.value);
            final learned =
                (from.learned + (to.learned - from.learned) * t).round();
            final fromPercent = from.percent ?? 0;
            final toPercent = to.percent ?? 0;
            final percent = showPercent
                ? fromPercent + (toPercent - fromPercent) * t
                : null;
            return Column(
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
                        text: '/${to.total}',
                        style: HomeText.of(context).subtitle
                            .copyWith(color: colors.ink),
                      ),
                    ],
                  ),
                ),
                if (percent != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${percent.round()}%',
                    style: HomeText.of(context).subtitle
                        .copyWith(color: colors.ink),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 140,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (var index = 0;
                                index < to.counts.length;
                                index++)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Builder(
                                    builder: (context) {
                                      final height =
                                          from.counts[index] +
                                          (to.counts[index] -
                                                  from.counts[index]) *
                                              t;
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          if (height > 0.05)
                                            Text(
                                              '${height.round()}',
                                              style: HomeText.of(
                                                context,
                                              ).caption,
                                            ),
                                          const SizedBox(height: 4),
                                          Container(
                                            height: 8 + (88 * height / peak),
                                            decoration: BoxDecoration(
                                              color: colorsForLevel[index],
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Builder(
                      builder: (context) {
                        final labels = <String>[
                          localizations.levelMastered,
                          localizations.levelGood,
                          localizations.levelFamiliar,
                          localizations.levelLearning,
                          localizations.levelHard,
                          localizations.levelForgot,
                        ];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var index = 0; index < labels.length; index++)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 3,
                                ),
                                child: Builder(
                                  builder: (context) {
                                    final countIndex = 5 - index;
                                    final count =
                                        (from.counts[countIndex] +
                                                (to.counts[countIndex] -
                                                        from.counts[countIndex]) *
                                                    t)
                                            .round();
                                    return Row(
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: colorsForLevel[countIndex],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          labels[index],
                                          style: HomeText.of(context).body,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '${studyPercent(count, to.total)}%',
                                          style: HomeText.of(context).body,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PracticeComplete extends StatefulWidget {
  const _PracticeComplete({
    required this.words,
    required this.levels,
    required this.total,
    required this.know,
    required this.learning,
    required this.left,
    required this.onDone,
    required this.onPracticeQuiz,
    required this.onRestartFlashcards,
    this.overview,
    this.fromStats,
  });

  final List<VocabularyWord> words;
  final Map<int, StudyWordState> levels;
  final int total;
  final int know;
  final int learning;
  final int left;
  final VoidCallback onDone;
  final VoidCallback onPracticeQuiz;
  final VoidCallback onRestartFlashcards;
  final HomeSample? overview;
  final _StatsSnapshot? fromStats;

  static const _ring = Color(0xFF18C964);

  @override
  State<_PracticeComplete> createState() => _PracticeCompleteState();
}

class _PracticeCompleteState extends State<_PracticeComplete>
    with SingleTickerProviderStateMixin {
  static const _enterDuration = Duration(milliseconds: 900);

  late final AnimationController _enter;
  var _started = false;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: _enterDuration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _enter.value = 1;
      return;
    }
    _enter.forward(from: 0);
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  double _phase(double start, double end) {
    final span = end - start;
    if (span <= 0) {
      return 1;
    }
    return Curves.easeOutCubic.transform(
      ((_enter.value - start) / span).clamp(0.0, 1.0),
    );
  }

  Widget _reveal({
    required double start,
    required double end,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: _enter,
      builder: (context, child) {
        final t = _phase(start, end);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - t)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colors = HomePalette.of(context);
    final text = HomeText.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final knowFill = dark ? const Color(0xFF0B4F2C) : const Color(0xFFD1FADF);
    final knowText = dark ? const Color(0xFF6CDE8C) : HomeSample.good;
    final learnFill = dark ? const Color(0xFF4A2A12) : const Color(0xFFFFEAD5);
    final learnText = HomeSample.learning;
    final leftFill = dark ? const Color(0xFF2A3344) : colors.folderFill;
    final leftText = colors.muted;
    final summary = widget.total == 1
        ? localizations.studyCompleteOne
        : localizations.studyCompleteMany(widget.total);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            key: const Key('set-study-practice-back'),
            onPressed: widget.onDone,
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.close, color: colors.ink),
          ),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _reveal(
                  start: 0,
                  end: 0.35,
                  child: Text(
                    localizations.studyCompleteHeadline,
                    key: const Key('set-study-complete'),
                    style: text.title.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _reveal(
                  start: 0.12,
                  end: 0.45,
                  child: Text(
                    summary,
                    style: text.subtitle.copyWith(color: colors.muted),
                  ),
                ),
                const SizedBox(height: 28),
                _reveal(
                  start: 0.22,
                  end: 0.6,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final stacked = constraints.maxWidth < 560;
                      final doing = _completeDoing(
                        context,
                        localizations: localizations,
                        text: text,
                        knowFill: knowFill,
                        knowText: knowText,
                        learnFill: learnFill,
                        learnText: learnText,
                        leftFill: leftFill,
                        leftText: leftText,
                      );
                      final next = _completeNext(
                        context,
                        localizations: localizations,
                        colors: colors,
                        text: text,
                      );
                      if (stacked) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            doing,
                            const SizedBox(height: 28),
                            next,
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: doing),
                          const SizedBox(width: 28),
                          Expanded(flex: 2, child: next),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),
                _reveal(
                  start: 0.4,
                  end: 0.8,
                  child: _StudyStats(
                    words: widget.words,
                    levels: widget.levels,
                    overview: widget.overview,
                    from: widget.fromStats,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _completeDoing(
    BuildContext context, {
    required AppLocalizations localizations,
    required HomeText text,
    required Color knowFill,
    required Color knowText,
    required Color learnFill,
    required Color learnText,
    required Color leftFill,
    required Color leftText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.studyHowYoureDoing,
          style: text.subtitle.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _enter,
              builder: (context, child) {
                final t = _phase(0.28, 0.62);
                return Transform.scale(scale: 0.7 + 0.3 * t, child: child);
              },
              child: const _CompleteRing(color: _PracticeComplete._ring),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  _CompleteBar(
                    label: localizations.studyKnow,
                    count: widget.know,
                    fill: knowFill,
                    labelColor: knowText,
                  ),
                  const SizedBox(height: 8),
                  _CompleteBar(
                    label: localizations.studyStillLearning,
                    count: widget.learning,
                    fill: learnFill,
                    labelColor: learnText,
                  ),
                  const SizedBox(height: 8),
                  _CompleteBar(
                    label: localizations.studyTermsLeft,
                    count: widget.left,
                    fill: leftFill,
                    labelColor: leftText,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _completeNext(
    BuildContext context, {
    required AppLocalizations localizations,
    required HomePalette colors,
    required HomeText text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          localizations.studyNextSteps,
          style: text.subtitle.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          key: const Key('set-study-complete-quiz'),
          onPressed: widget.onPracticeQuiz,
          style: FilledButton.styleFrom(
            backgroundColor: colors.practice,
            foregroundColor: colors.onAccent,
            minimumSize: const Size.fromHeight(52),
            shape: const StadiumBorder(),
            textStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          icon: const Icon(Icons.autorenew, size: 20),
          label: Text(localizations.studyPracticeWithQuestions),
        ),
        const SizedBox(height: 12),
        FilledButton(
          key: const Key('set-study-complete-flashcards'),
          onPressed: widget.onRestartFlashcards,
          style: FilledButton.styleFrom(
            backgroundColor: colors.folderFill,
            foregroundColor: colors.ink,
            minimumSize: const Size.fromHeight(52),
            shape: const StadiumBorder(),
            textStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: Text(localizations.studyRestartFlashcards),
        ),
      ],
    );
  }
}

class _CompleteRing extends StatelessWidget {
  const _CompleteRing({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 88,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 8),
        ),
        child: Icon(Icons.check, size: 36, color: color),
      ),
    );
  }
}

class _CompleteBar extends StatelessWidget {
  const _CompleteBar({
    required this.label,
    required this.count,
    required this.fill,
    required this.labelColor,
  });

  final String label;
  final int count;
  final Color fill;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: HomeText.of(context).subtitle.copyWith(
                  color: labelColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '$count',
              style: HomeText.of(context).subtitle.copyWith(
                color: labelColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrowseHeader extends StatelessWidget {
  const _BrowseHeader({
    required this.title,
    required this.onEdit,
    required this.onPractice,
    required this.onLearnNew,
  });

  final String title;
  final VoidCallback onEdit;
  final VoidCallback onPractice;
  final VoidCallback onLearnNew;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colors = HomePalette.of(context);
    return ColoredBox(
      color: colors.page,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.menu_book_outlined, size: 20, color: colors.ink),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
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
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
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
                    buttonKey: const Key('set-study-learn-new'),
                    label: localizations.studyLearnNew,
                    filled: false,
                    onPressed: onLearnNew,
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
      color: selected ? colors.selectedFill : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: HomeText.of(context).body
                    .copyWith(color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizRatings extends StatelessWidget {
  const _QuizRatings({required this.onRate, required this.localizations});

  final ValueChanged<StudyAction> onRate;
  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        QuizRise(
          slot: 0,
          builder: (ready) => _RatingButton(
            buttonKey: const Key('set-study-hard'),
            icon: Icons.sentiment_dissatisfied,
            label: localizations.studyHard,
            color: HomeSample.forgot,
            onPressed: ready ? () => onRate(StudyAction.hard) : () {},
          ),
        ),
        const SizedBox(width: 60),
        QuizRise(
          slot: 1,
          builder: (ready) => _RatingButton(
            buttonKey: const Key('set-study-familiar'),
            icon: Icons.sentiment_neutral,
            label: localizations.studyFamiliar,
            color: HomeSample.learning,
            onPressed: ready ? () => onRate(StudyAction.familiar) : () {},
          ),
        ),
        const SizedBox(width: 60),
        QuizRise(
          slot: 2,
          builder: (ready) => _RatingButton(
            buttonKey: const Key('set-study-easy'),
            icon: Icons.sentiment_satisfied,
            label: localizations.studyEasy,
            color: HomeSample.familiar,
            onPressed: ready ? () => onRate(StudyAction.easy) : () {},
          ),
        ),
      ],
    );
  }
}

class _QuizNewWordActions extends StatelessWidget {
  const _QuizNewWordActions({
    required this.onSkip,
    required this.onStudied,
    required this.localizations,
  });

  final VoidCallback onSkip;
  final VoidCallback onStudied;
  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    return Row(
      children: [
        Expanded(
          child: QuizRise(
            slot: 0,
            builder: (ready) => OutlinedButton(
              key: const Key('set-study-skip'),
              onPressed: ready ? onSkip : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.text,
                side: BorderSide(color: colors.border),
                minimumSize: const Size(0, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(localizations.studyNotYetStudied),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: QuizRise(
            slot: 1,
            builder: (ready) => FilledButton(
              key: const Key('set-study-studied'),
              onPressed: ready ? onStudied : null,
              style: FilledButton.styleFrom(
                backgroundColor: colors.practice,
                foregroundColor: colors.onAccent,
                minimumSize: const Size(0, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(localizations.studyStudiedAction),
            ),
          ),
        ),
      ],
    );
  }
}

class _RatingButton extends StatefulWidget {
  const _RatingButton({
    required this.buttonKey,
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final Key buttonKey;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  State<_RatingButton> createState() => _RatingButtonState();
}

class _RatingButtonState extends State<_RatingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scale;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 0.84,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.84,
          end: 1.14,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.14,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(_press);
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  Future<void> _tap() async {
    if (_busy) {
      return;
    }
    _busy = true;
    widget.onPressed();
    if (!mounted) {
      return;
    }
    if (!MediaQuery.disableAnimationsOf(context)) {
      await _press.forward(from: 0);
    }
    if (mounted) {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _press,
      builder: (context, child) {
        final progress = _press.value;
        final showRing = progress > 0 && progress < 1;
        return Column(
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  if (showRing)
                    IgnorePointer(
                      child: Transform.scale(
                        scale: 1 + progress * 0.75,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: widget.color.withValues(
                                alpha: (1 - progress) * 0.8,
                              ),
                              width: 2.5,
                            ),
                          ),
                          child: const SizedBox.square(dimension: 56),
                        ),
                      ),
                    ),
                  Transform.scale(scale: _scale.value, child: child),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              style: HomeText.of(context).body.copyWith(color: widget.color),
            ),
          ],
        );
      },
      child: IconButton(
        key: widget.buttonKey,
        onPressed: _tap,
        icon: Icon(widget.icon, color: Colors.white, size: 28),
        style: IconButton.styleFrom(
          backgroundColor: widget.color,
          fixedSize: const Size(56, 56),
          shape: const CircleBorder(),
        ),
      ),
    );
  }
}
