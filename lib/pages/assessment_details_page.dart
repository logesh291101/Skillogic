import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../helper/user_details.dart';
import '../model/candidate_activities_model.dart';
import '../model/user_model.dart';
import '../widgets/CustomWidget.dart';
import 'activity_card.dart';

class AssessmentDetailsPage extends StatefulWidget {
  final String enrollmentId;
  final String title;

  const AssessmentDetailsPage({required this.enrollmentId, required this.title, Key? key}) : super(key: key);

  @override
  State<AssessmentDetailsPage> createState() => _AssessmentDetailsPageState();
}

class _AssessmentDetailsPageState extends State<AssessmentDetailsPage> {
  final AssessmentDetailsService _AssessmentDetailsService = AssessmentDetailsService();
  List<CandidateActivitiesModel> candidateActivities = [];
  bool loaded = false;
  String errorText = "No any activity found!";

  void _getEnrollments() async {
    setState(() {
      loaded = false;
    });
    candidateActivities = await _AssessmentDetailsService.getActivities(
        widget.enrollmentId, context);
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
            child: loaded ? (candidateActivities.isEmpty )? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(errorText),
                MaterialButton(
                    elevation: 1,
                    color: Colors.white,
                    onPressed: _getEnrollments, child: const Text("Refresh")),
              ],
            ) : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 0, 0), // Adjust padding values as needed
                    child: Text(
                      "Assessment Details",
                      style: TextStyle( fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                  ),
                  for (CandidateActivitiesModel cActivity in candidateActivities) ActivityCard(candidateActivitiesModel: cActivity, isAssessment: true)
                ],
              ),
            ) : const Center(child: Text("Loading"),)
        )
    );
  }
}


class AssessmentDetailsService {
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

  Future<List<CandidateActivitiesModel>> getActivities(enrollmentId, BuildContext context) async {
    List<CandidateActivitiesModel> cadAcList = [];
    if (kDebugMode)  print("Resetting password");
    prefs = await SharedPreferences.getInstance();
    authUrl = prefs.getString("candidate_portal_url")?? "";
    finalUrl = "${authUrl}dm-api/ActivityLog?candidate_id=${prefs.getString("candidate_id")}&enrollment_id=$enrollmentId&activity_type=1";
    if (kDebugMode) {
      print(finalUrl);
    }

    http.Response response = await http.get(Uri.parse(finalUrl));

    try{
      var responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        List<dynamic> body = responseBody['data'] as List;
        cadAcList = body
            .map(
              (dynamic item) => CandidateActivitiesModel.fromJson(item),
        )
            .toList().cast<CandidateActivitiesModel>();
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(responseBody['message'],
              textAlign: TextAlign.center),
        ));
      }
    } catch(err){
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(err.toString(),
            textAlign: TextAlign.center),
      ));
    }

    return cadAcList;
  }
}