import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/doubuClearance_Model.dart';
class DoubtClearanceService {

  Future<List<Schedule>> fetchDoubtSession() async{
    var prefs = await SharedPreferences.getInstance();
    var email_id= await prefs.getString("user_email") ?? "";
    var candidate_portal_url = prefs.getString("candidate_portal_url");
    //var finalUrl="http://13.232.222.140/aks-stage/dm-api/DoubtClearance_api/schedule?email_id=$email_id";
    var finalUrl = "${candidate_portal_url}dm-api/DoubtClearance_api/schedule?email_id=$email_id";
    try{
      log("----try block working");
      final response= await http.get(Uri.parse(finalUrl));
      log("----${response.statusCode}");
      if(response.statusCode==200){
        log("response success");
        final data= json.decode(response.body);
         List<dynamic> scheduleList = data['data']['schedule'];
         return scheduleList.map((e) => Schedule.fromJson(e)).toList();
      }
      else{
       log("else--${response.statusCode}");
       // throw Exception('Unable to fetch data: ${response.statusCode}');
       return [];
      }
    }
    catch(e){
      print(e);
      return [];
      //throw Exception('Error -: $err');
    }
  }

}