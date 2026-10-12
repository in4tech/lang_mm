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
}
