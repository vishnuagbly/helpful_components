import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'animation_switch_controller.dart';

class AnimatedInOut extends StatefulWidget {
  const AnimatedInOut({
    Key? key,
    required this.child,
    this.controller,
    this.transitionBuilder,
    this.duration,
    this.switchInCurve = Curves.linear,
    this.switchOutCurve = Curves.linear,
    this.inAnimationWithController = false,
  }) : super(key: key);

  final Widget child;
  final AnimationSwitchController? controller;

  ///Used for [AnimatedSwitcher.transitionBuilder].
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;
  final Curve switchInCurve;
  final Curve switchOutCurve;
  final Duration? duration;

  ///If this is true, then the "in animation" will happen only if the
  ///[controller] value is true initially, which, will be then changed to false.
  ///
  ///i.e, if the [controller] value is false initially, no "in animation" will
  ///be there, instead the [child] will be shown directly.
  final bool inAnimationWithController;

  @override
  State<AnimatedInOut> createState() => _AnimatedInOutState();
}

class _AnimatedInOutState extends State<AnimatedInOut> {
  static final _emptyContainer = Container(key: UniqueKey());
  Widget child = _emptyContainer;
  late AnimationSwitchController controller;

  void tryNextSetState(void Function() fn) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(fn);
    });
  }

  void trySetState(void Function() fn) {
    if (mounted) setState(fn);
  }

  @override
  void initState() {
    controller = widget.controller ??
        AnimationSwitchController(
          duration: widget.duration ?? kThemeAnimationDuration,
        );

    //Here this works like this:-
    //For [controller.value] is [true], [child] should be the [_emptyContainer]
    //and otherwise should be the actual Widget, i.e [widget.child].
    //
    //State of the [child] is always supposed to be changed to [widget.child]
    //either in next frame, with animation or without animation from the start
    //only.
    //
    //So here, initially, during the initState of the widget, if
    //[controller.value] is [false] then, [child] should be [widget.child],
    //then if [widget.inAnimationWithController] is true, [child] will be
    //updated before [build] otherwise in the next frame.
    //
    //While if initially, [controller.value] is [true] then, it means, in first
    //build [child] should be [_emptyContainer] only, doesn't matter the value
    //of [widget.inAnimationWithController], [controller.value] will be changed
    //to [false] in next frame, hence, also changing the state of [child] to
    //[widget.child] because of the [_outListener] added to the controller.
    if (!controller.value) {
      if (widget.inAnimationWithController) {
        child = widget.child;
      } else {
        tryNextSetState(() => child = widget.child);
      }
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.value = false;
      });
    }
    controller.addListener(_outListener);
    log('initiated in animation', name: 'animated_in_out');
    super.initState();
  }

  void _outListener() {
    log('listening new value ${controller.value}');
    if (controller.value) {
      trySetState(() => child = _emptyContainer);
    } else if (child == _emptyContainer) {
      trySetState(() => child = widget.child);
    }
  }

  @override
  void dispose() {
    controller.removeListener(_outListener);

    //If user has not provided controller themselves then dispose the internally
    //created controller.
    if (widget.controller == null) controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: controller.duration,
      transitionBuilder:
          widget.transitionBuilder ?? AnimatedSwitcher.defaultTransitionBuilder,
      switchInCurve: widget.switchInCurve,
      switchOutCurve: widget.switchOutCurve,
      child: child,
    );
  }
}
