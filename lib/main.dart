import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:widgets_playground/shaders/shaders_provider.dart';

import 'color_picker/water_color_blending.dart';

void main() async {
  final waterColorBlending = await ui.FragmentProgram.fromAsset('lib/shaders/glsl/water_color_blending.frag');

  runApp(
    ShaderProvider(
      shader: ShaderCollection(
        waterColorBlending: waterColorBlending,
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
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: RepaintBoundary(
        child: WaterColorBlendingOrbWidget(),
      ),
    );
  }
}
