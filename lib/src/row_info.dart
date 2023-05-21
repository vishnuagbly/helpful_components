import 'package:flutter/material.dart';

///Shows two widgets in a row. Useful when wants to show a row of bill, i.e
///when we want to show a value for a certain heading/title.
class RowInfo extends StatelessWidget {
  ///Shows two widgets in a row. Useful when wants to show a row of bill, i.e
  ///when we want to show a value for a certain heading/title.
  const RowInfo(
    this.firstText,
    this.secondText, {
    this.firstStyle,
    this.secondStyle,
    this.firstColor,
    this.secondColor,
    double? size,
    Key? key,
  })  : firstWidget = null,
        secondWidget = null,
        firstSize = size,
        secondSize = size,
        super(key: key);

  ///Shows two widgets in a row. Useful when wants to show a row of bill, i.e
  ///when we want to show a value for a certain heading/title.
  const RowInfo.raw({
    this.firstWidget,
    this.secondWidget,
    this.firstText,
    this.secondText,
    this.firstStyle,
    this.secondStyle,
    this.firstColor,
    this.secondColor,
    this.firstSize,
    this.secondSize,
    Key? key,
  }) : super(key: key);

  final Widget? firstWidget, secondWidget;
  final String? firstText, secondText;
  final TextStyle? firstStyle, secondStyle;
  final Color? firstColor, secondColor;
  final double? firstSize, secondSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        firstWidget ??
            Text(
              firstText ?? "",
              style: firstStyle ??
                  Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: firstSize,
                        color: firstColor ??
                            DefaultTextStyle.of(context).style.color,
                      ),
            ),
        secondWidget ??
            Text(
              secondText ?? "",
              style: secondStyle ??
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w300,
                        fontSize: secondSize,
                        color: secondColor ??
                            DefaultTextStyle.of(context).style.color,
                      ),
            ),
      ],
    );
  }
}
