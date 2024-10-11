import 'package:bailey/style/color/color_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

class MTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? label;
  final String? icon;
  final Widget? iconWidget;
  final Widget? trailing;
  final bool obscuretext;
  final Color borderColor;
  final Color fieldColor;
  final TextInputType keyboardType;
  final int? maxLength;
  final int? maxLines;
  final bool autofocus;
  final Color textColor;
  final double verticalFieldPadding;
  final Color cursorColor;
  final BorderRadius? customRadius;
  final double borderWidth;
  final FocusNode? focusNode;
  final TextStyle? hintStyle;
  final List<TextInputFormatter>? inputFormatters;
  final Function? onChanged;
  final Function? onTap;
  final bool readOnly;
  final String? errorText;
  const MTextField(
      {super.key,
      required this.controller,
      this.label,
      this.autofocus = false,
      this.hint = '',
      this.hintStyle,
      this.icon,
      this.iconWidget,
      this.trailing,
      this.obscuretext = false,
      this.borderColor = ColorStyle.borderColor,
      this.keyboardType = TextInputType.text,
      this.maxLength,
      this.maxLines = 1,
      this.inputFormatters,
      this.fieldColor = ColorStyle.backgroundColor,
      this.textColor = ColorStyle.whiteColor,
      this.verticalFieldPadding = 15,
      this.cursorColor = ColorStyle.whiteColor,
      this.customRadius,
      this.borderWidth = 3,
      this.focusNode,
      this.onChanged,
      this.errorText,
      this.onTap,
      this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: readOnly ? 0.4 : 1,
      child: TextField(
          focusNode: focusNode,
          controller: controller,
          obscureText: obscuretext,
          obscuringCharacter: '*',
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          maxLines: maxLines,
          autofocus: autofocus,
          cursorColor: cursorColor,
          readOnly: readOnly,
          onTap: () {
            if (onTap != null) {
              onTap!();
            }
          },
          onChanged: (value) {
            if (onChanged != null) {
              onChanged!(value);
            }
          },
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            errorText: errorText,
            errorStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: ColorStyle.red100Color),
            errorBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: ColorStyle.red100Color, width: borderWidth),
              borderRadius: customRadius != null
                  ? customRadius!
                  : BorderRadius.circular(12),
            ),
            hintStyle: hintStyle ??
                const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: ColorStyle.secondaryTextColor),
            filled: true,
            fillColor: fieldColor,
            prefixIcon: Container(
              margin: const EdgeInsets.all(15.0),
              padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: borderColor,
                    width: 2.0,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: iconWidget ?? SvgPicture.asset(
                        'assets/icons/$icon.svg',
                      ),
              ),
            ),
            suffixIcon: trailing,
            hintText: label != null ? null : hint,
            label: label == null
                ? null
                : Text(
                    label!,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: ColorStyle.secondaryTextColor),
                  ),
            contentPadding: EdgeInsets.symmetric(
                horizontal: 15, vertical: verticalFieldPadding),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: borderColor.withOpacity(0.6), width: borderWidth),
              borderRadius: customRadius != null
                  ? customRadius!
                  : BorderRadius.circular(6),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: borderColor, width: borderWidth),
              borderRadius: customRadius != null
                  ? customRadius!
                  : BorderRadius.circular(6),
            ),
          )),
    );
  }
}
