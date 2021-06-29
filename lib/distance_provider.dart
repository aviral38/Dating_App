import 'package:flutter/material.dart';
class Distance_provider extends ChangeNotifier{
  int distance=100;
  void changeDistance(int dis)
  {
    distance=dis;
    notifyListeners();
  }
}