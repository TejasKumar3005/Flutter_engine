import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import '../engine/game.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
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
    return super.onLoad();
  }

  @override
  void update(double dt) {
    // Your update logic here
    if (!isDragged) {
      // Do something when the object is dragged
      position = gameRef.gamedata.characters[name]!.position + (position - gameRef.gamedata.characters[name]!.position) * dt * 5 ;
    }
  }

  // Override TapCallbacks methods
  @override
  void onTapUp(TapUpEvent details) {
    gameRef.gamedata.shouldShowDialog = true;

    //  showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return AlertDialog(
    //       title: const Text('Input Dialog'),
    //       content: TextField(
    //         decoration: InputDecoration(hintText: "Enter your input here"),
    //       ),
    //       actions: <Widget>[
    //         TextButton(
    //           child: const Text('Cancel'),
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //           },
    //         ),
    //         TextButton(
    //           child: const Text('Submit'),
    //           onPressed: () {
    //             // Handle the submit action
    //           },
    //         ),
    //       ],
    //     );
    //   },
    // );
    gameRef.gameRules.onTap(name!, gameRef.gamedata);
  }

  // Override DragCallbacks methods
  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    priority = 10;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    priority = 2;
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
