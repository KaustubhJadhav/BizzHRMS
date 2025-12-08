import 'package:flutter/material.dart';

/// Optimized glassmorphic container without expensive BackdropFilter
/// Uses simple gradient overlay for better performance
class GlassContainer extends StatelessWidget {
  final double? height;
  final double? width;
  final Widget? child;
  final double borderRadius;
  final Color borderColor;
  final Gradient gradient;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<BoxShadow>? boxShadow;

  const GlassContainer({
    super.key,
    this.height,
    this.width,
    this.child,
    this.borderRadius = 20,
    this.borderColor = Colors.white24,
    this.gradient = const LinearGradient(
      colors: [Colors.white24, Colors.white10],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    this.padding,
    this.margin,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        gradient: gradient,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
      ),
      child: child,
    );
  }
}
