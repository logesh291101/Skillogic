class EnrollmentModel {
  final String enrollment_id;
  final String enroll_type;
  final String agreed_price;
  final String enrollment_number;
  final String bundle_event_id;
  final String bundle_id;
  final String bundle_name;
  final String bundle_event_name;
  final String bundle_status;
  final String bundle_total_duration;
  final String bundle_event_type_name;

  EnrollmentModel({required this.enrollment_id,
    required this.bundle_event_id,
    required this.enroll_type,
    required this.agreed_price,
    required this.enrollment_number,
    required this.bundle_id,
    required this.bundle_name,
    required this.bundle_event_name,
    required this.bundle_total_duration,
    required this.bundle_status,
    required this.bundle_event_type_name
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentModel(
        enrollment_id: json["enrollment_id"]??"0",
        enroll_type: json["enrollment_type"]??"",
        agreed_price: json["enrollment_agreed_price"]??"",
        enrollment_number: json["enrollment_number"]??"",
        bundle_id: json["bundle_event"]["bundle_id"]??"0",
        bundle_event_id: json["bundle_event"]["bundle_event_id"]??"0",
        bundle_name: json["bundle_event"]["bundle_name"]??"",
        bundle_event_name: json["bundle_event"]["bundle_event_name"]??"",
        bundle_total_duration: json["bundle_event"]["bundle_event_duration"] ??"0",
        bundle_status: json["bundle_event"]["bundle_status"]??"0",
        bundle_event_type_name: json["bundle_event"]["bundle_event_type_name"]??"");
  }
}