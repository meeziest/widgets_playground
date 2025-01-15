import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:vector_math/vector_math.dart' as vector;
import 'package:widgets_playground/widgets/color_orb/painter.dart';

class OrbItem {
  final String name;
  final Color? color;
  vector.Vector3 position;
  double scale;

  OrbItem({
    required this.name,
    required this.position,
    this.color,
    this.scale = 1.0,
  });
}

class ColorOrbController extends ChangeNotifier {
  List<OrbItem> items = [];
  double fullRadius;
  Color color;

  /// Holds the current rotation and transformation matrix
  vector.Matrix4 currentMatrix = vector.Matrix4.identity();

  ColorOrbController({required this.color, required this.fullRadius});

  void generateParticles(int particlesCount, double radius) {
    fullRadius = radius;
    if (particlesCount < 2) return;

    final itemCount = particlesCount;
    final double goldenAngle = math.pi * (3 - math.sqrt(5)); // Golden angle approximation

    items = List.generate(itemCount, (index) {
      final double y = 1 - (index / (itemCount - 1)) * 2; // y ranges from 1 to -1
      final double radius = math.sqrt(1 - y * y); // Calculate radius at current y level

      final double theta = goldenAngle * index; // Uniformly distribute points in azimuthal angle

      return OrbItem(
        name: 'Item $index',
        position: vector.Vector3(
          fullRadius * radius * math.cos(theta),
          fullRadius * y,
          fullRadius * radius * math.sin(theta),
        ),
      );
    });
  }

  void update() {
    for (var item in items) {
      final transformed = currentMatrix.transform3(item.position);
      item.position.setValues(transformed.x, transformed.y, transformed.z);
    }
    notifyListeners();
  }
}

class ColorOrb extends StatefulWidget {
  final int particlesCount;
  final double radius;
  final Color defaultIconColor;
  final void Function(Offset motionOffset)? onPanUpdate;

  const ColorOrb({
    super.key,
    required this.particlesCount,
    this.radius = 150.0,
    this.defaultIconColor = Colors.white,
    this.onPanUpdate,
  });

  @override
  State<ColorOrb> createState() => _ColorOrbState();
}

class _ColorOrbState extends State<ColorOrb> with SingleTickerProviderStateMixin {
  late final ColorOrbController _controller = ColorOrbController(
    color: widget.defaultIconColor,
    fullRadius: widget.radius,
  );
  Offset _position = Offset.zero;
  Offset _lastPanPosition = Offset.zero;
  late final Ticker ticker;

  @override
  void initState() {
    super.initState();
    ticker = createTicker(_onTick);
    _controller.generateParticles(widget.particlesCount, widget.radius);
  }

  @override
  void didUpdateWidget(covariant ColorOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.particlesCount != oldWidget.particlesCount || widget.radius != oldWidget.radius) {
      _controller.generateParticles(widget.particlesCount, widget.radius);
    }
  }

  void _onTick(_) {
    final delta = _position - _lastPanPosition;

    final deltaY = -delta.dy * 0.001;
    final deltaX = delta.dx * 0.001;

    final rotationMatrix = vector.Matrix4.rotationY(deltaX) //
      ..multiply(vector.Matrix4.rotationX(deltaY));

    _controller.currentMatrix = rotationMatrix;

    _controller.update();
    _lastPanPosition = _position;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    widget.onPanUpdate?.call(details.globalPosition);
    _position = details.localPosition;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => ticker.start(),
      onPanUpdate: _handlePanUpdate,
      onPanEnd: (_) => ticker.stop(),
      child: CustomPaint(
        painter: BackgroundPainter(widget.radius, widget.defaultIconColor),
        foregroundPainter: OrbPainter(_controller, widget.defaultIconColor, widget.radius),
        child: SizedBox.square(dimension: widget.radius * 2),
      ),
    );
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }
}
