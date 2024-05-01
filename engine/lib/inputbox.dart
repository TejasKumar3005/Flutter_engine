import 'dart:convert';
// import 'dart:js_interop';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:engine/engine/engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:kafkabr/kafka.dart';
import 'package:rive/rive.dart';
import 'package:engine/utils/gameWidgets/puzzlegame.dart';


class RiveAnimationDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      content: Container(
        width: 200,
        height: 200,
        child: RiveAnimation.asset(
          'assets/loading.riv', // Replace with your Rive animation asset path
          fit: BoxFit.contain,
        ),
      ),
      actions: [],
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

  StateMachineController? stateMachineController;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Future<Map<String, dynamic>> getJson(BuildContext context) async {
    try {
      print("---msg    " +
          _emailController.text.toString() +
          "-----api" +
          _passwordController.text.toString());
      // http.Response response = await http.post(
      //     Uri.parse("https://gameapi.svar.in/send_data"),
      //     body: jsonEncode(
      //       {
      //         "msg": _emailController.text.toString(),
      //         "api_key": _passwordController.text.toString()
      //       },
      //     ),
      //     headers: <String, String>{
      //       'Content-Type': 'application/json; charset=UTF-8'
      //     });
      // if (response.statusCode != 200) {
      //   // Navigator.of(context).pop();
      //   final materialBanner = SnackBar(
      //             /// need to set following properties for best effect of awesome_snackbar_content
      //             elevation: 0,
      //             backgroundColor: Colors.transparent,
      //             behavior: SnackBarBehavior.floating,
      //             content: AwesomeSnackbarContent(
      //               title: 'Oh Snap!!',
      //               message:
      //                   "Something went wrng",

      //               /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
      //               contentType: ContentType.failure,
      //               // to configure for material banner
      //               inMaterialBanner: true,
      //             ),
                  
      //           );

      //           ScaffoldMessenger.of(context)
      //             ..hideCurrentMaterialBanner()
      //             ..showSnackBar(materialBanner);
      //   failTrigger?.fire();
      //   return {};
      // }
      // successTrigger?.fire();
      return jsonDecode("{\"Objective\": \"The game educates children about Christmas through an interactive and informative game. Children will learn about the traditions, symbols, and spirit of Christmas while playing the game.\", \"Character\": [{\"name\": \"Santa Claus1\", \"description\": \"Jolly old man with a red suit and white beard who brings gifts.\", \"count\": 1, \"size\": {\"width\": 200, \"height\": 300}, \"isMovable\": true, \"position\": {\"x\": 100, \"y\": 100}, \"image\": \"image1\"}, {\"name\": \"Reindeer1\", \"description\": \"Majestic animals with antlers that pull Santa's sleigh.\", \"count\": 1, \"size\": {\"width\": 250, \"height\": 150}, \"isMovable\": true, \"position\": {\"x\": 400, \"y\": 400}, \"image\": \"image2\"}, {\"name\": \"Christmas Tree1\", \"description\": \"Evergreen tree decorated with lights, ornaments, and a star on top.\", \"count\": 1, \"size\": {\"width\": 300, \"height\": 400}, \"isMovable\": false, \"position\": {\"x\": 800, \"y\": 800}, \"image\": \"image3\"}, {\"name\": \"Snowman1\", \"description\": \"Frosty figure made of snow with a carrot nose and top hat.\", \"count\": 1, \"size\": {\"width\": 150, \"height\": 200}, \"isMovable\": true, \"position\": {\"x\": 600, \"y\": 600}, \"image\": \"image4\"}], \"Background\": \"A winter wonderland setting with snow-covered landscapes, twinkling lights, and festive decorations, creating a magical atmosphere for the Christmas game.\", \"Game State\": [{\"name\": \"GiftsDelivered\", \"type\": \"Integer\", \"value\": 0}, {\"name\": \"SnowballsThrown\", \"type\": \"Integer\", \"value\": 0}, {\"name\": \"GameOver\", \"type\": \"Boolean\", \"value\": false}], \"Game Rules\": {\"Santa Claus1\": [{\"with_collision\": {\"Christmas Tree1\": [{\"condition\": [], \"action\": [{\"target\": {\"name\": \"GiftsDelivered\", \"type\": \"variable\"}, \"operand1\": {\"name\": \"GiftsDelivered\", \"type\": \"variable\"}, \"operand2\": {\"name\": \"1\", \"type\": \"Integer\", \"value\": 1}, \"operator\": \"+\"}, {\"operator\": \"show_text\", \"operand1\": {\"name\": \"name\", \"type\": \"String\", \"value\": \"Gift delivered!\"}}, {\"target\": {\"name\": \"Santa Claus1\", \"type\": \"character\", \"value\": \"Santa Claus1\"}, \"operator\": \"update_position\", \"operand1\": {\"name\": \"Christmas Tree1\", \"type\": \"character\", \"value\": \"Christmas Tree1\"}}]}, {\"condition\": [[{\"operand1\": {\"name\": \"GiftsDelivered\", \"type\": \"variable\"}, \"operand2\": {\"name\": \"3\", \"type\": \"Integer\", \"value\": 3}, \"operator\": \"=\"}]], \"action\": [{\"target\": {\"name\": \"GameOver\", \"type\": \"variable\"}, \"operand1\": {\"name\": \"true\", \"type\": \"Boolean\", \"value\": \"true\"}, \"operator\": \"=\"}, {\"operator\": \"show_text\", \"operand1\": {\"name\": \"name\", \"type\": \"String\", \"value\": \"All gifts delivered! Game Completed\"}}]}]}, \"on_drag\": {\"Reindeer1\": [{\"condition\": [], \"action\": [{\"target\": {\"name\": \"SnowballsThrown\", \"type\": \"variable\"}, \"operand1\": {\"name\": \"SnowballsThrown\", \"type\": \"variable\"}, \"operand2\": {\"name\": \"1\", \"type\": \"Integer\", \"value\": 1}, \"operator\": \"+\"}, {\"operator\": \"show_text\", \"operand1\": {\"name\": \"name\", \"type\": \"String\", \"value\": \"Snowball thrown!\"}}, {\"target\": {\"name\": \"Santa Claus1\", \"type\": \"character\", \"value\": \"Santa Claus1\"}, \"operator\": \"update_position\", \"operand1\": {\"name\": \"Reindeer1\", \"type\": \"character\", \"value\": \"Reindeer1\"}}]}, {\"condition\": [[{\"operand1\": {\"name\": \"SnowballsThrown\", \"type\": \"variable\"}, \"operand2\": {\"name\": \"5\", \"type\": \"Integer\", \"value\": 5}, \"operator\": \"=\"}]], \"action\": [{\"target\": {\"name\": \"GameOver\", \"type\": \"variable\"}, \"operand1\": {\"name\": \"true\", \"type\": \"Boolean\", \"value\": \"true\"}, \"operator\": \"=\"}, {\"operator\": \"show_text\", \"operand1\": {\"name\": \"name\", \"type\": \"String\", \"value\": \"Too many snowballs thrown! Game Over\"}}]}]}}], \"Reindeer1\": [{\"with_collision\": {\"Santa Claus1\": [{\"condition\": [], \"action\": [{\"target\": {\"name\": \"SnowballsThrown\", \"type\": \"variable\"}, \"operand1\": {\"name\": \"SnowballsThrown\", \"type\": \"variable\"}, \"operand2\": {\"name\": \"1\", \"type\": \"Integer\", \"value\": 1}, \"operator\": \"+\"}, {\"operator\": \"show_text\", \"operand1\": {\"name\": \"name\", \"type\": \"String\", \"value\": \"Snowball thrown!\"}}, {\"target\": {\"name\": \"Reindeer1\", \"type\": \"character\", \"value\": \"Reindeer1\"}, \"operator\": \"update_position\", \"operand1\": {\"name\": \"Santa Claus1\", \"type\": \"character\", \"value\": \"Santa Claus1\"}}]}, {\"condition\": [[{\"operand1\": {\"name\": \"SnowballsThrown\", \"type\": \"variable\"}, \"operand2\": {\"name\": \"5\", \"type\": \"Integer\", \"value\": 5}, \"operator\": \"=\"}]], \"action\": [{\"target\": {\"name\": \"GameOver\", \"type\": \"variable\"}, \"operand1\": {\"name\": \"true\", \"type\": \"Boolean\", \"value\": \"true\"}, \"operator\": \"=\"}, {\"operator\": \"show_text\", \"operand1\": {\"name\": \"name\", \"type\": \"String\", \"value\": \"Too many snowballs thrown! Game Over\"}}]}]}}], \"Snowman1\": [{\"with_collision\": {\"Santa Claus1\": [{\"condition\": [], \"action\": [{\"target\": {\"name\": \"GiftsDelivered\", \"type\": \"variable\"}, \"operand1\": {\"name\": \"GiftsDelivered\", \"type\": \"variable\"}, \"operand2\": {\"name\": \"1\", \"type\": \"Integer\", \"value\": 1}, \"operator\": \"+\"}, {\"operator\": \"show_text\", \"operand1\": {\"name\": \"name\", \"type\": \"String\", \"value\": \"Gift delivered!\"}}, {\"target\": {\"name\": \"Snowman1\", \"type\": \"character\", \"value\": \"Snowman1\"}, \"operator\": \"update_position\", \"operand1\": {\"name\": \"Santa Claus1\", \"type\": \"character\", \"value\": \"Santa Claus1\"}}]}, {\"condition\": [[{\"operand1\": {\"name\": \"GiftsDelivered\", \"type\": \"variable\"}, \"operand2\": {\"name\": \"3\", \"type\": \"Integer\", \"value\": 3}, \"operator\": \"=\"}]], \"action\": [{\"target\": {\"name\": \"GameOver\", \"type\": \"variable\"}, \"operand1\": {\"name\": \"true\", \"type\": \"Boolean\", \"value\": \"true\"}, \"operator\": \"=\"}, {\"operator\": \"show_text\", \"operand1\": {\"name\": \"name\", \"type\": \"String\", \"value\": \"All gifts delivered! Game Completed\"}}]}]}}]}, \"Images\": {\"image1\": \"https://images.svar.in/Images/e3965f57-5790-4fb3-8206-5bd065bf4620.png\", \"image2\": \"https://images.svar.in/Images/bd8c378b-3777-4386-a051-c2149d40c4be.png\", \"image3\": \"https://images.svar.in/Images/4197cf2e-2337-40de-abda-a300351042b4.png\", \"image4\": \"https://images.svar.in/Images/0a324035-cc57-4d27-bbf3-ffc2458c8838.png\"}}");
      // return jsonDecode(response.body)["message"];
    } catch (e) {
      // Navigator.of(context).pop();
      print(e.toString());
      final materialBanner = SnackBar(
                  /// need to set following properties for best effect of awesome_snackbar_content
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                behavior: SnackBarBehavior.floating,
                  content: AwesomeSnackbarContent(
                    title: 'Oh Snap!!',
                    message:
                        e.toString(),

                    /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                    contentType: ContentType.failure,
                    // to configure for material banner
                    
                  ),
                  
                );

                ScaffoldMessenger.of(context)
                  ..hideCurrentMaterialBanner()
                  ..showSnackBar(materialBanner);
      failTrigger?.fire();
      return {};
    }
  }

  @override
  void initState() {
    // TODO: implement initState
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

  void handsOnTheEyes() {
    isHandsUp?.change(true);
  }

  void lookOnTheTextField() {
    isHandsUp?.change(false);
    isChecking?.change(true);
    numLook?.change(0);
  }

  void moveEyeBalls(val) {
    print("hi");
    print("val$val");
    // print();
    if (val.isEmpty) {
      setState(() {
        errorText = "enter valid prompt";
      });
    } else {
      setState(() {
        errorText = null;
      });
    }
    print(val.length.toDouble());
    numLook?.change(val.length.toDouble());
  }

  void login() {
    isChecking?.change(false);
    isHandsUp?.change(false);
    if (_emailController.text == "admin" &&
        _passwordController.text == "admin") {
      successTrigger?.fire();
    } else {
      failTrigger?.fire();
    }
  }

  String? errorText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                              hintText: "make game on Holi",
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
                              errorText: _passwordController.text.isEmpty &&
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //remember me checkbox
                              // Row(
                              //   children: [
                              //     Checkbox(
                              //       value: false,
                              //       onChanged: (value) {},
                              //     ),
                              //     const Text("Remember me"),
                              //   ],
                              // ),
                              ElevatedButton(
                                onPressed: () {
                                  if (_emailController.text.isNotEmpty &&
                                      _passwordController.text.isNotEmpty) {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return RiveAnimationDialog();
                                      },
                                    );
                                    getJson(context).then((value) => {
                                          Navigator.of(context).pop(),
                                          login(),
                                          print(value.toString()),
                                          if (value.isNotEmpty)
                                            {

                                              if ( value["type"] == "puzzle") {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => PuzzleGame(
                                                                imageUrls: [],
                                                              )), // Replace AnotherRoute() with your desired route
                                                    )
                                                  } else {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          Game(
                                                              gameJson: value)))
                                            }
                                            }
                                        });
                                  } else {
                                    setState(() {
                                      errorText = "enter valid prompt";
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xffb04863),
                                ),
                                child: const Row(
                                  children: [
                                    Text(
                                      "Generate Game",
                                      style: TextStyle(color: Colors.white),
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
