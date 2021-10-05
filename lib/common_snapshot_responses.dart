import 'package:flutter/material.dart';

///Common Wrapper for FutureBuilder and StreamBuilder, this provides auto error
///checking and loading sign etc.
class CommonAsyncSnapshotResponses<T> extends StatelessWidget {
  const CommonAsyncSnapshotResponses(
    this.snapshot, {
    Key? key,
    this.builder,
    this.onLoading = const Center(child: CircularProgressIndicator()),
  }) : super(key: key);

  final AsyncSnapshot<T> snapshot;
  final Widget Function(T data)? builder;
  final Widget onLoading;

  @override
  Widget build(BuildContext context) {
    if (snapshot.connectionState == ConnectionState.waiting) return onLoading;
    if (snapshot.hasError) {
      return const Center(child: Text("Some Error occurred"));
    }
    if (!snapshot.hasData) {
      return const Center(child: Text("No Data Available"));
    }
    return builder == null ? Container() : builder!(snapshot.data!);
  }
}
