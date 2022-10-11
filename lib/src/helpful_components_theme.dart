import 'package:flutter/material.dart';

import 'common_alert_dialog.dart';

class HelpfulComponentsThemeData {
  const HelpfulComponentsThemeData({
    this.commonAlertDialogThemeData,
  });

  final CommonAlertDialogThemeData? commonAlertDialogThemeData;

  @override
  bool operator ==(Object other) {
    return other is HelpfulComponentsThemeData &&
        other.commonAlertDialogThemeData == commonAlertDialogThemeData;
  }

  @override
  int get hashCode => commonAlertDialogThemeData.hashCode;
}

class HelpfulComponentsTheme extends InheritedWidget {
  const HelpfulComponentsTheme({
    Key? key,
    required Widget child,
    this.data,
  }) : super(key: key, child: child);

  final HelpfulComponentsThemeData? data;

  static const _kFallbackTheme = HelpfulComponentsThemeData();

  @override
  bool updateShouldNotify(covariant HelpfulComponentsTheme oldWidget) {
    return oldWidget.data == data;
  }

  static HelpfulComponentsThemeData of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<HelpfulComponentsTheme>()
          ?.data ??
      _kFallbackTheme;
}
