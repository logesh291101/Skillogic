
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helper/color.dart';
import '../model/candidate_enrollment_model.dart';
import 'activity_details_page.dart';
import 'assessment_details_page.dart';

class EnrollmentCard extends StatelessWidget {
  final CandidateEnrollmentModel candidateEnrollmentModel;
  final int assessment;

  const EnrollmentCard(
      {required this.candidateEnrollmentModel,
      required this.assessment,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        color: Colors.white,
      ),
      child: MaterialButton(
        padding: const EdgeInsets.all(8),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => (assessment != 1)
                      ? ActivityDetailsPage(
                          enrollmentId: candidateEnrollmentModel.enrollmentId,
                          title: "Enrollment Details")
                      : AssessmentDetailsPage(
                          enrollmentId: candidateEnrollmentModel.enrollmentId,
                          title: "Assessment Details")));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              candidateEnrollmentModel.enrollmentName,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: MainColor.textColorConst),
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                ),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  "${DateFormat('dd-MM-yyyy').format(DateTime.parse(candidateEnrollmentModel.enrollmentDate))}",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: MainColor.textColorConst),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  candidateEnrollmentModel.eventCity,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: MainColor.textColorConst),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
