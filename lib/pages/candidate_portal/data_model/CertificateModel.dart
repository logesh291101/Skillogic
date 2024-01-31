class CertificateModel {
  final String certificate_id;
  final String certificate_file_name;
  final String course_name;
  final String created_date;
  final String sent_status;

  CertificateModel({required this.certificate_id,
    required this.certificate_file_name,
    required this.course_name,
    required this.created_date,
    required this.sent_status});

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
        certificate_id: json["certificate_id"]??"",
        certificate_file_name: json["certificate_file_name"]??"",
        course_name: json["course_name"]??"",
        created_date: json["created_date"]??"",
        sent_status: json["sent_status"]??"");
  }
}