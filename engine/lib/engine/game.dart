import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:engine/models/game_data_model.dart';
import 'package:engine/models/rules_model.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/painting.dart';
import '../models/object.dart';

class MyGame extends FlameGame with HasCollisionDetection,TapCallbacks {
  MyGame({required this.gamedata, required this.gameRules,required this.context})
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
  double get height => size.y;
  @override
  Future<void> onLoad() async {
    await preloadImages();
    camera.viewfinder.anchor = Anchor.topLeft;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Hello"),
          content: Text("This is a custom dialog"),
          actions: <Widget>[
            TextField(
              
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide()
                ),
                focusedBorder:OutlineInputBorder(
                  borderSide: BorderSide()
                ) ,
                
                prefixIcon: Icon(Icons.person),
                hintText: "Name",
                iconColor: Colors.blue
              ),
            ),
            SizedBox(height: 20,),
            ElevatedButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    gamedata.characters.values.forEach((element) {
      world.add(Object(
          position: element.position,
          size: element.size,
          image: element.image,
          isStatic: element.isMovable,
          name: element.name,
          context: context));
    });
  }

  @override
  void onTapUp(TapUpEvent details) {
    
  }

  Future<void> preloadImages() async {
    print("loading images");
    // for each key, value in the b64images map in gamedata loop
    for (var image_pair in gamedata.b64images.entries) {
      print("loading some image");
      Uint8List bytes = base64.decode(image_pair.value);

      final image = await decodeImageFromList(bytes);

      // Store the ui.Image in the generatedImages map
      generatedImages[image_pair.key] = image;
    }
  }
}
