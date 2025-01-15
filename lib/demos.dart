import 'package:flutter/material.dart';

class Demos extends StatelessWidget {
  const Demos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demos')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/theme_switcher_demo'),
                child: const Text('Theme Switcher Demo'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/color_orb_demo'),
                child: const Text('Color Orb Demo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
