import 'package:flutter/material.dart';
import 'package:lang/features/home/sample/home_sample.dart';
import 'package:lang/theme/home_palette.dart';
import 'package:lang/theme/home_text.dart';
import 'package:lang/l10n/app_localizations.dart';

class StatisticsPanel extends StatelessWidget {
  const StatisticsPanel({super.key, required this.sample});

  final HomeSample sample;

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
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SetHeading(sample: sample),
              const SizedBox(height: 8),
              _ScoreRow(sample: sample),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: _BarChart(bars: sample.bars)),
                  const SizedBox(width: 24),
                  _Legend(labels: levels, levels: sample.levels),
                ],
              ),
              const SizedBox(height: 16),
              _ChartFooter(
                learned: localizations.wordsLearned,
                notLearned: localizations.wordsNotLearned,
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: _AllSwitch(label: localizations.allLabel),
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
  const _SetHeading({required this.sample});

  final HomeSample sample;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.menu_book_outlined,
          size: 18,
          color: HomePalette.of(context).ink,
        ),
        const SizedBox(width: 8),
        Text(sample.statisticsSetName, style: HomeText.of(context).heading),
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

class _BarChart extends StatelessWidget {
  const _BarChart({required this.bars});

  final List<HomeBar> bars;

  @override
  Widget build(BuildContext context) {
    if (bars.isEmpty) {
      return const SizedBox(height: 161, width: double.infinity);
    }
    return SizedBox(
      height: 161,
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.bottomLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final bar in bars)
              Padding(
                padding: const EdgeInsets.only(right: 26),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (bar.label != null)
                      Text(bar.label!, style: HomeText.of(context).caption),
                    const SizedBox(height: 3),
                    Container(
                      width: 62,
                      height: bar.height,
                      decoration: BoxDecoration(
                        color: bar.color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
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
  const _ChartFooter({required this.learned, required this.notLearned});

  final String learned;
  final String notLearned;

  @override
  Widget build(BuildContext context) {
    final style = HomeText.of(context).body.copyWith(
      fontWeight: FontWeight.w500,
      color: HomePalette.of(context).ink,
    );
    return Row(
      children: [
        Expanded(
          child: Text(learned, textAlign: TextAlign.center, style: style),
        ),
        Container(
          width: 1,
          height: 20,
          color: HomePalette.of(context).scrollTrack,
        ),
        Expanded(
          child: Text(notLearned, textAlign: TextAlign.center, style: style),
        ),
      ],
    );
  }
}

class _AllSwitch extends StatefulWidget {
  const _AllSwitch({required this.label});

  final String label;

  @override
  State<_AllSwitch> createState() => _AllSwitchState();
}

class _AllSwitchState extends State<_AllSwitch> {
  bool _on = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _on = !_on),
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
