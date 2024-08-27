

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

OverlayEntry createOverlayEntry(BuildContext context) {
    return OverlayEntry(
      builder: (context) => Material(
        type: MaterialType.transparency,
        child: Container(
          height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.grey.withOpacity(0.5),
          child:const Center(
            child:SizedBox(
          width: 200,
          height: 200,
          child: RiveAnimation.asset(
            'loading.riv', // Replace with your Rive animation asset path
            fit: BoxFit.contain,
          ),
                ),
          ),
        ),
      ),
    );
  }


