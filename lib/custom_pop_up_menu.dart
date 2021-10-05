import 'package:flutter/material.dart';

///Align type for the popup.
enum PopupAlign {
  belowLeft,
  belowCenter,
  belowRight,
}

///Shows [Popup] widget.
///
/// This function returns an [OverlayEntry] object, on which we can call
/// the remove function to dynamically remove the popup.
OverlayEntry showPopup({
  required BuildContext context,
  required Popup popup,
  bool barrierDismissible = true,
  bool showBarrierColor = false,
  Color barrierColor = Colors.black38,
}) {
  late final OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
      builder: (context) => Stack(
            children: [
              Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: barrierDismissible ? overlayEntry.remove : null,
                  child: Container(
                    color: showBarrierColor ? barrierColor : Colors.transparent,
                  ),
                ),
              ),
              popup,
            ],
          ));
  Overlay.of(context)!.insert(overlayEntry);
  return overlayEntry;
}

///Create a popup, here [parentKey] key is important as the popup will appear
///according to the parent widget represented by the [parentKey] only.
class Popup extends StatefulWidget {
  ///Create a popup, here [parentKey] key is important as the popup will appear
  ///according to the parent widget represented by the [parentKey] only.
  const Popup({
    required this.child,
    required this.parentKey,
    Key? key,
    this.align = PopupAlign.belowRight,
  })  : rect = null,
        relativeRect = null,
        super(key: key);

  ///Create a popup, here [parentKey] key is important as the popup will appear
  ///according to the parent widget represented by the [parentKey] only.
  ///
  /// Currently This constructor is under work.
  const Popup.fromRect({
    Key? key,
    required this.child,
    required this.parentKey,
    required this.rect,
  })  : align = null,
        relativeRect = null,
        super(key: key);

  ///Create a popup, here [parentKey] key is important as the popup will appear
  ///according to the parent widget represented by the [parentKey] only.
  ///
  /// Currently this constructor is under work.
  const Popup.fromRelativeRect({
    Key? key,
    required this.child,
    required this.parentKey,
    required this.relativeRect,
  })  : rect = null,
        align = null,
        super(key: key);

  final Widget child;

  ///GlobalKey of the parent widget in the widget tree, relative to which we
  ///want to show our popup.
  final GlobalKey parentKey;

  ///Set any predefined align method to your parent
  final PopupAlign? align;

  ///Currently this value is not used anywhere.
  final Rect Function(Size size, Offset pos)? rect;

  ///Currently this value is not used anywhere.
  final RelativeRect Function(Size size, Offset pos)? relativeRect;

  @override
  PopupState createState() => PopupState();
}

class PopupState extends State<Popup> {
  late RenderBox renderBox;
  late Size size;
  late Offset position;

  Alignment get alignment {
    switch (widget.align) {
      case PopupAlign.belowLeft:
        return Alignment.topLeft;
      case PopupAlign.belowCenter:
        return Alignment.topCenter;
      case PopupAlign.belowRight:
        break;
      case null:
        break;
    }
    return Alignment.topRight;
  }

  double get _left => position.dx;

  double get _right =>
      MediaQuery.of(context).size.width - position.dx - size.width;

  double get _top => position.dy;

  // double get _bottom =>
  //     MediaQuery.of(context).size.height - position.dy - size.height;

  @override
  void initState() {
    renderBox =
        widget.parentKey.currentContext!.findRenderObject() as RenderBox;
    size = renderBox.size;
    position = renderBox.localToGlobal(Offset.zero);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _top + size.height,
      left: _left,
      right: _right,
      child: Align(
        alignment: alignment,
        child: Material(
          color: Colors.transparent,
          child: widget.child,
        ),
      ),
    );
  }
}
