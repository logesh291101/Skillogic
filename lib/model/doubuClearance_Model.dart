// To parse this JSON data, do
//
//     final doubtSessionModel = doubtSessionModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

DoubtSessionModel doubtSessionModelFromJson(String str) => DoubtSessionModel.fromJson(json.decode(str));

String doubtSessionModelToJson(DoubtSessionModel data) => json.encode(data.toJson());

class DoubtSessionModel {
  int statuscode;
  String message;
  Data data;

  DoubtSessionModel({
    required this.statuscode,
    required this.message,
    required this.data,
  });

  factory DoubtSessionModel.fromJson(Map<String, dynamic> json) => DoubtSessionModel(
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
  List<Schedule> schedule;

  Data({
    required this.schedule,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    schedule: List<Schedule>.from(json["schedule"].map((x) => Schedule.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "schedule": List<dynamic>.from(schedule.map((x) => x.toJson())),
  };
}

class Schedule {
  String day;
  String time;
  dynamic meetingLink;
  String status;
  String trainerName;
  String date;
  String course;

  Schedule({
    required this.day,
    required this.time,
    required this.meetingLink,
    required this.status,
    required this.trainerName,
    required this.date,
    required this.course
  });

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
      day: json["day"],
      time: json["time"],
      meetingLink: json["meeting_link"],
      status: json["status"],
      trainerName: json["trainer_name"],
      date: json["date"],
      course: json["course"]
  );

  Map<String, dynamic> toJson() => {
    "day": day,
    "time": time,
    "meeting_link": meetingLink,
    "status": status,
    "trainer_name": trainerName,
    "date": date,
    "course" : course
  };
}
