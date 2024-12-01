import 'dart:convert';

import 'package:engine/utils/gameWidgets/puzzlegame.dart';
import 'package:engine/utils/puzzlefunctions.dart';
// import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'test.dart';
import 'engine/engine.dart';
import 'inputbox.dart';

void main() {
   WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(providers: [ChangeNotifierProvider(create: (context) =>ImageSlicer())],
  child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Svar GameGen AI',
      
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple,primary: Colors.blueAccent),
        useMaterial3: true,
        
      ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
  // home:  ResponsiveWidgetTest(),
  // home: PuzzleGame(imageUrls: [],),
      home:KafkaMessageWidget(),
    );
  }
}



