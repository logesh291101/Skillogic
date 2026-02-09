import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/project_statusCall_model.dart';


class ProjectStatusService {
  late SharedPreferences prefs;
  //var finalUrl="http://13.232.222.140/akc-erp/dm-api/Project_status_call_api/schedule";
  var finalUrl= "https://erp.akshayacorp.com/dm-api/Project_status_call_api/schedule";
  Future <List<StatusCall>> fetchStatusCall() async{
    try{
      log("----try block working");
      final response= await http.get(Uri.parse(finalUrl));
      log("----${response.statusCode}");
      if(response.statusCode==200){
        log("response success");
        final data= json.decode(response.body);
        List<dynamic> scheduleList=data['data']['statusCall'];
        return scheduleList.map((e) => StatusCall.fromJson(e)).toList();
      }
      else{
        throw Exception('Unable to fetch data: ${response.statusCode}');
      }
    }
    catch(err){
      throw Exception('Error -: $err');
    }
  }
}