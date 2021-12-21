import 'dart:developer';

import 'package:flutter/material.dart';

///Common Wrapper for FutureBuilder and StreamBuilder, this provides auto error
///checking and loading sign etc.
class CommonAsyncSnapshotResponses<T> extends StatelessWidget {
  String get _name => 'CommonAsyncSnapshotResponses<$T>';

  const CommonAsyncSnapshotResponses(
    this.snapshot, {
    Key? key,
    this.builder,
    this.debug = false,
    this.throwError = false,
    this.onLoading = const Center(child: CircularProgressIndicator()),
  }) : super(key: key);

  final AsyncSnapshot<T> snapshot;
  final Widget Function(T data)? builder;
  final Widget onLoading;
  final bool debug, throwError;

  @override
  Widget build(BuildContext context) {
    if (snapshot.connectionState == ConnectionState.waiting) return onLoading;
    if (snapshot.hasError) {
      if (debug) log('error: ${snapshot.error}', name: _name);
      if (throwError) throw snapshot.error!;
      return const Center(child: Text("Some Error occurred"));
    }
    if (!snapshot.hasData) {
      return const Center(child: Text("No Data Available"));
    }
    return builder == null ? Container() : builder!(snapshot.data!);
  }
}
