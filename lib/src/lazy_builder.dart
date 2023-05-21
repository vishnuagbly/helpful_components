import 'package:flutter/material.dart';

typedef LazyOnErrorWidgetBuilder = Widget Function(
    BuildContext, Object?, Widget);

typedef LazyWidgetBuilder = Widget Function(BuildContext, RenderBox, Widget);

///Can be used to build a [Widget] lazily, such that, we can get the [RenderBox]
///for the [Widget] then build another widget accordingly.
class LazyBuilder extends StatefulWidget {
  ///This can be used to build a [Widget] lazily, such that, we can get the
  ///[RenderBox] for the [Widget] then build another widget accordingly.
  const LazyBuilder({
    Key? key,
    required this.child,
    this.builder,
    this.onError,
    this.forceTry,
    this.emptyOnError = false,
    this.constraints,
    this.preventRedundantRebuilds = false,
  }) : super(key: key);

  ///[Widget] for which a [RenderBox] is generated.
  final Widget child;

  ///Provides the [BuildContext], [RenderBox] of the offstage [child], and the
  ///[child] itself.
  ///
  ///Default function, will simply return [child] itself.
  final LazyWidgetBuilder? builder;

  ///Used to generate [Widget] in case of an error. Error is passed as Nullable
  ///[Object].
  ///
  ///It provides [BuildContext], error and [child].
  ///
  ///Default function, will simple return [child] itself, unless [emptyOnError]
  ///is true, in which case, default function, will return empty [Container].
  final LazyOnErrorWidgetBuilder? onError;

  ///If it is true, then the [child] in offstage will be displayed until the
  ///[RenderBox] for [child] is found or not null.
  ///
  ///Default value is false.
  final bool? forceTry;

  ///If it is true, then [onError] default function, will return empty
  ///[Container].
  final bool emptyOnError;

  ///If is not null, then the [child] is displayed with these [BoxConstraints]
  ///as parent's [BoxConstraints] in offstage. i.e [child]'s [RenderBox] is
  ///found under these [BoxConstraints].
  final BoxConstraints? constraints;

  ///If it is true, then the [RenderBox] will be generated again, only if the
  ///[child]'s key has changed, instead of every build.
  final bool preventRedundantRebuilds;

  @override
  State<LazyBuilder> createState() => _LazyBuilderState();
}

class _LazyBuilderState extends State<LazyBuilder> {
  late GlobalKey key;
  late bool forceTry;
  OverlayEntry? overlayEntry;
  var offstage = true;
  Object? error;
  RenderBox? renderBox;

  void _init() {
    offstage = true;
    forceTry = widget.forceTry ?? false;
    key = GlobalKey();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      } catch (err) {
        error = err;
      }
      if (forceTry || renderBox != null) {
        offstage = false;
      }
      setState(() {});
    });
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant LazyBuilder oldWidget) {
    if (widget.preventRedundantRebuilds) {
      if (widget.child.key != oldWidget.child.key) _init();
    } else {
      if (widget.child != oldWidget.child) _init();
    }
    super.didUpdateWidget(oldWidget);
  }

  Widget get offstageChild {
    final child = Container(
      key: key,
      child: widget.child,
    );
    final parentConstraints = widget.constraints;
    return Offstage(
      offstage: true,
      child: parentConstraints == null
          ? child
          : OverflowBox(
              maxHeight: parentConstraints.maxHeight,
              minHeight: parentConstraints.minHeight,
              maxWidth: parentConstraints.maxWidth,
              minWidth: parentConstraints.minWidth,
              child: child,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    defaultChildFn(BuildContext _, __, Widget child) => child;
    emptyContainerFn(BuildContext _, __, Widget child) => Container();
    final onError = widget.onError ??
        (widget.emptyOnError ? emptyContainerFn : defaultChildFn);
    final builder = widget.builder ?? defaultChildFn;

    if (offstage) return offstageChild;
    if (renderBox == null) {
      return onError(context, error, widget.child);
    }
    return builder(context, renderBox!, widget.child);
  }
}
