import 'package:datamites/helper/color.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class SuccessScreen extends StatefulWidget {
  final String? code;

  const SuccessScreen({Key? key, required this.code}) : super(key: key);

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  bool success = false;
  String message = "";
  bool loading = true;

  checkQR(String? code) async {
    // TODO checking server the qr code

    await Future.delayed(Duration(seconds: 2));
    if (Random().nextInt(3) != 1) {
      setState(() {
        success = true;
        message = "You attendance is registered";
        loading = false;
      });
    } else {
      setState(() {
        success = false;
        message = "Not a valid qr";
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkQR(widget.code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
          width: double.infinity,
          height: double.infinity,
          child: loading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (success)
                      Icon(
                        Icons.done,
                        color: Colors.green,
                        size: 64,
                      ),
                    if (!success)
                      Icon(
                        Icons.sms_failed,
                        color: MainColor.darkRed,
                        size: 64,
                      ),
                    if (success)
                      Text(
                        "Success",
                        style:
                            TextStyle(color: MainColor.darkGreen, fontSize: 32),
                      ),
                    if (!success)
                      Text(
                        "Failure",
                        style:
                            TextStyle(color: MainColor.darkRed, fontSize: 32),
                      ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      "${message}",
                      style: TextStyle(
                          color:
                              success ? MainColor.darkGreen : MainColor.darkRed,
                          fontSize: 24),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    MaterialButton(
                      minWidth: 120.0,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      color: MainColor.darkGreen,
                      textColor: Colors.white,
                      child: Text("Scan Again"),
                    ),
                    if (success)
                      MaterialButton(
                        minWidth: 120.0,
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        color: MainColor.lightGreen,
                        textColor: MainColor.darkGreen,
                        child: Text("Go Back"),
                      ),
                  ],
                )),
    );
  }
}
