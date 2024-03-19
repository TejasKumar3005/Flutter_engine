import 'dart:convert';

import 'package:engine/utils/gameWidgets/puzzlegame.dart';
import 'package:engine/utils/puzzlefunctions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'test.dart';
import 'engine/engine.dart';

void main() {
   WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(providers: [ChangeNotifierProvider(create: (context) =>ImageSlicer())],
  child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple,primary: Colors.blueAccent),
        useMaterial3: true,
        
      ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
  home: PuzzleGame(imageUrls: ["Back (1).png","Badges (1).png","Check (1).png","Cross (1).png","Down (1).png","DownArrow (1).png","Download (1).png","Exit (1).png","Facebook (1).png"]),
      // home: Game(gameJson: {}),
    );
  }
}



