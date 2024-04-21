import 'dart:convert';
import 'dart:js_interop';
import 'package:engine/engine/engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:kafkabr/kafka.dart';
import 'package:rive/rive.dart';

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
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            jsonDecode(response.body)["message"],
          ),
          backgroundColor: Colors.red,
        ));
        failTrigger?.fire();
        return {};
      }
      successTrigger?.fire();
      return jsonDecode(response.body)["message"];
    } catch (e) {
      Navigator.of(context).pop();
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        action: SnackBarAction(label: "ok", onPressed: () {}),
        content: Text(
          e.toString(),
        ),
        backgroundColor: Colors.red,
      ));
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
    if (val.isEmpty()) {
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
                                          print(value.toString()),
                                          if (value.isNotEmpty)
                                            {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          Game(
                                                              gameJson: value)))
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
