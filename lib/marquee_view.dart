library marquee_view;

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

part 'marquee_controller.dart';

enum MarqueeDirection {
  /// Right to Left
  rtl,

  /// Left to Right
  ltr,

  /// Top to Bottom
  ttb,

  /// Bottom to Top
  btt,
}

class MarqueeView extends StatefulWidget {
  const MarqueeView({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.backgroundColor,
    this.controller,
    this.direction = MarqueeDirection.rtl,
    this.padding = 0,
    this.spacing = 100,
    this.pps = 30,
    this.autoStart = true,
    this.autoStartDelayed = const Duration(milliseconds: 100),
    this.interaction = false,
    this.restartAfterInteraction = true,
    this.restartAfterInteractionDelayed = const Duration(seconds: 1),
  })  : assert(padding >= 0, "The value of `padding` cannot be less than 0"),
        assert(spacing >= 0, "The value of `spacing` cannot be less than 0"),
        assert(pps > 0, "The value of `pps` must be greater than 0"),
        assert(autoStart == false || autoStartDelayed >= Duration.zero,
            "If `autoStart` is true, `autoStartDelayed` cannot be less than zero"),
        assert(
            restartAfterInteraction == false ||
                restartAfterInteractionDelayed >= Duration.zero,
            "If `restartAfterInteraction` is true, `restartAfterInteractionDelayed` cannot be less than zero");

  final Widget child;

  /// Marquee width
  final double? width;

  /// Marquee width
  final double? height;

  /// Marquee backgroundColor
  final Color? backgroundColor;

  /// Controller
  final MarqueeController? controller;

  /// Direction
  final MarqueeDirection direction;

  /// Content padding in the scrolling direction
  final double padding;

  /// The spacing between the children of marquee
  final double spacing;

  /// Pixel per second
  final double pps;

  /// Auto start
  final bool autoStart;

  /// Auto Start delayed duration
  final Duration autoStartDelayed;

  /// Interactions
  final bool interaction;

  /// Restart after interaction stops
  final bool restartAfterInteraction;

  /// Restart after interaction stops delayed
  final Duration restartAfterInteractionDelayed;

  @override
  State<MarqueeView> createState() => _MarqueeViewState();
}

class _MarqueeViewState extends State<MarqueeView>
    with TickerProviderStateMixin {
  late final scrollController = ScrollController();

  late final isWebOrDesktop =
      kIsWeb || (!Platform.isAndroid && !Platform.isIOS);

  bool get isReverse =>
      widget.direction == MarqueeDirection.ltr ||
      widget.direction == MarqueeDirection.ttb;

  bool get isVertical =>
      widget.direction == MarqueeDirection.btt ||
      widget.direction == MarqueeDirection.ttb;

  Axis get scrollDirection => isVertical ? Axis.vertical : Axis.horizontal;

  EdgeInsetsGeometry get contentPadding => getContentPadding();

  EdgeInsetsGeometry get spacingPadding => getSpacingPadding();

  AnimationController? animationController;

  Animation<double>? animation;

  Timer? interactionTimer;

  double currentOffset = 0.0;

  void start() {
    if (mounted) {
      currentOffset = scrollController.offset;
      animationController?.value = 0;
      animationController?.forward();
    }
  }

  void stop() {
    if (mounted) {
      interactionTimer?.cancel();
      animationController?.stop();
    }
  }

  void reset() {
    if (mounted) {
      interactionTimer?.cancel();
      animationController?.reset();
      scrollController.jumpTo(0);
    }
  }

  void onPointerDown(PointerDownEvent event) {
    interactionTimer?.cancel();
    stop();
  }

  void onPointerUp(PointerUpEvent event) {
    if (widget.restartAfterInteraction) {
      interactionTimer = Timer(widget.restartAfterInteractionDelayed, () {
        start();
      });
    }
  }

  EdgeInsetsGeometry getContentPadding() {
    switch (widget.direction) {
      case MarqueeDirection.rtl:
        return EdgeInsets.only(left: widget.padding);
      case MarqueeDirection.ltr:
        return EdgeInsets.only(right: widget.padding);
      case MarqueeDirection.btt:
        return EdgeInsets.only(top: widget.padding);
      case MarqueeDirection.ttb:
        return EdgeInsets.only(bottom: widget.padding);
    }
  }

  EdgeInsetsGeometry getSpacingPadding() {
    switch (widget.direction) {
      case MarqueeDirection.rtl:
        return EdgeInsets.only(right: widget.spacing);
      case MarqueeDirection.ltr:
        return EdgeInsets.only(left: widget.spacing);
      case MarqueeDirection.btt:
        return EdgeInsets.only(bottom: widget.spacing);
      case MarqueeDirection.ttb:
        return EdgeInsets.only(top: widget.spacing);
    }
  }

  void initAnimation() {
    const tweenDistance = 2000.0;
    final milliseconds = (tweenDistance / widget.pps) * 1000;

    animationController?.dispose();
    animationController = AnimationController(
      duration: Duration(milliseconds: milliseconds.round()),
      vsync: this,
    );

    animationController?.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        start();
      }
    });

    animation = Tween<double>(begin: 0, end: tweenDistance)
        .animate(animationController!)
      ..addListener(() {
        scrollController.jumpTo(currentOffset + animation!.value);
      });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.autoStart) {
        Future.delayed(widget.autoStartDelayed, () {
          start();
        });
      }
    });
  }

  // void update() {
  //   if (mounted) {
  //     setState(() {});
  //   }
  // }

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);

    /// Wait for render to end
    WidgetsBinding.instance.addPostFrameCallback((Duration timestamp) {
      initAnimation();
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    animationController?.dispose();
    interactionTimer?.cancel();
    widget.controller?._detach(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final physics = widget.interaction
        ? const BouncingScrollPhysics()
        : const NeverScrollableScrollPhysics();

    Widget listView = ListView.builder(
      physics: physics,
      controller: scrollController,
      scrollDirection: scrollDirection,
      reverse: isReverse,
      padding: contentPadding,
      itemBuilder: (context, index) {
        return Padding(
          padding: spacingPadding,
          child: Center(child: widget.child),
        );
      },
    );

    if (widget.interaction) {
      if (isWebOrDesktop) {
        listView = ScrollConfiguration(
          behavior: _MouseDragScrollBehavior(),
          child: MouseRegion(
            onEnter: (_) => stop(),
            onExit: (_) => start(),
            child: listView,
          ),
        );
      }

      listView = Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: onPointerDown,
        onPointerUp: onPointerUp,
        child: listView,
      );
    }

    return Container(
      width: widget.width,
      height: widget.height,
      color: widget.backgroundColor,
      child: listView,
    );
  }
}

class _MouseDragScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices {
    return {
      PointerDeviceKind.touch,
      PointerDeviceKind.mouse,
    };
  }
}
