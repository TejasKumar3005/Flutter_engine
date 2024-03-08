import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:engine/models/game_data_model.dart';
import 'package:engine/models/rules_model.dart';
import 'package:flame/components.dart';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/painting.dart';
import '../models/object.dart';

class MyGame extends FlameGame with HasCollisionDetection {
  MyGame({required this.gamedata, required this.gameRules})
      : super(
          camera: CameraComponent.withFixedResolution(
            width: 1200,
            height: 900,
          ),
        );

  final generatedImages = <String, ui.Image>{};

  final GameData gamedata;
  final GameRules gameRules;
  double get width => size.x;
  double get height => size.y;
  @override
  Future<void> onLoad() async {
    await preloadImages();
    camera.viewfinder.anchor = Anchor.topLeft;

    gamedata.characters.values.forEach((element) {
      world.add(Object(
          position: element.position,
          size: element.size,
          image: element.image,
          isStatic: element.isMovable,
          name: element.name));
    });
  }

  Future<void> preloadImages() async {
    for (var character in gamedata.characters.values) {
      final response = await http.get(Uri.parse(character.image));

      final image = await decodeImageFromList(response.bodyBytes);

      // Store the ui.Image in the generatedImages map
      generatedImages[character.name] = image;
    }
  }
}
