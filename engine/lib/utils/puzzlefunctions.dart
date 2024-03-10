import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class ImageSlicer {
  static List<img.Image> sliceImage(img.Image image, int rows, int columns) {
    final int tileWidth = image.width ~/ columns;
    final int tileHeight = image.height ~/ rows;
    final List<img.Image> tiles = [];

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < columns; x++) {
        final img.Image tile = img.copyCrop(
          image,
          x * tileWidth,
          y * tileHeight,
          tileWidth,
          tileHeight,
        );
        tiles.add(tile);
      }
    }

    return tiles;
  }
}



