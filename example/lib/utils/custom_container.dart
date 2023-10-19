import 'dart:math';

import 'package:flutter/material.dart';

// ignore_for_file: public_member_api_docs

enum ShadowDirection {
  topLeft,
  top,
  topRight,
  right,
  bottomRight,
  bottom,
  bottomLeft,
  left,
  center,
}

class CustomContainer extends StatelessWidget {
  final double borderRadius;
  final double elevation;
  final double? height;
  final double? width;
  final Border? border;
  final BorderRadius? customBorders;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Widget? child;
  final Color color;
  final Color? shadowColor;
  final List<BoxShadow>? boxShadows;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final BoxShape boxShape;
  final AlignmentGeometry? alignment;
  final ShadowDirection shadowDirection;
  final Color? rippleColor;
  final bool animate;
  final Duration duration;
  const CustomContainer({
    Key? key,
    this.child,
    this.border,
    this.color = Colors.transparent,
    this.borderRadius = 0.0,
    this.elevation = 0.0,
    this.rippleColor,
    this.shadowColor = Colors.black12,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.height,
    this.width,
    this.margin,
    this.customBorders,
    this.alignment,
    this.boxShadows,
    this.animate = false,
    this.duration = const Duration(milliseconds: 200),
    this.boxShape = BoxShape.rectangle,
    this.shadowDirection = ShadowDirection.bottomRight,
    this.padding = const EdgeInsets.all(0),
  }) : super(key: key);

  static const double wrap = -1;
  static const double expand = -2;

  bool get circle => boxShape == BoxShape.circle;

  @override
  Widget build(BuildContext context) {
    final w = width == null || width == expand
        ? double.infinity
        : width == wrap
            ? null
            : width;
    final h = height == expand ? double.infinity : height;
    final br = customBorders ??
        BorderRadius.circular(
          boxShape == BoxShape.rectangle
              ? borderRadius
              : w != null
                  ? w / 2.0
                  : h != null
                      ? h / 2.0
                      : 0,
        );

    Widget content = Container(
      padding: padding,
      child: child,
    );

    if (boxShape == BoxShape.circle ||
        (customBorders != null || borderRadius > 0.0)) {
      content = ClipRRect(
        borderRadius: br,
        child: content,
      );
    }

    content = Material(
      color: Colors.transparent,
      type: MaterialType.transparency,
      shape: circle
          ? const CircleBorder()
          : RoundedRectangleBorder(borderRadius: br),
      child: InkWell(
        splashColor: onTap != null ? rippleColor : Colors.transparent,
        customBorder: circle
            ? const CircleBorder()
            : RoundedRectangleBorder(borderRadius: br),
        onTap: onTap,
        onLongPress: onLongPress,
        onDoubleTap: onDoubleTap,
        child: content,
      ),
    );

    final List<BoxShadow> boxShadow = boxShadows ??
        (elevation != 0
            ? [
                BoxShadow(
                  color: shadowColor ?? Colors.black12,
                  offset: _getShadowOffset(min(elevation / 5.0, 1.0)),
                  blurRadius: elevation,
                  spreadRadius: 0,
                ),
              ]
            : const []);

    final boxDecoration = BoxDecoration(
      color: color,
      borderRadius: circle ? null : br,
      shape: boxShape,
      boxShadow: boxShadow,
      border: border,
    );

    return animate
        ? AnimatedContainer(
            height: h,
            width: w,
            margin: margin,
            alignment: alignment,
            duration: duration,
            decoration: boxDecoration,
            child: content,
          )
        : Container(
            height: h,
            width: w,
            margin: margin,
            alignment: alignment,
            decoration: boxDecoration,
            child: content,
          );
  }

  Offset _getShadowOffset(double ele) {
    final ym = 5 * ele;
    final xm = 2 * ele;
    switch (shadowDirection) {
      case ShadowDirection.topLeft:
        return Offset(-1 * xm, -1 * ym);
      case ShadowDirection.top:
        return Offset(0, -1 * ym);
      case ShadowDirection.topRight:
        return Offset(xm, -1 * ym);
      case ShadowDirection.right:
        return Offset(xm, 0);
      case ShadowDirection.bottomRight:
        return Offset(xm, ym);
      case ShadowDirection.bottom:
        return Offset(0, ym);
      case ShadowDirection.bottomLeft:
        return Offset(-1 * xm, ym);
      case ShadowDirection.left:
        return Offset(-1 * xm, 0);
      default:
        return Offset.zero;
    }
  }
}
