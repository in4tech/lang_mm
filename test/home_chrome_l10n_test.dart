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
    expect(english.editorAddWord, 'Add new word');
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
    expect(vietnamese.editorAddWord, 'Thêm từ mới');
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
    expect(german.editorAddWord, 'Neues Wort hinzufügen');
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
