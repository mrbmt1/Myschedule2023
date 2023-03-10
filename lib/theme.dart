import 'package:flutter/material.dart';

enum ThemeType { light, dark }

class ThemeProvider extends ChangeNotifier {
  ThemeData _currentTheme = ThemeData.light();
  ThemeType _currentType = ThemeType.light;

  ThemeData get currentTheme => _currentTheme;
  ThemeType get currentType => _currentType;

  void setTheme(ThemeType type) {
    _currentType = type;
    if (type == ThemeType.light) {
      _currentTheme = ThemeData.light();
    } else {
      _currentTheme = ThemeData.dark();
    }
    notifyListeners();
  }
}
