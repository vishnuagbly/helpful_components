import 'package:flutter/material.dart';

import 'hero_data.dart';

class SHeroScopeData {
  SHeroScopeData(
    this.key, {
    bool value = false,
    Map<String, HeroData>? heroes,
  })  : inAnimation = ValueNotifier<bool>(value),
        heroes = heroes ?? {} {
    debugPrint('scope data key: $key');
  }

  final GlobalKey<SHeroScopeState> key;
  final ValueNotifier<bool> inAnimation;
  final Map<String, HeroData> heroes;
}

class _InheritedSHeroScope extends InheritedWidget {
  final SHeroScopeData data;

  const _InheritedSHeroScope({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant _InheritedSHeroScope oldWidget) {
    return oldWidget.data.key != data.key;
  }
}

class SHeroScope extends StatefulWidget {
  ///Wrap your widget, inside which want to show localised popups.
  ///
  ///As default [PopupController] object, generated or gotten inside this will
  ///show [Popup] inside this only.
  ///
  ///[key] should not change when the [setState] is called for Hero Animation
  ///trigger.
  ///
  ///Note:- SHeroScope will expand to take all the space available by the
  ///Parent Widget.
  const SHeroScope({
    required GlobalKey<SHeroScopeState> key,
    required this.child,
    this.duration = const Duration(milliseconds: 100),
  }) : super(key: key);

  final Widget child;
  final Duration duration;

  @override
  State<SHeroScope> createState() => SHeroScopeState();

  static SHeroScopeData? of(BuildContext context) {
    return context.findAncestorWidgetOfExactType<_InheritedSHeroScope>()?.data;
  }
}

class SHeroScopeState extends State<SHeroScope> {
  final Map<String, Widget> popups = {};
  late final SHeroScopeData data;

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
  void initState() {
    data = SHeroScopeData(widget.key as GlobalKey<SHeroScopeState>);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedSHeroScope(
      data: data,
      child: AnimatedSwitcher(
        duration: widget.duration,
        child: Container(
          color: Colors.green[900],
          child: Stack(
            children: [
              SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: widget.child,
              ),
              ...popups.values,
            ],
          ),
        ),
      ),
    );
  }
}
