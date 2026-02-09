// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:intl/intl.dart';
// import 'package:skillogic/helper/color.dart';
// import 'package:skillogic/pages/candidate_portal/candidate_rest_request.dart';
// import 'package:skillogic/pages/candidate_portal/course_schedules.dart';
// import 'package:skillogic/pages/candidate_portal/data_model/CourseEventModel.dart';
// import 'package:skillogic/pages/candidate_portal/data_model/EnrollmentModel.dart';
// import 'package:flutter/material.dart';
//
// import '../../helper/connection.dart';
// import '../../helper/user_details.dart';
// import '../../model/user_model.dart';
// import '../../widgets/CustomWidget.dart';
// import '../main_page.dart';
//
// class EnrolledCourseDetails extends StatefulWidget {
//   final EnrollmentModel enrollmentModel;
//   final String enrollmentNumber;
//   final String classType;
//
//   // ignore: use_key_in_widget_constructors
//   const EnrolledCourseDetails({
//     required this.enrollmentModel,
//     required this.enrollmentNumber,
//     required this.classType,
//   });
//
//   @override
//   State<EnrolledCourseDetails> createState() => _EnrolledCourseDetailsState();
// }
//
// class _EnrolledCourseDetailsState extends State<EnrolledCourseDetails> {
//   CandidateRestRequest candidateRestRequest = CandidateRestRequest();
//   List<CourseEventModel> courses = [];
//   bool loaded = false;
//   bool loading = true;
//   String startDate = "";
//   String endDate = "";
//
//   void getStartEndDate() {
//     for (CourseEventModel course in courses) {
//       if (startDate.isEmpty && course.course_event_start_date.isNotEmpty) {
//         startDate = course.course_event_start_date;
//       }
//       if (course.course_event_end_time.isNotEmpty) {
//         endDate = course.course_event_end_time;
//       }
//     }
//     setState(() {});
//   }
//
//   void getCourses(String bundle_event_id) async {
//     if (kDebugMode) {
//       print("Getting courses");
//     }
//     bool connected = await ConnectionCheck.isAvailable();
//     if (!connected) {
//       showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: const Text("Connection Lost"),
//             content: const Text("Please check your internet connection"),
//             actions: [
//               MaterialButton(
//                 onPressed: () {
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (context) => const MainPage()),
//                     (route) => false,
//                   );
//                 },
//                 child: const Text("Ok"),
//               ),
//             ],
//           );
//         },
//       );
//     } else {
//       courses = await candidateRestRequest.getCourseDetails(
//         context,
//         bundle_event_id,
//       );
//       getStartEndDate();
//     }
//     setState(() {
//       loaded = true;
//       loading = false;
//     });
//   }
//
//   var userDetails = UserDetails();
//   UserModel? userModel;
//
//   _getUserDetail() async {
//     userModel = await userDetails.getDetail();
//     setState(() {});
//   }
//
//   @override
//   void initState() {
//     setState(() {
//       loading = true;
//     });
//     _getUserDetail();
//     getCourses(widget.enrollmentModel.bundle_event_id);
//     super.initState();
//   }
//
//   getTag(String text, bool selected) {
//     return Container(
//       padding: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: selected
//             ? MainColor.lightskillogicBlue
//             : MainColor.lightskillogicRed,
//         borderRadius: BorderRadius.circular(8.0),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: 12,
//           color: selected ? MainColor.skillogicBlue : MainColor.skillogicRed,
//           decoration: selected ? null : TextDecoration.lineThrough,
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: CustomWidget.getSkillogicAppBar(context, userModel, 1),
//       body: loaded
//           ? Padding(
//               padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
//               child: SingleChildScrollView(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 16),
//                     Text(
//                       widget.enrollmentModel.bundle_name,
//                       style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 5),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             //Text("Start date: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(startDate))} (IST)"),
//                             Row(
//                               children: [
//                                 Text(
//                                   "Enrollment Number: ",
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.red,
//                                   ),
//                                 ),
//                                 Text(widget.enrollmentNumber),
//                                 IconButton(
//                                   onPressed: () {
//                                     Clipboard.setData(
//                                       ClipboardData(
//                                         text: widget.enrollmentNumber,
//                                       ),
//                                     );
//                                     Fluttertoast.showToast(
//                                       msg: "Copied",
//                                       toastLength: Toast.LENGTH_SHORT,
//                                       gravity: ToastGravity.TOP,
//                                       backgroundColor: Colors.black87,
//                                       textColor: Colors.white,
//                                       fontSize: 16.0,
//                                     );
//                                   },
//                                   icon: Icon(
//                                     Icons.copy,
//                                     color: Colors.redAccent,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Row(
//                               children: [
//                                 Text(
//                                   "Class Type: ",
//                                   style: TextStyle(
//                                     color: Colors.green,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 Text(widget.classType),
//                               ],
//                             ),
//                             SizedBox(height: 10),
//                             Text(startDate),
//                             SizedBox(height: 3),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Icon(
//                                   Icons.my_library_books_outlined,
//                                   size: 18,
//                                 ),
//                                 Text(
//                                   " ${courses.isNotEmpty ? courses.length : ""} ${courses.isEmpty
//                                       ? "No course"
//                                       : courses.length > 1
//                                       ? "courses"
//                                       : "course"}",
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     for (CourseEventModel course in courses)
//                       Container(
//                         margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
//                         width: double.infinity,
//                         padding: const EdgeInsets.all(8.0),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.black38),
//                           borderRadius: BorderRadius.circular(8.0),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               course.courses.first.course_name,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 16,
//                               ),
//                             ),
//
//                             if (course.courses.first.course_code.isNotEmpty)
//                               Text(
//                                 course.courses.first.course_code,
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             if (course
//                                 .courses
//                                 .first
//                                 .course_description
//                                 .isNotEmpty)
//                               Padding(
//                                 padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
//                                 child: Text(
//                                   course.courses.first.course_description,
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.w600,
//                                     fontSize: 12,
//                                     color: Colors.black38,
//                                   ),
//                                 ),
//                               ),
//                             if (course.courses.first.course_language.isNotEmpty)
//                               Row(
//                                 children: [
//                                   const Icon(Icons.language, size: 18),
//                                   Text(
//                                     " ${course.courses.first.course_language}",
//                                   ),
//                                 ],
//                               ),
//                             if (course.courses.first.course_duration.isNotEmpty)
//                               Row(
//                                 children: [
//                                   const Icon(
//                                     Icons.access_time_outlined,
//                                     size: 18,
//                                   ),
//                                   Text(
//                                     " ${course.courses.first.course_duration} weeks",
//                                   ),
//                                 ],
//                               ),
//
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               children: [
//                                 if (course.course_event_status != "" &&
//                                     course.course_event_status.isNotEmpty)
//                                   Container(
//                                     padding: const EdgeInsets.fromLTRB(
//                                       8,
//                                       4,
//                                       8,
//                                       4,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(8.0),
//                                       color:
//                                           course.course_event_status == "0" &&
//                                               course
//                                                   .course_event_status
//                                                   .isNotEmpty
//                                           ? MainColor.skillogicBlue
//                                           : MainColor.skillogicRed,
//                                     ),
//                                     child: Text(
//                                       course.course_event_status == "1"
//                                           ? "Scheduled"
//                                           : course.course_event_status == "2"
//                                           ? "Postponed"
//                                           : course.course_event_status == "3"
//                                           ? "Completed"
//                                           : course.course_event_status == "4"
//                                           ? "Cancelled"
//                                           : course.course_event_status == "5"
//                                           ? "Audited"
//                                           : "",
//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 10,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ),
//                                 if (course.courses.first.course_level != "")
//                                   Container(
//                                     padding: const EdgeInsets.fromLTRB(
//                                       8,
//                                       4,
//                                       8,
//                                       4,
//                                     ),
//                                     margin: const EdgeInsets.fromLTRB(
//                                       4,
//                                       0,
//                                       0,
//                                       0,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(8.0),
//                                       color:
//                                           course.courses.first.course_level ==
//                                               "1"
//                                           ? MainColor.skillogicBlue
//                                           : course.courses.first.course_level ==
//                                                 "2"
//                                           ? MainColor.skillogicRed
//                                           : MainColor.darkRed,
//                                     ),
//                                     child: Text(
//                                       course.courses.first.course_level == "1"
//                                           ? "Beginner"
//                                           : course.courses.first.course_level ==
//                                                 "2"
//                                           ? "Intermediate"
//                                           : course.courses.first.course_level ==
//                                                 "3"
//                                           ? "Expert"
//                                           : "",
//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 8,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ),
//                               ],
//                             ),
//                             const SizedBox(height: 8),
//                             Wrap(
//                               spacing: 5,
//                               runSpacing: 5.0,
//                               children: [
//                                 if (course.courses.first.has_assessment != "")
//                                   getTag(
//                                     "assessment",
//                                     course.courses.first.has_assessment == "1",
//                                   ),
//                                 if (course
//                                         .courses
//                                         .first
//                                         .has_placement_assistance !=
//                                     "")
//                                   getTag(
//                                     "placement assessment",
//                                     course
//                                             .courses
//                                             .first
//                                             .has_placement_assistance ==
//                                         "1",
//                                   ),
//                                 if (course.courses.first.has_internship != "")
//                                   getTag(
//                                     "internship",
//                                     course.courses.first.has_internship == "1",
//                                   ),
//                                 if (course.courses.first.has_projects != "")
//                                   getTag(
//                                     "projects",
//                                     course.courses.first.has_projects == "1",
//                                   ),
//                                 if (course.courses.first.has_coding != "")
//                                   getTag(
//                                     "coding",
//                                     course.courses.first.has_coding == "1",
//                                   ),
//                               ],
//                             ),
//                             const SizedBox(height: 8),
//                             if (course.schedules.isNotEmpty)
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     "Start: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(course.schedules.first.event_start_date))}",
//                                     style: const TextStyle(color: Colors.grey),
//                                   ),
//                                   Text(
//                                     "End: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(course.schedules.last.event_start_date))}",
//                                     // Assuming startDate is a String
//                                     style: const TextStyle(color: Colors.grey),
//                                   ),
//                                 ],
//                               ),
//                             MaterialButton(
//                               onPressed: course.schedules.isEmpty
//                                   ? null
//                                   : () {
//                                       Navigator.of(context).push(
//                                         MaterialPageRoute(
//                                           builder: (context) => CourseSchedules(
//                                             title: course
//                                                 .courses
//                                                 .first
//                                                 .course_name,
//                                             courseSchedules: course.schedules,
//                                             courseType:course.course_event_type_name,
//                                           ),
//                                         ),
//                                       );
//                                     },
//                               color: MainColor.skillogicBlue,
//                               minWidth: double.infinity,
//                               child: course.schedules.isNotEmpty
//                                   ? const Text(
//                                       "Check Schedule",
//                                       style: TextStyle(color: Colors.white),
//                                     )
//                                   : const Text(
//                                       "No Schedule",
//                                       style: TextStyle(
//                                         color: Color(0xffb62451),
//                                       ),
//                                     ),
//                             ),
//                           ],
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             )
//           : const Center(child: CircularProgressIndicator()),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../../helper/color.dart';
import '../../helper/connection.dart';
import '../../helper/user_details.dart';
import '../../model/user_model.dart';
import '../../widgets/CustomWidget.dart';
import '../main_page.dart';
import 'candidate_rest_request.dart';
import 'course_schedules.dart';
import 'data_model/CourseEventModel.dart';
import 'data_model/EnrollmentModel.dart';

class EnrolledCourseDetails extends StatefulWidget {
  final EnrollmentModel enrollmentModel;
  final String enrollmentNumber;
  final String classType;

  // ignore: use_key_in_widget_constructors
  const EnrolledCourseDetails({
    required this.enrollmentModel,
    required this.enrollmentNumber,
    required this.classType,
  });

  @override
  State<EnrolledCourseDetails> createState() => _EnrolledCourseDetailsState();
}

class _EnrolledCourseDetailsState extends State<EnrolledCourseDetails> {
  CandidateRestRequest candidateRestRequest = CandidateRestRequest();
  List<CourseEventModel> courses = [];
  bool loaded = false;
  bool loading = true;
  String startDate = "";
  String endDate = "";
  //String courseEventId = "";

  void getStartEndDate() {
    for (CourseEventModel course in courses) {
      if (startDate.isEmpty && course.course_event_start_date.isNotEmpty) {
        startDate = course.course_event_start_date;
      }
      if (course.course_event_end_time.isNotEmpty) {
        endDate = course.course_event_end_time;
      }
      // if (course.course_event_id.isNotEmpty) {
      //   courseEventId = course.course_event_id;
      // }
    }
    setState(() {});
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "Date not available";
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return "Date not available";
    return DateFormat("dd-MMM-yyyy").format(parsed);
  }

  void getCourses(String bundle_event_id) async {
    print("Getting courses");
    bool connected = await ConnectionCheck.isAvailable();
    if (!connected) {
      CustomWidget.showInternetDialog(context);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Connection Lost"),
            content: const Text("Please check your internet connection"),
            actions: [
              MaterialButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainPage()),
                    (route) => false,
                  );
                },
                child: const Text("Ok"),
              ),
            ],
          );
        },
      );
    } else {
      courses = await candidateRestRequest.getCourseDetails(
        context,
        bundle_event_id,
      );
      getStartEndDate();
    }
    setState(() {
      loaded = true;
      loading = false;
    });
  }

  var userDetails = UserDetails();
  UserModel? userModel;

  _getUserDetail() async {
    userModel = await userDetails.getDetail();
    setState(() {});
  }

  @override
  void initState() {
    setState(() {
      loading = true;
    });
    _getUserDetail();
    getCourses(widget.enrollmentModel.bundle_event_id);
    super.initState();
  }

  getTag(String text, bool selected) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: selected ? MainColor.lightGreen : MainColor.lightRed,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: selected ? MainColor.darkGreen : MainColor.darkRed,
          decoration: selected ? null : TextDecoration.lineThrough,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomWidget.getSkillogicAppBar(context, userModel, 1),
      body: loaded ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      widget.enrollmentModel.bundle_name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //Text("Start date: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(startDate))} (IST)"),
                            Row(
                              children: [
                                Text(
                                  "Enrollment Number: ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                Text(widget.enrollmentNumber),
                                IconButton(
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(
                                        text: widget.enrollmentNumber,
                                      ),
                                    );
                                    Fluttertoast.showToast(
                                      msg: "Copied",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.TOP,
                                      backgroundColor: Colors.black87,
                                      textColor: Colors.white,
                                      fontSize: 16.0,
                                    );
                                  },
                                  icon: Icon(
                                    Icons.copy,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "Class Type: ",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(widget.classType),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(formatDate(startDate)),
                            SizedBox(height: 3),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.my_library_books_outlined,
                                  size: 18,
                                ),
                                Text(
                                  " ${courses.isNotEmpty ? courses.length : ""} ${courses.isEmpty
                                      ? "No course"
                                      : courses.length > 1
                                      ? "courses"
                                      : "course"}",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    for (CourseEventModel course in courses)
                      GestureDetector(
                        onTap: course.schedules.isEmpty
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => CourseSchedules(
                                      title: course.courses.first.course_name,
                                      courseSchedules: course.schedules,
                                      courseType: course.course_event_type_name,
                                    ),
                                  ),
                                );
                              },
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                          width: double.infinity,
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black38),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.courses.first.course_name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),

                              if (course.courses.first.course_code.isNotEmpty)
                                Text(
                                  course.courses.first.course_code,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              if (course
                                  .courses
                                  .first
                                  .course_description
                                  .isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    0,
                                    0,
                                    0,
                                    8,
                                  ),
                                  child: Text(
                                    course.courses.first.course_description,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: Colors.black38,
                                    ),
                                  ),
                                ),
                              if (course
                                  .courses
                                  .first
                                  .course_language
                                  .isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(Icons.language, size: 18),
                                    Text(
                                      " ${course.courses.first.course_language}",
                                    ),
                                  ],
                                ),
                              if (course
                                  .courses
                                  .first
                                  .course_duration
                                  .isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time_outlined,
                                      size: 18,
                                    ),
                                    Text(
                                      " ${course.courses.first.course_duration} weeks",
                                    ),
                                  ],
                                ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (course.course_event_status != "" &&
                                      course.course_event_status.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(
                                        8,
                                        4,
                                        8,
                                        4,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                        color:
                                            course.course_event_status == "0" &&
                                                course
                                                    .course_event_status
                                                    .isNotEmpty
                                            ? MainColor.darkGreen
                                            : MainColor.darkRed,
                                      ),
                                      child: Text(
                                        course.course_event_status == "1"
                                            ? "Scheduled"
                                            : course.course_event_status == "2"
                                            ? "Postponed"
                                            : course.course_event_status == "3"
                                            ? "Completed"
                                            : course.course_event_status == "4"
                                            ? "Cancelled"
                                            : course.course_event_status == "5"
                                            ? "Audited"
                                            : "",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  if (course.courses.first.course_level != "")
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(
                                        8,
                                        4,
                                        8,
                                        4,
                                      ),
                                      margin: const EdgeInsets.fromLTRB(
                                        4,
                                        0,
                                        0,
                                        0,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                        color:
                                            course.courses.first.course_level ==
                                                "1"
                                            ? MainColor.darkGreen
                                            : course
                                                      .courses
                                                      .first
                                                      .course_level ==
                                                  "2"
                                            ? MainColor.datamiteOrange
                                            : MainColor.darkRed,
                                      ),
                                      child: Text(
                                        course.courses.first.course_level == "1"
                                            ? "Beginner"
                                            : course
                                                      .courses
                                                      .first
                                                      .course_level ==
                                                  "2"
                                            ? "Intermediate"
                                            : course
                                                      .courses
                                                      .first
                                                      .course_level ==
                                                  "3"
                                            ? "Expert"
                                            : "",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 5,
                                runSpacing: 5.0,
                                children: [
                                  if (course.courses.first.has_assessment != "")
                                    getTag(
                                      "assessment",
                                      course.courses.first.has_assessment ==
                                          "1",
                                    ),
                                  if (course
                                          .courses
                                          .first
                                          .has_placement_assistance !=
                                      "")
                                    getTag(
                                      "placement assessment",
                                      course
                                              .courses
                                              .first
                                              .has_placement_assistance ==
                                          "1",
                                    ),
                                  if (course.courses.first.has_internship != "")
                                    getTag(
                                      "internship",
                                      course.courses.first.has_internship ==
                                          "1",
                                    ),
                                  if (course.courses.first.has_projects != "")
                                    getTag(
                                      "projects",
                                      course.courses.first.has_projects == "1",
                                    ),
                                  if (course.courses.first.has_coding != "")
                                    getTag(
                                      "coding",
                                      course.courses.first.has_coding == "1",
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (course.schedules.isNotEmpty)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Text(
                                    //   "Start: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(course.schedules.first.event_start_date))}",
                                    //   style: const TextStyle(
                                    //     color: Colors.grey,
                                    //   ),
                                    // ),
                                    // Text(
                                    //   "End: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(course.schedules.last.event_start_date))}",
                                    //   // Assuming startDate is a String
                                    //   style: const TextStyle(
                                    //     color: Colors.grey,
                                    //   ),
                                    // ),
                                    Text(
                                      "Start: ${formatDate(course.schedules.first.event_start_date)}",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      "End: ${formatDate(course.schedules.last.event_start_date)}",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              MaterialButton(
                                onPressed: course.schedules.isEmpty
                                    ? null
                                    : () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CourseSchedules(
                                                  title: course
                                                      .courses
                                                      .first
                                                      .course_name,
                                                  courseSchedules:
                                                      course.schedules,
                                                  courseType: course
                                                      .course_event_type_name,
                                                ),
                                          ),
                                        );
                                      },
                                color: MainColor.darkGreen,
                                minWidth: double.infinity,
                                child: course.schedules.isNotEmpty
                                    ? const Text(
                                        "Check Schedule",
                                        style: TextStyle(color: Colors.white),
                                      )
                                    : const Text(
                                        "No Schedule",
                                        style: TextStyle(color: Colors.red),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ) : Center(child:CircularProgressIndicator()),
    );
  }
}
