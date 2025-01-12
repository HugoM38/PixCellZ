import 'package:flutter/material.dart';

class PixelArtViewModelModification extends ChangeNotifier {
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

  PixelArtViewModelModification()
      : pixels = List.generate(
          32,
          (y) => List.generate(32, (x) => Colors.white),
        );

  PixelArtViewModelModification.fromData(List<List<Map<String, dynamic>>> pixelData)
      : pixels = pixelData.map((row) {
          return row.map((pixel) {
            return Color.fromRGBO(
              pixel['r'] ?? 0,
              pixel['g'] ?? 0,
              pixel['b'] ?? 0,
              1.0,
            );
          }).toList();
        }).toList();

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
    if (x >= 0 && x < pixels[0].length && y >= 0 && y < pixels.length) {
      pixels[y][x] = _selectedColor;
      notifyListeners();
    }
  }

  void setSelectedColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  Map<String, dynamic> getPixelArtData() {
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
      'data': rgbData,
    };
  }

  Map<String, dynamic> getPixelArtJsonString() {
    return getPixelArtData();
  }
}
