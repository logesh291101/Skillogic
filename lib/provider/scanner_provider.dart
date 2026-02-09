import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ScannerProvider with ChangeNotifier {
  String scannerValue = '';

  initiateScannerValue(){
    scannerValue = "";
  }
  set setScannerValue(String scannerValue){
    this.scannerValue = scannerValue;
    notifyListeners();
  }

  String get getScannerValue => scannerValue;

}
