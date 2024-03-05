import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import '../engine/game.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flame/components.dart';

class Object extends CircleComponent
    with HasGameRef<MyGame>, CollisionCallbacks, DragCallbacks {
  Object({name, position, size, image, required this.isStatic})
      : super(
            position: position,
            radius: 10,
            paint: Paint()
              ..color = const Color(0xff1e6091)
              ..style = PaintingStyle.fill);
  String? name;
  final bool isStatic;
  String? image;

  // @override
  // FutureOr<void> onLoad() async {
  //   // final networkImage = await Flame.images.fromCache(image!);
  //   // sprite = Sprite.fromImage(await networkImage.image);
  //   return super.onLoad();
  // }

  @override
  void update(double dt) {
    // Your update logic here
    if (!isDragged) {
      // Do something when the object is dragged
      position = gameRef.gamedata.characters[name]!.position;
    }
  }


  // Override TapCallbacks methods
  @override
  void onTapUp(TapUpDetails details) {
    gameRef.gameRules.onTap(name!, gameRef.gamedata);
  }

  // Override DragCallbacks methods
  @override
  void onDragStart(DragStartEvent event) {
    if (isStatic) return;
    super.onDragStart(event);
    priority = 10;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    priority = 0;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (isStatic) {
      return;
    }
    position += event.localDelta;
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Object) {
      String curr_obj = name!;
      String oth_obj = other.name!;
      gameRef.gameRules.onCollision(curr_obj,oth_obj, gameRef.gamedata);
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
