import 'package:flutter/material.dart';

class PuzzleGame extends StatefulWidget {
  final List<String> imageUrls;

  PuzzleGame({required this.imageUrls});

  @override
  _PuzzleGameState createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> {
  List<String> shuffledImageUrls = [];
  int? currentIndex;

  @override
  void initState() {
    super.initState();
    shuffledImageUrls = List.from(widget.imageUrls)..shuffle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Puzzle Game'),
      ),
      body: Center(
        child: SizedBox(
          height: 150,
          width: 150,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, 
              childAspectRatio: 1.0,// Adjust as per your puzzle size
            ),
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return DragTarget<int>(
                onAccept: (int data) {
                  setState(() {
                    final temp = shuffledImageUrls[index];
                    shuffledImageUrls[index] = shuffledImageUrls[data];
                    shuffledImageUrls[data] = temp;
                    currentIndex = null;
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  return Draggable<int>(
                    feedback: Container(
                      width: 50,
                      height: 50,
                      child: Image.asset("assets/icons/"+
                        shuffledImageUrls[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                    child:  Container(
                      width: 50,
                      height: 50,
                      child:currentIndex != index
                        ? Image.asset("assets/icons/"+
                        shuffledImageUrls[index],
                        fit: BoxFit.cover,
                      ):Container(),
                    )
                        , // Hide the original image when dragging
                    data: index, // Pass index as data when dragging
                    
                    onDragStarted: () {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}


