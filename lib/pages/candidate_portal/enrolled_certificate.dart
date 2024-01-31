//@utsav added enrolledcertificate and model 23-01-2024
import 'dart:io';

import 'package:datamites/helper/color.dart';
import 'package:datamites/model/user_model.dart';
import 'package:datamites/pages/candidate_portal/candidate_rest_request.dart';
import 'package:datamites/pages/candidate_portal/data_model/CertificateModel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

import '../../helper/connection.dart';
import '../../helper/user_details.dart';
import '../../widgets/CustomWidget.dart';
import '../main_page.dart';

class EnrolledCertificate extends StatefulWidget {
  const EnrolledCertificate({Key? key}) : super(key: key);

  @override
  State<EnrolledCertificate> createState() => _EnrolledCertificateState();
}

class _EnrolledCertificateState extends State<EnrolledCertificate> {
  CandidateRestRequest candidateRestRequest = CandidateRestRequest();
  List<CertificateModel> earnedCertificate =[];
  bool loaded = false;
  bool loading = true;

  void loadData() async {
    if (kDebugMode) {
      print("Getting certificate");
    }
    bool connected = await ConnectionCheck.isAvailable();
    if (!connected) {
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
                        MaterialPageRoute(
                            builder: (context) => const MainPage()),
                            (route) => false);
                  },
                  child: const Text("Ok"),
                )
              ],
            );
          });
    } else {
      earnedCertificate = await candidateRestRequest.getCertificate(context);
      // print("Earned Certificates: $earnedCertificate");
      setState(() {
        loaded = true;
        loading = false;
      });
    }
  }

  // Add a function to open the certificate URL in a web-view
  void openCertificateWebView(String certificateFileName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text("Certificate"),
          ),
          body: WebView(
            initialUrl: certificateFileName,
            javascriptMode: JavascriptMode.unrestricted,
            gestureNavigationEnabled: true,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<VerticalDragGestureRecognizer>(
                    () => VerticalDragGestureRecognizer(),
              ),
            },
          ),
          // body: PDFView(
          //   filePath: certificateUrl,
          //   autoSpacing: true,
          //   enableSwipe: true,
          //   pageSnap: true,
          //   swipeHorizontal: true,
          //   nightMode: false,
          //   onError: (e) {
          //     print(e);
          //   },
          // ),
        ),
      ),
    );
  }

  void downloadCertificate(String certificateFileName, String courseName, BuildContext context) async {
    var url = Uri.parse(certificateFileName);
    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        Directory? appDocDir = await getExternalStorageDirectory();
        String? appDocPath = appDocDir?.path;

        // Create a new folder if it doesn't exist
        Directory folder = Directory('$appDocPath/Datamites/$courseName');
        if (!await folder.exists()) {
          folder.createSync(recursive: true);
        }

        // Clean the courseName to make it suitable for a file name
        String cleanedFileName = '$courseName/certificate.pdf';
        File file = File('$appDocPath/Datamites/$cleanedFileName');

        // Check if the file already exists
        int count = 1;
        while (await file.exists()) {
          cleanedFileName = '$courseName/certificate($count).pdf'; // Append count to avoid overwriting
          file = File('$appDocPath/Datamites/$cleanedFileName');
          count++;
        }

        await file.writeAsBytes(response.bodyBytes);
        if (kDebugMode) {
          print("Certificate downloaded at: ${file.path}");
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Certificate downloaded at: ${file.path}'),
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        if (kDebugMode) {
          print("Failed to download certificate. Status code: ${response.statusCode}");
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to download the Certificate'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to download certificate: $e");
      }
    }
  }


  var userDetails = UserDetails();
  UserModel? userModel;

  _getUserDetail() async {
    userModel = await userDetails.getDetail();
    setState(() {});
  }

  @override
  void initState() {
    loadData();
    _getUserDetail();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f6f6),
      appBar: CustomWidget.getDatamitesAppBar(context, userModel, 1),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(earnedCertificate.isNotEmpty) const Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 16.0, 0, 0),
                  child: Text(
                    "Certificates",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                ),
                if (loaded && earnedCertificate.isEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 64,
                        ),
                        const Text("No any certificate found"),
                        const SizedBox(
                          height: 8,
                        ),
                        MaterialButton(
                          onPressed: () {
                            loadData();
                          },
                          color: MainColor.skillogicRed,
                          child: const Text("Refresh", style: TextStyle(color: Colors.white),),
                        )
                      ],
                    ),
                  ),

                if (loaded && earnedCertificate.isNotEmpty)
                  for (CertificateModel earnedCertificate in earnedCertificate)
                    Container(
                        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        padding: const EdgeInsets.all(8.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.white),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              earnedCertificate.course_name,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Adjust the alignment as needed
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => openCertificateWebView(earnedCertificate.certificate_file_name),
                                  icon:const Icon(Icons.book_outlined),
                                  label: const Text("View"),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => downloadCertificate(earnedCertificate.certificate_file_name, earnedCertificate.course_name, context),
                                  icon: const Icon(Icons.download),
                                  label: const Text("Download"),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    // )
              ],
            ),
          ),
          if (loading)
            const SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
        ],
      ),
    );
  }
}
