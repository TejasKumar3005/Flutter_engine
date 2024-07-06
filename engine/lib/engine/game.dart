import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:engine/controllers/player_controller.dart';
import 'package:engine/models/game_data_model.dart';
import 'package:engine/models/rules_model.dart';
import 'package:engine/utils/gameWidgets/puzzlegame.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:rive/rive.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/object.dart';
import "../models/popup.dart";

class MyGame extends FlameGame with HasCollisionDetection, TapCallbacks {
  MyGame({
    required this.gamedataList,
    required this.gameRules,
    required this.context,
    required this.currentSceneIndex,
    required this.provider
  }) : super(
          camera: CameraComponent.withFixedResolution(
            width: 900,
            height: 900,
          ),
        );

  final List<GameData> gamedataList;
  final GameUtilsProvider provider;
  final BuildContext context;
  final GameRules gameRules;
  final int currentSceneIndex;
  late GameData gamedata = gamedataList[currentSceneIndex];
  final generatedImages = <String, ui.Image>{};

  double get width => size.x;
  double get height => size.y;

  Artboard? teddyArtboard;
  StateMachineController? stateMachineController;
  Artboard? compArtboard;
  StateMachineController? compStateMachineController;
  bool isLoaded = false;
  SMITrigger? successTrigger;

  @override
  Future<void> onLoad() async {
    await preloadImages();
    prepareRive();
    camera.viewfinder.anchor = Anchor.topLeft;

    gamedata.characters.values.forEach((element) {
      print("Adding character: ${element.name}");
      world.add(Object(
        position: element.position,
        size: element.size,
        image: element.image,
        isStatic: !element.isMovable,
        name: element.name,
        context: context,
      ));
    });

    // wait for all Objects to be added to the world
    await Future.delayed(Duration(seconds: 1));

    await world.add(Popup(
      name: "popup",
      isStatic: false,
      context: context,
    ));
  }

  @override
  void onTapUp(TapUpEvent details) {}

  @override
  void update(double dt) {
    super.update(dt);
    if (successTrigger != null) {
      successTrigger!.fire();
    }
  }

  void prepareRive() {
    rootBundle.load("assets/text_pop_up.riv").then(
      (data) {
        final file = RiveFile.import(data);
        final artboard = file.mainArtboard;

        artboard.stateMachines.forEach((element) {
          print(element.name);
        });
        stateMachineController =
            StateMachineController.fromArtboard(artboard, "Post Session Menu");
        if (stateMachineController != null) {
          artboard.addController(stateMachineController!);

          stateMachineController!.inputs.forEach((element) {
            if (element.name == "click") {
              successTrigger = element as SMITrigger;
            }
          });
        }

        teddyArtboard = artboard;
      },
    );

    rootBundle.load("assets/complete.riv").then(
      (data) {
        final file = RiveFile.import(data);
        final artboard = file.mainArtboard;

        artboard.stateMachines.forEach((element) {
          print(element.name);
        });
        compStateMachineController =
            StateMachineController.fromArtboard(artboard, "Post Session Menu");
        if (compStateMachineController != null) {
          artboard.addController(compStateMachineController!);
        }

        compArtboard = artboard;
      },
    );

    isLoaded = true;
  }

  Future<void> preloadImages() async {
    print("loading images");
    for (var imagePair in gamedata.imageLinks.entries) {
      try {
        print(imagePair.key);

        final response = await http.get(Uri.parse(imagePair.value));
        if (response.statusCode == 200) {
          final Uint8List bytes = response.bodyBytes;

          final ui.Codec codec = await ui.instantiateImageCodec(bytes);
          final ui.FrameInfo frameInfo = await codec.getNextFrame();
          final ui.Image image = frameInfo.image;

          generatedImages[imagePair.key] = image;
        } else {
          print("Failed to load image: ${response.statusCode}");
        }
      } catch (e) {
        print("Error loading image: $e");
      }
    }
  }
}
