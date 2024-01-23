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


class Character extends Object {
  // Character has a name
  String name;
  // Character has an image 
  
  // Constructor with named parameters
  Character({required this.name, required double x, required double y, required double width, required double height}) : super(x: x, y: y, width: width, height: height);

  @override
  String toString() {  
    return 'Character{name: $name, x: $x, y: $y, width: $width, height: $height}';
  }
}