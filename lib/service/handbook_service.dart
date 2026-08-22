// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';
//
// class HandbookProvider extends ChangeNotifier{
//   String? handbookLink;
//   String? handbookName;
//   Future <void> fetchHandbook() async{
//     try{
//       //final url ="http://13.232.222.140/akc-erp/dm-api/Lma/getLearnersHandbook";
//       final url = "https://erp.akshayacorp.com/dm-api/Lma/getLearnersHandbook";
//       final response = await http.get(Uri.parse(url));
//       if(response.statusCode == 200){
//         final data = json.decode(response.body);
//          handbookLink = data['data']['learners_handbook_link'];
//          handbookName = data['data']['learners_handbook_name'];
//          notifyListeners();
//          log("link---$handbookLink");
//       }
//       else{
//         throw Exception("Unable to fetch date: ${response.statusCode}");
//       }
//     }
//     catch(e){
//       throw Exception("Error: $e");
//     }
//   }
// }

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/handbook_model.dart';

class HandbookProvider extends ChangeNotifier {
  List<Datum> _handbooks = [];
  bool _isLoading = false;
  List<Datum> get handbooks => _handbooks;
  bool get isloading => _isLoading;

  Future<void> fetchHandbook() async {
    _isLoading = true;
    notifyListeners();
    try {
      var prefs = await SharedPreferences.getInstance();
      var candidate_portal_url = prefs.getString("candidate_portal_url") ?? "";
      var bundle_event_id = prefs.getString("bundle_event_id") ?? "";
      log("bundle_event_id----$bundle_event_id");
      final url = "${candidate_portal_url}dm-api/Lma/getLearnersHandbook?bundle_id=$bundle_event_id";
      //final url = "http://13.232.222.140/aks-stage//dm-api/Lma/getLearnersHandbook?bundle_event_id=3075";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        log("RESPONSE: ${response.body}");
       final model = handbookModelFromJson(response.body);
       _handbooks = model.data;
       log(_handbooks.toString());
      } else {
        log("Server error: ${response.statusCode}");
        _handbooks = [];
      }
    } catch (e) {
      log("Handbook error: $e");
      _handbooks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

