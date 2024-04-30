import 'package:flutter/material.dart';
import 'package:helpful_components/helpful_components.dart';

class PopupScopeData {
  PopupScopeData(this.key);

  final GlobalKey<PopupScopeState> key;
}

class _InheritedPopupScope extends InheritedWidget {
  final PopupScopeData data;

  const _InheritedPopupScope({required this.data, required Widget child})
      : super(child: child);

  @override
  bool updateShouldNotify(covariant _InheritedPopupScope oldWidget) {
    return oldWidget.data.key != data.key;
  }
}

class PopupScope extends StatefulWidget {
  ///Wrap your widget, inside which want to show localised popups.
  ///
  ///As default [PopupController] object, generated or gotten inside this will
  ///show [Popup] inside this only.
  ///
  ///Note:- PopupScope will expand to take all the space available by the
  ///Parent Widget.
  PopupScope({
    Key? key,
    required this.builder,
  }) : super(key: key ?? GlobalKey<PopupScopeState>());

  final WidgetBuilder builder;

  @override
  State<PopupScope> createState() => PopupScopeState();

  static PopupScopeData? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedPopupScope>()
        ?.data;
  }
}

class PopupScopeState extends State<PopupScope> {
  final Map<String, Widget> popups = {};

  void addPopup(String id, Widget popup) {
    setState(() {
      popups[id] = popup;
    });
  }

  void removePopup(String id) {
    setState(() {
      popups.remove(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedPopupScope(
      data: PopupScopeData(widget.key as GlobalKey<PopupScopeState>),
      child: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Builder(builder: widget.builder),
          ),
          ...popups.values,
        ],
      ),
    );
  }
}
