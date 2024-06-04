import 'package:flutter/material.dart';

import '../Models/barcode_input_model.dart';

class BarcodeInputLogProvider extends ChangeNotifier {
  List<BarcodeInputModel> log = [];

  List<BarcodeInputModel> getLog() {
    return log;
  }

  void pushLog(BarcodeInputModel model) {
    log.add(model);
    notifyListeners();
  }

  void popLog(int index) {
    log.removeAt(index);
    notifyListeners();
  }

  void clear() {
    log.clear();
    notifyListeners();
  }
}
