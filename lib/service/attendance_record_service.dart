import 'dart:convert';

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
    var mailId= prefs.getString("user_email");
    _isLoading = true;
    notifyListeners();
    try {
      final url="https://erp.akshayacorp.com/attendance_candidate_api/get_attendance_details?candidate_mail=$mailId&brandId=1";
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
          throw Exception("Error parsing response: $parseError");
        }
      }
      else{
        _attendanceData = null;
        notifyListeners();
        throw Exception("Unable to fetch data: ${res.statusCode}");
      }
    }
    catch (e) {
      print("Error in getAttendanceDetails: $e");
      _attendanceData = null;
      notifyListeners();
      rethrow;
    }
    finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
