import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helper/color.dart';
import '../../helper/user_details.dart';
import '../../model/user_model.dart';
import '../../widgets/CustomWidget.dart';
//import '../../widgets/custom_widget_2.dart';

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

  var userDetails = UserDetails();
  UserModel? userModel;

  checkQR(String? code) async {
    setState(() {
      loading = true;
    });

    await Future.delayed(const Duration(seconds: 2));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String valid_qr = prefs.getString("valid_qr") ?? "";
    if (code != null && code.contains(valid_qr)) {
      setState(() {
        success = true;
        message = "Your attendance is recorded successfully.";
        loading = false;
      });
    } else {
      setState(() {
        success = false;
        message = "Invalid QR code. Attendance recording failed.";
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
      appBar: CustomWidget2.getSkillogicAppBar(context, userModel, 1),
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              success
                  ? Lottie.asset(
                'assets/success.json', // Animation for success
                height: 120,
              )
                  : Lottie.asset(
                'assets/failure.json', // Animation for failure
                height: 120,
              ),
              const SizedBox(height: 16),
              Text(
                success ? "Success" : "Failure",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: success
                      ? MainColor.darkGreen
                      : MainColor.darkRed,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: MainColor.darkGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Scan Again",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: success
                      ? MainColor.darkGreen
                      : MainColor.darkRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Go Back",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
