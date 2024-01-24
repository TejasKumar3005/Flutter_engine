import 'dart:ui';

import 'package:flame/game.dart';
import 'game.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flame/components.dart';

class Object extends SpriteComponent with HasGameReference<MyGame> {
  Object({position, size}) : super(position: position, size: size);
  @override
  FutureOr<void> onLoad() async {
    final networkImage = await Flame.images.fromCache('your_network_image_key');
    sprite = Sprite(networkImage);
    return super.onLoad();
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
