import 'dart:ui';
import 'dart:ui';

import 'package:engine/engine/engine.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';

class DialogTextBox extends TextBoxComponent {
  final Game game;
  DialogTextBox(
      {required String text, required this.game, position, required this.color})
      : super(
            text: text,
            position: position,
            boxConfig: TextBoxConfig(
                dismissDelay: 5.0,
                maxWidth: 1200,
                timePerChar: 0.1,
                growingBox: true)) {
    anchor = Anchor.center;
  }
  final Color color;

  @override
  void drawBackground(c) {
    Rect rect = Rect.fromLTWH(0, 0, width, height);
    c.drawRect(rect, Paint()..color = color);
    c.drawRect(
      rect.deflate(boxConfig.margins.top),
      BasicPalette.black.paint()..style = PaintingStyle.stroke,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
  }
}
