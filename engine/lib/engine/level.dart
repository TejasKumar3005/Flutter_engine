

import 'dart:async';

import 'package:engine/engine/game.dart';
import 'package:engine/models/game_data_model.dart';
import 'package:engine/models/popup.dart';
import 'package:flame/components.dart';
import 'package:engine/models/object.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'package:rive/rive.dart';
class Level extends Component with HasGameRef<MyGame>,HasCollisionDetection,TapCallbacks{
  final int level;
  Level(this.level);
  
  late GameData gamedata =  gameRef.gamedataList[level];
    // final generatedImages = <String, ui.Image>{};
  final generatedGifs = <String, SpriteAnimation>{};
  @override
  Future<void> onLoad() async{
    
    for (var element in gamedata.characters.values) {
  print("Adding Character: ${element.name}");
  add(
    Object(
      position: element.position,
      size: element.size,
      currentGif: element.currentGif,
      gifs:  element.gifs, // Pass the Map<String, String> directly
      image: element.image,
      isStatic: false, // Set to false
      name: element.name,
      context: gameRef.context,
    ),
  );
}




    // wait for all Objects to be added to the world
    await Future.delayed(Duration(seconds: 1));

    await add(Popup(
      name: "popup",
      isStatic: false,
      context: gameRef.context,
    ));
  }

  @override
  void onTapUp(TapUpEvent details) {
    print("location tapped: ${details}");
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.successTrigger != null) {
       gameRef.successTrigger!.fire();
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
      gameRef.stateMachineController =
            StateMachineController.fromArtboard(artboard, "Post Session Menu");
        if (gameRef.stateMachineController != null) {
          artboard.addController(gameRef.stateMachineController!);

          for (var element in gameRef.stateMachineController!.inputs) {
            if (element.name == "click") {
            gameRef.successTrigger = element as SMITrigger;
            }
          }
        }

      gameRef.teddyArtboard = artboard;
      },
    );

    rootBundle.load("complete.riv").then(
      (data) {
        final file = RiveFile.import(data);
        final artboard = file.mainArtboard;

        artboard.stateMachines.forEach((element) {
          print(element.name);
        });
      gameRef.compStateMachineController =
            StateMachineController.fromArtboard(artboard, "Post Session Menu");
        if (gameRef.compStateMachineController != null) {
          artboard.addController(gameRef.compStateMachineController!);
        }

      gameRef.compArtboard = artboard;
      },
    );

  gameRef.isLoaded = true;
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
}