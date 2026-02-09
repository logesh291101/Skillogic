// // To parse this JSON data, do
// //
// //     final coursePercentageModel = coursePercentageModelFromJson(jsonString);
//
// import 'package:meta/meta.dart';
// import 'dart:convert';
//
// List<CoursePercentageModel> coursePercentageModelFromJson(String str) => List<CoursePercentageModel>.from(json.decode(str).map((x) => CoursePercentageModel.fromJson(x)));
//
// String coursePercentageModelToJson(List<CoursePercentageModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
//
// class CoursePercentageModel {
//   String bundleEventName;
//   String bundleName;
//   String matchedLocation;
//   int completionPercentage;
//   List<Course> courses;
//
//   CoursePercentageModel({
//     required this.bundleEventName,
//     required this.bundleName,
//     required this.matchedLocation,
//     required this.completionPercentage,
//     required this.courses,
//   });
//
//   factory CoursePercentageModel.fromJson(Map<String, dynamic> json) => CoursePercentageModel(
//     bundleEventName: json["bundle_event_name"],
//     bundleName: json["bundle_name"],
//     matchedLocation: json["matched_location"],
//     completionPercentage: json["completion_percentage"],
//     courses: List<Course>.from(json["courses"].map((x) => Course.fromJson(x))),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "bundle_event_name": bundleEventName,
//     "bundle_name": bundleName,
//     "matched_location": matchedLocation,
//     "completion_percentage": completionPercentage,
//     "courses": List<dynamic>.from(courses.map((x) => x.toJson())),
//   };
// }
//
// class Course {
//   String courseName;
//   int status;
//
//   Course({
//     required this.courseName,
//     required this.status,
//   });
//
//   factory Course.fromJson(Map<String, dynamic> json) => Course(
//     courseName: json["course_name"],
//     status: json["status"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "course_name": courseName,
//     "status": status,
//   };
// }


// To parse this JSON data, do
//
//     final coursePercentageModel = coursePercentageModelFromJson(jsonString);
import 'package:meta/meta.dart';
import 'dart:convert';

List<CoursePercentageModel> coursePercentageModelFromJson(String str) => List<CoursePercentageModel>.from(json.decode(str).map((x) => CoursePercentageModel.fromJson(x)));

String coursePercentageModelToJson(List<CoursePercentageModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CoursePercentageModel {
  String bundleEventName;
  String bundleName;
  String matchedLocation;
  int completionPercentage;
  List<Course> courses;

  CoursePercentageModel({
    required this.bundleEventName,
    required this.bundleName,
    required this.matchedLocation,
    required this.completionPercentage,
    required this.courses,
  });

  factory CoursePercentageModel.fromJson(Map<String, dynamic> json) => CoursePercentageModel(
    bundleEventName: json["bundle_event_name"],
    bundleName: json["bundle_name"],
    matchedLocation: json["matched_location"],
    completionPercentage: json["completion_percentage"],
    courses: List<Course>.from(json["courses"].map((x) => Course.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "bundle_event_name": bundleEventName,
    "bundle_name": bundleName,
    "matched_location": matchedLocation,
    "completion_percentage": completionPercentage,
    "courses": List<dynamic>.from(courses.map((x) => x.toJson())),
  };
}

class Course {
  String courseName;
  int status;

  Course({
    required this.courseName,
    required this.status,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    courseName: json["course_name"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "course_name": courseName,
    "status": status,
  };
}
