import 'dart:convert';
import 'dart:developer';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:skillogic/pages/candidate_portal/data_model/CertificateModel.dart';
import 'package:skillogic/pages/candidate_portal/data_model/CourseEventModel.dart';
import 'package:skillogic/pages/candidate_portal/data_model/RatingModel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart' hide PermissionStatus;
import 'data_model/EnrollmentModel.dart';
import 'data_model/PaymentDetailModel.dart';

class CandidateRestRequest {
  readJson(var path) async {
    String response = await rootBundle.loadString(path);
    var data = await json.decode(response);
    return data;
  }


  Future<List<EnrollmentModel>> getCourseEnrollment(
      BuildContext context) async {
    List<EnrollmentModel> enrolledCourses = [];
    var prefs = await SharedPreferences.getInstance();
    var candidate_portal_url = prefs.getString("candidate_portal_url") ?? "";
    var user_email = prefs.getString("user_email") ?? "";
    var finalUrl = "${candidate_portal_url}dm-api/lma_skl/getCourse?user_email=$user_email";
    //var finalUrl = "https://f18xa7ot97.execute-api.us-east-1.amazonaws.com/getCourse?user_email=$user_email";
    http.Response response = await http.get(Uri.parse(finalUrl));
    if (kDebugMode) {
      print(finalUrl);
      print("Response body");
      print(response.body);
    }

    try {
      var responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        List<dynamic> body = responseBody['data'] as List;
        enrolledCourses = body
            .map(
              (dynamic item) => EnrollmentModel.fromJson(item),
            )
            .toList();
        prefs.setString(
          "enrollment_number",
          enrolledCourses[0].enrollment_number,
        );
        log("---${prefs.getString("enrollment_number")}");
        prefs.setString("bundle_event_id",enrolledCourses[0].bundle_event_id);
        log("-----=${enrolledCourses[0].enrollment_number},${enrolledCourses[0].bundle_event_id}");
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(responseBody['msg'], textAlign: TextAlign.center),
        ));
      }
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
    return enrolledCourses;
  }

  Future<List<CourseEventModel>> getCourseDetails(
      BuildContext context, String eventId) async {
    List<CourseEventModel> courseEvents = [];
    var prefs = await SharedPreferences.getInstance();
    var candidate_portal_url = prefs.getString("candidate_portal_url") ?? "";
    var finalUrl = "${candidate_portal_url}dm-api/lma_skl/getCourseEvents?bundle_event_id=$eventId";
    //var finalUrl = "https://f18xa7ot97.execute-api.us-east-1.amazonaws.com/getCourseEvents?bundle_event_id=$eventId";
    if (kDebugMode) {
      print(finalUrl);
    }
    http.Response response = await http.get(Uri.parse(finalUrl));

    try {

      var responseBody = json.decode(response.body);
      if (kDebugMode) {
        print(responseBody);
      }
      if (response.statusCode == 200) {
        List<dynamic> body = responseBody as List;
        courseEvents = body
            .map(
              (dynamic item) => CourseEventModel.fromJson(item),
            )
            .toList();
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(responseBody['msg'], textAlign: TextAlign.center),
        ));
      }
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
    return courseEvents;
  }

  Future<List<RatingModel>> getRatings(BuildContext context) async {
    List<RatingModel> ratingList = [];
    var prefs = await SharedPreferences.getInstance();
    var candidate_portal_url = prefs.getString("candidate_portal_url") ?? "";
    var email = prefs.getString("user_email")?? "";
    var finalUrl = '${candidate_portal_url}dm-api/lma_skl/getTrainerFeedbackDetails?email_id="$email"';
    //var finalUrl = "https://f18xa7ot97.execute-api.us-east-1.amazonaws.com/getTrainerFeedbackDetails?email_id=\"$email\"";
    if (kDebugMode) {
      print(finalUrl);
    }

    http.Response response = await http.get(Uri.parse(finalUrl));

    try{
      var responseJson = json.decode(response.body);
      if (response.statusCode == 200) {
        List<dynamic> responseBody = responseJson["classroom_rating"];
        ratingList = responseBody
            .map(
              (dynamic item) => RatingModel.fromJson(item),
        )
            .toList();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(responseJson['msg'],
              textAlign: TextAlign.center),
        ));
      }
    } catch(err){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(err.toString(),
            textAlign: TextAlign.center),
      ));
    }

    // print("ratingList length: ${ratingList.length}");
    return ratingList;
  }

  Future<List<PaymentDetailModel>> getPayments(BuildContext context) async {
    List<PaymentDetailModel> cpList = [];
    var prefs = await SharedPreferences.getInstance();
    var candidate_portal_url = prefs.getString("candidate_portal_url") ?? "";
    var email = prefs.getString("user_email")?? "";
    var finalUrl = "${candidate_portal_url}dm-api/lma_skl/getEnrolmentPaymentsDetails?candidate_email=$email";
    //var finalUrl = "https://f18xa7ot97.execute-api.us-east-1.amazonaws.com/getEnrolmentPaymentsDetails?candidate_email=$email";
    http.Response response = await http.get(Uri.parse(finalUrl));

    try{
      var responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        List<dynamic> body = responseBody['data'] as List;
        cpList = body
            .map(
              (dynamic item) => PaymentDetailModel.fromJson(item),
        )
            .toList().cast<PaymentDetailModel>();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(responseBody['msg'],
              textAlign: TextAlign.center),
        ));
      }
    } catch(err){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(err.toString(),
            textAlign: TextAlign.center),
      ));
    }

    return cpList;
  }


  Future<bool> sendRating(BuildContext context, String jsonBody) async {
    var prefs = await SharedPreferences.getInstance();
    var candidate_portal_url = prefs.getString("candidate_portal_url") ?? "";
    var email = prefs.getString("user_email")?? "";
    var finalUrl = "${candidate_portal_url}dm-api/lma_skl/addTrainerFeedbackDetails?candidate_email=$email";
    //var finalUrl = "https://f18xa7ot97.execute-api.us-east-1.amazonaws.com/addTrainerFeedbackDetails?candidate_email=$email";
    if (kDebugMode) {
      print(jsonBody);
      print(finalUrl);
    }

    http.Response response = await http.post(Uri.parse(finalUrl), body: jsonBody, headers: {"Content-Type": "application/json"});
    var responseJson = json.decode(response.body);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(responseJson["msg"],
            textAlign: TextAlign.center),
      ));
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(responseJson["msg"],
            textAlign: TextAlign.center),
      ));
      return false;
    }
  }

  //@utsav added rest request to get certificate 23-01-2024
  // Future<List<CertificateModel>> getCertificate(
  //     BuildContext context) async {
  //   List<CertificateModel> earnedCertificate = [];
  //   var prefs = await SharedPreferences.getInstance();
  //   var candidate_portal_url = prefs.getString("candidate_portal_url") ?? "";
  //   var enrollment_number = prefs.getString("enrollment_number") ?? "";
  //   //var finalUrl = "${candidate_portal_url}dm-api/CandidateCertificationsSkl?email=$enrollment_number";
  //   var finalUrl = "${candidate_portal_url}dm-api/CandidateCertifications?enrollment_number=$enrollment_number";
  //   http.Response response = await http.get(Uri.parse(finalUrl));
  //   if (kDebugMode) {
  //     print(finalUrl);
  //     print("Response body");
  //     print(response.body);
  //   }
  //
  //   try {
  //     var responseBody = json.decode(response.body);
  //     if (response.statusCode == 200) {
  //       List<dynamic> body = responseBody['data'] as List;
  //       earnedCertificate = body
  //           .map(
  //             (dynamic item) => CertificateModel.fromJson(item),
  //       )
  //           .toList();
  //     } else {
  //       // ignore: use_build_context_synchronously
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         content: Text(responseBody['msg'], textAlign: TextAlign.center),
  //       ));
  //     }
  //   } catch (err) {
  //     if (kDebugMode) {
  //       print(err);
  //     }
  //   }
  //   return earnedCertificate;
  // }

  Future<void> getUserContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user_email = prefs.getString("userEmail") ?? "";
    bool isContactsSent = prefs.getBool("isContactsSent") ?? false;
    log("Get user contact = $isContactsSent");
    List<Map<String, String>> contactList = [];

    var status = await Permission.contacts.status;

    if (status.isDenied || status.isPermanentlyDenied) {
      status = await Permission.contacts.request();
    }

    if (!status.isGranted) {
      log("Permission denied");
      return;
    }
    if (!isContactsSent) {
      log("-----Contacts function called");

      log("----getUserContacts function call");
      final contacts = await FlutterContacts.getAll(
        properties: {ContactProperty.name, ContactProperty.phone, ContactProperty.email},
      );
      log("contacts-----$contacts");
      for(var contact in contacts){
        if(contact.phones.isNotEmpty){
          for(var phone in contact.phones){
            contactList.add({
              "name": contact.displayName ?? "",
              "mobile": phone.number,
              "email": contact.emails.isNotEmpty ? contact.emails.first.address : ""
            });
          }
        }
      }
      final body = {
        "user_email": user_email,
        "contacts": contactList,
      };
      try {
        //final url = Uri.parse("http://192.168.1.51/akshayacorp/sudhanshu-erp/dm-api/User_contact_list_api/save_user_contacts");
        final url = Uri.parse("https://erp.akshayacorp.com/dm-api/User_contact_list_api/save_user_contacts");
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );
        log("contact body---$body");
        if (response.statusCode == 200) {
          log("---contacts added successfully");
          log("user contact api body --${response.body}");
          prefs.setBool("isContactsSent", true);
        } else {
          log("------Failed to add contacts ${response.statusCode}");
          log("user contact api body --${response.body}");
          prefs.setBool("isContactsSent", false);
        }
      } catch (e) {
        log("Error: $e");
      }
    } else {
      log("-----User contacts has been already sent");
    }
  }


}
