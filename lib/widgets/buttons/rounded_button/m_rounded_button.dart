import 'package:bailey/style/color/color_style.dart';
import 'package:flutter/material.dart';

class MRoundedButton extends StatelessWidget {
  final String buttonText;
  final Function onTap;
  final Color textColor;
  final double textSize;
  final FontWeight textWeight;
  final Color buttonBackgroundColor;
  final double roundedCorners;
  final double elevation;
  final bool isEnabled;
  final double leftPadding;
  final double rightPadding;
  final Color borderColor;
  final Color waterColor;
  final Widget? widgetButton;

  const MRoundedButton(this.buttonText, this.onTap,
      {Key? key,
      this.textColor = ColorStyle.blackColor,
      this.textSize = 14.0,
      this.textWeight = FontWeight.w500,
      this.buttonBackgroundColor = ColorStyle.primaryColor,
      this.roundedCorners = 12,
      this.elevation = 0.0,
      this.isEnabled = true,
      this.leftPadding = 16,
      this.rightPadding = 16,
      this.borderColor = ColorStyle.primaryColor,
      this.waterColor = Colors.black12,
      this.widgetButton})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
          padding: WidgetStateProperty.resolveWith<EdgeInsets>(
            (Set<WidgetState> states) {
              return EdgeInsets.only(left: leftPadding, right: rightPadding);
            },
          ),
          elevation: WidgetStateProperty.resolveWith<double>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return 0;
              }
              return elevation;
            },
          ),
          overlayColor: WidgetStateProperty.all<Color>(
              isEnabled ? waterColor : Colors.transparent),
          backgroundColor: WidgetStateProperty.all<Color>(isEnabled
              ? buttonBackgroundColor
              : buttonBackgroundColor.withOpacity(0.5)),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  side: BorderSide(
                      color: isEnabled
                          ? borderColor
                          : borderColor.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(roundedCorners)))),
      onPressed: () {
        if (isEnabled) onTap();
      },
      child: widgetButton ??
          FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              buttonText,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                  height: 1.2,
                  fontSize: textSize,
                  color: textColor,
                  fontWeight: textWeight),
            ),
          ),
    );
  }
}
