import 'package:flutter/material.dart';
import 'package:lang/features/word_editor/sentence_format.dart';
import 'package:lang/l10n/app_localizations.dart';
import 'package:lang/library/vocabulary_set.dart';
import 'package:lang/theme/home_palette.dart';
import 'package:lang/theme/home_text.dart';

const quizCorrectColor = Color(0xFF12B76A);
const quizWrongColor = Color(0xFFF79009);

enum QuizMark { correct, wrong, skip }

class QuizChoice {
  const QuizChoice({
    required this.wordIndex,
    required this.number,
    required this.line,
  });

  final int wordIndex;
  final int number;
  final String line;
}

String quizOptionLine(VocabularyWord word) {
  final parts = <String>[
    if (word.ipa.trim().isNotEmpty) word.ipa.trim(),
    if ((word.type ?? '').trim().isNotEmpty) word.type!.trim(),
    if (word.definition.trim().isNotEmpty) word.definition.trim(),
  ];
  final sentence = sentencePlain(word.sentence).trim();
  final head = parts.join(' ');
  if (head.isEmpty) {
    return sentence;
  }
  if (sentence.isEmpty) {
    return head;
  }
  return '$head — $sentence';
}

class QuizOptionBorder extends StatelessWidget {
  const QuizOptionBorder({
    super.key,
    required this.color,
    required this.dashed,
    required this.child,
  });

  final Color color;
  final bool dashed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    return CustomPaint(
      foregroundPainter: dashed ? _DashPainter(color: color) : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: dashed
              ? null
              : Border.all(
                  color: color,
                  width: color == quizCorrectColor || color == quizWrongColor
                      ? 1.5
                      : 1,
                ),
        ),
        child: child,
      ),
    );
  }
}

class QuizCard extends StatefulWidget {
  const QuizCard({
    super.key,
    required this.termLabel,
    required this.term,
    required this.prompt,
    required this.wrongSentence,
    required this.skipSentence,
    required this.dontKnowLabel,
    required this.speak,
    required this.choices,
    required this.mark,
    required this.currentIndex,
    required this.chosenIndex,
    required this.correctStreak,
    required this.onChoose,
    required this.onDontKnow,
    required this.onSettled,
  });

  final String termLabel;
  final String term;
  final String prompt;
  final String wrongSentence;
  final String skipSentence;
  final String dontKnowLabel;
  final Widget speak;
  final List<QuizChoice> choices;
  final QuizMark? mark;
  final int currentIndex;
  final int? chosenIndex;
  final int correctStreak;
  final ValueChanged<int> onChoose;
  final VoidCallback onDontKnow;
  final VoidCallback onSettled;

  @override
  State<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _reveal;
  int? _playedFor;

  @override
  void initState() {
    super.initState();
    _reveal = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncReveal();
  }

  @override
  void didUpdateWidget(QuizCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mark != oldWidget.mark ||
        widget.currentIndex != oldWidget.currentIndex) {
      _syncReveal();
    }
  }

  void _syncReveal() {
    if (widget.mark == null) {
      _reveal.stop();
      _reveal.value = 0;
      _playedFor = null;
      return;
    }
    if (_playedFor == widget.currentIndex) {
      return;
    }
    _playedFor = widget.currentIndex;
    if (MediaQuery.disableAnimationsOf(context)) {
      _reveal.value = 1;
      return;
    }
    _reveal.forward(from: 0).whenComplete(() {
      if (mounted && widget.mark != null) {
        widget.onSettled();
      }
    });
  }

  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final text = HomeText.of(context);
    final sentence = switch (widget.mark) {
      QuizMark.wrong => widget.wrongSentence,
      QuizMark.skip => widget.skipSentence,
      QuizMark.correct => '',
      null => widget.prompt,
    };
    return Container(
      key: const Key('quiz-card'),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                widget.termLabel,
                style: text.caption.copyWith(color: colors.muted),
              ),
              widget.speak,
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.term,
            key: const Key('quiz-term'),
            style: text.title.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (widget.mark == QuizMark.correct)
            _QuizPraise(
              key: ValueKey(widget.correctStreak),
              phrases: _quizPraises(AppLocalizations.of(context)),
              streak: widget.correctStreak,
            )
          else
            Text(
              sentence,
              style: text.body.copyWith(
                color: widget.mark == QuizMark.wrong
                    ? quizWrongColor
                    : colors.muted,
              ),
            ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 560 ? 2 : 1;
              const gap = 12.0;
              final itemWidth = columns == 1
                  ? constraints.maxWidth
                  : (constraints.maxWidth - gap) / 2;
              return AnimatedBuilder(
                animation: _reveal,
                builder: (context, _) {
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (final choice in widget.choices)
                        SizedBox(
                          width: itemWidth,
                          child: _option(choice, _reveal.value),
                        ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _reveal,
            builder: (context, _) {
              final revealed = widget.mark != null;
              final tone = Theme.of(context).colorScheme.primary;
              return Align(
                alignment: Alignment.centerRight,
                child: Opacity(
                  opacity: revealed ? 1 - (0.55 * _reveal.value) : 1,
                  child: TextButton(
                    key: const Key('quiz-dont-know'),
                    onPressed: revealed ? null : widget.onDontKnow,
                    style: TextButton.styleFrom(disabledForegroundColor: tone),
                    child: Text(widget.dontKnowLabel),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _option(QuizChoice choice, double progress) {
    final colors = HomePalette.of(context);
    final current = choice.wordIndex == widget.currentIndex;
    final chosen = choice.wordIndex == widget.chosenIndex;
    final revealed = widget.mark != null;
    var color = colors.border;
    var dashed = false;
    var dim = false;
    Widget marker = Text(
      '${choice.number}',
      style: HomeText.of(context).body.copyWith(color: colors.muted),
    );
    if (revealed && widget.mark == QuizMark.correct && chosen) {
      color = quizCorrectColor;
      marker = _scaledIcon(Icons.check, quizCorrectColor, progress);
    } else if (revealed && current) {
      color = quizCorrectColor;
      dashed = true;
      marker = _scaledIcon(Icons.check, quizCorrectColor, progress);
    } else if (revealed && chosen && widget.mark == QuizMark.wrong) {
      color = quizWrongColor;
      marker = _scaledIcon(Icons.close, quizWrongColor, progress);
    } else if (revealed) {
      dim = true;
    }
    final opacity = dim ? 1 - (0.55 * progress) : 1.0;
    return Opacity(
      opacity: opacity,
      child: Material(
        key: Key('quiz-option-${choice.wordIndex}'),
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onChoose(choice.wordIndex),
          borderRadius: BorderRadius.circular(12),
          child: QuizOptionBorder(
            color: color,
            dashed: dashed,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 28, child: marker),
                  Expanded(
                    child: Text(choice.line, style: HomeText.of(context).body),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _scaledIcon(IconData icon, Color color, double progress) {
    return Transform.scale(
      scale: 0.6 + (0.4 * progress),
      child: Icon(icon, color: color, size: 18),
    );
  }
}

List<String> _quizPraises(AppLocalizations text) {
  return <String>[
    text.quizPraiseNice,
    text.quizPraiseGreat,
    text.quizPraiseAwesome,
    text.quizPraiseGotIt,
    text.quizPraiseBrilliant,
  ];
}

class _QuizPraise extends StatefulWidget {
  const _QuizPraise({
    super.key,
    required this.phrases,
    required this.streak,
  });

  final List<String> phrases;
  final int streak;

  @override
  State<_QuizPraise> createState() => _QuizPraiseState();
}

class _QuizPraiseState extends State<_QuizPraise>
    with SingleTickerProviderStateMixin {
  static const _icons = <IconData>[
    Icons.auto_awesome,
    Icons.celebration,
    Icons.star_rounded,
    Icons.emoji_events,
    Icons.thumb_up_alt_rounded,
  ];
  static const _iconColors = <Color>[
    Color(0xFF9E77ED),
    Color(0xFFEE46BC),
    Color(0xFFFEC84B),
    Color(0xFFEAAA08),
    Color(0xFF2E90FA),
  ];

  late final AnimationController _motion;
  var _started = false;

  int get _level {
    if (widget.phrases.isEmpty) {
      return 0;
    }
    final streak = widget.streak < 1 ? 1 : widget.streak;
    return (streak - 1).clamp(0, widget.phrases.length - 1);
  }

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _motion.value = 1;
      return;
    }
    _motion.forward(from: 0);
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final level = _level;
    final phrase = widget.phrases[level];
    final icon = _icons[level % _icons.length];
    final iconColor = _iconColors[level % _iconColors.length];
    return AnimatedBuilder(
      animation: _motion,
      builder: (context, child) {
        final t = Curves.easeOut.transform(_motion.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - t)),
            child: child,
          ),
        );
      },
      child: Row(
        key: const Key('quiz-praise'),
        children: [
          Icon(
            icon,
            key: const Key('quiz-praise-icon'),
            color: iconColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              phrase,
              style: HomeText.of(context).body.copyWith(
                color: quizCorrectColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuizRise extends StatefulWidget {
  const QuizRise({super.key, required this.slot, required this.builder});

  final int slot;
  final Widget Function(bool ready) builder;

  @override
  State<QuizRise> createState() => _QuizRiseState();
}

class _QuizRiseState extends State<QuizRise>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  var _ready = false;
  var _started = false;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _motion.value = 1;
      _ready = true;
      return;
    }
    Future<void>.delayed(Duration(milliseconds: 50 * widget.slot), () {
      if (!mounted) {
        return;
      }
      _motion.forward().whenComplete(() {
        if (mounted) {
          setState(() => _ready = true);
        }
      });
    });
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _motion,
      builder: (context, child) {
        final progress = _motion.value;
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - progress)),
            child: child,
          ),
        );
      },
      child: widget.builder(_ready),
    );
  }
}

class _DashPainter extends CustomPainter {
  const _DashPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + 6;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + 4;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
