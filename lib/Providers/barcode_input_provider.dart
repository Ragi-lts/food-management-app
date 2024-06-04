import 'package:flutter/material.dart';
import 'package:food_management/Models/barcode_input_model.dart';

class BarcodeInputProvider extends ChangeNotifier {
  BarcodeInputModel? model;
  bool isRunning = false;
  bool isRead = false;

  void init(BarcodeInputModel m) {
    model = m;
    notifyListeners();
  }

  String getBarcodeNumber() {
    return model != null ? model!.barcodeNumber : '';
  }

  DateTime? getLimit() {
    return model != null ? model!.limitDate : null;
  }

  void setLimitDate(DateTime value) {
    if (model != null) {
      model!.setLimitDate(value);
      notifyListeners();
    }
  }

  void setIsRead(bool value) {
    isRead = value;
  }

  void setIsRunning(bool value) {
    isRunning = value;
    notifyListeners();
  }

  void reset() {
    model = null;
    isRead = false;
    notifyListeners();
  }

  void setBarcodeNumber(String value) {
    if (model != null) {
      model!.setBarcodeInfo(value: value);
      notifyListeners();
    }
  }
}
