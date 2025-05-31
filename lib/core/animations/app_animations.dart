import 'package:flutter/material.dart';

class AppAnimations {
  static const Duration defaultDuration = Duration(milliseconds: 300);
  static const Duration fastDuration = Duration(milliseconds: 150);
  static const Duration slowDuration = Duration(milliseconds: 500);

  static Curve defaultCurve = Curves.easeInOut;
  static Curve bounceCurve = Curves.elasticOut;
  static Curve smoothCurve = Curves.easeOutCubic;

  static Widget fadeScale({
    required Widget child,
    required bool isVisible,
    Duration? duration,
    Curve? curve,
  }) {
    return AnimatedOpacity(
      duration: duration ?? defaultDuration,
      curve: curve ?? defaultCurve,
      opacity: isVisible ? 1.0 : 0.0,
      child: AnimatedScale(
        duration: duration ?? defaultDuration,
        curve: curve ?? defaultCurve,
        scale: isVisible ? 1.0 : 0.8,
        child: child,
      ),
    );
  }

  static Widget slideIn({
    required Widget child,
    required bool isVisible,
    Duration? duration,
    Curve? curve,
    Offset? offset,
  }) {
    return AnimatedSlide(
      duration: duration ?? defaultDuration,
      curve: curve ?? defaultCurve,
      offset: isVisible ? Offset.zero : (offset ?? const Offset(0, 0.1)),
      child: AnimatedOpacity(
        duration: duration ?? defaultDuration,
        curve: curve ?? defaultCurve,
        opacity: isVisible ? 1.0 : 0.0,
        child: child,
      ),
    );
  }

  static Widget pulse({
    required Widget child,
    required bool isActive,
    Duration? duration,
  }) {
    return AnimatedScale(
      duration: duration ?? defaultDuration,
      curve: bounceCurve,
      scale: isActive ? 1.1 : 1.0,
      child: child,
    );
  }
}


