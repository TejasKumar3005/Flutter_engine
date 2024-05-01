import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

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
  MyGame(
      {required this.gamedata, required this.gameRules, required this.context})
      : super(
          camera: CameraComponent.withFixedResolution(
            width: 1200,
            height: 900,
          ),
        );

  final generatedImages = <String, ui.Image>{};

  final GameData gamedata;
  final BuildContext context;
  final GameRules gameRules;
  double get width => size.x;
  Artboard? _teddyArtboard;
  StateMachineController? stateMachineController;
  SMITrigger? successTrigger;
  double get height => size.y;
  @override
  Future<void> onLoad() async {
    await preloadImages();
    camera.viewfinder.anchor = Anchor.topLeft;
    // Navigate to another route using Navigator
    // if (gamedata.type == "puzzle") {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => PuzzleGame(
    //               imageUrls: [],
    //             )), // Replace AnotherRoute() with your desired route
    //   );
    // }

    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return AlertDialog(
    //       title: Text("Hello"),
    //       content: Text("This is a custom dialog"),
    //       actions: <Widget>[
    //         TextField(
    //           decoration: InputDecoration(
    //               enabledBorder: OutlineInputBorder(borderSide: BorderSide()),
    //               focusedBorder: OutlineInputBorder(borderSide: BorderSide()),
    //               prefixIcon: Icon(Icons.person),
    //               hintText: "Name",
    //               iconColor: Colors.blue),
    //         ),
    //         SizedBox(
    //           height: 20,
    //         ),
    //         ElevatedButton(
    //           child: Text("Close"),
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //           },
    //         ),
    //       ],
    //     );
    //   },
    // );
    gamedata.characters.values.forEach((element) {
      print("jhjgkhfjgxhfgjfghjhugiyfhjk");
      print(element);
      world.add(Object(
          position: element.position,
          size: element.size,
          image: element.image,
          isStatic: element.isMovable,
          name: element.name,
          context: context));
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
    // if (
    if (successTrigger != null) {
      successTrigger!.fire();
    }
  }

    void prepareRive() {
    rootBundle.load("assets/complete.riv").then(
      (data) {
        final file = RiveFile.import(data);
        final artboard = file.mainArtboard;
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

        _teddyArtboard = artboard;
      },
    );
  }

  Future<void> preloadImages() async {
    print("loading images");
    for (var image_pair in gamedata.image_links.entries) {
      try {
        print("loading some image");
        print(image_pair.key);

        final response = await http.get(Uri.parse(image_pair.value));
        if (response.statusCode == 200) {
          final Uint8List bytes = response.bodyBytes;

          final ui.Codec codec = await ui.instantiateImageCodec(bytes);
          final ui.FrameInfo frameInfo = await codec.getNextFrame();
          final ui.Image image = frameInfo.image;

          generatedImages[image_pair.key] = image;
        } else {
          print("Failed to load image: ${response.statusCode}");
        }
      } catch (e) {
        print("Error loading image: $e");
      }
    }
  }
}
