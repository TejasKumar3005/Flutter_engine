import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../engine/game.dart'; // Assuming this is where MyGame is defined

class Popup extends PositionComponent with HasGameRef<MyGame> {
  Popup({
    required this.name,
    required this.isStatic,
    required this.context,
  }) : super(
          // Pass proper values or variables for position and size
          position: Vector2(0, 0), // Example position
          size: Vector2(100, 100), // Example size
          children: [], // No children initially
          // paint: Paint()
          //   ..color = Color.fromARGB(255, 6, 180, 76)
          //   ..style = PaintingStyle.fill,
        );

  final String name;
  final bool isStatic;
  final BuildContext context;

  // @override
  // Future<void> onLoad() async {
  //   // Load sprite image from gameRef
  //   final image = gameRef.generatedImages[name];
  //   if (image != null) {
  //     sprite = Sprite(image);
  //   }
  //   return super.onLoad();
  // }

@override
void update(double dt) {
  // Example logic for showing a dialog
  if (gameRef.gamedata.shouldShowDialog) {
    final String message = gameRef.gamedata.dialogMessage ?? 'Default message';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
      appBar: AppBar(
        title: Text('Text Over Image'),
      ),
      body: Center(
        child: Stack(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              child: Image.asset(
              'assets/—Pngtree—old paper scroll manuscript_8794609.png',
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Container(
                alignment: Alignment.center,
                child: Text(
                  message,
                  style: TextStyle(color: Color.fromARGB(255, 81, 30, 233), fontWeight: FontWeight.bold, fontSize: 22.0),
                )),
          ],
        ),
      ),
    );
        
      },
    );
    gameRef.gamedata.shouldShowDialog = false; // Prevent showing the dialog repeatedly
  }
  super.update(dt); // Call super update method
}
}
