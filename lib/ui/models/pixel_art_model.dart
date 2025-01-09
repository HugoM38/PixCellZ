import 'package:flutter/material.dart';

class PixelArtModel {
  final int width;
  final int height;
  List<List<Color>> pixels;
  
  PixelArtModel({
    required this.width,
    required this.height,
  }) : pixels = List.generate(
         height,
         (y) => List.generate(width, (x) => Colors.white),
       );

  void setPixel(int x, int y, Color color) {
    if (x >= 0 && x < width && y >= 0 && y < height) {
      pixels[y][x] = color;
    }
  }

  Color getPixel(int x, int y) {
    return pixels[y][x];
  }
}