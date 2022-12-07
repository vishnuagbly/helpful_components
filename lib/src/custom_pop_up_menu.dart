import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:helpful_components/src/animated_in_out.dart';
import 'package:helpful_components/src/animation_switch_controller.dart';

import 'pop_up_scope.dart';
import 'positioned_align.dart';

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
  bool _mounted = false;

  bool get mounted => _mounted;

  PopupController._({
    required this.context,
    required this.id,
    this.key,
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
    Overlay.of(context)!.insert(overlayEntry);
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
  ///[barrierDismissible] and [showBarrierColor] only works in case of there is
  ///no [PopupScope] above in the widget tree.
  PopupController show({
    required Popup Function(BuildContext context) builder,
    bool barrierDismissible = true,
    bool showBarrierColor = false,
    Color barrierColor = Colors.black38,
    AnimationSwitchController? animationController,
    bool animation = false,
  }) {
    if (mounted) {
      throw PlatformException(
        code: 'POPUP_ALREADY_EXIST',
        message: 'A popup is already being shown, using this controller',
      );
    }

    Widget child = _PopupInherited(
      controller: this,
      child: Builder(builder: (_) => builder(_)),
    );

    if (key == null) {
      child = Stack(
        children: [
          Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: barrierDismissible ? remove : null,
              child: Container(
                color: showBarrierColor ? barrierColor : Colors.transparent,
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
  static PopupController of(
    BuildContext context, {
    String? id,
    bool forceOverlay = false,
  }) {
    final popupInherited =
        context.dependOnInheritedWidgetOfExactType<_PopupInherited>();
    if (popupInherited != null) return popupInherited.controller;

    id ??= _uniqueId;
    final scope = forceOverlay ? null : PopupScope.of(context);
    return PopupController._(context: context, id: id, key: scope?.key);
  }
}

///Create a popup, here [parentKey] key is important as the popup will appear
///according to the parent widget represented by the [parentKey] only.
class Popup extends StatefulWidget {
  ///Widget to be returned from the builder parameter of [PopupController.show].
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

    final child = Material(
      color: Colors.transparent,
      child: widget.child,
    );

    return PositionedAlign(
      offset: position,
      alignment: widget.childAlign,
      size: widget.childSize,
      child: controller._animationController != null
          ? AnimatedInOut(
              duration: controller._animationController?.duration,
              controller: controller._animationController,
              transitionBuilder: widget.transitionBuilder,
              switchInCurve: widget.switchInCurve,
              switchOutCurve: widget.switchOutCurve,
              child: child,
            )
          : child,
    );
  }
}
