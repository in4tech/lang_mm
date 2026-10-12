import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lang/features/home/home_from_library.dart';
import 'package:lang/features/home/sample/home_sample.dart';
import 'package:lang/features/home/widgets/home_header.dart';
import 'package:lang/features/home/widgets/suggestion_columns.dart';
import 'package:lang/library/vocabulary_library.dart';
import 'package:lang/features/home/widgets/home_sidebar.dart';
import 'package:lang/features/home/widgets/recent_panel.dart';
import 'package:lang/features/home/widgets/statistics_panel.dart';
import 'package:lang/features/home/widgets/today_panel.dart';
import 'package:lang/theme/home_colors.dart';
import 'package:lang/theme/home_text.dart';
import 'package:lang/l10n/app_localizations.dart';

class VocabularyHome extends StatelessWidget {
  const VocabularyHome({
    super.key,
    this.sample,
    this.library = VocabularyLibrary.empty,
  });

  final HomeSample? sample;
  final VocabularyLibrary library;

  static const designWidth = 1440.0;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return _HomeFrame(sample: sample, library: library);
    }
    return _DebugHomeSwitch(sample: sample, library: library);
  }
}

class _DebugHomeSwitch extends StatefulWidget {
  const _DebugHomeSwitch({required this.sample, required this.library});

  final HomeSample? sample;
  final VocabularyLibrary library;

  @override
  State<_DebugHomeSwitch> createState() => _DebugHomeSwitchState();
}

class _DebugHomeSwitchState extends State<_DebugHomeSwitch> {
  bool? _forceOriginal;

  bool get _showingOriginal => _forceOriginal ?? widget.sample != null;

  @override
  Widget build(BuildContext context) {
    return _HomeFrame(
      sample: widget.sample,
      library: widget.library,
      forceOriginal: _forceOriginal,
      debugToggle: FloatingActionButton.extended(
        key: const Key('debug-home-toggle'),
        heroTag: 'debug-home-toggle',
        backgroundColor: HomeColors.newVocab,
        foregroundColor: Colors.white,
        onPressed: () {
          setState(() => _forceOriginal = !_showingOriginal);
        },
        icon: const Icon(Icons.swap_horiz),
        label: Text(_showingOriginal ? 'Empty' : 'Sample'),
      ),
    );
  }
}

class _HomeFrame extends StatefulWidget {
  const _HomeFrame({
    required this.sample,
    required this.library,
    this.forceOriginal,
    this.debugToggle,
  });

  final HomeSample? sample;
  final VocabularyLibrary library;
  final bool? forceOriginal;
  final Widget? debugToggle;

  @override
  State<_HomeFrame> createState() => _HomeFrameState();
}

class _HomeFrameState extends State<_HomeFrame> {
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    final sample = widget.sample;
    final library = widget.library;
    final forceOriginal = widget.forceOriginal;
    final debugToggle = widget.debugToggle;
    final dashboard = _resolveHomeDashboard(
      sample: sample,
      library: library,
      forceOriginal: forceOriginal,
    );
    final sidebarSample = dashboard ?? homeSampleFromLibrary(library);
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: debugToggle,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : VocabularyHome.designWidth;
          return Scrollbar(
            child: SingleChildScrollView(
              child: SizedBox(
                width: width,
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: VocabularyHome.designWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HomeHeader(
                          onMenuPressed: () {
                            setState(() => _collapsed = !_collapsed);
                          },
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HomeSidebar(
                              sample: sidebarSample,
                              collapsed: _collapsed,
                            ),
                            AnimatedContainer(
                              duration: HomeSidebar.animationDuration,
                              curve: HomeSidebar.animationCurve,
                              width:
                                  VocabularyHome.designWidth -
                                  (_collapsed
                                      ? HomeSidebar.collapsedWidth
                                      : HomeSidebar.width),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  32,
                                  20,
                                  46,
                                  48,
                                ),
                                child: dashboard == null
                                    ? const SuggestionColumns()
                                    : _Dashboard(sample: dashboard),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

HomeSample? _resolveHomeDashboard({
  required HomeSample? sample,
  required VocabularyLibrary library,
  bool? forceOriginal,
}) {
  if (forceOriginal == true) {
    return HomeSample.current;
  }
  if (forceOriginal == false) {
    return null;
  }
  return sample ??
      (library.folders.isEmpty ? null : homeSampleFromLibrary(library));
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.sample});

  final HomeSample sample;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(localizations.statisticsHeading, style: HomeText.title),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: StatisticsPanel(sample: sample)),
            const SizedBox(width: 16),
            TodayPanel(sample: sample),
          ],
        ),
        const SizedBox(height: 28),
        RecentPanel(sample: sample),
      ],
    );
  }
}
