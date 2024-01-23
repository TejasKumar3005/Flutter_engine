import 'dart:ui'; // Import dart:ui for Offset and Size
// object has size and position 

class Object {
  double x;
  double y;
  double width;
  double height;
  String name;

  // Constructor with named parameters
  Object({required this.x, required this.y, required this.width, required this.height, required this.name});

  // Example of a method to update position
  void updatePosition(Offset newPosition) {
    x = newPosition.dx;
    y = newPosition.dy;
  }

  // Example of a method to update size
  void updateSize(Size newSize) {
    width = newSize.width;
    height = newSize.height;
  }

  @override
  String toString() {
    return 'Object $name {x: $x, y: $y, width: $width, height: $height}';
  }

}


// class Character extends Object {

//   //  character has an image
//   // Take all possible ways to input an image
//   // 1. Image.asset('assets/images/character.png')
//   // 2. Image.file(File('assets/images/character.png'))
//   // 3. Image.memory(bytes)
//   // 4. Image.network('https://example.com/foobar.jpg')
//   // 5. Image(image: FileImage(File('assets/images/character.png')))
//   // 6. Image(image: MemoryImage(bytes))
//   // 7. Image(image: NetworkImage('https://example.com/foobar.jpg'))
//   // 8. Image(image: AssetImage('assets/images/character.png'))
//   // 9. Image(image: ExactAssetImage('assets/images/character.png'))
//   // 10. Image(image: ResizeImage(FileImage(File('assets/images/character.png')), width: 120, height: 120))

  
// }
