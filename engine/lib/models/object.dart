import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:quiver/strings.dart';
import '../engine/game.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import 'dart:async';
import 'package:flame/components.dart';

class Object extends SpriteComponent
    with HasGameRef<MyGame>, CollisionCallbacks, DragCallbacks, TapCallbacks {
  Object(
      {required this.name,
      position,
      size,
      required this.image,
      required this.isStatic,
      required this.context})
      : super(
            position: position,
            size: size,
            children: [CircleHitbox()],
            paint: Paint()
              ..color = Color.fromARGB(255, 6, 180, 76)
              ..style = PaintingStyle.fill);

  final String name;
  final bool isStatic;
  final BuildContext context;
  String image;
  Vector2? draggedPosition;
  bool shine = false; // Add a boolean to track shine state

  @override
  FutureOr<void> onLoad() async {
    print("in load");
    print(image);
    print(name);
    print(isStatic);
    print(position);
    if (image != "" && image != null) {
      print("in imag");
      final loaded_image = gameRef.generatedImages[image];
      if (loaded_image != null) {
        print("sprite done");
        sprite = Sprite(loaded_image);
      }
    }

    // Load and play the audio
    await FlameAudio.audioCache.load('assets/game_music.mp3');
    FlameAudio.loop('assets/game_music.mp3', volume: 0.25);

    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw the shine effect if shine is true
   if (shine) {
      final shinePaint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawRect(size.toRect(), shinePaint);
    }
  }

  @override
  void update(double dt) {
    // Your update logic here
    if (!isDragged) {
      // Do something when the object is dragged
      position = gameRef.gamedata.characters[name]!.position +
          (position - gameRef.gamedata.characters[name]!.position) * dt * 5;
    }
  }

  // Override TapCallbacks methods
  @override
  void onTapUp(TapUpEvent details) {
    gameRef.gameRules.onTap(name, gameRef.gamedata);
  }

  // Override DragCallbacks methods
  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);

    // Reduce the size when dragging starts
    size = size * 0.8;
    priority = 10;

    // Enable the shine effect
    shine = true;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);

    // Restore the size when dragging ends
    size = gameRef.gamedata.characters[name]!.size;
    priority = 10;

    // Disable the shine effect
    shine = false;
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
      String curr_obj = name!;
      String oth_obj = other.name!;
      print("col $curr_obj $oth_obj");
      print(gameRef.gamedata.variables);
      gameRef.gameRules.onCollision(curr_obj, oth_obj, gameRef.gamedata);
      print(gameRef.gamedata.variables);
    }
  }

  Future<Image> getImage(String path) async {
    Completer<Image> completer = Completer();

    try {
      var img = NetworkImage(path);
      img.resolve(ImageConfiguration()).addListener(
        ImageStreamListener((ImageInfo info, bool _) {
          completer.complete(info.image as FutureOr<Image>?);
        }),
      );
      await completer.future;
    } catch (error) {
      // Handle errors here
      print('Error loading image: $error');
      // You can throw the error or return a placeholder image if needed
      completer.completeError(error);
    }

    return completer.future;
  }
}
