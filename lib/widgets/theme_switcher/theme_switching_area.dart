import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import '../../shaders/shaders_provider.dart';
import 'theme_provider.dart';

class ThemeShockWaveArea extends StatefulWidget {
  const ThemeShockWaveArea({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 700),
    this.mixFactor = 1.0,
  });

  final Widget child;
  final Duration duration;
  final double mixFactor;

  @override
  State<ThemeShockWaveArea> createState() => _ThemeShockWaveAreaState();
}

class _ThemeShockWaveAreaState extends State<ThemeShockWaveArea> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late ThemeModel _model;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(covariant ThemeShockWaveArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _model = ThemeModelInheritedNotifier.of(context);
    _model.removeListener(_onListen);
    _model.addListener(_onListen);
  }

  void _onListen() async {
    _controller.forward(from: 0.0).then((value) {
      _model.isAnimating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = ThemeModelInheritedNotifier.of(context);
    final shader = ShaderProvider.of(context).circleWave.fragmentShader();

    return Material(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return AnimatedSampler(
            enabled: model.isAnimating && model.oldThemeImage != null,
            (ui.Image newThemeTexture, Size size, Canvas canvas) {
              shader.setFloat(0, _controller.value); // iTime
              shader.setFloat(1, size.width); // iResolution.x
              shader.setFloat(2, size.height); // iResolution.y
              shader.setFloat(3, model.switcherOffset.dx);
              shader.setFloat(4, model.switcherOffset.dy);
              shader.setFloat(5, widget.mixFactor); // circle mix factor

              shader.setImageSampler(0, model.oldThemeImage!); // iChannel0
              shader.setImageSampler(1, newThemeTexture); // iChannel1

              final paint = Paint()..shader = shader;
              canvas.drawRect(Offset.zero & size, paint);
            },
            child: widget.child,
          );
        },
      ),
    );
  }
}
