import 'dart:developer';

import 'package:flutter/material.dart';

import 'common_alert_dialog.dart';
import 'loading_dialog.dart';

class FutureDialog<T> extends StatelessWidget {
  String get _name => 'FutureDialog<$T>';

  const FutureDialog({
    required this.future,
    this.loadingText = 'Loading',
    this.hasData,
    this.hasError,
    this.debug = false,
    this.throwError = false,
    Key? key,
  }) : super(key: key);

  final Future<T> future;
  final String loadingText;
  final bool debug, throwError;
  final Widget Function(Object? error)? hasError;

  ///executes when either future is done with no error or returns data.
  ///
  ///In case of null,
  ///```
  ///hasData = (_) {
  ///     return CommonAlertDialog('Done');
  ///   }
  ///```
  final Widget Function(T? res)? hasData;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasData ||
            (snapshot.connectionState == ConnectionState.done &&
                !snapshot.hasError)) {
          if (hasData != null) {
            return hasData!(snapshot.data);
          } else {
            if (debug) log('data: ${snapshot.data}', name: _name);
            return const CommonAlertDialog('DONE');
          }
        }
        if (snapshot.hasError) {
          if (hasError != null) {
            return hasError!(snapshot.error);
          } else {
            if (debug) log('error: ${snapshot.error}', name: _name);
            if (throwError) throw snapshot.error!;
            String? errorMessage = 'SOME ERROR OCCURRED';
            if (snapshot.error is String) {
              errorMessage = snapshot.error as String?;
            }
            log('err: ${snapshot.error.toString()}', name: 'FutureDialog');
            return CommonAlertDialog(
              errorMessage!,
              icon: const Icon(
                Icons.block,
                color: Colors.red,
                size: 20,
              ),
            );
          }
        }
        return LoadingDialog(loadingText);
      },
    );
  }
}
