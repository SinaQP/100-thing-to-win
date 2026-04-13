import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppMotion {
  const AppMotion._();

  static const Duration quick = Duration(milliseconds: 160);
  static const Duration short = Duration(milliseconds: 220);
  static const Duration medium = Duration(milliseconds: 280);
  static const Duration long = Duration(milliseconds: 380);

  static const Curve enterCurve = Cubic(0.16, 1, 0.3, 1);
  static const Curve exitCurve = Cubic(0.4, 0, 1, 1);
  static const Curve emphasisCurve = Cubic(0.22, 1, 0.36, 1);

  static CustomTransitionPage<T> page<T>({
    required LocalKey key,
    required Widget child,
    Offset beginOffset = const Offset(0, 0.03),
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: medium,
      reverseTransitionDuration: short,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: enterCurve,
          reverseCurve: exitCurve,
        );

        return FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(curved),
          child: SlideTransition(
            position: Tween<Offset>(begin: beginOffset, end: Offset.zero)
                .animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

class AppFadeSlideIn extends StatefulWidget {
  const AppFadeSlideIn({
    required this.child,
    super.key,
    this.delay = Duration.zero,
    this.duration = AppMotion.medium,
    this.beginOffset = const Offset(0, 0.04),
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset beginOffset;

  @override
  State<AppFadeSlideIn> createState() => _AppFadeSlideInState();
}

class _AppFadeSlideInState extends State<AppFadeSlideIn> {
  Timer? _timer;
  var _visible = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: widget.duration,
      curve: AppMotion.enterCurve,
      opacity: _visible ? 1 : 0,
      child: AnimatedSlide(
        duration: widget.duration,
        curve: AppMotion.enterCurve,
        offset: _visible ? Offset.zero : widget.beginOffset,
        child: widget.child,
      ),
    );
  }
}

class AppScaleIn extends StatefulWidget {
  const AppScaleIn({
    required this.child,
    super.key,
    this.delay = Duration.zero,
    this.duration = AppMotion.short,
    this.beginScale = 0.96,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double beginScale;

  @override
  State<AppScaleIn> createState() => _AppScaleInState();
}

class _AppScaleInState extends State<AppScaleIn> {
  Timer? _timer;
  var _visible = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: widget.duration,
      curve: AppMotion.enterCurve,
      opacity: _visible ? 1 : 0,
      child: AnimatedScale(
        duration: widget.duration,
        curve: AppMotion.emphasisCurve,
        scale: _visible ? 1 : widget.beginScale,
        child: widget.child,
      ),
    );
  }
}

class AppCompletionFeedback extends StatelessWidget {
  const AppCompletionFeedback({
    required this.completed,
    required this.child,
    super.key,
  });

  final bool completed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: AppMotion.short,
      curve: AppMotion.emphasisCurve,
      scale: completed ? 1.02 : 1,
      child: child,
    );
  }
}
