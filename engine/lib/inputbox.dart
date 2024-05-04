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
      http.Response response = await http.post(
          Uri.parse("https://gameapi.svar.in/send_data"),
          body: jsonEncode(
            {
              "msg": _emailController.text.toString(),
              "api_key": _passwordController.text.toString()
            },
          ),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8'
          });
      if (response.statusCode != 200) {
        // Navigator.of(context).pop();
        final materialBanner = SnackBar(
                  /// need to set following properties for best effect of awesome_snackbar_content
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  behavior: SnackBarBehavior.floating,
                  content: AwesomeSnackbarContent(
                    title: 'Oh Snap!!',
                    message:
                        "Something went wrng",

                    /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                    contentType: ContentType.failure,
                    // to configure for material banner
                    inMaterialBanner: true,
                  ),
                  
                );

                ScaffoldMessenger.of(context)
                  ..hideCurrentMaterialBanner()
                  ..showSnackBar(materialBanner);
        failTrigger?.fire();
        return {};
      }
      successTrigger?.fire();
      // return jsonDecode("{\"Objective\": \"The objective of the game is for the child to explore and learn about a school environment through interactive gameplay.\", \"Character\": [{\"name\": \"Teacher1\", \"description\": \"An image of a teacher in a classroom.\", \"count\": 1, \"size\": {\"width\": 200, \"height\": 300}, \"isMovable\": false, \"position\": {\"x\": 0, \"y\": 0}, \"image\": \"image1\"}, {\"name\": \"Student1\", \"description\": \"An image of a student with a backpack.\", \"count\": 1, \"size\": {\"width\": 150, \"height\": 250}, \"isMovable\": true, \"position\": {\"x\": 600, \"y\": 400}, \"image\": \"image2\"}, {\"name\": \"Student2\", \"description\": \"An image of a student with a backpack.\", \"count\": 1, \"size\": {\"width\": 150, \"height\": 250}, \"isMovable\": true, \"position\": {\"x\": 1000, \"y\": 0}, \"image\": \"image2\"}, {\"name\": \"SchoolBus1\", \"description\": \"An image of a yellow school bus.\", \"count\": 1, \"size\": {\"width\": 300, \"height\": 200}, \"isMovable\": false, \"position\": {\"x\": 600, \"y\": 400}, \"image\": \"image3\"}, {\"name\": \"Books1\", \"description\": \"An image of colorful books.\", \"count\": 1, \"size\": {\"width\": 100, \"height\": 100}, \"isMovable\": true, \"position\": {\"x\": 600, \"y\": 400}, \"image\": \"image4\"}, {\"name\": \"Books2\", \"description\": \"An image of colorful books.\", \"count\": 1, \"size\": {\"width\": 100, \"height\": 100}, \"isMovable\": true, \"position\": {\"x\": 300, \"y\": 400}, \"image\": \"image4\"}, {\"name\": \"Books3\", \"description\": \"An image of colorful books.\", \"count\": 1, \"size\": {\"width\": 100, \"height\": 100}, \"isMovable\": true, \"position\": {\"x\": 500, \"y\": 400}, \"image\": \"image4\"}], \"Background\": \"https://images.svar.in/Images/bc71c9c3-8b92-4256-9119-f0123dd28d10.png\", \"Game State\": [{\"name\": \"GameOver\", \"type\": \"Boolean\", \"value\": false}, {\"name\": \"Points\", \"type\": \"Integer\", \"value\": 0}], \"Game Rules\": {\"Teacher1\": [{\"on_tap\": {\"condition\": [], \"action\": [{\"operator\": \"show_text\", \"operand1\": {\"name\": \"name\", \"type\": \"String\", \"value\": \"Welcome to the school! Let's learn together.\"}}]}}], \"Student1\": [{\"with_collision\": {\"Books1\": [{\"condition\": [], \"action\": [{\"target\": {\"name\": \"Points\", \"type\": \"variable\"}, \"operand1\": {\"name\": \"Points\", \"type\": \"variable\"}, \"operand2\": {\"name\": \"1\", \"type\": \"Integer\", \"value\": 1}, \"operator\": \"+\"}, {\"operator\": \"show_text\", \"operand1\": {\"name\": \"name\", \"type\": \"String\", \"value\": \"Great job! You found a book.\"}}, {\"target\": {\"name\": \"Student1\", \"type\": \"character\", \"value\": \"Student1\"}, \"operator\": \"update_position\", \"operand1\": {\"name\": \"Books1\", \"type\": \"character\", \"value\": \"Books1\"}}]}], \"Books2\": [{\"condition\": [], \"action\": [{\"target\": {\"name\": \"Points\", \"type\": \"variable\"}, \"operand1\": {\"name\": \"Points\", \"type\": \"variable\"}, \"operand2\": {\"name\": \"1\", \"type\": \"Integer\", \"value\": 1}, \"operator\": \"+\"}, {\"operator\": \"show_text\", \"operand1\": {\"name\": \"name\", \"type\": \"String\", \"value\": \"Great job! You found a book.\"}}, {\"target\": {\"name\": \"Student1\", \"type\": \"character\", \"value\": \"Student1\"}, \"operator\": \"update_position\", \"operand1\": {\"name\": \"Books2\", \"type\": \"character\", \"value\": \"Books2\"}}]}], \"Books3\": [{\"condition\": [], \"action\": [{\"target\": {\"name\": \"Points\", \"type\": \"variable\"}, \"operand1\": {\"name\": \"Points\", \"type\": \"variable\"}, \"operand2\": {\"name\": \"1\", \"type\": \"Integer\", \"value\": 1}, \"operator\": \"+\"}, {\"operator\": \"show_text\", \"operand1\": {\"name\": \"name\", \"type\": \"String\", \"value\": \"Great job! You found a book.\"}}, {\"target\": {\"name\": \"Student1\", \"type\": \"character\", \"value\": \"Student1\"}, \"operator\": \"update_position\", \"operand1\": {\"name\": \"Books3\", \"type\": \"character\", \"value\": \"Books3\"}}]}], \"Teacher1\": [{\"condition\": [], \"action\": [{\"operator\": \"show_text\", \"operand1\": {\"name\": \"name\", \"type\": \"String\", \"value\": \"Hello, teacher!\"}}, {\"target\": {\"name\": \"Student1\", \"type\": \"character\", \"value\": \"Student1\"}, \"operator\": \"update_position\", \"operand1\": {\"name\": \"Teacher1\", \"type\": \"character\", \"value\": \"Teacher1\"}}]}], \"SchoolBus1\": [{\"condition\": [], \"action\": [{\"operator\": \"show_text\", \"operand1\": {\"name\": \"name\", \"type\": \"String\", \"value\": \"Time to go home!\"}}, {\"target\": {\"name\": \"GameOver\", \"type\": \"variable\"}, \"operand1\": {\"name\": \"true\", \"type\": \"Boolean\", \"value\": \"true\"}, \"operator\": \"=\"}]}]}}], \"Student2\": [{\"with_collision\": {\"Books1\": [{\"condition\": [], \"action\": [{\"target\": {\"name\": \"Points\", \"type\": \"variable\"}, \"operand1\": {\"name\": \"Points\", \"type\": \"variable\"}, \"operand2\": {\"name\": \"1\", \"type\": \"Integer\", \"value\": 1}, \"operator\": \"+\"}, {\"operator\": \"show_text\", \"operand1\": {\"name\": \"name\", \"type\": \"String\", \"value\": \"Great job! You found a book.\"}}, {\"target\": {\"name\": \"Student2\", \"type\": \"character\", \"value\": \"Student2\"}, \"operator\": \"update_position\", \"operand1\": {\"name\": \"Books1\", \"type\": \"character\", \"value\": \"Books1\"}}]}], \"Books2\": [{\"condition\": [], \"action\": [{\"target\": {\"name\": \"Points\", \"type\": \"variable\"}, \"operand1\": {\"name\": \"Points\", \"type\": \"variable\"}, \"operand2\": {\"name\": \"1\", \"type\": \"Integer\", \"value\": 1}, \"operator\": \"+\"}, {\"operator\": \"show_text\", \"operand1\": {\"name\": \"name\", \"type\": \"String\", \"value\": \"Great job! You found a book.\"}}, {\"target\": {\"name\": \"Student2\", \"type\": \"character\", \"value\": \"Student2\"}, \"operator\": \"update_position\", \"operand1\": {\"name\": \"Books2\", \"type\": \"character\", \"value\": \"Books2\"}}]}], \"Books3\": [{\"condition\": [], \"action\": [{\"target\": {\"name\": \"Points\", \"type\": \"variable\"}, \"operand1\": {\"name\": \"Points\", \"type\": \"variable\"}, \"operand2\": {\"name\": \"1\", \"type\": \"Integer\", \"value\": 1}, \"operator\": \"+\"}, {\"operator\": \"show_text\", \"operand1\": {\"name\": \"name\", \"type\": \"String\", \"value\": \"Great job! You found a book.\"}}, {\"target\": {\"name\": \"Student2\", \"type\": \"character\", \"value\": \"Student2\"}, \"operator\": \"update_position\", \"operand1\": {\"name\": \"Books3\", \"type\": \"character\", \"value\": \"Books3\"}}]}], \"Teacher1\": [{\"condition\": [], \"action\": [{\"operator\": \"show_text\", \"operand1\": {\"name\": \"name\", \"type\": \"String\", \"value\": \"Hello, teacher!\"}}, {\"target\": {\"name\": \"Student2\", \"type\": \"character\", \"value\": \"Student2\"}, \"operator\": \"update_position\", \"operand1\": {\"name\": \"Teacher1\", \"type\": \"character\", \"value\": \"Teacher1\"}}]}], \"SchoolBus1\": [{\"condition\": [], \"action\": [{\"operator\": \"show_text\", \"operand1\": {\"name\": \"name\", \"type\": \"String\", \"value\": \"Time to go home!\"}}, {\"target\": {\"name\": \"GameOver\", \"type\": \"variable\"}, \"operand1\": {\"name\": \"true\", \"type\": \"Boolean\", \"value\": \"true\"}, \"operator\": \"=\"}]}]}}], \"Books1\": [{\"with_collision\": {\"Student1\": [{\"condition\": [], \"action\": [{\"target\": {\"name\": \"Points\", \"type\": \"variable\"}, \"operand1\": {\"name\": \"Points\", \"type\": \"variable\"}, \"operand2\": {\"name\": \"1\", \"type\": \"Integer\", \"value\": 1}, \"operator\": \"+\"}, {\"operator\": \"show_text\", \"operand1\": {\"name\": \"name\", \"type\": \"String\", \"value\": \"Well done! You picked up a book.\"}}, {\"target\": {\"name\": \"Books1\", \"type\": \"character\", \"value\": \"Books1\"}, \"operator\": \"update_position\", \"operand1\": {\"name\": \"Student1\", \"type\": \"character\", \"value\": \"Student1\"}}]}], \"Student2\": [{\"condition\": [], \"action\": [{\"target\": {\"name\": \"Points\", \"type\": \"variable\"}, \"operand1\": {\"name\": \"Points\", \"type\": \"variable\"}, \"operand2\": {\"name\": \"1\", \"type\": \"Integer\", \"value\": 1}, \"operator\": \"+\"}, {\"operator\": \"show_text\", \"operand1\": {\"name\": \"name\", \"type\": \"String\", \"value\": \"Well done! You picked up a book.\"}}, {\"target\": {\"name\": \"Books1\", \"type\": \"character\", \"value\": \"Books1\"}, \"operator\": \"update_position\", \"operand1\": {\"name\": \"Student2\", \"type\": \"character\", \"value\": \"Student2\"}}]}]}}], \"Books2\": [{\"with_collision\": {\"Student1\": [{\"condition\": [], \"action\": [{\"target\": {\"name\": \"Points\", \"type\": \"variable\"}, \"operand1\": {\"name\": \"Points\", \"type\": \"variable\"}, \"operand2\": {\"name\": \"1\", \"type\": \"Integer\", \"value\": 1}, \"operator\": \"+\"}, {\"operator\": \"show_text\", \"operand1\": {\"name\": \"name\", \"type\": \"String\", \"value\": \"Well done! You picked up a book.\"}}, {\"target\": {\"name\": \"Books2\", \"type\": \"character\", \"value\": \"Books2\"}, \"operator\": \"update_position\", \"operand1\": {\"name\": \"Student1\", \"type\": \"character\", \"value\": \"Student1\"}}]}], \"Student2\": [{\"condition\": [], \"action\": [{\"target\": {\"name\": \"Points\", \"type\": \"variable\"}, \"operand1\": {\"name\": \"Points\", \"type\": \"variable\"}, \"operand2\": {\"name\": \"1\", \"type\": \"Integer\", \"value\": 1}, \"operator\": \"+\"}, {\"operator\": \"show_text\", \"operand1\": {\"name\": \"name\", \"type\": \"String\", \"value\": \"Well done! You picked up a book.\"}}, {\"target\": {\"name\": \"Books2\", \"type\": \"character\", \"value\": \"Books2\"}, \"operator\": \"update_position\", \"operand1\": {\"name\": \"Student2\", \"type\": \"character\", \"value\": \"Student2\"}}]}]}}], \"Books3\": [{\"with_collision\": {\"Student1\": [{\"condition\": [], \"action\": [{\"target\": {\"name\": \"Points\", \"type\": \"variable\"}, \"operand1\": {\"name\": \"Points\", \"type\": \"variable\"}, \"operand2\": {\"name\": \"1\", \"type\": \"Integer\", \"value\": 1}, \"operator\": \"+\"}, {\"operator\": \"show_text\", \"operand1\": {\"name\": \"name\", \"type\": \"String\", \"value\": \"Well done! You picked up a book.\"}}, {\"target\": {\"name\": \"Books3\", \"type\": \"character\", \"value\": \"Books3\"}, \"operator\": \"update_position\", \"operand1\": {\"name\": \"Student1\", \"type\": \"character\", \"value\": \"Student1\"}}]}], \"Student2\": [{\"condition\": [], \"action\": [{\"target\": {\"name\": \"Points\", \"type\": \"variable\"}, \"operand1\": {\"name\": \"Points\", \"type\": \"variable\"}, \"operand2\": {\"name\": \"1\", \"type\": \"Integer\", \"value\": 1}, \"operator\": \"+\"}, {\"operator\": \"show_text\", \"operand1\": {\"name\": \"name\", \"type\": \"String\", \"value\": \"Well done! You picked up a book.\"}}, {\"target\": {\"name\": \"Books3\", \"type\": \"character\", \"value\": \"Books3\"}, \"operator\": \"update_position\", \"operand1\": {\"name\": \"Student2\", \"type\": \"character\", \"value\": \"Student2\"}}]}]}}], \"SchoolBus1\": [{\"on_tap\": {\"condition\": [], \"action\": [{\"operator\": \"show_text\", \"operand1\": {\"name\": \"name\", \"type\": \"String\", \"value\": \"Tap the bus to go on a field trip.\"}}]}}]}, \"Images\": {\"image1\": \"https://images.svar.in/Images/69cfc55d-c916-4faa-8617-4fe5198d6225.png\", \"image2\": \"https://images.svar.in/Images/e3e924b0-6d45-403e-9ea1-428ed8ad0435.png\", \"image3\": \"https://images.svar.in/Images/89096fa0-a512-44d5-9b41-d7486c69535d.png\", \"image4\": \"https://images.svar.in/Images/b026d298-b5c0-4265-94e4-fad40a170bb3.png\"}}");
      return jsonDecode(response.body)["message"];
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
