// To parse this JSON data, do
//
//     final projectStatusModel = projectStatusModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

ProjectStatusModel projectStatusModelFromJson(String str) => ProjectStatusModel.fromJson(json.decode(str));

String projectStatusModelToJson(ProjectStatusModel data) => json.encode(data.toJson());

class ProjectStatusModel {
  int statuscode;
  String message;
  Data data;

  ProjectStatusModel({
    required this.statuscode,
    required this.message,
    required this.data,
  });

  factory ProjectStatusModel.fromJson(Map<String, dynamic> json) => ProjectStatusModel(
    statuscode: json["statuscode"],
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "statuscode": statuscode,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  List<StatusCall> statusCall;

  Data({
    required this.statusCall,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    statusCall: List<StatusCall>.from(json["statusCall"].map((x) => StatusCall.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "statusCall": List<dynamic>.from(statusCall.map((x) => x.toJson())),
  };
}

class StatusCall {
  String day;
  String time;
  String trainerName;
  String date;
  String addCourse;
  String meetingLink;

  StatusCall({
    required this.day,
    required this.time,
    required this.trainerName,
    required this.date,
    required this.addCourse,
    required this.meetingLink,
  });

  factory StatusCall.fromJson(Map<String, dynamic> json) => StatusCall(
    day: json["day"],
    time: json["time"],
    trainerName: json["trainer_name"],
    date: json["date"],
    addCourse: json["add_course"],
    meetingLink: json["meeting_link"],
  );

  Map<String, dynamic> toJson() => {
    "day": day,
    "time": time,
    "trainer_name": trainerName,
    "date": date,
    "add_course": addCourse,
    "meeting_link": meetingLink,
  };
}
