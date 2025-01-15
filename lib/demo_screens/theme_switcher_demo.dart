import 'package:flutter/material.dart';
import 'package:widgets_playground/widgets/elastic_switcher/elastic_blob_widget.dart';
import 'package:widgets_playground/widgets/theme_switcher/theme_provider.dart';
import 'package:widgets_playground/widgets/theme_switcher/theme_shockwave_area.dart';
import 'package:widgets_playground/widgets/theme_switcher/theme_switcher_point.dart';

final light = ThemeData.light();
final dark = ThemeData.dark();

class ThemeSwitcherDemo extends StatelessWidget {
  const ThemeSwitcherDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      initTheme: dark,
      builder: (context, theme) => Theme(
        data: theme,
        child: const DemoScreen(),
      ),
    );
  }
}

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  final ValueNotifier<double> colorMixFactor = ValueNotifier<double>(5);
  final ValueNotifier<int> animationDuration = ValueNotifier<int>(1500);

  @override
  void initState() {
    super.initState();
    colorMixFactor.addListener(updateView);
    animationDuration.addListener(updateView);
  }

  @override
  void dispose() {
    colorMixFactor.dispose();
    animationDuration.dispose();
    super.dispose();
  }

  void updateView() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final model = ThemeModelInheritedNotifier.of(context);
    return ThemeShockWaveArea(
      duration: Duration(milliseconds: animationDuration.value),
      mixFactor: colorMixFactor.value,
      child: Scaffold(
        backgroundColor: model.theme.colorScheme.surface,
        appBar: AppBar(title: const Text('Dump screen')),
        floatingActionButton: ThemeSwitcherPoint(
          builder: (context, theme, changeTheme) => switcher(
            context,
            changeTheme: changeTheme,
            model: model,
            radius: 30,
            withText: false,
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                children: [
                  const Text('Change theme by dragging the blob'),
                  const SizedBox(height: 20.0),
                  ThemeSwitcherPoint(
                    builder: (context, theme, changeTheme) => switcher(
                      context,
                      changeTheme: changeTheme,
                      model: model,
                      radius: 60,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 150.0),
              Column(
                children: [
                  SizedBox(
                    width: 300,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Slider(
                          min: 0.0,
                          max: 10.0,
                          value: colorMixFactor.value.toDouble(),
                          onChanged: (val) => colorMixFactor.value = val,
                        ),
                        Text(
                          'Mix factor ${colorMixFactor.value.toStringAsFixed(1)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  SizedBox(
                    width: 300,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Slider(
                          min: 150.0,
                          max: 3000.0,
                          value: animationDuration.value.toDouble(),
                          onChanged: (val) => animationDuration.value = val.toInt(),
                        ),
                        Text(
                          'Animation duration ${animationDuration.value.toString()}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget switcher(
    BuildContext context, {
    required ThemeSwitcherCallback changeTheme,
    required ThemeModel model,
    double radius = 40.0,
    bool withText = true,
  }) {
    return ElasticBlob(
      radius: radius,
      onPanEnd: () => changeTheme(
        theme: model.theme == light ? dark : light,
        isReversed: false,
      ),
      blobOnWidget: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            model.theme == light ? Icons.dark_mode : Icons.light_mode,
            color: Theme.of(context).colorScheme.onSurface,
            size: radius,
          ),
          if (withText)
            Text(
              model.theme == light ? 'Dark' : 'Light',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
        ],
      ),
      blogOffWidget: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            model.theme == light ? Icons.light_mode : Icons.dark_mode,
            color: Theme.of(context).colorScheme.surface,
            size: radius,
          ),
          if (withText)
            Text(
              model.theme == light ? 'Light' : 'Dark',
              style: TextStyle(
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
        ],
      ),
      color: Theme.of(context).colorScheme.onSurface,
      duration: const Duration(milliseconds: 700),
    );
  }
}
