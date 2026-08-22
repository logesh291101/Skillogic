// class CertificateModel {
//   final String certificate_id;
//   final String certificate_file_name;
//   final String course_name;
//   final String created_date;
//   final String sent_status;
//
//   CertificateModel({required this.certificate_id,
//     required this.certificate_file_name,
//     required this.course_name,
//     required this.created_date,
//     required this.sent_status});
//
//   factory CertificateModel.fromJson(Map<String, dynamic> json) {
//     return CertificateModel(
//         certificate_id: json["certificate_id"]??"",
//         certificate_file_name: json["certificate_file_name"]??"",
//         course_name: json["course_name"]??"",
//         created_date: json["created_date"]??"",
//         sent_status: json["sent_status"]??"");
//   }
// }

class CertificateResponseModel {
  final int statuscode;
  final String message;
  final List<CertificateModel> data;

  CertificateResponseModel({
    required this.statuscode,
    required this.message,
    required this.data,
  });

  factory CertificateResponseModel.fromJson(Map<String, dynamic> json) {
    return CertificateResponseModel(
      statuscode: json['statuscode'] ?? 0,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => CertificateModel.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statuscode': statuscode,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class CertificateModel {
  final String certificateId;
  final String certificateFileName;
  final String courseName;
  final String certificateTypeValue;
  final String certificateTypeName;
  final String createdDate;
  final String sentStatus;

  CertificateModel({
    required this.certificateId,
    required this.certificateFileName,
    required this.courseName,
    required this.certificateTypeValue,
    required this.certificateTypeName,
    required this.createdDate,
    required this.sentStatus,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      certificateId: json['certificate_id'] ?? '',
      certificateFileName: json['certificate_file_name'] ?? '',
      courseName: json['course_name'] ?? '',
      certificateTypeValue: json['certificate_type_value'] ?? '',
      certificateTypeName: json['certificate_type_name'] ?? '',
      createdDate: json['created_date'] ?? '',
      sentStatus: json['sent_status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'certificate_id': certificateId,
      'certificate_file_name': certificateFileName,
      'course_name': courseName,
      'certificate_type_value': certificateTypeValue,
      'certificate_type_name': certificateTypeName,
      'created_date': createdDate,
      'sent_status': sentStatus,
    };
  }
}