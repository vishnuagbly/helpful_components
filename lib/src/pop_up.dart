import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:helpful_components/helpful_components.dart';
import 'package:helpful_components/src/animated_in_out.dart';
import 'package:helpful_components/src/animation_switch_controller.dart';

class _PopupInherited extends InheritedWidget {
  final PopupController controller;

  const _PopupInherited({required this.controller, required Widget child})
      : super(child: child);

  @override
  bool updateShouldNotify(covariant _PopupInherited oldWidget) {
    return oldWidget.controller.id != controller.id;
  }
}

///To show and remove a popup on the screen.
///
///Get a [PopupController] object, using the [PopupController.of] static method.
///
///Using this, one can show popups either inside a [PopupScope] or using an
///[Overlay], i.e above the whole screen.
class PopupController {
  OverlayEntry? _overlayEntry;
  final String id;
  final GlobalKey<PopupScopeState>? key;
  AnimationSwitchController? _animationController;
  final BuildContext context;
  void Function()? onDismiss;
  bool _mounted = false;

  bool get mounted => _mounted;

  PopupController._({
    required this.context,
    required this.id,
    this.key,
    this.onDismiss,
  });

  void _mount(
    Widget child,
    bool animation,
    AnimationSwitchController? controller,
  ) {
    _mounted = true;

    if (animation) {
      _animationController = controller ?? AnimationSwitchController();
    }

    final scope = key?.currentState;
    if (scope != null) {
      scope.addPopup(id, child);
      return;
    }

    final overlayEntry = OverlayEntry(builder: (context) => child);
    Overlay.of(context).insert(overlayEntry);
    _overlayEntry = overlayEntry;
  }

  ///Shows [Popup] widget.
  ///
  ///This function returns an [PopupController] object, on which we can call
  ///the [remove] function to dynamically remove the popup.
  ///
  ///Can also get the same [PopupController] from inside the [Popup] widget
  ///tree, using [PopupController.of] method, on which one can call [remove]
  ///method.
  ///
  ///[barrierDismissible] and [showBarrier] only works in case of there is
  ///no [PopupScope] above in the widget tree.
  ///
  ///It is recommended for [builder] to return [Popup], while it can also return
  ///a [Positioned] or a [Builder] widget which returns [Positioned] or similar
  ///widget.
  ///
  ///Provide [onDismiss] function to perform any callback action on dismissing
  ///the popup.
  ///
  ///Provide [onHoverInBarrier] to provide a callback for the [onHover] method
  ///of the Barrier.
  ///
  ///Provide [dismissCondition] to dismiss the popup conditionally.
  PopupController show({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    bool showBarrier = false,
    Color barrierColor = Colors.black38,
    AnimationSwitchController? animationController,
    bool animation = false,
    void Function(PointerHoverEvent)? onHoverInBarrier,
    bool Function(TapDownDetails)? dismissCondition,
    void Function()? onDismiss,
  }) {
    if (onDismiss != null) this.onDismiss = onDismiss;

    if (mounted) {
      throw PlatformException(
        code: 'POPUP_ALREADY_EXIST',
        message: 'A popup is already being shown, using this controller',
      );
    }

    Widget child = _PopupInherited(
      controller: this,
      child: Builder(builder: builder),
    );

    if (key == null) {
      child = Stack(
        children: [
          if (showBarrier)
            IgnorePointer(
              ignoring: !barrierDismissible,
              child: Material(
                color: Colors.transparent,
                child: MouseRegion(
                  onHover: onHoverInBarrier,
                  child: GestureDetector(
                    onTapDown: (details) async {
                      if (!((dismissCondition?.call(details) ?? true) &&
                          barrierDismissible)) {
                        return;
                      }
                      await remove();
                    },
                    child: Container(
                      color: barrierColor,
                    ),
                  ),
                ),
              ),
            ),
          child,
        ],
      );
    }

    _mount(child, animation, animationController);
    return this;
  }

  ///Removes the popup, being shown via this controller.
  ///
  ///If no popup is being shown via this controller then, this will throw
  ///error.
  Future<void> remove() async {
    if (!_mounted) {
      throw PlatformException(
        code: 'NO_POPUP',
        message: 'No popup as added to remove',
      );
    }

    if (_animationController != null) {
      await _animationController!.setValue(true);
      _animationController!.dispose();
      _animationController = null;
    }

    onDismiss?.call();
    if (_overlayEntry != null) return _overlayEntry!.remove();
    key?.currentState?.removePopup(id);
    _mounted = false;
  }

  static String get _uniqueId => DateTime.now().toString();

  ///Return a [PopupController] object. This also determines, whether the popup
  ///will show using an [Overlay] over whole screen, or inside a [PopupScope].
  ///
  ///[PopupController] returned, will be of the nearest [PopupScope] parent,
  ///which if not exists, then it will be for [Overlay].
  ///
  ///If called inside a [Popup] will return the [PopupController] of that
  ///[Popup] only, i.e cannot use it to show more [Popup], but instead can use
  ///to remove the [Popup] dynamically, using [PopupController.remove] method.
  ///
  ///If [forceOverlay] is true, then pop up will be displayed as an
  ///[OverlayEntry], i.e like there is no [PopupScope] above in the widget tree,
  ///regardless of it actually exists or not.
  ///
  ///Use [id] to specify own specific id, of the popup.
  ///
  ///Provide [onDismiss] function to perform any callback action on dismissing
  ///the popup.
  static PopupController of(
    BuildContext context, {
    String? id,
    bool forceOverlay = false,
    void Function()? onDismiss,
  }) {
    final popupInherited =
        context.dependOnInheritedWidgetOfExactType<_PopupInherited>();
    if (popupInherited != null) return popupInherited.controller;

    id ??= _uniqueId;
    final scope = forceOverlay ? null : PopupScope.of(context);
    return PopupController._(
      context: context,
      id: id,
      key: scope?.key,
      onDismiss: onDismiss,
    );
  }
}

///Create a popup, here [parentKey] key is important as the popup will appear
///according to the parent widget represented by the [parentKey] only.
class Popup extends StatefulWidget {
  ///NOTE:- This widget uses [PositionedAlign] Widget, which may cause, loss of
  ///frame. For further information, look into the Documentation of
  ///[PositionedAlign].
  ///
  ///This should be returned from the builder parameter of [PopupController.show].
  ///
  ///Show this widget by firstly getting a [PopupController] object using
  ///[PopupController.of] static method. For further information look
  ///documentation of [PopupController].
  ///
  ///Also can use [PopupScope] to show popups localized on a widget, i.e popup
  ///will only be displayed inside that widget, using offsets local to that
  ///widget. For further information look documentation of [PopupScope].
  ///
  ///Uses [PositionedAlign] to align the child according to the given alignment.
  ///
  ///For preventing frame loss, define [childSize].
  ///
  ///Create a popup, here [parentKey] key is important as the popup will appear
  ///according to the parent widget represented by the [parentKey].
  ///
  ///If [parentKey] is not provided then the popup will appear at the top-left
  ///corner of the screen or [PopupScope]. Use [childAlign] and [offset]
  ///parameters to add offset and align the popup.
  ///
  ///Note:- To enable animation, Set [animation] from [PopupController.show] to
  ///true.
  const Popup({
    required this.child,
    this.parentKey,
    Key? key,
    this.childAlign = Alignment.topLeft,
    this.parentAlign = Alignment.bottomRight,
    this.childSize,
    this.offset = Offset.zero,
    this.transitionBuilder,
    this.builder,
    this.switchOutCurve = Curves.linear,
    this.switchInCurve = Curves.linear,
    this.inAnimationWithController = false,
  }) : super(key: key);

  final Widget child;

  ///GlobalKey of the parent widget in the widget tree, relative to which we
  ///want to show our popup.
  final GlobalKey? parentKey;

  ///To add an offset to the popup from its position after [parentAlign].
  final Offset offset;

  ///Defines the popup alignment at the [parentAlign] position of the parent.
  final Alignment childAlign;

  ///Determines the position of parent where, the pop will be.
  final Alignment parentAlign;

  ///If not null, then will be passed to [PositionedAlign] to prevent it from
  ///creating the popup "lazily".
  final Size? childSize;

  ///This will be called after the size of [child] is found. As default it will
  ///return the [child] only.
  ///
  ///Note:- This should not change the size of the [child], for correct
  ///positioning and alignment.
  ///
  ///Note:- This is not called when either [childSize] is not null, or,
  ///[childAlign] is [Alignment.topLeft].
  final LazyWidgetBuilder? builder;

  final AnimatedSwitcherTransitionBuilder? transitionBuilder;
  final Curve switchInCurve;
  final Curve switchOutCurve;
  final bool inAnimationWithController;

  @override
  PopupState createState() => PopupState();
}

class PopupState extends State<Popup> {
  late final RenderBox? renderBox;
  late final Size? size;

  @override
  void initState() {
    renderBox =
        widget.parentKey?.currentContext?.findRenderObject() as RenderBox?;
    size = renderBox?.size;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    defaultBuilder(BuildContext context, RenderBox box, Widget child) => child;
    final builder = widget.builder ?? defaultBuilder;

    var position = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final scopeBox = PopupScope.of(context)
        ?.key
        .currentContext
        ?.findRenderObject() as RenderBox?;
    if (scopeBox != null && widget.parentKey != null) {
      position -= scopeBox.localToGlobal(Offset.zero);
    }
    final size = this.size ?? Size.zero;
    final halfWidth = size.width / 2;
    final halfHeight = size.height / 2;
    position += Offset(
      (widget.parentAlign.x * halfWidth) + halfWidth,
      (widget.parentAlign.y * halfHeight) + halfHeight,
    );
    position += widget.offset;

    final controller = PopupController.of(context);

    ///This is the main child content, i.e without animations.
    final staticChild = Material(
      color: Colors.transparent,
      child: widget.child,
    );

    Widget genChild(Widget child) {
      Widget animatedChild(Widget child) {
        return AnimatedInOut(
          duration: controller._animationController?.duration,
          controller: controller._animationController,
          transitionBuilder: widget.transitionBuilder,
          switchInCurve: widget.switchInCurve,
          switchOutCurve: widget.switchOutCurve,
          child: child,
        );
      }

      return controller._animationController != null
          ? animatedChild(child)
          : child;
    }

    return PositionedAlign(
      offset: position,
      alignment: widget.childAlign,
      size: widget.childSize,
      child: widget.childSize != null ? genChild(staticChild) : staticChild,
      builder: (_, __, child) => genChild(builder(_, __, child)),
    );
  }
}
