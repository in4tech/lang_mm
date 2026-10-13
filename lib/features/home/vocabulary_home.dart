import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lang/features/home/home_from_library.dart';
import 'package:lang/features/home/sample/home_sample.dart';
import 'package:lang/features/home/widgets/home_header.dart';
import 'package:lang/features/word_editor/word_editor.dart';
import 'package:lang/features/home/widgets/suggestion_columns.dart';
import 'package:lang/library/vocabulary_library.dart';
import 'package:lang/features/home/widgets/home_sidebar.dart';
import 'package:lang/features/home/widgets/recent_panel.dart';
import 'package:lang/features/home/widgets/statistics_panel.dart';
import 'package:lang/features/home/widgets/today_panel.dart';
import 'package:lang/theme/home_palette.dart';
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
    final colors = HomePalette.of(context);
    return _HomeFrame(
      sample: widget.sample,
      library: widget.library,
      forceOriginal: _forceOriginal,
      debugToggle: FloatingActionButton.extended(
        key: const Key('debug-home-toggle'),
        heroTag: 'debug-home-toggle',
        backgroundColor: colors.newVocab,
        foregroundColor: colors.onAccent,
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
  bool _overlayOpen = false;
  bool _editing = false;

  void _openEditor() => setState(() => _editing = true);

  void _closeEditor() => setState(() => _editing = false);

  Widget _center({required bool narrow, required HomeSample? dashboard}) {
    if (_editing) {
      return WordEditor(onClose: _closeEditor);
    }
    if (dashboard == null) {
      return SuggestionColumns(narrow: narrow);
    }
    return _Dashboard(sample: dashboard, narrow: narrow);
  }

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
    final colors = HomePalette.of(context);
    return Scaffold(
      backgroundColor: colors.page,
      floatingActionButton: debugToggle,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : VocabularyHome.designWidth;
          final wide =
              !constraints.maxWidth.isFinite ||
              width >= VocabularyHome.designWidth;
          if (wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HomeHeader(
                  onMenuPressed: () {
                    setState(() => _collapsed = !_collapsed);
                  },
                  onNewVocab: _openEditor,
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Scrollbar(
                          child: SingleChildScrollView(
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: SizedBox(
                                key: const Key('home-canvas'),
                                width:
                                    VocabularyHome.designWidth -
                                    HomeSidebar.width,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    32,
                                    20,
                                    46,
                                    48,
                                  ),
                                  child: _center(
                                    narrow: false,
                                    dashboard: dashboard,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: ColoredBox(
                          color: colors.page,
                          child: SingleChildScrollView(
                            child: HomeSidebar(
                              sample: sidebarSample,
                              collapsed: _collapsed,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: HomeHeader(
                  narrow: true,
                  onMenuPressed: () {
                    setState(() => _overlayOpen = !_overlayOpen);
                  },
                  onNewVocab: _openEditor,
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Scrollbar(
                      child: SingleChildScrollView(
                        child: SizedBox(
                          key: const Key('home-canvas'),
                          width: width,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
                            child: _center(narrow: true, dashboard: dashboard),
                          ),
                        ),
                      ),
                    ),
                    if (_overlayOpen) ...[
                      Positioned.fill(
                        child: GestureDetector(
                          key: const Key('sidebar-barrier'),
                          onTap: () => setState(() => _overlayOpen = false),
                          behavior: HitTestBehavior.opaque,
                          child: const ColoredBox(color: Color(0x66000000)),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: ColoredBox(
                          color: colors.page,
                          child: SingleChildScrollView(
                            child: HomeSidebar(
                              sample: sidebarSample,
                              collapsed: false,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
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
  const _Dashboard({required this.sample, this.narrow = false});

  final HomeSample sample;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final heading = Text(
      localizations.statisticsHeading,
      style: HomeText.of(context).title,
    );
    if (narrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          heading,
          const SizedBox(height: 16),
          StatisticsPanel(sample: sample),
          const SizedBox(height: 16),
          TodayPanel(sample: sample, width: double.infinity),
          const SizedBox(height: 28),
          RecentPanel(sample: sample, width: double.infinity),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading,
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
