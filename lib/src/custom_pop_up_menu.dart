import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Pop_up_scope.dart';
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

class PopupController {
  OverlayEntry? _overlayEntry;
  final String id;
  final GlobalKey<PopupScopeState>? key;
  final BuildContext context;
  bool _mounted = false;

  bool get mounted => _mounted;

  PopupController._({
    required this.context,
    required this.id,
    this.key,
  });

  void _mount(Widget child) {
    _mounted = true;

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

    _mount(child);
    return this;
  }

  ///Removes the popup, being shown via this controller.
  ///
  ///If no popup is being shown via this controller then, this will throw
  ///error.
  void remove() {
    if (!_mounted) {
      throw PlatformException(
        code: 'NO_POPUP',
        message: 'No popup as added to remove',
      );
    }
    if (_overlayEntry != null) return _overlayEntry!.remove();
    key?.currentState?.removePopup(id);
    _mounted = false;
  }

  static String get _uniqueId => DateTime.now().toString();

  ///If [forceOverlay] is true, then pop up will be displayed as an
  ///[OverlayEntry], i.e like there is no [PopupScope] above in the widget tree,
  ///regardless of it actually exists or not.
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
  ///Uses [PositionedAlign] to align the child according to the given alignment.
  ///
  ///For preventing frame loss, define
  ///
  ///Create a popup, here [parentKey] key is important as the popup will appear
  ///according to the parent widget represented by the [parentKey] only.
  const Popup({
    required this.child,
    required this.parentKey,
    Key? key,
    this.childAlign = Alignment.topLeft,
    this.parentAlign = Alignment.bottomRight,
    this.childSize,
  }) : super(key: key);

  final Widget child;

  ///GlobalKey of the parent widget in the widget tree, relative to which we
  ///want to show our popup.
  final GlobalKey parentKey;

  ///Defines the popup alignment at the [parentAlign] position of the parent.
  final Alignment childAlign;

  ///Determines the position of parent where, the pop will be.
  final Alignment parentAlign;

  ///If not null, then will be passed to [PositionedAlign] to prevent it from
  ///creating the popup "lazily".
  final Size? childSize;

  @override
  PopupState createState() => PopupState();
}

class PopupState extends State<Popup> {
  late final RenderBox renderBox;
  late final Size size;

  @override
  void initState() {
    renderBox =
        widget.parentKey.currentContext!.findRenderObject() as RenderBox;
    size = renderBox.size;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var position = renderBox.localToGlobal(Offset.zero);
    final scopeBox = PopupScope.of(context)
        ?.key
        .currentContext
        ?.findRenderObject() as RenderBox?;
    if (scopeBox != null) {
      position -= scopeBox.localToGlobal(Offset.zero);
    }
    position += Offset(
      widget.parentAlign.x * size.width,
      widget.parentAlign.y * size.height,
    );

    return PositionedAlign(
      offset: position,
      alignment: widget.childAlign,
      size: widget.childSize,
      child: Material(
        color: Colors.transparent,
        child: widget.child,
      ),
    );
  }
}
