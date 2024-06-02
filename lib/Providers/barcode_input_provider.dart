import 'package:flutter/material.dart';
import 'package:food_management/Models/barcode_input_model.dart';

class BarcodeInputProvider extends ChangeNotifier {
  BarcodeInputModel model = BarcodeInputModel();

  String getBarcodeNumber() {
    return model.barcodeNumber;
  }

  bool getIsRunning() {
    return model.isRunning;
  }

  bool getIsRead() {
    return model.isRead;
  }

  DateTime? getLimit() {
    return model.limit;
  }

  void setLimitDate(DateTime value) {
    model.limit = value;
    notifyListeners();
  }

  void setIsRunning(bool value) {
    model.isRunning = value;
    notifyListeners();
  }

  void reset() {
    model.init();
    notifyListeners();
  }

  void setBarcodeNumber(String value) {
    model.setBarcodeNumber(value);
    notifyListeners();
  }
}
