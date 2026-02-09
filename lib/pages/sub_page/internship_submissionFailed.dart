import 'package:flutter/material.dart';

import '../main_page.dart';

class InternshipSubmissionFailed extends StatefulWidget {
  const InternshipSubmissionFailed({super.key});

  @override
  State<InternshipSubmissionFailed> createState() =>
      _InternshipSubmissionFailedState();
}

class _InternshipSubmissionFailedState
    extends State<InternshipSubmissionFailed> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F3F3),
      //backgroundColor:Colors.green,
      body: SafeArea(
        child: Column(
          children: [
            ClipPath(
              clipper: CustomClipPath(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.45,
                width: double.infinity,
                color:Color(0xfff84242),//FAILED

                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        //backgroundColor:Colors.red
                        backgroundColor: Color(0xffffffff),
                        radius: MediaQuery.of(context).size.width * 0.14,
                        child: Center(
                          child:
                          Icon(Icons.warning_amber_outlined,
                           color: Color(0xffff0000),
                              size:
                              MediaQuery.of(context).size.width * 0.17)
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Error",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              "Something went worng\nPlease try again later",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17),
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => MainPage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: StadiumBorder(),
                padding:
                const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
              child: const Text("Done"),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);

    path.quadraticBezierTo(
        size.width * 0.25, size.height, size.width * 0.5, size.height - 60);
    path.quadraticBezierTo(
        size.width * 0.75, size.height - 120, size.width, size.height - 60);

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
