import 'package:flutter/material.dart';

class Age_provider extends ChangeNotifier{
  int minage=18;
  int maxage=30;
  void changemin(int min)
  {
    minage=min;
    notifyListeners();
  }
  void changemax(int max)
  {
    maxage=max;
    notifyListeners();
  }
}