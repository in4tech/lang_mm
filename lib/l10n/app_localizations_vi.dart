// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get homeTitle => 'Trang chủ bản demo Flutter';

  @override
  String get counterMessage => 'Bạn đã nhấn nút này bấy nhiêu lần:';

  @override
  String get incrementAction => 'Tăng';

  @override
  String get missingTranslationProbe => 'Missing translation probe';

  @override
  String get statisticsHeading => 'Thống kê từ vựng của bạn';

  @override
  String get searchHint => 'Tìm từ vựng...';

  @override
  String get newVocab => 'Từ mới';

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navLibrary => 'Thư viện';

  @override
  String get navNotification => 'Thông báo';

  @override
  String get vocabularySet => 'Bộ từ vựng của bạn';

  @override
  String get setOfWords => 'Bộ từ';

  @override
  String get allLabel => 'Tất cả';

  @override
  String get wordsLearned => 'Từ đã học';

  @override
  String get wordsNotLearned => 'Từ chưa học';

  @override
  String get levelMastered => 'Lv.6 - Thành thạo';

  @override
  String get levelGood => 'Lv.5 - Tốt';

  @override
  String get levelFamiliar => 'Lv.4 - Quen';

  @override
  String get levelLearning => 'Lv.3 - Đang học';

  @override
  String get levelHard => 'Lv.2 - Khó';

  @override
  String get levelForgot => 'Lv.1 - Quên';

  @override
  String get todaysVocabulary => 'Từ vựng hôm nay';

  @override
  String get practice => 'Luyện tập';

  @override
  String get recent => 'Gần đây';

  @override
  String progressComplete(int percent) {
    return 'Tiến trình đã hoàn thành $percent%.';
  }

  @override
  String get continueAction => 'Tiếp tục';

  @override
  String get hotSearch => 'Tìm kiếm nổi bật';

  @override
  String get suggestedSets => 'Bộ từ gợi ý';

  @override
  String get suggestedPractice => 'Luyện tập gợi ý';

  @override
  String get saveWord => 'Lưu từ';

  @override
  String saveCount(int count) {
    return '$count Lượt lưu';
  }
}
