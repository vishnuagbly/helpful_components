import 'dart:developer';

import 'package:flutter/material.dart';

typedef VoidType = void;

///Common Wrapper for FutureBuilder and StreamBuilder, this provides auto error
///checking and loading sign etc.
class CommonAsyncSnapshotResponses<T> extends StatelessWidget {
  String get _name => 'CommonAsyncSnapshotResponses<$T>';

  const CommonAsyncSnapshotResponses(
    this.snapshot, {
    Key? key,
    this.onData,
    this.debug = false,
    this.throwError = false,
    this.onLoading,
    this.onError,
  }) : super(key: key);

  final AsyncSnapshot<T> snapshot;
  final Widget Function(T data)? onData;
  final bool debug, throwError;
  final Widget Function(Object? error)? onError;
  final Widget Function()? onLoading;

  @override
  Widget build(BuildContext context) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return (onLoading ??
          () => const Center(child: CircularProgressIndicator()))();
    }
    if (snapshot.hasError) {
      if (debug) log('error: ${snapshot.error}', name: _name);
      if (throwError) throw snapshot.error!;
      return (onError ??
          (_) =>
              const Center(child: Text("Some Error occurred")))(snapshot.error);
    }
    if (!snapshot.hasData && T != VoidType) {
      return const Center(child: Text("No Data Available"));
    }
    return onData == null ? Container() : onData!(snapshot.data as T);
  }
}
