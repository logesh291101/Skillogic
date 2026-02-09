import 'package:flutter/material.dart';

class NotEligibleScreen extends StatelessWidget {

  const NotEligibleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Attention",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
            SizedBox(height: MediaQuery.of(context).size.height * 0.07),
             Text("You must complete the course to be \neligible for the internship application",
               style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15)),
            SizedBox(height: MediaQuery.of(context).size.height * 0.07),
            MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Back"),
                color: Colors.redAccent,
                textColor: Colors.white)
          ],
        ),
      ),
    ));
  }
}
