import 'package:flutter/material.dart';
import 'package:lang/features/home/sample/home_sample.dart';
import 'package:lang/theme/home_colors.dart';
import 'package:lang/theme/home_text.dart';
import 'package:lang/l10n/app_localizations.dart';

class TodayPanel extends StatelessWidget {
  const TodayPanel({super.key, required this.sample, this.width = 302});

  final HomeSample sample;
  final double width;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return SizedBox(
      width: width,
      height: 372,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: HomeColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 12, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(localizations.todaysVocabulary, style: HomeText.heading),
              const SizedBox(height: 16),
              Expanded(child: _TodayList(rows: sample.today)),
              FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: HomeColors.practice,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                child: Text(localizations.practice),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PairRow extends StatelessWidget {
  const _PairRow({required this.row});

  final TodayRow row;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final leftWidth = (constraints.maxWidth - 12) * 0.45;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: leftWidth,
              child: _Chip(pair: row.left),
            ),
            const SizedBox(width: 12),
            Expanded(child: _Chip(pair: row.right)),
          ],
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.pair});

  final VocabPair pair;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: HomeColors.chip,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pair.word,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: HomeText.caption,
            ),
            Text(
              pair.form,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: HomeText.fine,
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayList extends StatefulWidget {
  const _TodayList({required this.rows});

  final List<TodayRow> rows;

  @override
  State<_TodayList> createState() => _TodayListState();
}

class _TodayListState extends State<_TodayList> {
  final ScrollController _controller = ScrollController();
  bool _overflows = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onMetrics(ScrollMetricsNotification notification) {
    final overflows = notification.metrics.maxScrollExtent > 0;
    if (overflows == _overflows || !mounted) {
      return;
    }
    setState(() => _overflows = overflows);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: NotificationListener<ScrollMetricsNotification>(
            onNotification: (notification) {
              _onMetrics(notification);
              return false;
            },
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context)
                  .copyWith(scrollbars: false),
              child: SingleChildScrollView(
                controller: _controller,
                child: Column(
                  children: [
                    for (final row in widget.rows)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PairRow(row: row),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_overflows)
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _ScrollIndicator(position: _controller.position),
              );
            },
          ),
      ],
    );
  }
}

class _ScrollIndicator extends StatelessWidget {
  const _ScrollIndicator({required this.position});

  final ScrollPosition position;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = position.viewportDimension;
        final extent = viewport + position.maxScrollExtent;
        final fraction = extent <= 0 ? 1.0 : viewport / extent;
        final trackHeight = constraints.maxHeight;
        final thumbHeight = (trackHeight * fraction).clamp(24.0, trackHeight);
        final travel = trackHeight - thumbHeight;
        final offset = position.maxScrollExtent <= 0
            ? 0.0
            : travel * (position.pixels / position.maxScrollExtent);
        return SizedBox(
          key: const Key('today-scrollbar'),
          width: 5,
          height: trackHeight,
          child: Stack(
            children: [
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: HomeColors.scrollTrack,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
              Positioned(
                top: offset,
                left: 0,
                right: 0,
                height: thumbHeight,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    color: HomeColors.scrollThumb,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
