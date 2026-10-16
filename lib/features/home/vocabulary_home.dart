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
    return _HomeFrame(
      sample: sample,
      library: library,
      setStore: setStore,
      studyProgress: studyProgress,
    );
  }
}

class _HomeFrame extends StatefulWidget {
  const _HomeFrame({
    required this.sample,
    required this.library,
    required this.setStore,
    this.studyProgress,
  });

  final HomeSample? sample;
  final VocabularyLibrary library;
  final VocabularySetStore? setStore;
  final StudyProgressStore? studyProgress;

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
  bool _homePractice = false;
  bool _practicingSession = false;
  String? _focusFolder;
  int? _focusIndex;
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
      _focusFolder = null;
      _focusIndex = null;
      _practicingSession = false;
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
      _homePractice = false;
      _focusFolder = folderName;
      _focusIndex = setIndex;
      _openSet =
          stored ??
          VocabularySet(
            title: name,
            description: '',
            words: const <VocabularyWord>[],
          );
    });
  }

  void _focusOn(VocabularySet set) {
    for (final folder in _library.folders) {
      for (var index = 0; index < folder.sets.length; index++) {
        final content = folder.contentAt(index);
        final sameId = set.id != null && content?.id == set.id;
        if (sameId || folder.sets[index] == set.title) {
          _focusFolder = folder.name;
          _focusIndex = index;
          return;
        }
      }
    }
  }

  List<VocabFolder> _sidebarFolders() {
    final dashboard = _resolveHomeDashboard(
      sample: widget.sample,
      library: _library,
      progress: _study.progress,
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
      _homePractice = false;
      _focusFolder = null;
      _focusIndex = null;
      _practicingSession = false;
    });
    _loadStudy();
  }

  void _showPracticeAlert() {
    final localizations = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          content: Text(localizations.studyPracticeAlert),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(localizations.studyPracticeOk),
            ),
          ],
        );
      },
    );
  }

  List<StudyWordRef> _queue({String? setId}) {
    final now = DateTime.now();
    return choosePracticeQueue(
      studyInputs(_library, _study.progress, now),
      now,
      setId: setId,
    );
  }

  void _openPractice() {
    final cues = cuesForAgenda(_library, _queue());
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
      _homePractice = true;
      _focusOn(set);
    });
  }

  void _openStatisticsSet(String id) {
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
      _homePractice = false;
      _focusOn(set);
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
    final cues = cuesForAgenda(_library, _queue(setId: id));
    setState(() {
      _studying = true;
      _editing = false;
      _studyReturn = false;
      _openSet = set;
      _cues = cues.isEmpty ? null : cues;
      _homePractice = false;
      _focusOn(set);
    });
  }

  void _showLibrary() {
    setState(() {
      _libraryOpen = true;
      _editing = false;
      _studying = false;
      _studyReturn = false;
      _focusFolder = null;
      _focusIndex = null;
      _practicingSession = false;
    });
  }

  List<VocabularyFolder> _libraryFolders(HomeSample? dashboard) {
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

  VocabularySet? _pendingWords;
  var _writingWords = false;

  Future<void> _saveWordStars(VocabularySet set) async {
    _pendingWords = set;
    if (mounted) {
      setState(() {
        _openSet = set;
        _library = _library.replaceSet(set);
      });
    }
    if (_writingWords) {
      return;
    }
    final store = widget.setStore;
    if (store == null) {
      _pendingWords = null;
      return;
    }
    _writingWords = true;
    try {
      while (_pendingWords != null) {
        final next = _pendingWords!;
        _pendingWords = null;
        try {
          await store.updateWords(next);
        } catch (_) {}
      }
    } finally {
      _writingWords = false;
    }
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
        statisticsLibrary: _homePractice ? _library : null,
        statisticsProgress: _study.progress,
        statisticsAll: _allSets,
        onPracticing: (active) {
          if (mounted) {
            setState(() => _practicingSession = active);
          }
        },
        onWordsChanged: _saveWordStars,
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
      onOpenStatisticsSet: dashboard.statisticsSetId == null
          ? null
          : () => _openStatisticsSet(dashboard.statisticsSetId!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sample = widget.sample;
    final library = _library;
    final dashboard = _resolveHomeDashboard(
      sample: sample,
      library: library,
      progress: _study.progress,
      allSets: _allSets,
    );
    final sidebarSample = dashboard ?? homeSampleFromLibrary(library);
    final colors = HomePalette.of(context);
    return Scaffold(
      backgroundColor: colors.page,
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
                              focusedFolder: _focusFolder,
                              focusedSetIndex: _focusIndex,
                              practiceLocked: _practicingSession,
                              onPracticeLocked: _showPracticeAlert,
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
                              focusedFolder: _focusFolder,
                              focusedSetIndex: _focusIndex,
                              practiceLocked: _practicingSession,
                              onPracticeLocked: _showPracticeAlert,
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
  Map<String, StudySetProgress> progress = const <String, StudySetProgress>{},
  bool allSets = true,
}) {
  return sample ??
      (library.folders.isEmpty
          ? null
          : homeSampleFromLibrary(
              library,
              progress: progress,
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
    this.onOpenStatisticsSet,
  });

  final HomeSample sample;
  final bool narrow;
  final ValueChanged<bool>? onAllChanged;
  final VoidCallback? onPractice;
  final ValueChanged<RecentSet>? onContinue;
  final VoidCallback? onOpenStatisticsSet;

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
          SizedBox(
            height: TodayPanel.height,
            child: StatisticsPanel(
              sample: sample,
              onAllChanged: onAllChanged,
              onOpenSet: onOpenStatisticsSet,
            ),
          ),
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
              child: SizedBox(
                height: TodayPanel.height,
                child: StatisticsPanel(
                  sample: sample,
                  onAllChanged: onAllChanged,
                  onOpenSet: onOpenStatisticsSet,
                ),
              ),
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

  @override
  Future<void> updateWords(VocabularySet set) {
    return inner.updateWords(set);
  }
}
