// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/user_details.dart';
import '../model/candidate_enrollment_model.dart';
import '../model/user_model.dart';
import '../widgets/CustomWidget.dart';
import 'enrollment_card.dart';

class EnrollmentPage extends StatefulWidget {
  final String pageTitle;

  const EnrollmentPage({super.key, required this.pageTitle});

  @override
  State<EnrollmentPage> createState() => _EnrollmentPageState();
}

class _EnrollmentPageState extends State<EnrollmentPage> {
  EnrolmentService enrolmentService = EnrolmentService();
  List<CandidateEnrollmentModel> candidateEnrollments = [];
  bool loaded = false;

  void _getEnrollments() async {
    setState(() {
      loaded = false;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    candidateEnrollments = await enrolmentService.getEnrollments(
        prefs.getString("candidate_id") ?? "", context);
    setState(() {
      loaded = true;
    });
  }

  var userDetails = UserDetails();
  UserModel? userModel;

  _getUserDetail() async {
    userModel = await userDetails.getDetail();
    setState(() {});
  }

  @override
  void initState() {
    _getEnrollments();
    _getUserDetail();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomWidget.getSkillogicAppBar(context, userModel, 1),
        body: Container(
            height: double.infinity,
            width: double.infinity,
            color: const Color(0xfff6f6f6),
            child: loaded
                ? (candidateEnrollments.isEmpty)
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("No any enrollment found!"),
                          MaterialButton(
                              elevation: 1,
                              color: Colors.white,
                              onPressed: _getEnrollments,
                              child: const Text("Refresh")),
                        ],
                      )
                    : SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(16, 16, 0, 0),
                              // Adjust padding values as needed
                              child: Text(
                                "Your Activity",
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w600),
                              ),
                            ),
                            for (CandidateEnrollmentModel ceModel
                                in candidateEnrollments)
                              EnrollmentCard(
                                  candidateEnrollmentModel: ceModel,
                                  assessment:
                                      (widget.pageTitle == "My Assessment")
                                          ? 1
                                          : 0)
                          ],
                        ),
                      )
                : const Center(
                    child: Text("Loading"),
                  )));
  }
}

class EnrolmentService {
  late http.Response resp;
  late String authUrl;
  late String finalUrl;
  late String email;
  late String jwtToken;
  late SharedPreferences prefs;
  late BuildContext context;
  String apiPath = 'Candidate/';

  set setEmail(String email) {
    // print("Setting email " + email);
    this.email = email;
  }

  set setContext(BuildContext context) {
    this.context = context;
  }

  Future<List<CandidateEnrollmentModel>> getEnrollments(
      candidateId, BuildContext context) async {
    List<CandidateEnrollmentModel> candidateEnrollmentList = [];
    // print("Resetting password");
    prefs = await SharedPreferences.getInstance();
    authUrl = prefs.getString("candidate_portal_url") ?? "";
    log("candidate_portal_url----${authUrl}");
    finalUrl = "${authUrl}dm-api/Enrollments?CandidateID=$candidateId";
    if (kDebugMode) {
      print(finalUrl);
    }
    http.Response response = await http.get(Uri.parse(finalUrl));

    try {
      log("candidate_portal_url----${authUrl}");
      var responseBody = json.decode(response.body);
      if (kDebugMode) {
        print(responseBody['data']);
      }
      if (response.statusCode == 200) {
        log("candidate_portal_url----${authUrl}");
        List<dynamic> body = responseBody['data'] as List;
        candidateEnrollmentList = body
            .map(
              (dynamic item) => CandidateEnrollmentModel.fromJson(item),
            )
            .toList()
            .cast<CandidateEnrollmentModel>();
      } else {

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(responseBody['message'], textAlign: TextAlign.center),
        ));
      }
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(err.toString(), textAlign: TextAlign.center),
      ));
    }

    return candidateEnrollmentList;
  }
}
