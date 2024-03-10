import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

class DialogButton extends SpriteComponent with TapCallbacks {
  DialogButton({size, position, required this.name})
      : super(
          position: position,
          size: size,
        );
  final String name;
  @override
  FutureOr<void> onLoad() async {
    sprite = await Sprite.load(name);
    return super.onLoad();
  }
  @override
  void onTapUp(TapUpEvent event) {
    
    super.onTapUp(event);
  }
}
