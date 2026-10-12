import 'package:flutter/material.dart';
import 'package:lang/theme/home_colors.dart';

abstract final class HomeText {
  static const title = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: HomeColors.ink,
  );
  static const heading = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: HomeColors.ink,
  );
  static const subtitle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: HomeColors.text,
  );
  static const body = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: HomeColors.text,
  );
  static const caption = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: HomeColors.ink,
  );
  static const fine = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 10,
    fontWeight: FontWeight.w300,
    height: 1.4,
    color: HomeColors.ink,
  );
}
