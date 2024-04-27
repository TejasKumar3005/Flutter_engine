import 'package:flutter/material.dart';
import 'package:http/http.dart';
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
        body: Column(
          children: [
            const Center(
                child: Image(
                    image: NetworkImage(
                        "https://images.svar.in/Images/cat.png")) //Text
                ),
          ],
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
// class ResponsiveWidgetTest extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // return Scaffold(
//     //   appBar: AppBar(
//     //     title: Text('Responsive Widget Test'),
//     //   ),
//     //   body: Center(
//     //     child:
//     return Container(
//           width: getHorizontalSize(200.0),
//           height: getVerticalSize(0100.0),
//           margin: getMargin(all: 16.0),
//           padding: getPadding(all: 8.0),
//           color: Color.fromARGB(255, 115, 195, 49),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'Responsive Text',
//                 style: TextStyle(fontSize: getFontSize(20.0)),
//               ),
//               SizedBox(height: 16.0),
//               Container(
//                 width: getSize(50.0),
//                 height: getSize(500.0),
//                 color: Colors.red,
//               ),
//             ],
//           ),
//         );
//       // ),
//     // );
//   }
// }
// //
// //
// // void main() {
// //   runApp(MaterialApp(
// //     home: ResponsiveWidgetTest(),
// //   ));
// // }

class Aditya extends StatefulWidget {
  final String t;
  const Aditya({Key? key,required this.t}) : super(key: key);
  @override
  AdityaState createState() => AdityaState();
}

class AdityaState extends State<Aditya> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
