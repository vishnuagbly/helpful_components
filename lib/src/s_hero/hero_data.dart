import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HeroData {
  final String tag;
  final ValueNotifier<bool> inAnimation;
  Size? size;
  Offset? firstPosition;
  bool isFull;

  HeroData({
    required this.tag,
    this.size,
    this.firstPosition,
    bool inAnimation = false,
    this.isFull = false,
  }) : inAnimation = ValueNotifier<bool>(inAnimation);

  void reset() {
    isFull = false;
    firstPosition = null;
    size = null;
  }

  void setFirst(BuildContext firstContext) {
    final box = firstContext.findRenderObject() as RenderBox?;
    if (box == null) {
      throw PlatformException(code: 'FIRST_RENDER_BOX_NOT_FOUND');
    }
    final key = firstContext.widget.key as GlobalKey?;
    if (key == null) {
      throw PlatformException(code: 'FIRST_KEY_NOT_FOUND');
    }

    size = box.size;
    firstPosition = box.localToGlobal(Offset.zero);
    log('set first, size: $size, firstPosition: $firstPosition',
        name: 'HeroData');
  }
}
