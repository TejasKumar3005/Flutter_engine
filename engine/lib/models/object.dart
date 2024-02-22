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
    with HasGameReference<MyGame>, CollisionCallbacks, DragCallbacks {
  Object({name, position, size, image ,required this.isStatic})
      : super(position: position, size: size);
  String? name;
  final bool isStatic;
  String? image;

  @override
  FutureOr<void> onLoad() async {
    final networkImage = await Flame.images.fromCache(image!);
    sprite = Sprite.fromImage(await networkImage.image);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    // Your update logic here
  }

  // Override DragCallbacks methods
  @override
  bool onDragStart(int pointerId, DragStartInfo info) {
    // Only start dragging if isStatic is false
    return !isStatic;
  }

  @override
  bool onDragUpdate(int pointerId, DragUpdateInfo info) {
    // Only allow dragging if isStatic is false
    if (!isStatic) {
      position.add(info.delta.game);
      return true;
    }
    return false;
  }

  @override
  bool onDragEnd(int pointerId, DragEndInfo info) {
    // You can implement any logic needed when drag ends
    // For example, snapping the object back into a grid or boundaries
    return !isStatic;
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
