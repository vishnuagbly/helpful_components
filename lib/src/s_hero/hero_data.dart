import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 's_hero_scope.dart';

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
    final scopeData = SHeroScope.of(firstContext);
    if (scopeData == null) {
      throw PlatformException(code: 'S_HERO_SCOPE_NOT_FOUND');
    }

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

    if (!scopeData.useOverlay) {
      final scopeBox =
          scopeData.key.currentContext?.findRenderObject() as RenderBox?;
      if (scopeBox == null) {
        throw PlatformException(code: 'SCOPE_BOX_NOT_FOUND');
      }

      firstPosition = firstPosition! - scopeBox.localToGlobal(Offset.zero);
    }
    log('set first, size: $size, firstPosition: $firstPosition',
        name: 'HeroData');
  }
}
