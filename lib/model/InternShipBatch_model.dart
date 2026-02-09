// // To parse this JSON data, do
// //
// //     final internshipBatchModel = internshipBatchModelFromJson(jsonString);
//
// import 'package:meta/meta.dart';
// import 'dart:convert';
//
// InternshipBatchModel internshipBatchModelFromJson(String str) => InternshipBatchModel.fromJson(json.decode(str));
//
// String internshipBatchModelToJson(InternshipBatchModel data) => json.encode(data.toJson());
//
// class InternshipBatchModel {
//   int statusCode;
//   String message;
//   int eligibilityStatus;
//   List<Datum> data;
//
//   InternshipBatchModel({
//     required this.statusCode,
//     required this.message,
//     required this.eligibilityStatus,
//     required this.data,
//   });
//
//   factory InternshipBatchModel.fromJson(Map<String, dynamic> json) => InternshipBatchModel(
//     statusCode: json["status_code"],
//     message: json["message"],
//     eligibilityStatus: json["eligibility_status"],
//     data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "status_code": statusCode,
//     "message": message,
//     "eligibility_status": eligibilityStatus,
//     "data": List<dynamic>.from(data.map((x) => x.toJson())),
//   };
// }
//
// class Datum {
//   String name;
//   String email;
//   dynamic isoCode;
//   String phoneNumber;
//   String bundleEventId;
//   String enrollmentId;
//   String batchDetails;
//
//   Datum({
//     required this.name,
//     required this.email,
//     required this.isoCode,
//     required this.phoneNumber,
//     required this.bundleEventId,
//     required this.enrollmentId,
//     required this.batchDetails,
//   });
//
//   factory Datum.fromJson(Map<String, dynamic> json) => Datum(
//     name: json["name"],
//     email: json["email"],
//     isoCode: json["iso_code"],
//     phoneNumber: json["phone_number"],
//     bundleEventId: json["bundle_event_id"],
//     enrollmentId: json["enrollment_id"],
//     batchDetails: json["batch_details"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "name": name,
//     "email": email,
//     "iso_code": isoCode,
//     "phone_number": phoneNumber,
//     "bundle_event_id": bundleEventId,
//     "enrollment_id": enrollmentId,
//     "batch_details": batchDetails,
//   };
// }

// To parse this JSON data, do
//
//     final internshipBatchModel = internshipBatchModelFromJson(jsonString);

// To parse this JSON data, do
//
//     final internshipBatchModel = internshipBatchModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

InternshipBatchModel internshipBatchModelFromJson(String str) => InternshipBatchModel.fromJson(json.decode(str));

String internshipBatchModelToJson(InternshipBatchModel data) => json.encode(data.toJson());

class InternshipBatchModel {
  int statusCode;
  String message;
  int eligibilityStatus;
  List<Datum> data;

  InternshipBatchModel({
    required this.statusCode,
    required this.message,
    required this.eligibilityStatus,
    required this.data,
  });

  factory InternshipBatchModel.fromJson(Map<String, dynamic> json) => InternshipBatchModel(
    statusCode: json["status_code"],
    message: json["message"],
    eligibilityStatus: json["eligibility_status"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status_code": statusCode,
    "message": message,
    "eligibility_status": eligibilityStatus,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  String leadId;
  String name;
  String email;
  dynamic isoCode;
  String phoneNumber;
  String bundleEventId;
  String enrollmentId;
  String batchDetails;

  Datum({
    required this.leadId,
    required this.name,
    required this.email,
    required this.isoCode,
    required this.phoneNumber,
    required this.bundleEventId,
    required this.enrollmentId,
    required this.batchDetails,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    leadId: json["lead_id"],
    name: json["name"],
    email: json["email"],
    isoCode: json["iso_code"],
    phoneNumber: json["phone_number"],
    bundleEventId: json["bundle_event_id"],
    enrollmentId: json["enrollment_id"],
    batchDetails: json["batch_details"],
  );

  Map<String, dynamic> toJson() => {
    "lead_id": leadId,
    "name": name,
    "email": email,
    "iso_code": isoCode,
    "phone_number": phoneNumber,
    "bundle_event_id": bundleEventId,
    "enrollment_id": enrollmentId,
    "batch_details": batchDetails,
  };
}
