import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lang/l10n/app_localizations.dart';

void main() {
  Future<AppLocalizations> load(WidgetTester tester, Locale locale) async {
    late AppLocalizations localizations;
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            localizations = AppLocalizations.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    return localizations;
  }

  testWidgets('chrome strings match the design in each language', (
    tester,
  ) async {
    final english = await load(tester, const Locale('en'));
    expect(english.statisticsHeading, 'Your vocabulary statistics');
    expect(english.practice, 'Practice');
    expect(english.progressComplete(25), 'The process is 25% complete.');
    expect(english.hotSearch, 'Hot search');
    expect(english.suggestedSets, 'Suggested sets');
    expect(english.suggestedPractice, 'Suggested practice');
    expect(english.saveWord, 'Save');
    expect(english.saveCount(80), '80 saves');
    expect(english.editorDone, 'Done');
    expect(english.editorBack, 'All posts');
    expect(english.editorTitle, 'Title');
    expect(english.editorTitleHint, 'Enter a title...');
    expect(english.editorDescriptionHint, 'Add a description...');
    expect(english.editorImport, 'Import');
    expect(english.editorTerm, 'Term');
    expect(english.editorTermHint, 'Enter term');
    expect(english.editorDefinition, 'Definition');
    expect(english.editorDefinitionHint, 'Enter definition');
    expect(english.editorSentence, 'Sentence');
    expect(english.editorSentenceHint, 'Enter sentence');
    expect(english.editorDetails, 'Details');
    expect(english.editorIpa, 'IPA');
    expect(english.editorIpaHint, 'Enter IPA');
    expect(english.editorSingularPlural, 'Singular - Plural');
    expect(english.editorSingularPluralHint, 'Enter singular and plural');
    expect(english.editorNote, 'Note');
    expect(english.editorNoteHint, 'Enter a note');
    expect(english.editorType, 'Type');
    expect(english.editorChunking, 'Chunking');
    expect(english.editorNoun, 'Noun');
    expect(english.editorVerb, 'Verb');
    expect(english.editorAdj, 'Adj');
    expect(english.editorImageLinkHint, 'Enter image link');
    expect(english.editorAddWord, 'Add new word');
    expect(english.editorAddType, 'Add type');
    expect(english.editorTypeNameHint, 'Enter type');
    expect(english.termRequired, 'Enter a term');
    expect(english.definitionRequired, 'Enter a definition');
    expect(english.titleRequired, 'Enter a title');
    expect(english.newTerm, 'New term');
    expect(english.newFolder, 'New folder');
    expect(english.newFolderHint, 'Enter folder name');
    expect(english.createFolder, 'Create');
    expect(english.cancelAction, 'Cancel');
    expect(english.libraryTitle, 'Your library');
    expect(english.librarySets, 'Flashcard sets');
    expect(english.libraryFolders, 'Folders');
    expect(english.librarySearchHint, 'Search');
    expect(english.libraryTermCount(4), '4 terms');
    expect(english.librarySetCount(2), '2 sets');
    expect(english.libraryEmpty, 'Nothing here yet');
    expect(english.libraryFolderEmpty, 'Add a set and it will show up here.');
    expect(english.librarySortCreated, 'Created');
    expect(english.librarySortStudied, 'Studied');
    expect(english.librarySearchFolder, 'Search this folder');
    expect(english.libraryStudy, 'Study');
    expect(english.libraryAddSets, 'Add sets');
    expect(english.folderAddTag, 'Add tag');
    expect(english.folderEdit, 'Edit');
    expect(english.folderShare, 'Share');
    expect(english.folderUnpin, 'Unpin from sidebar');
    expect(english.folderPin, 'Pin to sidebar');
    expect(english.folderSave, 'Save');
    expect(english.folderDelete, 'Delete');
    expect(english.studyTodayPractice, 'Today practice');
    expect(english.studyLearnNew, 'Learn new vocab');
    expect(english.studyFlashcard, 'Flashcard');
    expect(english.studyHard, 'Hard');
    expect(english.studyStillLearning, 'Still learning');
    expect(english.studyKnow, 'Know');
    expect(english.studyTrackProgress, 'Track progress');
    expect(english.studyNotYetStudied, 'Not yet studied');
    expect(english.studyStudiedAction, 'Studied');
    expect(english.studyFlipShortcut, 'Press Space or click the card to flip');
    expect(english.studyList, 'Vocabulary list');
    expect(english.studyMastered, 'Mastered');
    expect(english.themeLight, 'Light');
    expect(english.themeDark, 'Dark');
    expect(english.menuAchievements, 'Achievements');
    expect(english.menuSettings, 'Settings');
    expect(english.menuLightMode, 'Light mode');
    expect(english.menuDarkMode, 'Dark mode');
    expect(english.menuLogOut, 'Log out');
    expect(english.menuPrivacy, 'Privacy policy');
    expect(english.menuHelp, 'Help and feedback');
    expect(english.menuUpgrade, 'Upgrade');

    final vietnamese = await load(tester, const Locale('vi'));
    expect(vietnamese.statisticsHeading, 'Thống kê từ vựng của bạn');
    expect(vietnamese.practice, 'Luyện tập');
    expect(vietnamese.hotSearch, 'Tìm kiếm nổi bật');
    expect(vietnamese.suggestedSets, 'Bộ từ gợi ý');
    expect(vietnamese.suggestedPractice, 'Luyện tập gợi ý');
    expect(vietnamese.saveWord, 'Lưu từ');
    expect(vietnamese.saveCount(80), '80 Lượt lưu');
    expect(vietnamese.editorDone, 'Xong');
    expect(vietnamese.editorBack, 'Tất cả bài viết');
    expect(vietnamese.editorTitle, 'Tiêu đề');
    expect(vietnamese.editorTitleHint, 'Nhập tiêu đề...');
    expect(vietnamese.editorDescriptionHint, 'Thêm mô tả...');
    expect(vietnamese.editorImport, 'Nhập');
    expect(vietnamese.editorTerm, 'Từ');
    expect(vietnamese.editorTermHint, 'Nhập từ');
    expect(vietnamese.editorDefinition, 'Định nghĩa');
    expect(vietnamese.editorDefinitionHint, 'Nhập định nghĩa');
    expect(vietnamese.editorSentence, 'Câu');
    expect(vietnamese.editorSentenceHint, 'Nhập câu');
    expect(vietnamese.editorDetails, 'Chi tiết');
    expect(vietnamese.editorIpa, 'IPA');
    expect(vietnamese.editorIpaHint, 'Nhập IPA');
    expect(vietnamese.editorSingularPlural, 'Số ít - Số nhiều');
    expect(vietnamese.editorSingularPluralHint, 'Nhập số ít và số nhiều');
    expect(vietnamese.editorNote, 'Ghi chú');
    expect(vietnamese.editorNoteHint, 'Nhập ghi chú');
    expect(vietnamese.editorType, 'Loại');
    expect(vietnamese.editorChunking, 'Chunking');
    expect(vietnamese.editorNoun, 'Danh từ');
    expect(vietnamese.editorVerb, 'Động từ');
    expect(vietnamese.editorAdj, 'Tính từ');
    expect(vietnamese.editorImageLinkHint, 'Nhập link ảnh');
    expect(vietnamese.editorAddWord, 'Thêm từ mới');
    expect(vietnamese.editorAddType, 'Thêm loại');
    expect(vietnamese.editorTypeNameHint, 'Nhập loại');
    expect(vietnamese.termRequired, 'Hãy nhập từ');
    expect(vietnamese.definitionRequired, 'Hãy nhập định nghĩa');
    expect(vietnamese.titleRequired, 'Hãy nhập tiêu đề');
    expect(vietnamese.newTerm, 'Từ mới');
    expect(vietnamese.newFolder, 'Thư mục mới');
    expect(vietnamese.newFolderHint, 'Nhập tên thư mục');
    expect(vietnamese.createFolder, 'Tạo');
    expect(vietnamese.cancelAction, 'Hủy');
    expect(vietnamese.libraryTitle, 'Thư viện của bạn');
    expect(vietnamese.librarySets, 'Bộ từ');
    expect(vietnamese.libraryFolders, 'Thư mục');
    expect(vietnamese.librarySearchHint, 'Tìm kiếm');
    expect(vietnamese.libraryTermCount(4), '4 từ');
    expect(vietnamese.librarySetCount(2), '2 bộ từ');
    expect(vietnamese.libraryEmpty, 'Chưa có gì ở đây');
    expect(
      vietnamese.libraryFolderEmpty,
      'Thêm một bộ từ, nó sẽ hiện ở đây.',
    );
    expect(vietnamese.librarySortCreated, 'Đã tạo');
    expect(vietnamese.librarySortStudied, 'Đã học');
    expect(vietnamese.librarySearchFolder, 'Tìm trong thư mục này');
    expect(vietnamese.libraryStudy, 'Học');
    expect(vietnamese.libraryAddSets, 'Thêm bộ từ');
    expect(vietnamese.folderAddTag, 'Thêm thẻ');
    expect(vietnamese.folderEdit, 'Sửa');
    expect(vietnamese.folderShare, 'Chia sẻ');
    expect(vietnamese.folderUnpin, 'Bỏ ghim khỏi thanh bên');
    expect(vietnamese.folderPin, 'Ghim vào thanh bên');
    expect(vietnamese.folderSave, 'Lưu');
    expect(vietnamese.folderDelete, 'Xóa');
    expect(vietnamese.studyTodayPractice, 'Luyện hôm nay');
    expect(vietnamese.studyLearnNew, 'Học từ mới');
    expect(vietnamese.studyFlashcard, 'Thẻ học');
    expect(vietnamese.studyHard, 'Khó');
    expect(vietnamese.studyStillLearning, 'Đang học');
    expect(vietnamese.studyKnow, 'Đã biết');
    expect(vietnamese.studyTrackProgress, 'Theo dõi tiến độ');
    expect(vietnamese.studyNotYetStudied, 'Chưa học');
    expect(vietnamese.studyStudiedAction, 'Đã học');
    expect(vietnamese.studyFlipShortcut, 'Nhấn Space hoặc nhấn thẻ để lật');
    expect(vietnamese.studyList, 'Danh sách từ');
    expect(vietnamese.studyMastered, 'Đã thuộc');
    expect(vietnamese.themeLight, 'Sáng');
    expect(vietnamese.themeDark, 'Tối');
    expect(vietnamese.menuAchievements, 'Thành tích');
    expect(vietnamese.menuSettings, 'Cài đặt');
    expect(vietnamese.menuLightMode, 'Chế độ sáng');
    expect(vietnamese.menuDarkMode, 'Chế độ tối');
    expect(vietnamese.menuLogOut, 'Đăng xuất');
    expect(vietnamese.menuPrivacy, 'Chính sách quyền riêng tư');
    expect(vietnamese.menuHelp, 'Trợ giúp và phản hồi');
    expect(vietnamese.menuUpgrade, 'Nâng cấp');

    final german = await load(tester, const Locale('de'));
    expect(german.statisticsHeading, 'Deine Vokabelstatistik');
    expect(german.practice, 'Üben');
    expect(german.hotSearch, 'Beliebte Suche');
    expect(german.suggestedSets, 'Vorgeschlagene Sets');
    expect(german.suggestedPractice, 'Vorgeschlagenes Üben');
    expect(german.saveWord, 'Speichern');
    expect(german.saveCount(80), '80 Mal gespeichert');
    expect(german.editorDone, 'Fertig');
    expect(german.editorBack, 'Alle Beiträge');
    expect(german.editorTitle, 'Titel');
    expect(german.editorTitleHint, 'Titel eingeben...');
    expect(german.editorDescriptionHint, 'Beschreibung hinzufügen...');
    expect(german.editorImport, 'Importieren');
    expect(german.editorTerm, 'Begriff');
    expect(german.editorTermHint, 'Begriff eingeben');
    expect(german.editorDefinition, 'Definition');
    expect(german.editorDefinitionHint, 'Definition eingeben');
    expect(german.editorSentence, 'Satz');
    expect(german.editorSentenceHint, 'Satz eingeben');
    expect(german.editorDetails, 'Details');
    expect(german.editorIpa, 'IPA');
    expect(german.editorIpaHint, 'IPA eingeben');
    expect(german.editorSingularPlural, 'Singular - Plural');
    expect(german.editorSingularPluralHint, 'Singular und Plural eingeben');
    expect(german.editorNote, 'Notiz');
    expect(german.editorNoteHint, 'Notiz eingeben');
    expect(german.editorType, 'Typ');
    expect(german.editorChunking, 'Chunking');
    expect(german.editorNoun, 'Nomen');
    expect(german.editorVerb, 'Verb');
    expect(german.editorAdj, 'Adjektiv');
    expect(german.editorImageLinkHint, 'Bildlink eingeben');
    expect(german.editorAddWord, 'Neues Wort hinzufügen');
    expect(german.editorAddType, 'Typ hinzufügen');
    expect(german.editorTypeNameHint, 'Typ eingeben');
    expect(german.termRequired, 'Begriff eingeben');
    expect(german.definitionRequired, 'Definition eingeben');
    expect(german.titleRequired, 'Titel eingeben');
    expect(german.newTerm, 'Neuer Begriff');
    expect(german.newFolder, 'Neuer Ordner');
    expect(german.newFolderHint, 'Ordnernamen eingeben');
    expect(german.createFolder, 'Erstellen');
    expect(german.cancelAction, 'Abbrechen');
    expect(german.libraryTitle, 'Deine Bibliothek');
    expect(german.librarySets, 'Sets');
    expect(german.libraryFolders, 'Ordner');
    expect(german.librarySearchHint, 'Suchen');
    expect(german.libraryTermCount(4), '4 Begriffe');
    expect(german.librarySetCount(2), '2 Sets');
    expect(german.libraryEmpty, 'Noch nichts hier');
    expect(
      german.libraryFolderEmpty,
      'Füge ein Set hinzu, dann erscheint es hier.',
    );
    expect(german.librarySortCreated, 'Erstellt');
    expect(german.librarySortStudied, 'Gelernt');
    expect(german.librarySearchFolder, 'Diesen Ordner durchsuchen');
    expect(german.libraryStudy, 'Lernen');
    expect(german.libraryAddSets, 'Sets hinzufügen');
    expect(german.folderAddTag, 'Tag hinzufügen');
    expect(german.folderEdit, 'Bearbeiten');
    expect(german.folderShare, 'Teilen');
    expect(german.folderUnpin, 'Von der Seitenleiste lösen');
    expect(german.folderPin, 'An Seitenleiste anheften');
    expect(german.folderSave, 'Speichern');
    expect(german.folderDelete, 'Löschen');
    expect(german.studyTodayPractice, 'Heute üben');
    expect(german.studyLearnNew, 'Neue Vokabeln lernen');
    expect(german.studyFlashcard, 'Karteikarte');
    expect(german.studyHard, 'Schwer');
    expect(german.studyStillLearning, 'Noch am Lernen');
    expect(german.studyKnow, 'Gewusst');
    expect(german.studyTrackProgress, 'Fortschritt verfolgen');
    expect(german.studyNotYetStudied, 'Noch nicht gelernt');
    expect(german.studyStudiedAction, 'Gelernt');
    expect(
      german.studyFlipShortcut,
      'Leertaste drücken oder auf die Karte klicken zum Umdrehen',
    );
    expect(german.studyList, 'Vokabelliste');
    expect(german.studyMastered, 'Gemeistert');
    expect(german.themeLight, 'Hell');
    expect(german.themeDark, 'Dunkel');
    expect(german.menuAchievements, 'Erfolge');
    expect(german.menuSettings, 'Einstellungen');
    expect(german.menuLightMode, 'Heller Modus');
    expect(german.menuDarkMode, 'Dunkler Modus');
    expect(german.menuLogOut, 'Abmelden');
    expect(german.menuPrivacy, 'Datenschutz');
    expect(german.menuHelp, 'Hilfe und Feedback');
    expect(german.menuUpgrade, 'Upgrade');
    expect(german.homeTitle, 'Flutter-Demo-Startseite');
    expect(german.missingTranslationProbe, 'Missing translation probe');
  });
}
