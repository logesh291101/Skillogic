// To parse this JSON data, do
//
//     final attendanceRecordModel = attendanceRecordModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

AttendanceRecordModel attendanceRecordModelFromJson(String str) => AttendanceRecordModel.fromJson(json.decode(str));

String attendanceRecordModelToJson(AttendanceRecordModel data) => json.encode(data.toJson());

class AttendanceRecordModel {
  int statuscode;
  String message;
  List<Datum> data;

  AttendanceRecordModel({
    required this.statuscode,
    required this.message,
    required this.data,
  });

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) => AttendanceRecordModel(
    statuscode: json["statuscode"],
    message: json["message"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "statuscode": statuscode,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  String courseName;
  List<Schedule> schedules;

  Datum({
    required this.courseName,
    required this.schedules,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    courseName: json["course_name"],
    schedules: List<Schedule>.from(json["schedules"].map((x) => Schedule.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "course_name": courseName,
    "schedules": List<dynamic>.from(schedules.map((x) => x.toJson())),
  };
}

class Schedule {
  dynamic topic;
  DateTime trainerScheduleDate;
  String attendanceStatus;
  dynamic scanDate;

  Schedule({
    required this.topic,
    required this.trainerScheduleDate,
    required this.attendanceStatus,
    required this.scanDate,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
    topic: json["topic"],
    trainerScheduleDate: DateTime.parse(json["trainer_schedule_date"]),
    attendanceStatus: json["attendance_status"],
    scanDate: json["scan_date"],
  );

  Map<String, dynamic> toJson() => {
    "topic": topic,
    "trainer_schedule_date": "${trainerScheduleDate.year.toString().padLeft(4, '0')}-${trainerScheduleDate.month.toString().padLeft(2, '0')}-${trainerScheduleDate.day.toString().padLeft(2, '0')}",
    "attendance_status": attendanceStatus,
    "scan_date": scanDate,
  };
}
