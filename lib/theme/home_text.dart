import 'package:flutter/widgets.dart';
import 'package:lang/theme/home_palette.dart';

class HomeText {
  const HomeText._(this._ink, this._text);

  final Color _ink;
  final Color _text;

  static HomeText of(BuildContext context) {
    final palette = HomePalette.of(context);
    return HomeText._(palette.ink, palette.text);
  }

  TextStyle get title => TextStyle(
    fontFamily: 'Poppins',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: _ink,
  );

  TextStyle get heading => TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: _ink,
  );

  TextStyle get subtitle => TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: _text,
  );

  TextStyle get body => TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: _text,
  );

  TextStyle get caption => TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: _ink,
  );

  TextStyle get fine => TextStyle(
    fontFamily: 'Poppins',
    fontSize: 10,
    fontWeight: FontWeight.w300,
    height: 1.4,
    color: _ink,
  );
}
