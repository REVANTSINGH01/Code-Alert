import 'package:flutter/material.dart';
enum ThemeOption{light,dark}
class ThemeProvider extends ChangeNotifier{
  Color bgColor=Colors.white;
  ThemeOption selectedTheme=ThemeOption.light;
  void changeTheme(ThemeOption option){
    selectedTheme=option;
    switch(option){
      case ThemeOption.light:
        bgColor=Colors.white;
        break;
      case ThemeOption.dark:
        bgColor=const Color(0xFF121212);
        break;
    }
  notifyListeners();
  }
}