import 'dart:math';
import 'dart:ui';
import 'package:engine/models/game_data_model.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart'; // Assuming this is where MyGame is defined
import 'package:google_fonts/google_fonts.dart';
import 'package:rive/rive.dart';
import 'package:flutter/services.dart';
import '../engine/game.dart';


class CustomDialog extends StatefulWidget {
  String? message;
  Artboard? teddyArtboard;
  SMITrigger? successTrigger;
  bool? isCompleted = false;

  CustomDialog(
      {Key? key,
      required this.message,
      this.teddyArtboard,
      this.successTrigger,
      this.isCompleted})
      : super(key: key);

  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: <Widget>[
          Center(
            child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.8,
              child: GestureDetector(
                onTap: () {
                  widget.successTrigger?.fire();
                  print('Tapped');
                  Navigator.of(context).pop();
                  if (widget.isCompleted!) {
                    Navigator.of(context).pop();
                  }
                },
                child: widget.teddyArtboard == null
                    ? Text('')
                    : Rive(
                        fit: BoxFit.contain,
                        enablePointerEvents: true,
                        artboard: widget.teddyArtboard!,
                      ),
              ),
            ),
          ),
          Center(
            child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * 0.45,
              child: Text(
                widget.message!,
                style: GoogleFonts.irishGrover(
                    color: Color.fromARGB(255, 165, 120, 104),
                    fontSize: 40.0,
                    decoration: TextDecoration.none),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Popup extends PositionComponent with HasGameRef<MyGame> {
  Popup({
    required this.name,
    required this.isStatic,
    required this.context,
  }) : super(
          position: Vector2(0, 0), // Example position
          size: Vector2(100, 100), // Example size
        );

  final String name;
  final bool isStatic;
  final BuildContext context;
  SMITrigger? successTrigger;
  Artboard? _teddyArtboard;
  Artboard? _compArtboard;
  bool isLoaded = false;

  @override
  Future<void> onLoad() async {
    _compArtboard = gameRef.compArtboard;
    _teddyArtboard = gameRef.teddyArtboard;
    successTrigger = gameRef.successTrigger;
    isLoaded = true;
  }

  void showCompletionAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomDialog(
          message: "Congratulations!",
          teddyArtboard: _compArtboard,
          successTrigger: successTrigger,
          isCompleted: true,
        );
      },
    );
  }

  @override
  void update(double dt) {
    if (!isLoaded) {
      return;
    }

    super.update(dt);

    GameData gamedata = gameRef.gamedata;
    if (gamedata.variables["GameOver"]?.value == true) {
      gamedata.variables["GameOver"]?.value = false;

      
      // if (gameRef.provider.currentSceneIndex < gamedata.scenes.length - 1) {
      //   gameRef.router.pushNamed()
      //   // gamedata =
      //   //     GameData.fromJson(gamedata.scenes, gameRef.provider.currentSceneIndex);
      // } else {
      //   // Final game over logic if all scenes are completed
      //   print("All scenes completed. Game Over.");
      //   // Handle final game over logic here
      // }

      if(gameRef.router.currentRoute.name=="level1"){
        gameRef.router.pushNamed("level2");
    }else if(gameRef.router.currentRoute.name=="level2"){
        gameRef.router.pushNamed("level3");
    }else if(gameRef.router.currentRoute.name=="level3"){
        gameRef.router.pushNamed("level1");
    }
    }

    if (gamedata.shouldShowDialog) {
      final String message = gamedata.dialogMessage;
      successTrigger?.fire();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(
            message: message,
            teddyArtboard: _teddyArtboard,
            successTrigger: successTrigger,
            isCompleted: false,
          );
        },
      );
      gamedata.shouldShowDialog = false;
    }
  }
}
