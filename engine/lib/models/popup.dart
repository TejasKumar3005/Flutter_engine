import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../engine/game.dart'; // Assuming this is where MyGame is defined
import 'package:rive/rive.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDialog extends StatefulWidget {
  String? message;
  Artboard? teddyArtboard;
  SMITrigger? successTrigger;
  bool? isCompleted = false;

  CustomDialog({Key? key, required this.message, this.teddyArtboard, this.successTrigger, this.isCompleted}) : super(key: key);

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
                child: 
                widget.teddyArtboard == null ? Text('') :
                Rive(
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
                  decoration: TextDecoration.none
                ),
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
  // StateMachineController? stateMachineController;
  // StateMachineController? compStateMachineController;
  SMITrigger? successTrigger;
  Artboard? _teddyArtboard;
  Artboard? _compArtboard;
  bool isLoaded = false;
  @override
  Future<void> onLoad() async {
    // prepareRive();
  //   // Load sprite image from gameRef
  //   final image = gameRef.generatedImages[name];
  //   if (image != null) {
  //     sprite = Sprite(image);
  //   }
  //   return super.onLoad();
  _compArtboard = gameRef.compArtboard;
  _teddyArtboard = gameRef.teddyArtboard;
  successTrigger = gameRef.successTrigger;
  isLoaded = true;

  }

  // void prepareRive() {
  //   rootBundle.load("assets/text_pop_up.riv").then(
  //     (data) {
  //       final file = RiveFile.import(data);
  //       final artboard = file.mainArtboard;
  //       print("state mach");
  //       artboard.stateMachines.forEach((element) { print(element.name);});
  //       stateMachineController =
  //           StateMachineController.fromArtboard(artboard, "Post Session Menu");
  //       if (stateMachineController != null) {
  //         artboard.addController(stateMachineController!);

  //         print("length: ${stateMachineController!.inputs.length}");
  //         stateMachineController!.inputs.forEach((element) {
  //           print(element.name);
  //           if (element.name == "click") {
  //             print("trigger set");
  //             successTrigger = element as SMITrigger;
  //           }
  //         });
  //       }

  //       _teddyArtboard = artboard;
  //     },
  //   );

  //   rootBundle.load("assets/complete.riv").then(
  //     (data) {
  //       print("loading complete");
  //       print(data);
  //       final file = RiveFile.import(data);
  //       final artboard = file.mainArtboard;
  //       print("state mach");
  //       artboard.stateMachines.forEach((element) { print(element.name);});
  //       compStateMachineController =
  //           StateMachineController.fromArtboard(artboard, "Post Session Menu");
  //       if (compStateMachineController != null) {
  //         artboard.addController(compStateMachineController!);

  //         // print("length: ${compStateMachineController!.inputs.length}");
  //         // compStateMachineController!.inputs.forEach((element) {
  //         //   print(element.name);
  //         //   if (element.name == "click") {
  //         //     print("trigger set");
  //         //     successTrigger = element as SMITrigger;
  //         //   }
  //         // });
  //       }

  //       _compArtboard = artboard;
  //     },
  //   );
  
  //   isLoaded = true;
  // }


@override
void update(double dt) {

  if (!isLoaded) {
    return;
  }
  
  // Example logic for showing a dialog
  if (gameRef.gamedata.variables["GameOver"]?.value){
      showDialog(context: context,
      
      builder: (BuildContext context) {
        return CustomDialog(
          message: "",
          teddyArtboard: _compArtboard,
          successTrigger: successTrigger,
          isCompleted: true
        );
      }
    );
    // Navigator.of(context).pop();
    gameRef.gamedata.variables["GameOver"]?.value = false;
  }

  
  if (gameRef.gamedata.shouldShowDialog ) {
    final String message = gameRef.gamedata.dialogMessage ?? 'Default message';
    successTrigger?.fire();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          message: message,
          teddyArtboard: _teddyArtboard,
          successTrigger: successTrigger,
          isCompleted: false
        );
    //     return Center(
    //     child: Stack(
    //       children: <Widget>[
    //         Center(
    //           child: Container(
    //           alignment: Alignment.center,
    //           width: MediaQuery.of(context).size.width * 0.6,
    //           height: MediaQuery.of(context).size.height * 0.8,
    //           child: GestureDetector(
    //             onTap: () {
    //               successTrigger?.fire();
    //               print('Tapped');
    //               // gameRef.gamedata.shouldShowDialog = false;
    //               // Navigator.of(context).pop();
    //             },
    //             child: Rive(
    //             fit: BoxFit.contain,
    //             enablePointerEvents: true,
                
    //             // cursor: RiveCursor.hover,
    //             artboard: _teddyArtboard!,
    //           ),)
    //         )),
    //         Center(child: 
    //         Container(
    //             alignment: Alignment.center,
    //             width: MediaQuery.of(context).size.width * 0.55,
    //             child: Text(
    //               message,
    //               style: TextStyle(color: Color.fromARGB(255, 81, 30, 233), fontWeight: FontWeight.bold, fontSize: 22.0),
    //             )),)
    //       ],
    //     ),
      
    // );
        
      },
    );

    gameRef.gamedata.shouldShowDialog = false; // Prevent showing the dialog repeatedly
  }


  super.update(dt); // Call super update method
}
}
