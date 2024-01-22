import 'package:flutter/material.dart';
// import 'package:flame/game.dart';

// Engine widget that takes a JSON onject and then implements the game 

// Data structure class for the game
// widget that takes a JSON onject and then implements the game



class Game extends StatefulWidget {
  
  final String gameJson;

  Game({Key? key, required this.gameJson}) : super(key: key);

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
