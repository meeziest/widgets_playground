// lib/helpers/tech_icons.dart
import 'dart:math';

import 'package:flutter/material.dart';

Color blendColors(Color color1, Color color2, double t) {
  return Color.fromARGB(
    255,
    ((color1.red * (1 - t)) + (color2.red * t)).round(),
    ((color1.green * (1 - t)) + (color2.green * t)).round(),
    ((color1.blue * (1 - t)) + (color2.blue * t)).round(),
  );
}

Color getRandomColor() {
  Random random = Random();
  return Color.fromARGB(
    255, // Full opacity
    random.nextInt(256), // Red (0-255)
    random.nextInt(256), // Green (0-255)
    random.nextInt(256), // Blue (0-255)
  );
}

/// Returns the opposite (inverted) color of the given color.
Color invertColor(Color color) {
  return Color.fromARGB(
    color.alpha, // Preserve original alpha value
    255 - color.red,
    255 - color.green,
    255 - color.blue,
  );
}

/// Darkens a color by reducing its lightness.
/// [amount] determines how much darker the color will become (0.0 to 1.0).
Color darkenColor(Color color, [double amount = 0.2]) {
  assert(amount >= 0.0 && amount <= 1.0, 'Amount must be between 0.0 and 1.0');

  HSLColor hsl = HSLColor.fromColor(color);
  double newLightness = (hsl.lightness - amount).clamp(0.0, 1.0);

  return hsl.withLightness(newLightness).toColor();
}
