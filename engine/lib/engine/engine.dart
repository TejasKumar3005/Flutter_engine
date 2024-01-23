import 'package:flutter/material.dart';
import '../test.dart';

class Game extends StatefulWidget {
  final String gameJson;

  Game({Key? key, required this.gameJson}) : super(key: key);

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // Set your desired aspect ratio here
      width: 200.0,
      height: 100.0,
      color: Color.fromARGB(255, 23, 13, 220),
      child: AspectRatio(
        aspectRatio: 4/3, // Example aspect ratio: width / height
        child: Stack(
          children: [
            ResponsiveWidgetTest(),
          ],
        ),
      ),
    );
  }
}
