import 'package:flutter/material.dart';

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
      child: Builder(
          builder: (context) => Stack(
                children: [
                  widget.builder(context),
                  ...popups.values,
                ],
              )),
    );
  }
}
