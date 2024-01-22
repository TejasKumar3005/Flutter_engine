import 'package:flutter/material.dart';
import 'utils/dimensions.dart';

class ResponsiveWidgetTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text('Responsive Widget Test'),
    //   ),
    //   body: Center(
    //     child: 
    return Container(
          width: getHorizontalSize(200.0),
          height: getVerticalSize(0100.0),
          margin: getMargin(all: 16.0),
          padding: getPadding(all: 8.0),
          color: Color.fromARGB(255, 115, 195, 49),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Responsive Text',
                style: TextStyle(fontSize: getFontSize(20.0)),
              ),
              SizedBox(height: 16.0),
              Container(
                width: getSize(50.0),
                height: getSize(500.0),
                color: Colors.red,
              ),
            ],
          ),
        );
      // ),
    // );
  }
}
//
// void main() {
//   runApp(MaterialApp(
//     home: ResponsiveWidgetTest(),
//   ));
// }
