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
import 'package:flame/sprite.dart';
import 'package:flame/collisions.dart';
import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';




class MyGame extends FlameGame with HasCollisionDetection, TapCallbacks {
  MyGame({
    required this.gamedataList,
    required this.gameRules,
    required this.context,
    required this.currentSceneIndex,
    required this.provider,
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
  final generatedGifs = <String, SpriteAnimation>{}; // Updated to store SpriteAnimation

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
    // await preloadImages();
    await preloadGifs(); // Preload gifs
    prepareRive();
    camera.viewfinder.anchor = Anchor.topLeft;

   for (var element in gamedata.characters.values) {
  print("Adding Character: ${element.name}");
  world.add(
    Object(
      position: element.position,
      size: element.size,
      currentGif: element.currentGif,
      gifs:  element.gifs, // Pass the Map<String, String> directly
      image: element.image,
      isStatic: false, // Set to false
      name: element.name,
      context: context,
    ),
  );
}


    // wait for all Objects to be added to the world
    await Future.delayed(Duration(seconds: 1));

    await world.add(Popup(
      name: "popup",
      isStatic: false,
      context: context,
    ));
  }

  @override
  void onTapUp(TapUpEvent details) {
    print("location tapped: ${details.localPosition}");
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (successTrigger != null) {
      successTrigger!.fire();
    }
  }

  void prepareRive() {
    rootBundle.load("text_pop_up.riv").then(
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

          for (var element in stateMachineController!.inputs) {
            if (element.name == "click") {
              successTrigger = element as SMITrigger;
            }
          }
        }

        teddyArtboard = artboard;
      },
    );

    rootBundle.load("complete.riv").then(
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

Future<void> preloadGifs() async {
  print("loading gifs");
  for (var gifPair in gamedata.gifLinks.entries) {
    try {
      print("Downloading GIF from: ${gifPair.value}");
      
      // Download the GIF from the URL
      final response = await http.get(Uri.parse(gifPair.value));
      if (response.statusCode == 200) {
        final Uint8List bytes = response.bodyBytes;

        // Create a codec for the animated image
        final codec = await ui.instantiateImageCodec(bytes);
        List<Sprite> sprites = [];
        for (int i = 0; i < codec.frameCount; i++) {
          final frameInfo = await codec.getNextFrame();
          final image = frameInfo.image;
          sprites.add(Sprite(image));
        }

        final spriteAnimation = SpriteAnimation.spriteList(
          sprites,
          stepTime: 0.1, // Set the frame duration
        );

        generatedGifs[gifPair.key] = spriteAnimation;
      } else {
        print("Failed to download GIF: ${gifPair.key}, Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error loading gif: $e");
    }
  }
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