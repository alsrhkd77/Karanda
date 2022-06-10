import 'package:flutter/material.dart';

class ShutdownSchedulerNotifier with ChangeNotifier{
  bool running = false;

  void startSchedule(){
    running = true;
    notifyListeners();
  }

  void cancelSchedule(){
    running = false;
    notifyListeners();
  }
}