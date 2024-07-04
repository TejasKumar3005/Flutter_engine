import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:engine/utils/puzzlefunctions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

class ImageView extends StatelessWidget {
  final Uint8List imageData;

  const ImageView({Key? key, required this.imageData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      imageData,
      fit: BoxFit.fill,
    );
  }
}

class PuzzleGame extends StatefulWidget {
  final List<String> imageUrls;

  PuzzleGame({required this.imageUrls});

  @override
  _PuzzleGameState createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> {
  Artboard? _teddyArtboard;
  late String animationURL;
  SMITrigger? successTrigger;
  SMIBool? isHandsUp, isChecking;

  StateMachineController? stateMachineController;

  List<PuzzleTile> shuffledImageUrls = [];
  int? currentIndex;
  List<String> urls = [];
  late Timer _timer;
  int _seconds = 0;
  List<ui.Image> originalTiles = [];
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

    load_images();
    prepareRive();
  }

  Future<void> load_images() async {
    final ByteData data = await rootBundle.load('assets/bg1.jpg');
    final Uint8List bytes = data.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    originalTiles = await imageSlicer.sliceImage(frameInfo.image, 3, 3);
    puzzleTiles = originalTiles
        .asMap()
        .entries
        .map((e) => PuzzleTile(e.key, e.value))
        .toList()
      ..shuffle();
    shuffledImageUrls = List.from(puzzleTiles)..shuffle();
    imagePositions = {};
    imagePosIngGrid = List.generate(puzzleTiles.length, (index) => -1);
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      // Initialize randomPos here after the first frame has been drawn
      randomPos = List.generate(puzzleTiles.length, (index) {
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
    randomPos = List.generate(puzzleTiles.length, (index) {
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

    imagePosIngGrid = List.generate(originalTiles.length, (index) => -1);
    Provider.of<ImageSlicer>(context, listen: false).resetTime();
    startTimer();

    setState(() {
      gameStatus = "ST";
    });
  }

  void prepareRive() {
    rootBundle.load("assets/complete.riv").then(
      (data) {
        final file = RiveFile.import(data);
        final artboard = file.mainArtboard;
        stateMachineController =
            StateMachineController.fromArtboard(artboard, "Login Machine");
        if (stateMachineController != null) {
          artboard.addController(stateMachineController!);

          stateMachineController!.inputs.forEach((element) {
            if (element.name == "click") {
              successTrigger = element as SMITrigger;
            }
          });
        }

        setState(() => _teddyArtboard = artboard);
      },
    );
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
        for (var i = 0; i < originalTiles.length; i++) {
          if (imagePosIngGrid[i] != i) {
            print("---break" + i.toString());
            break;
          }
          if (i == originalTiles.length - 1) {
            _timer.cancel();
            gameStatus = "PS";
          }
        }
        print("Viewport width: $viewportWidth");
        return Scaffold(
          backgroundColor: const Color(0xffd6e2ea),
          body: Stack(children: [
            Center(
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/bg1.jpg"),
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
                  itemCount: shuffledImageUrls.length,
                  itemBuilder: (context, index) {
                    return DragTarget<int>(
                      key: Key(index.toString()),
                      onWillAccept: (data) {
                        return shuffledImageUrls[data!].originalIndex == index;
                      },
                      onMove: (details) {
                        print("-----moving");
                      },
                      onAccept: (int data) {
                        print(shuffledImageUrls[data].originalIndex.toString() +
                            "----");
                        setState(() {
                          imagePosIngGrid[
                              shuffledImageUrls[data].originalIndex] = index;
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
                          image: AssetImage("assets/icons/Play (3).png"),
                        )),
                      ),
                    ),
                  )),
            ),
            Visibility(
                visible: gameStatus == "ST" || gameStatus == "PS",
                child: TimerWidget()),
            if (_teddyArtboard != null && gameStatus == "PS")
              Positioned(
                top: (MediaQuery.of(context).size.height * 0.5) * 0.5,
                left: (MediaQuery.of(context).size.width * 0.2) * 0.5,
                child: GestureDetector(
                  onTap: () {
                    successTrigger?.change(true);
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Rive(
                      artboard: _teddyArtboard!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
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
                feedback: Container(
                    width: 100,
                    height: 100,
                    child: FutureBuilder<Uint8List>(
                      future:
                          _convertImageToBytes(shuffledImageUrls[index].tile),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return ImageView(imageData: snapshot.data!);
                        }
                      },
                    )),
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
                    currentIndex = null;
                  });
                },
                child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 0.3)),
                    child: FutureBuilder<Uint8List>(
                      future:
                          _convertImageToBytes(shuffledImageUrls[index].tile),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return ImageView(imageData: snapshot.data!);
                        }
                      },
                    )),
              ),
            );
          });
  }

  Future<Uint8List> _convertImageToBytes(ui.Image image) async {
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Failed to convert image to bytes');
    }
    return byteData.buffer.asUint8List();
  }
}
