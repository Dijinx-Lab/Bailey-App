import 'package:bailey/style/color/color_style.dart';
import 'package:flutter/material.dart';

class TypeStyle {
  static TextStyle h1 = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: ColorStyle.primaryTextColor,
  );

  static TextStyle h2 = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: ColorStyle.primaryTextColor,
  );

  static TextStyle h3 = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: ColorStyle.primaryTextColor,
  );

  static TextStyle body = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: ColorStyle.secondaryTextColor,
  );

  static TextStyle label = const TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: ColorStyle.secondaryTextColor,
  );

  static TextStyle info = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: ColorStyle.primaryTextColor,
  );

  static TextStyle info2 = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: ColorStyle.blackColor,
  );
}
