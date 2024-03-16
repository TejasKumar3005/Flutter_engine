import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:engine/utils/puzzlefunctions.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class PuzzleGame extends StatefulWidget {
  final List<String> imageUrls;

  PuzzleGame({required this.imageUrls});

  @override
  _PuzzleGameState createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> {
  List<String> shuffledImageUrls = [];
  int? currentIndex;
  List<String> urls = [];
  late Timer _timer;
  int _seconds = 0;
  List<img.Image> originalTiles = [];
  List<PuzzleTile> puzzleTiles = [];
  ImageSlicer imageSlicer = ImageSlicer();
  String gameStatus = "NS";
  List<int> imagePosIngGrid = [];
  Map<int, int> occupied = {};
  void fetchImage() async {
    var res = await http.get(Uri.parse("/url"));
    if (res.statusCode == 200) {
      setState(() {
        urls = jsonDecode(res.body);
        shuffledImageUrls = List.from(urls)..shuffle();
      });
    }
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) {
      Provider.of<ImageSlicer>(context, listen: false).changetime();
    });
  }

  late Map<int, Offset> imagePositions;
  List<Offset> randomPos = [];
  late List<Offset> offsetsOfDragTargets;
  List<int> overlappingTargets = [];

  @override
  void initState() {
    super.initState();

    img.Image originalImage =
        img.decodeImage(File("assets/bg.jpeg").readAsBytesSync())!;
    originalTiles = imageSlicer.sliceImage(originalImage, 3, 3);
    puzzleTiles = originalTiles
        .asMap()
        .entries
        .map((e) => PuzzleTile(e.key, e.value))
        .toList()
      ..shuffle();
    shuffledImageUrls = List.from(widget.imageUrls)..shuffle();
    imagePositions = {};
    imagePosIngGrid = List.generate(widget.imageUrls.length, (index) => -1);
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      // Initialize randomPos here after the first frame has been drawn
      randomPos = List.generate(widget.imageUrls.length, (index) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final randomX = Random().nextInt(screenWidth.toInt() - 100).toDouble();
        final randomY = Random().nextInt(screenHeight.toInt() - 100).toDouble();
        return Offset(randomX, randomY);
      });
      // Call setState to rebuild the widget with the updated randomPos
      setState(() {});
    });
  }

  void generatePos() {
    randomPos = List.generate(widget.imageUrls.length, (index) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      final randomX = Random().nextInt(screenWidth.toInt() - 100).toDouble();
      final randomY = Random().nextInt(screenHeight.toInt() - 100).toDouble();
      return Offset(randomX, randomY);
    });
    setState(() {});
  }

  void resetGame() {
    generatePos();
    imagePositions = {};

    imagePosIngGrid = List.generate(widget.imageUrls.length, (index) => -1);
    Provider.of<ImageSlicer>(context, listen: false).resetTime();
    startTimer();

    setState(() {
      gameStatus = "ST";
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double viewportWidth = constraints.maxWidth;
        for (var i = 0; i < widget.imageUrls.length; i++) {
          if (imagePosIngGrid[i] != puzzleTiles[i].originalIndex) {
            break;
          }
          if (i == widget.imageUrls.length - 1) {
           
            _timer.cancel();
            gameStatus = "PS";
          }
        }
        print("Viewport width: $viewportWidth");
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(children: [
            Center(
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/bg.jpeg"),
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.low),
                    border: Border.all(color: Colors.white, width: 2)),
                width: 300,
              ),
            ),
            Center(
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                    color: Colors.yellow.withOpacity(0.5),
                    border: Border.all(color: Colors.white, width: 2)),
                width: 300,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.0, // Adjust as per your puzzle size
                  ),
                  itemCount: widget.imageUrls.length,
                  itemBuilder: (context, index) {
                    return DragTarget<int>(
                      key: Key(index.toString()),
                      onWillAccept: (data) {
                        print("-----will accept");
                        return true;
                      },
                      onMove: (details) {
                        print("-----moving");
                      },
                      onAccept: (int data) {
                        setState(() {
                          imagePosIngGrid[data] = index;
                          imagePositions[data] = Offset(
                            puzzleOffsets(context)[0] + index % 3 * 100.0,
                            puzzleOffsets(context)[1] + index ~/ 3 * 100.0,
                          );
                        });
                      },
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black, width: 0.3)),
                          child: Container(),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            ..._buildScatteredImages(),
            Visibility(
              visible: gameStatus == "NS" || gameStatus == "PS",
              child: Positioned(
                  top: (MediaQuery.of(context).size.height - 100) / 2,
                  left: (MediaQuery.of(context).size.width - 100) / 2,
                  child: Transform.rotate(
                    angle: 0.4,
                    child: GestureDetector(
                      onTap: () {
                        resetGame();
                      },
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image:
                                    AssetImage("assets/icons/Play (3).png"))),
                      ),
                    ),
                  )),
            ),
            Visibility(
                visible: gameStatus == "ST" || gameStatus == "PS",
                child: TimerWidget()),
          ]),
        );
      },
    );
  }

  List<double> puzzleOffsets(BuildContext context) {
    List<double> off = [];
    double offX = (MediaQuery.of(context).size.width - 300) / 2;
    double offY = (MediaQuery.of(context).size.height - 300) / 2;
    off.add(offX);
    off.add(offY);
    return off;
  }

  List<int> getCurrentOverlappingTargets(Offset localOffset,
      List<Offset> targetOffsets, double targetWidth, double targetHeight) {
    List<int> overlappingTargets = [];
    for (int i = 0; i < targetOffsets.length; i++) {
      Offset targetOffset = targetOffsets[i];
      // Check if the local offset of the dragged item lies within the bounds of the target
      if (localOffset.dx >= targetOffset.dx &&
          localOffset.dx <= targetOffset.dx + targetWidth &&
          localOffset.dy >= targetOffset.dy &&
          localOffset.dy <= targetOffset.dy + targetHeight) {
        print("____index-> " + i.toString());
        overlappingTargets.add(i); // Add the index of the target to the list
      }
    }
    return overlappingTargets;
  }

  List<Widget> _buildScatteredImages() {
    return gameStatus == "NS"
        ? [Container()]
        : List.generate(puzzleTiles.length, (index) {
            final position = imagePositions[index] ?? randomPos[index];

            return Positioned(
              key: Key(index.toString()),
              left: position.dx,
              top: position.dy,
              child: Draggable<int>(
                key: Key(index.toString()),
                data: index,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 0.3)),
                  child: Image.memory(
                    Uint8List.fromList(img.encodePng(puzzleTiles[index].tile)),
                    fit: BoxFit.fill,
                  ),
                ),
                feedback: Container(
                  width: 100,
                  height: 100,
                  child: Image.memory(
                    Uint8List.fromList(img.encodePng(puzzleTiles[index].tile)),
                    fit: BoxFit.fill,
                  ),
                ),
                childWhenDragging: Container(),
                onDragStarted: () {
                  print("---darg started");
                  setState(() {
                    currentIndex = index;
                  });
                },
                onDragCompleted: () {
                  setState(() {
                    currentIndex = null;
                  });
                },
                onDraggableCanceled: (Velocity velocity, Offset offset) {
                  // Reset the position if the drag operation is canceled
                  setState(() {
                    imagePositions[index] = offset;
                    currentIndex = null;
                  });
                },
              ),
            );
          });
  }
}
