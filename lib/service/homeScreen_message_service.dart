import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreenMessageService extends ChangeNotifier{
  bool _isLoading = false;
  String? _message;
  bool get isLoading  => _isLoading;
  String? get message => _message;
  Future<void> getMessage() async{
    _isLoading = true;
    notifyListeners();
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var candidate_portal_url = prefs.getString("candidate_portal_url");
      //final url = "http://13.232.222.140/aks-stage/nocCertificateApi/getMessage";
      final url = "${candidate_portal_url}nocCertificateApi/getMessage";
      final res = await http.get(Uri.parse(url));
      if(res.statusCode == 200){
        final data = json.decode(res.body);
        _message = data['display_message']?.toString();
      }
      else{
        log("Falied to fetch data: ${res.statusCode}");
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