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
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('My demo app'),
          ), //AppBar
          body: const Center(
            child: Text(
              'Hello Geeks',
              style: TextStyle(fontSize: 24),
            ), //Text
          ), // center
        ), //Scaffold
        debugShowCheckedModeBanner: false, //Removing Debug Banner
      );
      // ),
    // );
  }
}
//
//
// void main() {
//   runApp(MaterialApp(
//     home: ResponsiveWidgetTest(),
//   ));
// }
