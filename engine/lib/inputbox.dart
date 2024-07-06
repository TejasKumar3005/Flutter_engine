import 'dart:async';
import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:engine/utils/loading.dart';
import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:engine/engine/engine.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:engine/utils/gameWidgets/puzzlegame.dart';
import '../engine/game.dart'; // Assuming this is where MyGame is defined
import 'package:google_fonts/google_fonts.dart';
import 'package:quiver/async.dart';

class CustomDialog extends StatefulWidget {
  final String message;
  final Artboard teddyArtboard;
  final SMITrigger successTrigger;
  final bool isCompleted;

  CustomDialog({
    Key? key,
    required this.message,
    required this.teddyArtboard,
    required this.successTrigger,
    required this.isCompleted,
  }) : super(key: key);

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
                  widget.successTrigger.fire();
                  print('Tapped');
                  Navigator.of(context).pop();
                  if (widget.isCompleted) {
                    Navigator.of(context).pop();
                  }
                },
                child: widget.teddyArtboard == null
                    ? Text('')
                    : Rive(
                        fit: BoxFit.contain,
                        enablePointerEvents: true,
                        artboard: widget.teddyArtboard,
                      ),
              ),
            ),
          ),
          Center(
            child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * 0.45,
              child: Text(
                widget.message,
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

class KafkaMessageWidget extends StatefulWidget {
  const KafkaMessageWidget({Key? key}) : super(key: key);

  @override
  _KafkaMessageWidgetState createState() => _KafkaMessageWidgetState();
}

class _KafkaMessageWidgetState extends State<KafkaMessageWidget> {
  Artboard? _teddyArtboard;
  late String animationURL;
  SMITrigger? successTrigger, failTrigger;
  SMIBool? isHandsUp, isChecking;
  SMINumber? numLook;
  List<Map<String, dynamic>> scenes = [];
  int currentSceneIndex = 0;
  CountdownTimer? sceneChangeTimer;
  StreamSubscription<CountdownTimer>? sceneChangeSubscription;

  StateMachineController? stateMachineController;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    rootBundle.load("assets/login.riv").then(
      (data) {
        final file = RiveFile.import(data);
        final artboard = file.mainArtboard;
        stateMachineController =
            StateMachineController.fromArtboard(artboard, "Login Machine");
        if (stateMachineController != null) {
          artboard.addController(stateMachineController!);
          stateMachineController!.inputs.forEach((element) {
            if (element.name == "trigSuccess") {
              successTrigger = element as SMITrigger;
            } else if (element.name == "trigFail") {
              failTrigger = element as SMITrigger;
            } else if (element.name == "isHandsUp") {
              isHandsUp = element as SMIBool;
            } else if (element.name == "isChecking") {
              isChecking = element as SMIBool;
            } else if (element.name == "numLook") {
              numLook = element as SMINumber;
            }
          });
        }

        setState(() => _teddyArtboard = artboard);
      },
    );

    
  }

  @override
  void dispose() {
    sceneChangeSubscription
        ?.cancel(); // Stop the timer when the widget is disposed
    super.dispose();
  }

  Future<void> fetchScenes(BuildContext context, int currentIndex) async {
    try {
      String jsonData = await rootBundle.loadString('assets/main.json');
      List<dynamic> responseJson = jsonDecode(jsonData);
      startSceneChangeTimer();
      setState(() {
        scenes =
            responseJson.map((scene) => scene as Map<String, dynamic>).toList();
        print("fetch scenes");
      });
    } catch (e) {
      showSnackBar(context, e.toString(), ContentType.failure);
      failTrigger?.fire();
    }
  }

  void startSceneChangeTimer() {
    sceneChangeSubscription?.cancel(); // Cancel any existing timer
    sceneChangeTimer = CountdownTimer(
      Duration(seconds: 15),
      Duration(seconds: 1),
    );

    sceneChangeSubscription = sceneChangeTimer!.listen((event) {
      final timeLeft = 15 - event.elapsed.inSeconds;
      print('Time left: $timeLeft seconds');
      print(currentSceneIndex);
    }, onDone: () {
      setState(() {
        currentSceneIndex = (currentSceneIndex + 1) % scenes.length;
        print("hello 1");
      }); 
        startSceneChangeTimer();
    });
  }

  void showSnackBar(
      BuildContext context, String message, ContentType contentType) {
    final materialBanner = SnackBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      content: AwesomeSnackbarContent(
        title: 'Oh Snap!!',
        message: message,
        contentType: contentType,
        inMaterialBanner: true,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showSnackBar(materialBanner);
  }

  void showCompletionAnimation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomDialog(
          message: "Congratulations!",
          teddyArtboard: _teddyArtboard!,
          successTrigger: successTrigger!,
          isCompleted: true,
        );
      },
    );
  }

  void handsOnTheEyes() {
    isHandsUp?.change(true);
  }

  void lookOnTheTextField() {
    isHandsUp?.change(false);
    isChecking?.change(true);
    numLook?.change(0);
  }

  void moveEyeBalls(val) {
    if (val.isEmpty) {
      setState(() {
        errorText = "enter valid prompt";
      });
    } else {
      setState(() {
        errorText = null;
      });
    }
    numLook?.change(val.length.toDouble());
  }

  void login() {
    isChecking?.change(false);
    isHandsUp?.change(false);
    if (_emailController.text == "admin" &&
        _passwordController.text == "admin") {
      successTrigger?.fire();
      // changeScene();
    } else {
      failTrigger?.fire();
    }
  }

  String? errorText;

  bool gameloaded = false;
  bool loading = false;
  OverlayEntry? _overlayEntry;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (loading) {
        _overlayEntry = createOverlayEntry(context);
        Overlay.of(context)?.insert(_overlayEntry!);
      } else if (!loading) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      }
    });
    print("===== Suurent Scene"+currentSceneIndex.toString());
    return (gameloaded && currentSceneIndex < scenes.length)
        ? Game(key: ValueKey(currentSceneIndex),
          gameJsonList: scenes)
        : Scaffold(
          
            backgroundColor: const Color(0xffd6e2ea),
            body: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_teddyArtboard != null)
                      SizedBox(
                        width: 400,
                        height: 300,
                        child: Rive(
                          artboard: _teddyArtboard!,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    Container(
                      alignment: Alignment.center,
                      width: 400,
                      padding: const EdgeInsets.only(bottom: 15),
                      margin: const EdgeInsets.only(bottom: 15 * 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Column(
                              children: [
                                const SizedBox(height: 15 * 2),
                                TextField(
                                  controller: _emailController,
                                  onTapOutside: (event) {
                                    FocusScope.of(context).unfocus();
                                    isChecking?.change(false);
                                  },
                                  onTap: () {
                                    lookOnTheTextField();
                                  },
                                  onChanged: moveEyeBalls,
                                  keyboardType: TextInputType.emailAddress,
                                  style: const TextStyle(fontSize: 14),
                                  cursorColor: const Color(0xffb04863),
                                  decoration: InputDecoration(
                                    labelText: "Prompt",
                                    errorText: _emailController.text.isEmpty
                                        ? errorText
                                        : null,
                                    hintText: "make game on Water",
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                    focusColor: Color(0xffb04863),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xffb04863),
                                      ),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                TextField(
                                  controller: _passwordController,
                                  onTap: handsOnTheEyes,
                                  keyboardType: TextInputType.visiblePassword,
                                  style: const TextStyle(fontSize: 14),
                                  cursorColor: const Color(0xffb04863),
                                  onTapOutside: (event) {
                                    setState(() {
                                      errorText = null;
                                    });
                                    FocusScope.of(context).unfocus();
                                    isHandsUp?.change(false);
                                  },
                                  decoration: InputDecoration(
                                    labelText: "Api key",
                                    hintText: "API key",
                                    errorText:
                                        _passwordController.text.isEmpty &&
                                                errorText != null
                                            ? "enter api key"
                                            : null,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                    focusColor: Color(0xffb04863),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xffb04863),
                                      ),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        if (_emailController.text.isNotEmpty &&
                                            _passwordController
                                                .text.isNotEmpty) {
                                          setState(() {
                                            loading = true;
                                          });
                                          fetchScenes(
                                                  context, currentSceneIndex)
                                              .then((_) => {
                                                startSceneChangeTimer(),
                                                  login(),
                                                    setState(() {
                                                      loading = false;
                                                      gameloaded = true;
                                                    }),
                                                  

                                                    // print(value.toString()),
                                                    // if (value.isNotEmpty)
                                                    //   // if (value["type"] == "puzzle")
                                                    //   //   {
                                                    //   //     Navigator.push(
                                                    //   //       context,
                                                    //   //       MaterialPageRoute(
                                                    //   //           builder: (context) =>
                                                    //   //               PuzzleGame(
                                                    //   //                 imageUrls: [],
                                                    //   //               )), // Replace AnotherRoute() with your desired route
                                                    //   //     )
                                                    //   //   }
                                                    //   // else
                                                    //   //   {
                                                    //   //     Navigator.push(
                                                    //   //         context,
                                                    //   //         MaterialPageRoute(
                                                    //   //             builder: (context) =>
                                                    //   //                 Game(
                                                    //   //                     gameJson:
                                                    //   //                         value)))
                                                    //   //   }
                                                  });
                                        } else {
                                          setState(() {
                                            errorText = "enter valid prompt";
                                          });
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xffb04863),
                                      ),
                                      child: const Row(
                                        children: [
                                          Text(
                                            "Generate Game",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          Icon(
                                            Icons.arrow_circle_right,
                                            color: Colors.white,
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
