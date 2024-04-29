import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'dart:ui' as ui;

import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

class PuzzleTile {
  final int originalIndex;
  final ui.Image tile;

  PuzzleTile(this.originalIndex, this.tile);
}

class ImageSlicer extends ChangeNotifier {
    String gamestatus = "NS";
  int time = 0;
  void setgamestatus(String status) {
    gamestatus = status;
    notifyListeners();
  }

  void resetTime() {
    time = 0;
    notifyListeners();
  }

  void changetime() {
    time++;
    notifyListeners();
  }

  Future<List<ui.Image>> sliceImage(ui.Image image, int rows, int columns) async {
    final int tileWidth = image.width ~/ columns;
    final int tileHeight = image.height ~/ rows;
    final List<ui.Image> tiles = [];

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < columns; x++) {
        final Uint8List bytes = await cropImageToBytes(image, x * tileWidth, y * tileHeight, tileWidth, tileHeight);
        final ui.Codec codec = await ui.instantiateImageCodec(bytes);
        final ui.FrameInfo frameInfo = await codec.getNextFrame();
        tiles.add(frameInfo.image);
      }
    }

    return tiles;
  }

  Future<Uint8List> cropImageToBytes(ui.Image image, int x, int y, int width, int height) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final Rect rect = Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
    final Rect cropRect = Rect.fromLTWH(x.toDouble(), y.toDouble(), width.toDouble(), height.toDouble());
    canvas.drawImageRect(image, cropRect, rect, Paint());
    final ui.Picture picture = recorder.endRecording();
    final ui.Image croppedImage = await picture.toImage(width, height);
    final ByteData? byteData = await croppedImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}

// class ImageSlicer extends ChangeNotifier {
  // String gamestatus = "NS";
  // int time = 0;
  // void setgamestatus(String status) {
  //   gamestatus = status;
  //   notifyListeners();
  // }

  // void resetTime() {
  //   time = 0;
  //   notifyListeners();
  // }

  // void changetime() {
  //   time++;
  //   notifyListeners();
  // }

//   List<img.Image> sliceImage(img.Image image, int rows, int columns) {
//     final int tileWidth = image.width ~/ columns;
//     final int tileHeight = image.height ~/ rows;
//     final List<img.Image> tiles = [];

//     for (int y = 0; y < rows; y++) {
//       for (int x = 0; x < columns; x++) {
//         final img.Image tile = img.copyCrop(
//           image,
//           x * tileWidth,
//           y * tileHeight,
//           tileWidth,
//           tileHeight,
//         );
//         tiles.add(tile);
//       }
//     }

//     return tiles;
//   }
// }

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
          border: Border.all(color: Colors.white),
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

Widget riveanimation(BuildContext context) {
  return SizedBox(
    height: MediaQuery.of(context).size.height,
    width:  MediaQuery.of(context).size.width,
    child: Center(
      child: SizedBox(
        height: 300,
        width: 200,
        child: RiveAnimation.asset(
          'assets/complete.riv',
          fit: BoxFit.contain,
        ),
      ),
    ),
  );
}
