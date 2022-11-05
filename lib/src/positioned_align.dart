import 'package:flutter/material.dart';

import 'lazy_builder.dart';

///A widget that will control where the child of the [Stack] will be placed and
///at what position, according to the [alignment], of the [child] will be the
///[offset].
///
///Example:-
///```dart
///PositionedAlign(
///  x: 10,
///  y: 10,
///  alignment: Alignment.center,
///  child: Container(
///    color: Colors.red,
///    width: 100,
///    height: 100,
///  ),
///);
///```
///
///In the above case, at [offset] from the top-left corner of the [Stack], there
///will be the center of the [child].
///
///Note:- This uses [LazyBuilder] to position [child] according to the
///alignment, therefore, it might not always be able to position it correctly,
///always. Hence, it is recommended to define [onError] or [forceTry] variables.
class PositionedAlign extends StatefulWidget {
  const PositionedAlign({
    this.offset,
    this.alignment = Alignment.topLeft,
    this.forceTry,
    this.onError,
    this.size,
    required this.child,
    Key? key,
  }) : super(key: key);

  ///[Offset] of the [child] from the top-left corner of the stack.
  ///
  ///Default value is [Offset.zero].
  final Offset? offset;

  ///The place or position of the [offset] inside the [child].
  ///
  ///Example:-
  ///```dart
  ///PositionedAlign(
  ///  x: 10,
  ///  y: 10,
  ///  alignment: Alignment.center,
  ///  child: Container(
  ///    color: Colors.red,
  ///    width: 100,
  ///    height: 100,
  ///  ),
  ///);
  ///```
  ///
  ///In the above case, at [offset] from the top-left corner of the [Stack],
  ///there will be the center of the [child].
  final Alignment alignment;

  final Widget child;

  ///If this is not-null, then position will NOT be aligned "lazily".
  ///
  ///Note: One way to get it, is using [LazyBuilder].
  final Size? size;

  ///Value of [LazyBuilder.forceTry], if true, will not display the [child]
  ///until the [RenderBox] of the [child] is obtained.
  ///
  ///If null, default value is according to [LazyBuilder].
  final bool? forceTry;

  ///This will be displayed in case, the [LazyBuilder] is not able to find the
  ///size of the [child].
  ///
  ///Default function, will simple put the [child] according to
  ///[Alignment.topLeft].
  final LazyOnErrorWidgetBuilder? onError;

  @override
  State<PositionedAlign> createState() => _PositionedAlignState();
}

class _PositionedAlignState extends State<PositionedAlign> {
  late final Widget child;
  late final Offset offset;
  late final LazyOnErrorWidgetBuilder onError;

  Offset getCorrectedOffset(Size size) {
    final halfWidth = size.width / 2;
    final halfHeight = size.height / 2;
    final alignOffset = Offset(widget.alignment.x + 1, widget.alignment.y + 1);
    return offset -
        Offset(alignOffset.dx * halfWidth, alignOffset.dy * halfHeight);
  }

  @override
  void initState() {
    child = widget.child;
    offset = widget.offset ?? Offset.zero;
    onError = widget.onError ??
        (_, __, child) => Positioned(
              left: offset.dx,
              top: offset.dy,
              child: child,
            );
    super.initState();
  }

  Widget correctedOffsetWidget(Size size, Widget child) {
    final correctOffset = getCorrectedOffset(size);
    return Positioned(
      left: correctOffset.dx,
      top: correctOffset.dy,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.size != null) return correctedOffsetWidget(widget.size!, child);

    return LazyBuilder(
      onError: onError,
      builder: (context, box, child) => correctedOffsetWidget(box.size, child),
      forceTry: widget.forceTry,
      child: child,
    );
  }
}
