import 'package:flutter/material.dart';

import 'theme_provider.dart';

typedef BuilderWithTheme = Widget Function(BuildContext, ThemeModel model, ThemeSwitcherCallback callback);
typedef ThemeSwitcherCallback = void Function({
  required ThemeData theme,
  bool isReversed,
  Offset? offset,
  VoidCallback? onAnimationFinish,
});

class ThemeSwitcherPoint extends StatefulWidget {
  const ThemeSwitcherPoint({
    super.key,
    required this.builder,
  });

  final BuilderWithTheme builder;

  @override
  ThemeSwitcherPointState createState() => ThemeSwitcherPointState();
}

class ThemeSwitcherPointState extends State<ThemeSwitcherPoint> {
  final GlobalKey _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Builder(
      key: _globalKey,
      builder: (context) => widget.builder(
        context,
        ThemeModelInheritedNotifier.of(context),
        changeTheme,
      ),
    );
  }

  void changeTheme({
    required ThemeData theme,
    bool isReversed = false,
    Offset? offset,
    VoidCallback? onAnimationFinish,
  }) {
    ThemeModelInheritedNotifier.of(context).changeTheme(
      theme: theme,
      key: _globalKey,
      offset: offset,
      onAnimationFinish: onAnimationFinish,
    );
  }
}
