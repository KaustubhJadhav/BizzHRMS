import 'package:flutter/material.dart';

/// Modern, smooth MaterialPageRoute with optimized animations
/// Uses Material Design 3 principles with hardware-accelerated transitions
class SmoothPageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;
  final RouteSettings? _settings;
  final bool _maintainState;

  SmoothPageRoute({
    required this.builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  })  : _settings = settings,
        _maintainState = maintainState;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => _maintainState;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 250);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 200);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Use Material Design 3 recommended curves for smooth, natural motion
    final forwardCurve = Curves.easeOut;
    final reverseCurve = Curves.easeIn;

    final forwardAnimation = CurvedAnimation(
      parent: animation,
      curve: forwardCurve,
      reverseCurve: reverseCurve,
    );

    // Modern fade + scale transition for smooth, polished feel
    return FadeTransition(
      opacity: forwardAnimation,
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.98,
          end: 1.0,
        ).animate(forwardAnimation),
        child: child,
      ),
    );
  }

  @override
  RouteSettings get settings => _settings ?? const RouteSettings();
}
