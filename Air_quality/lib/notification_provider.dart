import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  int _notificationCount = 0;

  int get notificationCount => _notificationCount;

  void incrementNotificationCount() {
    _notificationCount++;
    notifyListeners();
  }

  void decrementNotificationCount() {
    if (_notificationCount > 0) {
      _notificationCount--;
      notifyListeners();
    }
  }
}
