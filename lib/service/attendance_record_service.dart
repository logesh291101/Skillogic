import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/attendance_record_model.dart';

class AttendanceProvider extends ChangeNotifier {

  AttendanceRecordModel? _attendanceData;
  bool _isLoading = false;

  AttendanceRecordModel? get attendanceData => _attendanceData;
  bool get isLoading => _isLoading;

  Future<void> getAttendanceDetails() async {
    final prefs = await SharedPreferences.getInstance();
    var enrollment_number= prefs.getString("enrollment_number");
    var candidate_portal_url = prefs.getString("candidate_portal_url");
    _isLoading = true;
    notifyListeners();
    try {
      log("candidate_portal_url---${candidate_portal_url}");
      final url="${candidate_portal_url}attendance_candidate_api/get_attendance_details?enrollment_number=$enrollment_number";
      final res = await http.get(Uri.parse(url));
      if(res.statusCode==200){
        try {
          _attendanceData = attendanceRecordModelFromJson(res.body);
          notifyListeners();
        } catch (parseError) {
          print("Error parsing JSON: $parseError");
          print("Response body: ${res.body}");
          _attendanceData = null;
          notifyListeners();
          log("Error parsing response: $parseError");
        }
      }
      else{
        _attendanceData = null;
        notifyListeners();
        log("Unable to fetch data: ${res.statusCode}");
      }
    }
    catch (e) {
      print("Error in getAttendanceDetails: $e");
      _attendanceData = null;
      notifyListeners();
      //rethrow;
    }
    finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
