import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:widgets_playground/color_orb/utils.dart';

import 'color_orb.dart';

/// Painter for the globe.
class GlobePainter extends CustomPainter {
  final ColorOrbController _controller;
  final Color color;

  GlobePainter(this._controller, this.color) : super(repaint: _controller);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final sortedItems = List<OrbItem>.from(_controller.items)
      ..sort((a, b) => b.position.z.compareTo(a.position.z));

    for (var item in sortedItems) {
      final iconPosition = Offset(
        center.dx + item.position.x,
        center.dy + item.position.y,
      );

      final maxOpacity = (item.position.z + _controller.fullRadius) / (_controller.fullRadius * 2);
      final opacity = math.max(0.4, maxOpacity).clamp(0.0, 1.0);

      final paint = Paint()..color = color.withOpacity(opacity);

      canvas.drawCircle(iconPosition, 10, paint);
    }
  }

  @override
  bool shouldRepaint(GlobePainter oldDelegate) => false;
}

class BackgroundPainter extends CustomPainter {
  final double radius;
  final Color color;

  BackgroundPainter(this.radius, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final innerBlur = Paint()
      ..color = color.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    final outerBlur = Paint()
      ..color = darkenColor(color, 1).withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawCircle(center, radius + 15, outerBlur);
    canvas.drawCircle(center, radius, innerBlur);
  }

  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) => false;
}
