import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/project_statusCall_model.dart';


class ProjectStatusService {

  Future <List<StatusCall>> fetchStatusCall() async{
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var candidate_portal_url = prefs.getString("candidate_portal_url");
      //var finalUrl="http://13.232.222.140/akc-erp/dm-api/Project_status_call_api/schedule";
      var finalUrl= "${candidate_portal_url}dm-api/Project_status_call_api/schedule";
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
        log('Unable to fetch data: ${response.statusCode}');
        return [];
      }
    }
    catch(err){
      log('Error -: $err');
      return [];
    }
  }
}