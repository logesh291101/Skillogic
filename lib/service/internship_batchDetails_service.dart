import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/InternshipBatch_model.dart';
import '../pages/internship_submissionSuccess_screen.dart';
import '../pages/sub_page/internship_submissionFailed.dart';

class InternshipBatchProvider extends ChangeNotifier {
  InternshipBatchModel? _batchDetails;
  bool isSubmitted = false;

  InternshipBatchModel? get batchDetails => _batchDetails;

  Future<void> fetchBatchDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final mailId = prefs.getString("user_email");
    log("mailId----${mailId.toString()}");
    try {
      final url =
          "http://13.232.222.140/akc-erp/dm-api/Internship_api/get_internship/$mailId";
      final response = await http.get(Uri.parse(url));
      log(response.toString());
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        log("------jsonData $jsonData");
        int eligiblity = jsonData["eligibility_status"];
        if (eligiblity == 1) {
          _batchDetails = internshipBatchModelFromJson(response.body);
        } else {
          _batchDetails = InternshipBatchModel(
            statusCode: jsonData["status_code"],
            message: jsonData["message"] ?? '',
            eligibilityStatus: 0,
            data: [],
          );
        }
        notifyListeners();
      } else {
        throw Exception("Failed to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching batch details: $e");
    }
  }

  Future<void> PostInternshipDetails(
      int leadId,
      int bundleId,
      int enrollmentId,
      String filePath,
      String linkedinUrl,
      int eduBackground,
      num ugResult,
      num? pgResult,
      num? workExp,
      num? annualSalary,
      BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final url =
        "http://13.232.222.140/akc-erp/dm-api/Internship_api/add_internship";
    try {
      log("==${leadId.toString()}");
      final request = http.MultipartRequest('POST', Uri.parse(url));
      final navigator = Navigator.of(context);
      request.files
          .add(await http.MultipartFile.fromPath('address_proof', filePath));
      request.fields['lead_id'] = leadId.toString();
      request.fields['enrollment_id'] = enrollmentId.toString();
      request.fields['bundle_event_id'] = bundleId.toString();
      request.fields['linkedin_profile'] = linkedinUrl;
      request.fields['education_background'] = eduBackground.toString();
      request.fields['ug_result'] = ugResult.toString();
      request.fields['pg_result'] = pgResult.toString();
      request.fields['work_experience'] = workExp.toString();
      request.fields['current_annual_salary'] = annualSalary.toString();

      var response = await request.send();
      log("----$response");
      log("statusCode----${response.statusCode}");
      Navigator.pop(context);
      if (response.statusCode == 201) {
        prefs.setBool("isSubmitted", true);
        navigator.pushReplacement(MaterialPageRoute(
            builder: (context) => InternshipSubmissionSuccess()));
      } else {
        prefs.setBool("isSubmitted", false);
        navigator.pushReplacement(MaterialPageRoute(
            builder: (context) => InternshipSubmissionFailed()));
      }
    } catch (e) {
      throw Exception("Error fetching post details: $e");
    }
  }
}
