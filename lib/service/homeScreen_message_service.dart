import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class HomeScreenMessageService extends ChangeNotifier{
  bool _isLoading = false;
  String? _message;
  bool get isLoading  => _isLoading;
  String? get message => _message;
  Future<void> getMessage() async{
    _isLoading = true;
    notifyListeners();
    try{
      //final url = "http://13.232.222.140/aks-stage/nocCertificateApi/getMessage";
      final url = "https://erp.akshayacorp.com/nocCertificateApi/getMessage";
      final res = await http.get(Uri.parse(url));
      if(res.statusCode == 200){
        final data = json.decode(res.body);
        _message = data['display_message']?.toString();
      }
      else{
        throw Exception("Falied to fetch data: ${res.statusCode}");
      }
    }

        catch(e){
          _message = null;
        }
    finally{
     _isLoading = false;
     notifyListeners();
    }
  }

}