import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:widgets_playground/widgets/color_orb/utils.dart';

import '../../shaders/shaders_provider.dart';
import 'color_orb.dart';

const orbsColor = Colors.white;

class WaterColorBlendingOrbWidget extends StatefulWidget {
  const WaterColorBlendingOrbWidget({super.key});

  @override
  State<WaterColorBlendingOrbWidget> createState() => _WaterColorBlendingOrbWidgetState();
}

class _WaterColorBlendingOrbWidgetState extends State<WaterColorBlendingOrbWidget>
    with SingleTickerProviderStateMixin {
  Offset position = Offset.zero;
  Offset desiredPosition = Offset.zero;
  Offset velocity = const Offset(0.5, 0.5);
  Duration lastTime = Duration.zero;
  final ValueNotifier<int> particles = ValueNotifier<int>(200);

  Color pickerColor = Colors.white;
  Color currentColor = Colors.white;

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  late final Ticker ticker;

  @override
  void initState() {
    super.initState();
    ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    ticker.stop();
    ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final delta = ((elapsed.inMicroseconds - lastTime.inMicroseconds) / Duration.microsecondsPerSecond) * 60;

    lastTime = elapsed;

    if (desiredPosition == position) return;

    setState(() {
      final distance = desiredPosition - position;
      final amplitude = 1 - math.max(0, 1000 - distance.distance) / 1000;
      velocity = distance * (0.02 + 0.2 * Curves.easeInOut.transform(amplitude));

      position += velocity * delta;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Color orb Demo')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: invertColor(currentColor),
        child: Icon(Icons.colorize, color: currentColor),
        onPressed: () => showColorPickerDialog(context),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return Stack(
          children: [
            Positioned.fill(
              child: AnimatedSampler(
                (image, size, canvas) {
                  final shader = ShaderProvider.of(context).waterColorBlending.fragmentShader();

                  shader
                    ..setFloat(0, size.width)
                    ..setFloat(1, size.height)
                    ..setFloat(2, velocity.distance)
                    ..setFloat(3, position.dx)
                    ..setFloat(4, position.dy)
                    // Pass Color
                    ..setFloat(5, currentColor.red / 255.0)
                    ..setFloat(6, currentColor.green / 255.0)
                    ..setFloat(7, currentColor.blue / 255.0);

                  final paint = Paint()..shader = shader;
                  canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
                },
                enabled: true,
                child: const SizedBox.expand(child: Text('')),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: Center(
                child: SizedBox(
                  width: 300,
                  child: ValueListenableBuilder<int>(
                    valueListenable: particles,
                    builder: (context, value, child) => Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Slider(
                          min: 2,
                          max: 1000,
                          value: value.toDouble(),
                          onChanged: (val) => particles.value = val.toInt(),
                        ),
                        Text(
                          '${value * 100 ~/ 1000}%',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: ValueListenableBuilder<int>(
                valueListenable: particles,
                builder: (context, value, child) {
                  return ColorOrb(
                    defaultIconColor: currentColor,
                    radius: constraints.biggest.shortestSide / 2 - 100,
                    onPanUpdate: (motionPosition) => setState(() => desiredPosition = motionPosition),
                    particlesCount: value,
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Future<dynamic> showColorPickerDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: MaterialPicker(
            pickerColor: pickerColor,
            onColorChanged: changeColor,
          ),
        ),
        actions: <Widget>[
          FilledButton(
            child: const Text('Got it'),
            onPressed: () {
              setState(() => currentColor = pickerColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
