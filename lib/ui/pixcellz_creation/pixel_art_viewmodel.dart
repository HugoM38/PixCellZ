import 'package:flutter/material.dart';
import 'dart:convert';

class PixelArtViewModel extends ChangeNotifier {
  final List<List<Color>> pixels;
  Color _selectedColor = Colors.black;
  
  final List<Color> palette = [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];

  PixelArtViewModel()
      : pixels = List.generate(
          32,
          (y) => List.generate(32, (x) => Colors.white),
        );

  Color get selectedColor => _selectedColor;

  void addColor(Color color) {
    palette.add(color);
    notifyListeners();
  }

  void updateColor(int index, Color newColor) {
    if (index >= 0 && index < palette.length) {
      palette[index] = newColor;
      if (_selectedColor == palette[index]) {
        _selectedColor = newColor;
      }
      notifyListeners();
    }
  }

  void removeColor(int index) {
    if (index >= 0 && index < palette.length) {
      palette.removeAt(index);
      notifyListeners();
    }
  }

  void setPixel(int x, int y) {
    if (x >= 0 && x < 32 && y >= 0 && y < 32) {
      pixels[y][x] = _selectedColor;
      notifyListeners();
    }
  }

  void setSelectedColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  Map<String, dynamic> getPixelArtData(String userId) {
    List<List<Map<String, int>>> rgbData = pixels.map((row) {
      return row.map((color) {
        return {
          'r': color.red,
          'g': color.green,
          'b': color.blue,
        };
      }).toList();
    }).toList();

    return {
      'userId': userId,
      'creationDate': DateTime.now().millisecondsSinceEpoch,
      'data': rgbData,
    };
  }

  String getPixelArtJsonString(String userId) {
    return jsonEncode(getPixelArtData(userId));
  }
}