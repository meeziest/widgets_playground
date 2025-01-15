import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:widgets_playground/demo_screens/theme_switcher_demo.dart';
import 'package:widgets_playground/shaders/shaders_provider.dart';

import 'demo_screens/color_orb_demo.dart';
import 'demos.dart';

final light = ThemeData.light();
final dark = ThemeData.dark();

void main() async {
  final waterColorBlending = await ui.FragmentProgram.fromAsset('lib/shaders/glsl/water_color_blending.frag');
  final circleWave = await ui.FragmentProgram.fromAsset('lib/shaders/glsl/shockwave.frag');

  runApp(
    ShaderProvider(
      shader: ShaderCollection(
        waterColorBlending: waterColorBlending,
        circleWave: circleWave,
      ),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/theme_switcher_demo': (context) => const ThemeSwitcherDemo(),
        '/color_orb_demo': (context) => const ColorOrbDemo(),
        '/demos': (context) => const Demos(),
      },
      initialRoute: '/demos',
    );
  }
}
