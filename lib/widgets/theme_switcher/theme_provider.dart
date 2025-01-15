import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef ThemeBuilder = Widget Function(BuildContext, ThemeData theme);

class ThemeProvider extends StatefulWidget {
  const ThemeProvider({
    super.key,
    this.builder,
    this.child,
    required this.initTheme,
  });

  final ThemeBuilder? builder;
  final Widget? child;
  final ThemeData initTheme;

  @override
  State<ThemeProvider> createState() => _ThemeProviderState();
}

class _ThemeProviderState extends State<ThemeProvider> {
  late ThemeModel model;

  @override
  void initState() {
    super.initState();
    model = ThemeModel(startTheme: widget.initTheme);
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeModelInheritedNotifier(
      notifier: model,
      child: Builder(builder: (context) {
        var model = ThemeModelInheritedNotifier.of(context);
        return RepaintBoundary(
          key: model.previewContainer,
          child: widget.child ?? widget.builder!(context, model.theme),
        );
      }),
    );
  }
}

class ThemeModelInheritedNotifier extends InheritedNotifier<ThemeModel> {
  const ThemeModelInheritedNotifier({
    super.key,
    required ThemeModel super.notifier,
    required super.child,
  });

  static ThemeModel of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeModelInheritedNotifier>()!.notifier!;
  }
}

class ThemeModel extends ChangeNotifier {
  ThemeData _theme;
  ui.Image? oldThemeImage;

  late GlobalKey switcherGlobalKey;
  final previewContainer = GlobalKey();

  ThemeModel({
    required ThemeData startTheme,
  }) : _theme = startTheme;

  ThemeData get theme => _theme;
  ThemeData? oldTheme;

  bool isAnimating = false;

  late Offset switcherOffset;

  void changeTheme({
    required ThemeData theme,
    required GlobalKey key,
    Offset? offset,
    VoidCallback? onAnimationFinish,
  }) async {
    if (isAnimating) return;
    isAnimating = true;
    oldTheme = _theme;
    _theme = theme;
    switcherOffset = _getSwitcherCoordinates(key, offset);
    oldThemeImage = await _makeScreenshot();
    notifyListeners();
  }

  Future<ui.Image> _makeScreenshot() async {
    final boundary = previewContainer.currentContext!.findRenderObject() as RenderRepaintBoundary;
    return await boundary.toImage(pixelRatio: ui.window.devicePixelRatio);
  }

  Offset _getSwitcherCoordinates(GlobalKey<State<StatefulWidget>> switcherGlobalKey, [Offset? tapOffset]) {
    final renderObject = switcherGlobalKey.currentContext!.findRenderObject()! as RenderBox;
    final size = renderObject.size;
    return renderObject.localToGlobal(Offset.zero).translate(
          tapOffset?.dx ?? (size.width / 2),
          tapOffset?.dy ?? (size.height / 2),
        );
  }
}
