import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:helpful_components/helpful_components.dart';

import '../animated_in_out.dart';
import 'hero_data.dart';

class SHero extends StatefulWidget {
  SHero({
    GlobalKey? key,
    this.child,
    String? tag,
    this.useOverlay = false,
  })  : tag = tag ?? child.runtimeType.toString(),
        super(key: key ?? GlobalKey());

  final Widget? child;
  final String tag;
  final bool useOverlay;

  @override
  State<SHero> createState() => _SHeroState();
}

class _SHeroState extends State<SHero> {
  late final ValueNotifier<bool> inAnimation;
  late final Duration duration;
  late Widget child;
  late final Widget mainChild;
  late final void Function() animationListener;
  OverlayEntry? entry;

  RenderBox? get renderBox => context.findRenderObject() as RenderBox?;

  static final Widget defaultChild = Container(
    color: Colors.black12,
    width: 50,
    height: 50,
  );

  void startHeroAnimation(HeroData data) {
    log('Started Animation: ${DateTime.now()}', name: 'SHero');
    final currentBox = renderBox;
    if (currentBox == null) {
      log('Cannot found box, current: $currentBox', name: 'SHero');
      return;
    }

    final last = data.firstPosition;
    if (last == null) {
      throw PlatformException(
        code: 'LAST_CHILD_POS_NOT_FOUND',
        message: 'Cannot find last hero child position.',
      );
    }

    var current = currentBox.localToGlobal(Offset.zero);
    log('last pos: $last, current pos: $current', name: 'SHero');

    final difference = last - current;
    final beginningOffset = Offset(
      difference.dx / currentBox.size.width,
      difference.dy / currentBox.size.height,
    );

    transitionBuilder(child, animation) => SlideTransition(
          position: Tween<Offset>(
            begin: beginningOffset,
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );

    final scopeKey = SHeroScope.of(context)!.key;
    if (!widget.useOverlay) {
      final scopeBox = scopeKey.currentContext?.findRenderObject() as RenderBox;
      final scopeOffset = scopeBox.localToGlobal(Offset.zero);
      current = current - scopeOffset;
    }

    final child = Positioned(
      top: current.dy,
      left: current.dx,
      child: AnimatedInOut(
        duration: duration,
        transitionBuilder: transitionBuilder,
        child: mainChild,
      ),
    );

    if (widget.useOverlay) {
      entry = OverlayEntry(
        builder: (context) => Stack(
          children: [
            child,
          ],
        ),
      );
      Overlay.of(context).insert(entry!);
    } else {
      scopeKey.currentState!.addPopup(widget.tag, child);
    }
  }

  @override
  void initState() {
    super.initState();
    mainChild = widget.child ?? defaultChild;
    child = mainChild;

    final scope = SHeroScope.of(context);
    if (scope == null) {
      throw PlatformException(
        code: 'S_HERO_SCOPE_NOT_FOUND',
        message: 'SHero tagged as ${widget.tag} could not find S_HERO_SCOPE.',
      );
    }

    final animatedSwitcher =
        context.findAncestorWidgetOfExactType<AnimatedSwitcher>();
    if (animatedSwitcher == null) {
      throw PlatformException(
          code: 'ANIMATED_SWITCHER_NOT_FOUND',
          message:
              'SHero tagged as ${widget.tag} could not find AnimatedSwitcher.');
    }

    duration = animatedSwitcher.duration;
    final gKey = widget.key! as GlobalKey;
    final heroData =
        (scope.heroes[widget.tag]?..isFull = true) ?? HeroData(tag: widget.tag);
    inAnimation = heroData.inAnimation;
    final isSecondSHero = heroData.isFull;

    log('SHero key: $gKey', name: 'SHero');
    log('name: ${widget.tag}', name: 'SHero');
    log('heroData: ${scope.heroes[widget.tag]}', name: 'SHero');

    if (isSecondSHero) {
      if (heroData.size != null) {
        child = SizedBox.fromSize(size: heroData.size!);
      } else {
        throw PlatformException(
          code: 'SIZE_IS_NULL',
          message: 'HeroData.size is null even though on second SHero',
        );
      }
    } else {
      scope.heroes[widget.tag] = heroData;
    }

    if (!isSecondSHero) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        heroData.setFirst(context);
      });
    }

    animationListener = () {
      log(
        'called animation Listener, key: $gKey, value: '
        '${inAnimation.value} time: ${DateTime.now()}',
        name: 'SHero',
      );
      if (isSecondSHero && !inAnimation.value) {
        heroData.reset();
        heroData.setFirst(context);
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          if (inAnimation.value) {
            final size = heroData.size ?? renderBox?.size;
            if (size == null) {
              log(
                'Cannot find RenderBox, hence, cannot replace original SHero '
                'child, with SizedBox.',
                name: 'SHero',
              );
              throw PlatformException(code: 'RENDER_BOX_NOT_FOUND');
            }
            child = SizedBox.fromSize(size: size);
          }
        });
      });
    };

    inAnimation.addListener(animationListener);

    if (isSecondSHero) {
      log('starting hero animation, key: $gKey', name: 'SHero');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        inAnimation.value = true;
        startHeroAnimation(heroData);
        Future.delayed(duration).then((_) {
          inAnimation.value = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              child = mainChild;
            });
            try {
              if (widget.useOverlay) {
                entry?.remove();
              } else {
                scope.key.currentState!.removePopup(widget.tag);
              }
            } catch (err) {
              log('Cannot remove entry, error: $err', name: 'SHero');
            }
          });
        });
      });
    }
  }

  @override
  void dispose() {
    inAnimation.removeListener(animationListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => child;
}
