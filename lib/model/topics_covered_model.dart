// To parse this JSON data, do
//
//     final topicsCoveredModel = topicsCoveredModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

TopicsCoveredModel topicsCoveredModelFromJson(String str) => TopicsCoveredModel.fromJson(json.decode(str));

String topicsCoveredModelToJson(TopicsCoveredModel data) => json.encode(data.toJson());

class TopicsCoveredModel {
  int statuscode;
  String message;
  List<Datum> data;

  TopicsCoveredModel({
    required this.statuscode,
    required this.message,
    required this.data,
  });

  factory TopicsCoveredModel.fromJson(Map<String, dynamic> json) => TopicsCoveredModel(
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
  BundleName bundleName;
  String courseName;
  List<Schedule> schedules;

  Datum({
    required this.bundleName,
    required this.courseName,
    required this.schedules,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    bundleName: bundleNameValues.map[json["bundle_name"]]!,
    courseName: json["course_name"],
    schedules: List<Schedule>.from(json["schedules"].map((x) => Schedule.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "bundle_name": bundleNameValues.reverse[bundleName],
    "course_name": courseName,
    "schedules": List<dynamic>.from(schedules.map((x) => x.toJson())),
  };
}

enum BundleName {
  AI_ENGINEER_AI_ENGG
}

final bundleNameValues = EnumValues({
  "AI Engineer (AIEngg)": BundleName.AI_ENGINEER_AI_ENGG
});

class Schedule {
  dynamic topic;
  DateTime trainerScheduleDate;

  Schedule({
    required this.topic,
    required this.trainerScheduleDate,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
    topic: json["topic"],
    trainerScheduleDate: DateTime.parse(json["trainer_schedule_date"]),
  );

  Map<String, dynamic> toJson() => {
    "topic": topic,
    "trainer_schedule_date": "${trainerScheduleDate.year.toString().padLeft(4, '0')}-${trainerScheduleDate.month.toString().padLeft(2, '0')}-${trainerScheduleDate.day.toString().padLeft(2, '0')}",
  };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
