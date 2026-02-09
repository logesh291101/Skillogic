import 'package:flutter/material.dart';

class UserActivity extends StatefulWidget {
  const UserActivity({Key? key}) : super(key: key);

  @override
  State<UserActivity> createState() => _UserActivityState();
}

class _UserActivityState extends State<UserActivity> {
  var loading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        title: const Text(
          "Activities",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        // child: ListView(
        //   shrinkWrap: true,
        //   physics: NeverScrollableScrollPhysics(),
        //   scrollDirection: Axis.vertical,
        //   children: coursesList.map((course) => CardCoursePreview(course: course,))
        //       .toList(),),
      )
    );
  }
}
