class SubjectQueryModel {
  final String subject_type_id;
  final String subject_type_name;

  SubjectQueryModel({required this.subject_type_id,
    required this.subject_type_name});

  factory SubjectQueryModel.fromJson(Map<String, dynamic> json) {
    return SubjectQueryModel(
      subject_type_id: json["subject_type_id"]??"0",
      subject_type_name: json["subject_type_name"]??"",
    );
  }
}