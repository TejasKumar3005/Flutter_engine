import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame/components.dart';
import '../engine/game.dart';

class Object extends PositionComponent
    with HasGameRef<MyGame>, CollisionCallbacks, DragCallbacks, TapCallbacks {
  Object({
    required this.name,
    position,
    size,
    required this.image,
    required this.isStatic,
    required this.context,
    required this.gifs,
    required this.currentGif,
  }) : super(
          position: position,
          size: size,
        );

  final String name;
  final bool isStatic;
  final BuildContext context;
  String image;
  Map<String, String> gifs; // Changed to Map for key-value pairs
  String currentGif;
  SpriteAnimationTicker? gifAnimationTicker;
  Sprite? sprite;

  @override
  FutureOr<void> onLoad() async {
    print("in load");
    print(image);
    print(name);
    print(isStatic);
    print(position);

    // Ensure GIF animation is initialized
    if (gifs.isNotEmpty) {
      updateGifAnimation();
    }

    // FlameAudio.bgm.initialize();
    // // Load and play the audio
    // await FlameAudio.audioCache.load('assets/game_music.mp3');
    // FlameAudio.bgm.play('game_music.mp3', volume: .25);

    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw the current GIF animation frame if available
    if (gifAnimationTicker != null) {
      final sprite = gifAnimationTicker!.getSprite();
      sprite.render(
        canvas,
        position: position,
        size: size,
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update the GIF animation
    gifAnimationTicker?.update(dt);

    // Your update logic here
    if (!isDragged) {
      // Do something when the object is not dragged
      position = gameRef.gamedata.characters[name]!.position +
          (position - gameRef.gamedata.characters[name]!.position) * dt * 5;
    }

    // Update the current GIF based on the current animation
    final character = gameRef.gamedata.characters[name];
    if (character != null && character.currentGif != currentGif) {
      print("GIF change detected for $name. Updating to ${character.currentGif}");
      currentGif = character.currentGif;
      updateGifAnimation(); // Re-render with the new GIF
    }

    // Ensure the object stays within screen bounds
    final screenSize = gameRef.size;
    if (position.x < 0) {
      position.x = 0;
    } else if (position.x + size.x > screenSize.x) {
      position.x = screenSize.x - size.x;
    }
    if (position.y < 0) {
      position.y = 0;
    } else if (position.y + size.y > screenSize.y) {
      position.y = screenSize.y - size.y;
    }
  }

  void updateGifAnimation() {
    // Update the gifAnimationTicker with the correct animation
    gifAnimationTicker = gameRef.generatedGifs[currentGif]?.createTicker();
  }

  // Override TapCallbacks methods
  @override
  void onTapUp(TapUpEvent details) {
    print("Tapped on $name");
    print("tapped location: ${details.localPosition}");
    print("position: $position");
    gameRef.gameRules.onTap(name, gameRef.gamedata);
    // Assuming the tap action updates the currentGif via changeAnimation logic in gameRules
    final character = gameRef.gamedata.characters[name];
    if (character != null && character.gifs.containsKey(character.currentGif)) {
      currentGif = character.gifs[character.currentGif]!;
      updateGifAnimation(); // Apply the new animation
    }
  }

  // Override DragCallbacks methods
  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    // Reduce the size when dragging starts
    size = size * 0.8;
    priority = 10;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);

    // Restore the size when dragging ends
    size = gameRef.gamedata.characters[name]!.size;
    priority = 10;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (gameRef.gamedata.characters[name]!.isMovable == false) {
      return;
    }
    position += event.localDelta;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!isDragged) {
      return;
    }
    super.onCollisionStart(intersectionPoints, other);
    if (other is Object) {
      String currObj = name;
      String othObj = other.name;
      print("Collision detected between $currObj and $othObj");
      gameRef.gameRules.onCollision(currObj, othObj, gameRef.gamedata);
    }
  }
}
