import 'package:flutter/material.dart';
import 'package:lang/features/home/sample/home_sample.dart';
import 'package:lang/theme/home_palette.dart';
import 'package:lang/theme/home_text.dart';
import 'package:lang/l10n/app_localizations.dart';

class RecentPanel extends StatelessWidget {
  const RecentPanel({
    super.key,
    required this.sample,
    this.width = 1074,
    this.onContinue,
  });

  final HomeSample sample;
  final double width;
  final ValueChanged<RecentSet>? onContinue;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(localizations.recent, style: HomeText.of(context).title),
        const SizedBox(height: 16),
        _RecentStrip(
          sets: sample.recent,
          width: width,
          onContinue: onContinue,
        ),
      ],
    );
  }
}

class _RecentStrip extends StatefulWidget {
  const _RecentStrip({
    required this.sets,
    required this.width,
    this.onContinue,
  });

  final List<RecentSet> sets;
  final double width;
  final ValueChanged<RecentSet>? onContinue;

  @override
  State<_RecentStrip> createState() => _RecentStripState();
}

class _RecentStripState extends State<_RecentStrip> {
  static const cardWidth = 322.0;
  static const cardGap = 23.0;

  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (mounted) {
      setState(() {});
    }
  }

  bool get _atStart => !_controller.hasClients || _controller.offset <= 0.5;

  bool get _atEnd =>
      _controller.hasClients &&
      _controller.offset >= _controller.position.maxScrollExtent - 0.5;

  void _move(double delta) {
    if (!_controller.hasClients) {
      return;
    }
    final target = (_controller.offset + delta).clamp(
      0.0,
      _controller.position.maxScrollExtent,
    );
    _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: 206,
      child: Stack(
        children: [
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context)
                .copyWith(scrollbars: false),
            child: SingleChildScrollView(
              key: const Key('recent-clip'),
              controller: _controller,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var index = 0; index < widget.sets.length; index++) ...[
                    if (index > 0) const SizedBox(width: cardGap),
                    _RecentCard(
                      set: widget.sets[index],
                      index: index,
                      onContinue: widget.onContinue,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (!_atStart)
            Positioned(
              left: 16,
              top: 68,
              child: _StepButton(
                icon: Icons.chevron_left,
                onPressed: () => _move(-(cardWidth + cardGap)),
              ),
            ),
          if (!_atEnd)
            Positioned(
              right: 16,
              top: 68,
              child: _StepButton(
                icon: Icons.chevron_right,
                onPressed: () => _move(cardWidth + cardGap),
              ),
            ),
        ],
      ),
    );
  }
}

class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.set, required this.index, this.onContinue});

  final RecentSet set;
  final int index;
  final ValueChanged<RecentSet>? onContinue;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return SizedBox(
      key: Key('recent-card-$index'),
      width: _RecentStripState.cardWidth,
      height: 188,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: HomePalette.of(context).border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                set.name,
                style: HomeText.of(context).subtitle.copyWith(color: HomePalette.of(context).ink),
              ),
              const SizedBox(height: 16),
              _ThinBar(
                key: Key('recent-bar-$index'),
                percent: set.percent,
                color: set.color,
              ),
              const SizedBox(height: 8),
              Text(
                localizations.progressComplete(set.percent),
                style: HomeText.of(context).caption,
              ),
              const Spacer(),
              _ContinueButton(
                label: localizations.continueAction,
                onPressed: onContinue == null ? null : () => onContinue!(set),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThinBar extends StatelessWidget {
  const _ThinBar({super.key, required this.percent, required this.color});

  final int percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5,
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

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(30)),
        gradient: LinearGradient(
          colors: [
            HomePalette.of(context).continueStart,
            HomePalette.of(context).continueEnd,
          ],
        ),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: HomePalette.of(context).onAccent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          minimumSize: const Size(0, 40),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: HomeText.of(context).caption.copyWith(
            color: HomePalette.of(context).onAccent,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HomePalette.of(context).chevronFill,
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: const Color(0xFF667085)),
      ),
    );
  }
}
