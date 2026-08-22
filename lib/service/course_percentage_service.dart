import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/course_percentage_model.dart';

class CoursePercentageService extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<CoursePercentageModel> _courseData = [];
  List<CoursePercentageModel> get courseData => _courseData;

  Future<void> getCoursePercentage() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      var mailId= prefs.getString("user_email");
      var candidate_portal_url = prefs.getString("candidate_portal_url");
      final url = "${candidate_portal_url}bundle_details_api/getbundledetailsbyemail?email=$mailId&brandId=1";

      log(">>>----------tryyyyy");
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        _courseData = coursePercentageModelFromJson(res.body);
        _isLoading = false;
        notifyListeners();
        log("-------${res.body}");
        log(">>>----------$_courseData");
      } else {
        log("Failed to fetch data: ${res.statusCode}");
      }
    } catch (e) {
      log("Error: $e");
    }
    finally{
      _isLoading =false;
      notifyListeners();
    }
  }
  void reset() {
    _courseData = [];
    _isLoading = false;
    notifyListeners();
  }
}
