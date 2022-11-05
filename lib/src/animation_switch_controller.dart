import 'package:flutter/material.dart';

class AnimationSwitchController extends ValueNotifier<bool> {
  final Duration duration;

  AnimationSwitchController({
    Duration? duration,
    bool value = false,
  })  : duration = duration ?? kThemeAnimationDuration,
        super(value);

  Future<void> setValue(bool newValue) {
    value = newValue;
    return Future.delayed(duration + kThemeChangeDuration);
  }
}
