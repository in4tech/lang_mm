import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lang/features/home/home_from_library.dart';
import 'package:lang/features/home/sample/home_sample.dart';
import 'package:lang/features/home/widgets/home_header.dart';
import 'package:lang/features/home/widgets/library_page.dart';
import 'package:lang/features/word_editor/word_editor.dart';
import 'package:lang/features/home/widgets/suggestion_columns.dart';
import 'package:lang/library/study_progress.dart';
import 'package:lang/library/vocabulary_library.dart';
import 'package:lang/library/vocabulary_library_store.dart';
import 'package:lang/library/vocabulary_set.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lang/features/home/widgets/home_sidebar.dart';
import 'package:lang/features/home/widgets/set_study_page.dart';
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
    this.setStore,
    this.studyProgress,
  });

  final HomeSample? sample;
  final VocabularyLibrary library;
  final VocabularySetStore? setStore;
  final StudyProgressStore? studyProgress;

  static const designWidth = 1440.0;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return _HomeFrame(
        sample: sample,
        library: library,
        setStore: setStore,
        studyProgress: studyProgress,
      );
    }
    return _DebugHomeSwitch(
      sample: sample,
      library: library,
      setStore: setStore,
      studyProgress: studyProgress,
    );
  }
}

class _DebugHomeSwitch extends StatefulWidget {
  const _DebugHomeSwitch({
    required this.sample,
    required this.library,
    required this.setStore,
    required this.studyProgress,
  });

  final HomeSample? sample;
  final VocabularyLibrary library;
  final VocabularySetStore? setStore;
  final StudyProgressStore? studyProgress;

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
      setStore: widget.setStore,
      studyProgress: widget.studyProgress,
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
    required this.setStore,
    this.studyProgress,
    this.forceOriginal,
    this.debugToggle,
  });

  final HomeSample? sample;
  final VocabularyLibrary library;
  final VocabularySetStore? setStore;
  final StudyProgressStore? studyProgress;
  final bool? forceOriginal;
  final Widget? debugToggle;

  @override
  State<_HomeFrame> createState() => _HomeFrameState();
}

class _HomeFrameState extends State<_HomeFrame> {
  bool _collapsed = false;
  bool _overlayOpen = false;
  bool _editing = false;
  bool _studying = false;
  bool _studyReturn = false;
  bool _libraryOpen = false;
  String? _libraryFolder;
  int _editorSession = 0;
  VocabularySet? _openSet;
  List<StudyCue>? _cues;
  late VocabularyLibrary _library;
  String? _createdEditorFolderId;
  StudyHomeData _study = StudyHomeData.empty;
  var _allSets = true;

  @override
  void initState() {
    super.initState();
    _library = widget.library;
    _loadStudy();
  }

  void _openEditor() {
    setState(() {
      _editing = true;
      _studying = false;
      _studyReturn = false;
      _openSet = null;
      _editorSession += 1;
    });
  }

  void _editOpenSet() {
    setState(() {
      _editing = true;
      _studying = false;
      _studyReturn = true;
      _editorSession += 1;
    });
  }

  Future<void> _promptNewFolder() async {
    final name = await showNewFolderDialog(context);
    final trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty || !mounted) {
      return;
    }
    if (_library.folders.any((folder) => folder.name == trimmed)) {
      return;
    }
    final store = widget.setStore;
    String? id;
    if (store != null) {
      try {
        id = await store.createFolder(trimmed);
      } catch (_) {
        return;
      }
      if (!mounted) {
        return;
      }
    }
    final next = _library.addFolder(trimmed, id: id);
    final preferences = await SharedPreferences.getInstance();
    await SharedPreferencesVocabularyLibraryStore(preferences).write(next);
    if (!mounted) {
      return;
    }
    setState(() => _library = next);
  }

  void _openSavedSet(String folderName, int setIndex) {
    VocabularySet? stored;
    for (final folder in _library.folders) {
      if (folder.name == folderName) {
        stored = folder.contentAt(setIndex);
        break;
      }
    }
    final visible = _sidebarFolders().where(
      (folder) => folder.name == folderName,
    );
    final name = visible.isEmpty || setIndex >= visible.first.sets.length
        ? stored?.title ?? ''
        : visible.first.sets[setIndex];
    setState(() {
      _studying = true;
      _editing = false;
      _studyReturn = false;
      _cues = null;
      _openSet =
          stored ??
          VocabularySet(
            title: name,
            description: '',
            words: const <VocabularyWord>[],
          );
    });
  }

  List<VocabFolder> _sidebarFolders() {
    final dashboard = _resolveHomeDashboard(
      sample: widget.sample,
      library: _library,
      forceOriginal: widget.forceOriginal,
      progress: _study.progress,
      agenda: _study.agenda,
      allSets: _allSets,
    );
    return (dashboard ?? homeSampleFromLibrary(_library)).folders;
  }

  void _closeEditor() {
    setState(() {
      _editing = false;
      if (_studyReturn) {
        _studying = true;
      }
    });
  }

  Future<void> _loadStudy() async {
    final store = widget.studyProgress;
    if (store == null) {
      return;
    }
    try {
      final data = await store.loadHome(studySetsIn(_library));
      if (!mounted) {
        return;
      }
      setState(() => _study = data);
    } catch (_) {}
  }

  void _showHome() {
    setState(() {
      _libraryOpen = false;
      _editing = false;
      _studying = false;
      _studyReturn = false;
      _libraryFolder = null;
      _cues = null;
    });
    _loadStudy();
  }

  void _openPractice() {
    final cues = cuesForAgenda(_library, _study.agenda);
    if (cues.isEmpty) {
      return;
    }
    final set = setWithId(_library, cues.first.setId ?? '');
    if (set == null) {
      return;
    }
    setState(() {
      _studying = true;
      _editing = false;
      _studyReturn = false;
      _openSet = set;
      _cues = cues;
    });
  }

  void _continueRecent(RecentSet recent) {
    final id = recent.id;
    if (id == null) {
      return;
    }
    final set = setWithId(_library, id);
    if (set == null) {
      return;
    }
    setState(() {
      _studying = true;
      _editing = false;
      _studyReturn = false;
      _openSet = set;
      _cues = null;
    });
  }

  void _showLibrary() {
    setState(() {
      _libraryOpen = true;
      _editing = false;
      _studying = false;
      _studyReturn = false;
    });
  }

  List<VocabularyFolder> _libraryFolders(HomeSample? dashboard) {
    if (widget.forceOriginal == true) {
      return <VocabularyFolder>[
        for (final folder in HomeSample.current.folders)
          VocabularyFolder(name: folder.name, sets: folder.sets),
      ];
    }
    if (_library.folders.isNotEmpty) {
      return _library.folders;
    }
    if (dashboard == null) {
      return const <VocabularyFolder>[];
    }
    return <VocabularyFolder>[
      for (final folder in dashboard.folders)
        VocabularyFolder(name: folder.name, sets: folder.sets),
    ];
  }

  Future<String> _editorFolderId(VocabularySetStore store) async {
    final label = AppLocalizations.of(context).vocabularySet;
    final target = _library.editorFolder ?? label;
    for (final folder in _library.folders) {
      final id = folder.id;
      if (folder.name == target && id != null && id.isNotEmpty) {
        return id;
      }
    }
    final pending = _createdEditorFolderId;
    if (pending != null) {
      return pending;
    }
    final created = await store.createFolder(target, editor: true);
    _createdEditorFolderId = created;
    return created;
  }

  Future<void> _persistSavedSet(VocabularySet set) async {
    final next = _library.addSavedSet(
      name: set.title,
      folderLabel: AppLocalizations.of(context).vocabularySet,
      content: set,
      folderId: set.folderId,
    );
    final preferences = await SharedPreferences.getInstance();
    await SharedPreferencesVocabularyLibraryStore(preferences).write(next);
    _createdEditorFolderId = null;
    if (!mounted) {
      return;
    }
    setState(() => _library = next);
  }

  Widget _center({required bool narrow, required HomeSample? dashboard}) {
    final openSet = _openSet;
    if (_studying && openSet != null) {
      return SetStudyPage(
        set: openSet,
        narrow: narrow,
        onEdit: _editOpenSet,
        progress: widget.studyProgress,
        initialMarks: _study.progress[openSet.id]?.marks ?? const <int, StudyMark>{},
        cues: _cues,
      );
    }
    if (_editing) {
      final setStore = widget.setStore;
      return WordEditor(
        key: ValueKey(_editorSession),
        onClose: _closeEditor,
        initialSet: _openSet,
        setStore: setStore == null
            ? null
            : _LibrarySavingSetStore(
                inner: setStore,
                onSaved: _persistSavedSet,
                folderId: () => _editorFolderId(setStore),
              ),
      );
    }
    if (_libraryOpen) {
      return LibraryPage(
        folders: _libraryFolders(dashboard),
        narrow: narrow,
        openFolder: _libraryFolder,
        onOpenFolder: (name) => setState(() => _libraryFolder = name),
        onOpenSet: _openSavedSet,
      );
    }
    if (dashboard == null) {
      return SuggestionColumns(narrow: narrow);
    }
    return _Dashboard(
      sample: dashboard,
      narrow: narrow,
      onAllChanged: (allSets) => setState(() => _allSets = allSets),
      onPractice: _openPractice,
      onContinue: _continueRecent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sample = widget.sample;
    final library = _library;
    final forceOriginal = widget.forceOriginal;
    final debugToggle = widget.debugToggle;
    final dashboard = _resolveHomeDashboard(
      sample: sample,
      library: library,
      forceOriginal: forceOriginal,
      progress: _study.progress,
      agenda: _study.agenda,
      allSets: _allSets,
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
                  onNewFolder: _promptNewFolder,
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned(
                        left: HomeSidebar.width,
                        right: 0,
                        top: 0,
                        bottom: 0,
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
                              librarySelected: _libraryOpen,
                              onHome: _showHome,
                              onLibrary: _showLibrary,
                              onOpenSet: _openSavedSet,
                              onAddFolder: _promptNewFolder,
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
                  onNewFolder: _promptNewFolder,
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
                              librarySelected: _libraryOpen,
                              onHome: _showHome,
                              onLibrary: _showLibrary,
                              onOpenSet: _openSavedSet,
                              onAddFolder: _promptNewFolder,
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
  Map<String, StudySetProgress> progress = const <String, StudySetProgress>{},
  List<StudyWordRef> agenda = const <StudyWordRef>[],
  bool allSets = true,
}) {
  if (forceOriginal == true) {
    return HomeSample.current;
  }
  if (forceOriginal == false) {
    return null;
  }
  return sample ??
      (library.folders.isEmpty
          ? null
          : homeSampleFromLibrary(
              library,
              progress: progress,
              agenda: agenda,
              allSets: allSets,
            ));
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({
    required this.sample,
    this.narrow = false,
    this.onAllChanged,
    this.onPractice,
    this.onContinue,
  });

  final HomeSample sample;
  final bool narrow;
  final ValueChanged<bool>? onAllChanged;
  final VoidCallback? onPractice;
  final ValueChanged<RecentSet>? onContinue;

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
          StatisticsPanel(sample: sample, onAllChanged: onAllChanged),
          const SizedBox(height: 16),
          TodayPanel(
            sample: sample,
            width: double.infinity,
            onPractice: onPractice,
          ),
          const SizedBox(height: 28),
          RecentPanel(
            sample: sample,
            width: double.infinity,
            onContinue: onContinue,
          ),
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
            Expanded(
              child: StatisticsPanel(sample: sample, onAllChanged: onAllChanged),
            ),
            const SizedBox(width: 16),
            TodayPanel(sample: sample, onPractice: onPractice),
          ],
        ),
        const SizedBox(height: 28),
        RecentPanel(sample: sample, onContinue: onContinue),
      ],
    );
  }
}

class _LibrarySavingSetStore implements VocabularySetStore {
  _LibrarySavingSetStore({
    required this.inner,
    required this.onSaved,
    required this.folderId,
  });

  final VocabularySetStore inner;
  final Future<void> Function(VocabularySet set) onSaved;
  final Future<String> Function() folderId;

  @override
  Future<String> createFolder(String name, {bool editor = false}) {
    return inner.createFolder(name, editor: editor);
  }

  @override
  Future<void> save(VocabularySet set) async {
    final id = await folderId();
    final stored = VocabularySet(
      title: set.title,
      description: set.description,
      words: set.words,
      folderId: id,
    );
    await inner.save(stored);
    await onSaved(stored);
  }
}
