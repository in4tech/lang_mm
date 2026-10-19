import 'package:flutter/material.dart';
import 'package:lang/features/home/sample/home_sample.dart';
import 'package:lang/features/home/widgets/learned_words_dialog.dart';
import 'package:lang/library/vocabulary_set.dart';
import 'package:lang/theme/home_palette.dart';
import 'package:lang/theme/home_text.dart';
import 'package:lang/l10n/app_localizations.dart';

class StatisticsPanel extends StatelessWidget {
  const StatisticsPanel({
    super.key,
    required this.sample,
    this.onAllChanged,
    this.onOpenSet,
    this.learnedWords = const <VocabularyWord>[],
    this.notLearnedWords = const <VocabularyWord>[],
  });

  final HomeSample sample;
  final ValueChanged<bool>? onAllChanged;
  final VoidCallback? onOpenSet;
  final List<VocabularyWord> learnedWords;
  final List<VocabularyWord> notLearnedWords;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final levels = <String>[
      localizations.levelMastered,
      localizations.levelGood,
      localizations.levelFamiliar,
      localizations.levelLearning,
      localizations.levelHard,
      localizations.levelForgot,
    ];
    return _Card(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SetHeading(sample: sample, onOpenSet: onOpenSet),
              const SizedBox(height: 8),
              _ScoreRow(sample: sample),
              const SizedBox(height: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: _BarChart(bars: sample.bars)),
                        const SizedBox(width: 24),
                        _Legend(labels: levels, levels: sample.levels),
                      ],
                    ),
                    const Spacer(),
                    _ChartFooter(
                      learned: localizations.wordsLearned,
                      notLearned: localizations.wordsNotLearned,
                      onLearned: () => showLearnedWordsDialog(
                        context: context,
                        title: localizations.wordsLearned,
                        words: learnedWords,
                      ),
                      onNotLearned: () => showLearnedWordsDialog(
                        context: context,
                        title: localizations.wordsNotLearned,
                        words: notLearnedWords,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: _AllSwitch(
              label: localizations.allLabel,
              onChanged: onAllChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: HomePalette.of(context).border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
        child: child,
      ),
    );
  }
}

class _SetHeading extends StatelessWidget {
  const _SetHeading({required this.sample, this.onOpenSet});

  final HomeSample sample;
  final VoidCallback? onOpenSet;

  @override
  Widget build(BuildContext context) {
    final name = sample.statisticsSetName.isNotEmpty
        ? sample.statisticsSetName
        : (sample.statisticsAll && sample.totalCount > 0
              ? AppLocalizations.of(context).allVocabulary
              : '');
    return Row(
      children: [
        Icon(
          Icons.menu_book_outlined,
          size: 18,
          color: HomePalette.of(context).ink,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: _SetTitle(name: name, onTap: onOpenSet),
        ),
        const SizedBox(width: 8),
        _ProgressBar(
          width: 224,
          height: 10,
          percent: sample.percent,
          color: HomeSample.progressGreen,
        ),
      ],
    );
  }
}

class _SetTitle extends StatefulWidget {
  const _SetTitle({required this.name, this.onTap});

  final String name;
  final VoidCallback? onTap;

  @override
  State<_SetTitle> createState() => _SetTitleState();
}

class _SetTitleState extends State<_SetTitle> {
  final _labelKey = GlobalKey<_UnderlineTextState>();

  void _setHover(bool hover) {
    final label = _labelKey.currentState;
    if (label == null) {
      return;
    }
    // Mouse enter runs inside the tracker's device update. Changing the
    // label on the next task keeps that update from running again.
    Future<void>(() {
      label.setHovered(hover);
    });
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null && widget.name.isNotEmpty;
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: enabled ? (_) => _setHover(true) : null,
      onExit: enabled ? (_) => _setHover(false) : null,
      child: _UnderlineText(
        key: _labelKey,
        name: widget.name,
        onTap: enabled ? widget.onTap : null,
      ),
    );
  }
}

class _UnderlineText extends StatefulWidget {
  const _UnderlineText({super.key, required this.name, this.onTap});

  final String name;
  final VoidCallback? onTap;

  @override
  State<_UnderlineText> createState() => _UnderlineTextState();
}

class _UnderlineTextState extends State<_UnderlineText> {
  bool _hover = false;

  void setHovered(bool hover) {
    if (!mounted || _hover == hover) {
      return;
    }
    setState(() => _hover = hover);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Text(
        widget.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: HomeText.of(context).heading.copyWith(
          decoration: _hover ? TextDecoration.underline : TextDecoration.none,
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({required this.sample});

  final HomeSample sample;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text.rich(
          TextSpan(
            style: HomeText.of(context).title,
            children: [
              TextSpan(text: '${sample.learnedCount}'),
              TextSpan(
                text: '/${sample.totalCount}',
                style: HomeText.of(context).subtitle.copyWith(color: HomePalette.of(context).ink),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: HomeSample.progressGreen),
          ),
          child: const Icon(
            Icons.check,
            size: 10,
            color: HomeSample.progressGreen,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${sample.percent}%',
          style: HomeText.of(context).subtitle.copyWith(color: HomePalette.of(context).ink),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.width,
    required this.height,
    required this.percent,
    required this.color,
  });

  final double width;
  final double height;
  final int percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: HomePalette.of(context).border,
        borderRadius: BorderRadius.circular(100),
      ),
      child: FractionallySizedBox(
        widthFactor: percent / 100,
        heightFactor: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }
}

double _barHeight(double height, double tallest, double plotHeight) {
  if (height <= 0 || tallest <= 0) {
    return 4;
  }
  final scaled = plotHeight * height / tallest;
  return scaled < 4 ? 4 : scaled;
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.bars});

  final List<HomeBar> bars;

  @override
  Widget build(BuildContext context) {
    if (bars.isEmpty) {
      return const SizedBox(height: 161, width: double.infinity);
    }
    var tallest = 0.0;
    for (final bar in bars) {
      if (bar.height > tallest) {
        tallest = bar.height;
      }
    }
    const plotHeight = 128.0;
    return SizedBox(
      height: 161,
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final bar in bars)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (bar.label != null)
                    Text(
                      bar.label!,
                      textAlign: TextAlign.center,
                      style: HomeText.of(context).caption,
                    ),
                  const SizedBox(height: 3),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      height: _barHeight(bar.height, tallest, plotHeight),
                      decoration: BoxDecoration(
                        color: bar.color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.labels, required this.levels});

  final List<String> labels;
  final List<HomeLevel> levels;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < levels.length; index++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: levels[index].color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(labels[index], style: HomeText.of(context).body),
                const SizedBox(width: 12),
                Text('${levels[index].percent}%', style: HomeText.of(context).body),
              ],
            ),
          ),
      ],
    );
  }
}

class _ChartFooter extends StatelessWidget {
  const _ChartFooter({
    required this.learned,
    required this.notLearned,
    required this.onLearned,
    required this.onNotLearned,
  });

  final String learned;
  final String notLearned;
  final VoidCallback onLearned;
  final VoidCallback onNotLearned;

  @override
  Widget build(BuildContext context) {
    final style = HomeText.of(context).body.copyWith(
      fontWeight: FontWeight.w500,
      color: HomePalette.of(context).ink,
    );
    return Row(
      children: [
        Expanded(
          child: _FooterButton(
            buttonKey: const Key('statistics-learned'),
            label: learned,
            style: style,
            onTap: onLearned,
          ),
        ),
        Container(
          width: 1,
          height: 20,
          color: HomePalette.of(context).scrollTrack,
        ),
        Expanded(
          child: _FooterButton(
            buttonKey: const Key('statistics-not-learned'),
            label: notLearned,
            style: style,
            onTap: onNotLearned,
          ),
        ),
      ],
    );
  }
}

class _FooterButton extends StatelessWidget {
  const _FooterButton({
    required this.buttonKey,
    required this.label,
    required this.style,
    required this.onTap,
  });

  final Key buttonKey;
  final String label;
  final TextStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        key: buttonKey,
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(label, textAlign: TextAlign.center, style: style),
        ),
      ),
    );
  }
}

class _AllSwitch extends StatefulWidget {
  const _AllSwitch({required this.label, this.onChanged});

  final String label;
  final ValueChanged<bool>? onChanged;

  @override
  State<_AllSwitch> createState() => _AllSwitchState();
}

class _AllSwitchState extends State<_AllSwitch> {
  bool _on = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _on = !_on);
        widget.onChanged?.call(_on);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.label, style: HomeText.of(context).caption),
          const SizedBox(width: 8),
          Container(
            key: const Key('all-switch'),
            width: 28,
            height: 14,
            alignment: _on ? Alignment.centerRight : Alignment.centerLeft,
            decoration: BoxDecoration(
              color: HomePalette.of(context).surface,
              border: Border.all(color: HomePalette.of(context).border),
              borderRadius: BorderRadius.circular(100),
            ),
            child: SizedBox(
              key: const Key('all-switch-knob'),
              width: 14,
              height: 14,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: HomePalette.of(context).toggleKnob,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
