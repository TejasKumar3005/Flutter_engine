import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'dart:ui' as ui;

import 'package:provider/provider.dart';

class ImageSlicer extends ChangeNotifier {
  String gamestatus = "NS";
  int time = 0;
  void setgamestatus(String status) {
    gamestatus = status;
    notifyListeners();
  }

  void changetime() {
    time++;
    notifyListeners();
  }

  List<img.Image> sliceImage(img.Image image, int rows, int columns) {
    final int tileWidth = image.width ~/ columns;
    final int tileHeight = image.height ~/ rows;
    final List<img.Image> tiles = [];

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < columns; x++) {
        final img.Image tile = img.copyCrop(
          image,
          x * tileWidth,
          y * tileHeight,
          tileWidth,
          tileHeight,
        );
        tiles.add(tile);
      }
    }

    return tiles;
  }
}

class TimerWidget extends StatefulWidget {
  const TimerWidget({super.key});

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

String formatTime(int seconds) {
  int minutes = seconds ~/ 60;
  int remainingSeconds = seconds % 60;
  return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
}

class _TimerWidgetState extends State<TimerWidget> {
  @override
  Widget build(BuildContext context) {
    final myProvider = Provider.of<ImageSlicer>(context);
    return Positioned(
      top: 20,
      right: 20,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 209, 12, 192).withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'Timer: ${formatTime(myProvider.time)}',
          style: TextStyle(
            fontFamily: "samuraiblast",
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
