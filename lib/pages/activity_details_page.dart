import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/candidate_activities_model.dart';
import 'activity_card.dart';

class ActivityDetailsPage extends StatefulWidget {
  final String enrollmentId;
  final String title;
  const ActivityDetailsPage({required this.enrollmentId, required this.title, Key? key}): super(key: key);

  @override
  State<ActivityDetailsPage> createState() => _ActivityDetailsPageState();
}

class _ActivityDetailsPageState extends State<ActivityDetailsPage> {
  final ActivityDetailsService _activityDetailsService = ActivityDetailsService();
  List<CandidateActivitiesModel> candidateActivities = [];
  bool loaded = false;

  void _getEnrollments() async {
    setState(() {
      loaded = false;
    });
    candidateActivities = await _activityDetailsService.getActivities(
        widget.enrollmentId, context);
    setState(() {
      loaded = true;
    });
  }

  @override
  void initState() {
    _getEnrollments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.black,
          ),
          title: Text(
            widget.title,
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,

        ),
        body: Container(
            height: double.infinity,
            width: double.infinity,
            color: const Color(0xfff6f6f6),
            child: loaded ? (candidateActivities.isEmpty )? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("No any activity found!"),
                MaterialButton(
                    elevation: 1,
                    color: Colors.white,
                    onPressed: _getEnrollments, child: const Text("Refresh")),
              ],
            ) : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  for (CandidateActivitiesModel cActivity in candidateActivities) ActivityCard(candidateActivitiesModel: cActivity, isAssessment: false,)
                ],
              ),
            ) : const Center(child: Text("Loading"),)
        )


    );
  }
}

class ActivityDetailsService {
  late http.Response resp;
  late String authUrl;
  late String finalUrl;
  late String email;
  late String jwtToken;
  late SharedPreferences prefs;
  late BuildContext context;
  String apiPath = 'Candidate/';

  set setEmail(String email) {
    if (kDebugMode) print("Setting email $email");
    this.email = email;
  }

  set setContext(BuildContext context) {
    this.context = context;
  }

  Future<List<CandidateActivitiesModel>> getActivities(enrollmentId, BuildContext context) async {
    List<CandidateActivitiesModel> cadAcList = [];
    prefs = await SharedPreferences.getInstance();
    authUrl = prefs.getString("candidate_portal_url")?? "";
    log("candidate_portal_url-------${authUrl}");
    finalUrl = "${authUrl}dm-api/ActivityLog?candidate_id=${prefs.getString("candidate_id")}&enrollment_id=$enrollmentId&activity_type=1";
    if (kDebugMode) {
      print(finalUrl);
    }

    http.Response response = await http.get(Uri.parse(finalUrl));

    try{
      var responseBody = json.decode(response.body);
      if (kDebugMode) {
        print(responseBody['data']);
      }
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
          content: Text(responseBody['msg'],
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