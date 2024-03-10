import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'test.dart';
import 'engine/engine.dart';
void main() {
   WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
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
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        
      ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      home: Game(gameJson: {}),
    );
  }
}



