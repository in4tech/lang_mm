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
  var _endPractice = 0;
  String? _focusFolder;
  int? _focusIndex;
  int? _editWordIndex;
  late VocabularyLibrary _library;
  String? _createdEditorFolderId;
  String? _addSetsFolder;
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
      _addSetsFolder = null;
      _editing = true;
      _studying = false;
      _studyReturn = false;
      _openSet = null;
      _editWordIndex = null;
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
      _editWordIndex = null;
      _editorSession += 1;
    });
  }

  void _editWord(int index) {
    setState(() {
      _editing = true;
      _studying = false;
      _studyReturn = true;
      _editWordIndex = index;
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
        id = await store.createFolder(trimmed, pinned: false);
      } catch (_) {
        return;
      }
      if (!mounted) {
        return;
      }
    }
    final next = _library.addFolder(trimmed, id: id);
    await _storeLibrary(next);
    if (!mounted) {
      return;
    }
    setState(() {
      _library = next;
      _libraryOpen = true;
      _libraryFolder = trimmed;
      _editing = false;
      _studying = false;
      _studyReturn = false;
      _cues = null;
      _homePractice = false;
      _focusFolder = null;
      _focusIndex = null;
      _practicingSession = false;
    });
  }

  Future<void> _storeLibrary(VocabularyLibrary next) async {
    final preferences = await SharedPreferences.getInstance();
    await SharedPreferencesVocabularyLibraryStore(preferences).write(next);
  }

  Future<void> _renameLibraryFolder(String name) async {
    final nextName = await showRenameFolderDialog(context, name);
    final trimmed = nextName?.trim() ?? '';
    if (trimmed.isEmpty || trimmed == name || !mounted) {
      return;
    }
    if (_library.folders.any((folder) => folder.name == trimmed)) {
      return;
    }
    final current = _folderNamed(name);
    final id = current?.id;
    final store = widget.setStore;
    if (store != null && id != null && id.isNotEmpty) {
      try {
        await store.renameFolder(id, trimmed);
      } catch (_) {
        return;
      }
      if (!mounted) {
        return;
      }
    }
    final next = _library.renameFolder(name, trimmed);
    await _storeLibrary(next);
    if (!mounted) {
      return;
    }
    setState(() {
      _library = next;
      if (_libraryFolder == name) {
        _libraryFolder = trimmed;
      }
      if (_focusFolder == name) {
        _focusFolder = trimmed;
      }
    });
  }

  Future<void> _deleteLibraryFolder(String name) async {
    final current = _folderNamed(name);
    final id = current?.id;
    final store = widget.setStore;
    if (store != null && id != null && id.isNotEmpty) {
      try {
        await store.deleteFolder(id);
      } catch (_) {}
      if (!mounted) {
        return;
      }
    }
    if (id != null && id.isNotEmpty) {
      final preferences = await SharedPreferences.getInstance();
      await SharedPreferencesVocabularyLibraryStore(
        preferences,
      ).rememberRemovedFolder(id);
      if (!mounted) {
        return;
      }
    }
    final next = _library.removeFolder(name);
    await _storeLibrary(next);
    if (!mounted) {
      return;
    }
    setState(() {
      _library = next;
      if (_libraryFolder == name) {
        _libraryFolder = null;
      }
      if (_focusFolder == name) {
        _focusFolder = null;
        _focusIndex = null;
      }
    });
  }

  Future<void> _pinLibraryFolder(String name, bool pinned) async {
    final current = _folderNamed(name);
    if (current == null || current.pinned == pinned) {
      return;
    }
    final next = _library.setPinned(name, pinned);
    setState(() {
      _library = next;
      if (pinned) {
        _focusFolder = name;
        _focusIndex = null;
      } else if (_focusFolder == name) {
        _focusFolder = null;
        _focusIndex = null;
      }
    });
    await _storeLibrary(next);
    if (!mounted) {
      return;
    }
    final id = current.id;
    final store = widget.setStore;
    if (store == null || id == null || id.isEmpty) {
      return;
    }
    try {
      await store.setFolderPinned(id, pinned);
    } catch (_) {}
  }

  List<VocabularySet> _createdSets() {
    final sets = <VocabularySet>[];
    for (final folder in _library.folders) {
      for (var index = 0; index < folder.sets.length; index++) {
        final content = folder.contentAt(index);
        sets.add(
          content ??
              VocabularySet(
                title: folder.sets[index],
                description: '',
                words: const <VocabularyWord>[],
              ),
        );
      }
    }
    return sets;
  }

  VocabularyFolder? _folderNamed(String name) {
    for (final folder in _library.folders) {
      if (folder.name == name) {
        return folder;
      }
    }
    return null;
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
      _addSetsFolder = null;
      _editing = false;
      _editWordIndex = null;
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

  void _showHome({bool openSidebar = false}) {
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
      if (openSidebar) {
        _collapsed = false;
      }
    });
    _loadStudy();
  }

  void _showPracticeAlert(VoidCallback? action) {
    final localizations = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          content: Text(localizations.studyPracticeAlert),
          actions: [
            TextButton(
              key: const Key('practice-alert-stay'),
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(localizations.studyPracticeStay),
            ),
            TextButton(
              key: const Key('practice-alert-leave'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                setState(() {
                  _practicingSession = false;
                  _endPractice += 1;
                });
                action?.call();
              },
              child: Text(localizations.studyPracticeLeave),
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
      _focusFolder = null;
      _focusIndex = null;
      _collapsed = true;
      _overlayOpen = false;
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
      _libraryFolder = null;
      _editing = false;
      _studying = false;
      _studyReturn = false;
      _cues = null;
      _homePractice = false;
      _focusFolder = null;
      _focusIndex = null;
      _practicingSession = false;
      _overlayOpen = false;
    });
  }

  void _openLibraryFolder(String name) {
    setState(() {
      _libraryOpen = true;
      _libraryFolder = name;
      _editing = false;
      _studying = false;
      _studyReturn = false;
      _cues = null;
      _homePractice = false;
      _focusFolder = name;
      _focusIndex = null;
      _practicingSession = false;
      _overlayOpen = false;
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
    final adding = _addSetsFolder;
    if (adding != null) {
      for (final folder in _library.folders) {
        final id = folder.id;
        if (folder.name == adding && id != null && id.isNotEmpty) {
          return id;
        }
      }
    }
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

  void _applyEditedWords(VocabularySet set) {
    final next = set.id == null ? _library : _library.replaceSet(set);
    setState(() {
      _library = next;
      _openSet = set;
    });
    _storeLibrary(next);
  }

  Future<void> _addSetToLibraryFolder(String folderName, VocabularySet set) async {
    final next = _library.addSetToFolder(folderName, set);
    await _storeLibrary(next);
    if (!mounted) {
      return;
    }
    setState(() => _library = next);
  }

  Future<void> _removeSetFromLibraryFolder(
    String folderName,
    int setIndex,
  ) async {
    final preserveIn =
        _library.editorFolder ?? AppLocalizations.of(context).vocabularySet;
    final next = _library.removeSetFromFolder(
      folderName,
      setIndex,
      preserveIn: preserveIn,
    );
    await _storeLibrary(next);
    if (!mounted) {
      return;
    }
    setState(() => _library = next);
  }

  void _createSetInFolder(String folderName) {
    setState(() {
      _addSetsFolder = folderName;
      _editing = true;
      _studying = false;
      _studyReturn = false;
      _openSet = null;
      _editWordIndex = null;
      _editorSession += 1;
    });
  }

  Future<void> _persistSavedSet(VocabularySet set) async {
    final adding = _addSetsFolder;
    final next = adding == null
        ? _library.addSavedSet(
            name: set.title,
            folderLabel: AppLocalizations.of(context).vocabularySet,
            content: set,
            folderId: set.folderId,
          )
        : _library.addSetToFolder(adding, set);
    _addSetsFolder = null;
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
        onEditWord: _editWord,
        progress: widget.studyProgress,
        initialMarks: _study.progress[openSet.id]?.marks ?? const <int, StudyMark>{},
        cues: _cues,
        statisticsLibrary: _homePractice ? _library : null,
        statisticsProgress: _study.progress,
        statisticsAll: _allSets,
        endPractice: _endPractice,
        onPracticing: (active) {
          if (!mounted) {
            return;
          }
          if (!active && _homePractice) {
            _showHome(openSidebar: true);
            return;
          }
          setState(() {
            _practicingSession = active;
            if (active) {
              _collapsed = true;
              _overlayOpen = false;
            }
          });
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
        existingSets: _createdSets(),
        focusWordIndex: _editWordIndex,
        onWordsUpdated: _applyEditedWords,
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
        onOpenFolder: (name) => setState(() {
          _libraryFolder = name;
          _focusFolder = name;
          _focusIndex = null;
        }),
        onRenameFolder: _renameLibraryFolder,
        onDeleteFolder: _deleteLibraryFolder,
        onPinFolder: _pinLibraryFolder,
        onAddSet: _addSetToLibraryFolder,
        onCreateSet: _createSetInFolder,
        onRemoveSet: _removeSetFromLibraryFolder,
        onOpenSet: _openSavedSet,
      );
    }
    if (dashboard == null) {
      return SuggestionColumns(narrow: narrow);
    }
    final scopeAll = dashboard.statisticsAll;
    final scopeId = dashboard.statisticsSetId;
    return _Dashboard(
      sample: dashboard,
      narrow: narrow,
      learnedWords: statisticsWords(
        library: _library,
        progress: _study.progress,
        learned: true,
        allSets: scopeAll,
        setId: scopeId,
      ),
      notLearnedWords: statisticsWords(
        library: _library,
        progress: _study.progress,
        learned: false,
        allSets: scopeAll,
        setId: scopeId,
      ),
      wordsByLevel: <int, List<VocabularyWord>>{
        for (var level = 1; level <= 6; level++)
          level: statisticsWordsAtLevel(
            library: _library,
            progress: _study.progress,
            level: level,
            allSets: scopeAll,
            setId: scopeId,
          ),
      },
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
                        child: _editing || _studying
                            ? Align(
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
                              )
                            : Scrollbar(
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
                              librarySelected:
                                  _libraryOpen && _libraryFolder == null,
                              focusedFolder: _focusFolder,
                              focusedSetIndex: _focusIndex,
                              practiceLocked: _practicingSession,
                              onPracticeLocked: _showPracticeAlert,
                              onHome: _showHome,
                              onLibrary: _showLibrary,
                              onOpenSet: _openSavedSet,
                              onOpenFolder: _openLibraryFolder,
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
                    if (_editing || _studying)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
                        child: SizedBox(
                          key: const Key('home-canvas'),
                          width: width,
                          child: _center(narrow: true, dashboard: dashboard),
                        ),
                      )
                    else
                      Scrollbar(
                        child: SingleChildScrollView(
                          child: SizedBox(
                            key: const Key('home-canvas'),
                            width: width,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                20,
                                16,
                                48,
                              ),
                              child: _center(
                                narrow: true,
                                dashboard: dashboard,
                              ),
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
                              librarySelected:
                                  _libraryOpen && _libraryFolder == null,
                              focusedFolder: _focusFolder,
                              focusedSetIndex: _focusIndex,
                              practiceLocked: _practicingSession,
                              onPracticeLocked: _showPracticeAlert,
                              onHome: _showHome,
                              onLibrary: _showLibrary,
                              onOpenSet: _openSavedSet,
                              onOpenFolder: _openLibraryFolder,
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
    this.learnedWords = const <VocabularyWord>[],
    this.notLearnedWords = const <VocabularyWord>[],
    this.wordsByLevel = const <int, List<VocabularyWord>>{},
    this.onAllChanged,
    this.onPractice,
    this.onContinue,
    this.onOpenStatisticsSet,
  });

  final HomeSample sample;
  final bool narrow;
  final List<VocabularyWord> learnedWords;
  final List<VocabularyWord> notLearnedWords;
  final Map<int, List<VocabularyWord>> wordsByLevel;
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
              learnedWords: learnedWords,
              notLearnedWords: notLearnedWords,
              wordsByLevel: wordsByLevel,
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
                  learnedWords: learnedWords,
                  notLearnedWords: notLearnedWords,
                  wordsByLevel: wordsByLevel,
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
  Future<String> createFolder(
    String name, {
    bool editor = false,
    bool pinned = true,
  }) {
    return inner.createFolder(name, editor: editor, pinned: pinned);
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

  @override
  Future<void> renameFolder(String id, String name) {
    return inner.renameFolder(id, name);
  }

  @override
  Future<void> deleteFolder(String id) {
    return inner.deleteFolder(id);
  }

  @override
  Future<void> setFolderPinned(String id, bool pinned) {
    return inner.setFolderPinned(id, pinned);
  }
}
