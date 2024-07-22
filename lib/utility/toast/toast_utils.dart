import 'package:bailey/style/color/color_style.dart';
import 'package:flutter/material.dart';

class ToastUtils {
  static showSnackBar(BuildContext context, String text, String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            type == "fail" ? ColorStyle.red100Color : ColorStyle.primaryColor,
        content: type == "text"
            ? Text(text)
            : Row(
                children: [
                  Icon(
                    type == "success"
                        ? Icons.check_circle_outline
                        : type == "fail"
                            ? Icons.error_outline
                            : Icons.info_outline,
                    color: ColorStyle.whiteColor,
                  ),
                  const SizedBox(width: 15),
                  Text(
                    text,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  )
                ],
              ),
      ),
    );
  }

  static showCustomSnackbar({
    required BuildContext context,
    required String contentText,
    required String type,
    int second = 4,
    bool isShowIcon = true,
    bool isCenteredText = false,
  }) {
    final snackbar = SnackBar(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isShowIcon
              ? Icon(
                  type == "success"
                      ? Icons.check_circle_outline
                      : type == "fail"
                          ? Icons.error_outline
                          : Icons.info_outline,
                  color: ColorStyle.whiteColor,
                )
              : const SizedBox(
                  width: 0,
                  height: 0,
                ),
          isShowIcon
              ? const SizedBox(
                  width: 10,
                )
              : const SizedBox(
                  width: 0,
                  height: 0,
                ),
          Expanded(
            child: Text(
              contentText,
              textAlign: isCenteredText ? TextAlign.center : TextAlign.start,
              style: const TextStyle(
                  color: ColorStyle.whiteColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      backgroundColor:
          type == "fail" ? ColorStyle.red100Color : ColorStyle.green100Color,
      duration: Duration(seconds: second),
      behavior: SnackBarBehavior.fixed,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackbar);
  }
}
