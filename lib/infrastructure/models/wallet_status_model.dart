import 'package:flutter/cupertino.dart';

class WalletStatusModel extends ChangeNotifier {
  int cuntStep = 1;
  String? addressOfUserB;
  bool isLoading = false;

  updateCountStep(int value, {bool isNotify = true}) {
    cuntStep = value;
    if (isNotify) notifyListeners();
  }

  updateAddress(String value, {bool isNotify = true}) {
    addressOfUserB = value;
    if (isNotify) notifyListeners();
  }

  updateProgress(bool value) {
    isLoading = value;
  }
}
