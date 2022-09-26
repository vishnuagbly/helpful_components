import 'package:flutter/material.dart';

typedef LazyOnErrorWidgetBuilder = Widget Function(
    BuildContext, Object?, Widget);

///Can be used to build a [Widget] lazily, such that, we can get the [RenderBox]
///for the [Widget] then build another widget accordingly.
class LazyBuilder extends StatefulWidget {
  const LazyBuilder({
    Key? key,
    required this.child,
    this.builder,
    this.onError,
    this.forceTry,
    this.emptyOnError = false,
  }) : super(key: key);

  ///[Widget] for which a [RenderBox] is generated.
  final Widget child;

  ///Provides the [BuildContext], [RenderBox] of the offstage [child], and the
  ///[child] itself.
  ///
  ///Default function, will simply return [child] itself.
  final Widget Function(BuildContext, RenderBox, Widget)? builder;

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

  @override
  State<LazyBuilder> createState() => _LazyBuilderState();
}

class _LazyBuilderState extends State<LazyBuilder> {
  final GlobalKey key = GlobalKey();
  late final bool forceTry;
  var offstage = true;
  Object? error;
  RenderBox? renderBox;

  @override
  void initState() {
    forceTry = widget.forceTry ?? false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      } catch (err) {
        error = err;
      }
      if (forceTry || renderBox != null) offstage = false;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    defaultChildFn(BuildContext _, __, Widget child) => child;
    emptyContainerFn(BuildContext _, __, Widget child) => Container();
    final onError = widget.onError ??
        (widget.emptyOnError ? emptyContainerFn : defaultChildFn);
    final builder = widget.builder ?? defaultChildFn;

    if (offstage) {
      return Offstage(
        offstage: true,
        child: Container(
          key: key,
          child: widget.child,
        ),
      );
    }
    if (renderBox == null) {
      return onError(context, error, widget.child);
    }
    return builder(context, renderBox!, widget.child);
  }
}
