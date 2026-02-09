// To parse this JSON data, do
//
//     final handbookModel = handbookModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

HandbookModel handbookModelFromJson(String str) => HandbookModel.fromJson(json.decode(str));

String handbookModelToJson(HandbookModel data) => json.encode(data.toJson());

class HandbookModel {
  String message;
  List<Datum> data;

  HandbookModel({
    required this.message,
    required this.data,
  });

  factory HandbookModel.fromJson(Map<String, dynamic> json) => HandbookModel(
    message: json["message"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  String handbookName;
  String handbookLink;

  Datum({
    required this.handbookName,
    required this.handbookLink,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    handbookName: json["handbook_name"],
    handbookLink: json["handbook_link"],
  );

  Map<String, dynamic> toJson() => {
    "handbook_name": handbookName,
    "handbook_link": handbookLink,
  };
}
