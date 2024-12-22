import 'dart:math';

import 'package:flutter/material.dart';
import 'package:helpful_components/src/helpful_components_theme.dart';

class CommonAlertDialogThemeData {
  const CommonAlertDialogThemeData({
    this.textStyle,
    this.shape,
    this.elevation,
    this.successfulIconColor,
    this.successfulIconData,
    this.errorIconColor,
    this.errorIconData,
    this.showActionButton,
    this.actionButtonContent,
  });

  final TextStyle? textStyle;
  final ShapeBorder? shape;
  final double? elevation;
  final IconData? successfulIconData;
  final IconData? errorIconData;
  final Color? successfulIconColor;
  final Color? errorIconColor;
  final bool? showActionButton;
  final Widget? actionButtonContent;

  @override
  bool operator ==(Object other) {
    return other is CommonAlertDialogThemeData &&
        other.textStyle == textStyle &&
        other.shape == shape &&
        other.elevation == elevation &&
        other.successfulIconData == successfulIconData &&
        other.successfulIconColor == successfulIconColor &&
        other.errorIconData == errorIconData &&
        other.errorIconColor == errorIconColor &&
        other.showActionButton == showActionButton;
  }

  @override
  int get hashCode => Object.hash(
        textStyle,
        shape,
        elevation,
        successfulIconColor,
        successfulIconData,
        errorIconColor,
        errorIconData,
        showActionButton,
      );

  static const _kFallbackTheme = CommonAlertDialogThemeData();

  static CommonAlertDialogThemeData of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<HelpfulComponentsTheme>()
            ?.data
            ?.commonAlertDialogThemeData ??
        _kFallbackTheme;
  }
}

///Common Alert Dialog to show successful messages and error messages.
class CommonAlertDialog extends StatelessWidget {
  final String titleString;

  ///This will be showed below the [titleString] and [icon].
  final Widget? content;

  ///TextStyle of the [titleString] displayed, with the [icon] on the dialog.
  ///
  ///If this property is null, then it's default value is
  ///[CommonAlertDialogThemeData.textStyle] if it is also null, then it's default
  ///value is [TextTheme.titleMedium], if it is also null, then it's default
  ///value is:-
  ///
  ///```dart
  ///TextStyle(
  ///  fontSize: screenWidth * 0.04,
  ///  fontWeight: FontWeight.bold,
  ///)
  ///```
  ///
  ///where screenWidth is calculated as:-
  ///```
  ///double screenWidth = min(MediaQuery.of(context).size.width, 600);
  ///```
  final TextStyle? textStyle;

  ///If this is null, then the default value will be
  ///[CommonAlertDialogThemeData.shape], if it is also null, then it will be:-
  ///
  ///```dart
  ///RoundedRectangleBorder(
  ///  borderRadius: BorderRadius.all(
  ///    Radius.circular(screenWidth * 0.03),
  ///  ),
  ///),
  ///
  ///double screenWidth = min(MediaQuery.of(context).size.width, 600);
  ///```
  final ShapeBorder? shape;

  ///If this is null, then if [error] is false, then default value is
  ///[CommonAlertDialogThemeData.successfulIcon] [Data] and [Color],
  ///if it is null the default value is [Icons.check_circle_outline], with
  ///color, [Colors.lightGreen], while in case [error] is true, default value is
  ///[CommonAlertDialogThemeData.errorIcon] [Data] and [Color], if it is null
  ///the default value is [Icons.block] with color, [Colors.red].
  final Icon? icon;
  final Function? onPressed;

  ///If true, default [icon] changes to [Icons.block] with color, [Colors.red].
  final bool error;

  ///If it is null, it's default value will be
  ///[CommonAlertDialogThemeData.elevation], if it is null, then it will be 10.
  final double? elevation;

  ///If it is null, it's default value will be
  ///[CommonAlertDialogThemeData.showActionButton], if it is null, default value
  ///will be true.
  final bool? showActionButton;

  ///If it is null, it's default value will be
  ///[CommonAlertDialogThemeData.actionButtonContent], if it is also null,
  ///default value will be [CommonAlertDialog.getDefaultActionButtonContent].
  final Widget? actionButtonContent;

  const CommonAlertDialog(
    this.titleString, {
    Key? key,
    this.icon,
    this.onPressed,
    this.content,
    this.textStyle,
    this.shape,
    this.elevation,
    this.error = false,
    this.showActionButton,
    this.actionButtonContent,
  }) : super(key: key);

  static Widget getDefaultActionButtonContent(double screenWidth) => Text(
        "OK",
        style: TextStyle(
          fontSize: screenWidth * 0.04,
        ),
      );

  @override
  Widget build(BuildContext context) {
    double screenWidth = min(MediaQuery.of(context).size.width, 600);
    final theme = CommonAlertDialogThemeData.of(context);
    final textTheme = Theme.of(context).textTheme;

    final elevation = this.elevation ?? theme.elevation ?? 10;
    final textStyle = this.textStyle ??
        theme.textStyle ??
        textTheme.titleMedium ??
        TextStyle(
          fontSize: screenWidth * 0.04,
          fontWeight: FontWeight.bold,
        );

    final shape = this.shape ??
        theme.shape ??
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(screenWidth * 0.03),
          ),
        );

    final defaultIconData = (error
        ? (theme.errorIconData ?? Icons.block)
        : (theme.successfulIconData ?? Icons.check_circle_outline));

    final defaultIconColor = (error
        ? (theme.errorIconColor ?? Colors.red)
        : (theme.successfulIconColor ?? Colors.lightGreen));

    final icon = this.icon ?? Icon(defaultIconData, color: defaultIconColor);

    final showActionButton =
        this.showActionButton ?? theme.showActionButton ?? true;

    return AlertDialog(
      elevation: elevation,
      shape: shape,
      content: content,
      title: Row(
        children: <Widget>[
          Expanded(
            flex: 10,
            child: Text(
              titleString,
              style: textStyle,
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 15),
              child: FittedBox(child: icon),
            ),
          )
        ],
      ),
      actions: <Widget>[
        if (showActionButton)
          Center(
            child: TextButton(
              onPressed: onPressed as void Function()? ??
                  () => Navigator.of(context).pop(),
              child: actionButtonContent ??
                  getDefaultActionButtonContent(screenWidth),
            ),
          ),
      ],
    );
  }
}
