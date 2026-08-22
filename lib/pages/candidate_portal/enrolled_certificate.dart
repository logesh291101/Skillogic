// //@utsav added enrolledcertificate and model 23-01-2024
// import 'dart:io';
//
// import 'package:skillogic/helper/color.dart';
// import 'package:skillogic/model/user_model.dart';
// import 'package:skillogic/pages/candidate_portal/candidate_rest_request.dart';
// import 'package:skillogic/pages/candidate_portal/data_model/CertificateModel.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:open_filex/open_filex.dart';
// import '../../helper/connection.dart';
// import '../../helper/user_details.dart';
// import '../../widgets/CustomWidget.dart';
// import '../main_page.dart';
//
// class EnrolledCertificate extends StatefulWidget {
//   const EnrolledCertificate({Key? key}) : super(key: key);
//
//   @override
//   State<EnrolledCertificate> createState() => _EnrolledCertificateState();
// }
//
// class _EnrolledCertificateState extends State<EnrolledCertificate> {
//   CandidateRestRequest candidateRestRequest = CandidateRestRequest();
//   List<CertificateModel> earnedCertificate = [];
//   bool loaded = false;
//   bool loading = true;
//   String textTemplate = '';
//   String subjectTemplate = '';
//
//   void loadData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     if (kDebugMode) {
//       print("Getting certificate");
//     }
//     bool connected = await ConnectionCheck.isAvailable();
//     if (!connected) {
//       CustomWidget.showInternetDialog(context);
//       // showDialog(
//       //     context: context,
//       //     builder: (context) {
//       //       return AlertDialog(
//       //         title: const Text("Connection Lost"),
//       //         content: const Text("Please check your internet connection"),
//       //         actions: [
//       //           MaterialButton(
//       //             onPressed: () {
//       //               Navigator.pushAndRemoveUntil(
//       //                   context,
//       //                   MaterialPageRoute(
//       //                       builder: (context) => const MainPage()),
//       //                       (route) => false);
//       //             },
//       //             child: const Text("Ok"),
//       //           )
//       //         ],
//       //       );
//       //     });
//     } else {
//       earnedCertificate = await candidateRestRequest.getCertificate(context);
//       setState(() {
//         loaded = true;
//         loading = false;
//         textTemplate = prefs.getString('certificate_text')!;
//         subjectTemplate = prefs.getString('certificate_subject')!;
//       });
//     }
//   }
//
//   // Add a function to open the certificate URL in a web-view
//   void openCertificateWebView(BuildContext context, String certificateFileName,
//       String courseName) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) =>
//             Scaffold(
//               appBar: AppBar(
//                 title: const Text(
//                   "Certificate",
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1.2,
//                   ),
//                 ),
//                 backgroundColor: Colors.white,
//                 iconTheme: const IconThemeData(color: Colors.black),
//                 actions: <Widget>[
//                   IconButton(
//                     icon: const Icon(Icons.share),
//                     onPressed: () {
//                       shareCertificate(
//                           context, certificateFileName, courseName);
//                     },
//                     tooltip: 'Share Certificate',
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.download),
//                     onPressed: () {
//                       downloadCertificate(
//                           context, certificateFileName, courseName);
//                     },
//                     tooltip: 'Download Certificate',
//                   ),
//                 ],
//                 bottom: PreferredSize(
//                   preferredSize: const Size.fromHeight(4.0),
//                   child: Container(
//                     color: Colors.grey[300],
//                     height: 1.0,
//                   ),
//                 ),
//               ),
//               body: CertificateWebView(certificateFileName),
//             ),
//       ),
//     );
//   }
//
//   void shareCertificate(BuildContext context, String certificateUrl,
//       String courseName) {
//     String text = '$textTemplate\n\n$certificateUrl';
//     String subject = '$subjectTemplate $courseName';
//
//     if (Theme
//         .of(context)
//         .platform == TargetPlatform.iOS) {
//       Share.share(text, subject: subject);
//     } else {
//       Future.delayed(Duration.zero, () {
//         Share.share(text, subject: subject);
//       });
//     }
//   }
//
//   void downloadCertificate(BuildContext context, String certificateFileName, String courseName) async {
//     var url = Uri.parse(certificateFileName);
//     try {
//       var response = await http.get(url);
//
//       if (response.statusCode == 200) {
//         // Save to public Downloads folder
//         Directory downloadsDir = Directory('/storage/emulated/0/Download/Datamites/$courseName');
//         if (!await downloadsDir.exists()) {
//           await downloadsDir.create(recursive: true);
//         }
//
//         String filePath = '${downloadsDir.path}/certificate.pdf';
//         File file = File(filePath);
//
//         int count = 1;
//         while (await file.exists()) {
//           filePath = '${downloadsDir.path}/certificate($count).pdf';
//           file = File(filePath);
//           count++;
//         }
//
//         await file.writeAsBytes(response.bodyBytes);
//
//         if (kDebugMode) {
//           print("Certificate downloaded at: ${file.path}");
//         }
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Certificate downloaded to: ${file.path}'),
//             duration: const Duration(seconds: 4),
//           ),
//         );
//
//         // Optional: Open it or trigger media scan
//         await OpenFilex.open(file.path);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Failed to download the Certificate'),
//             duration: Duration(seconds: 2),
//           ),
//         );
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print("Download failed: $e");
//       }
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Something went wrong during download'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//     }
//   }
//
//   // void downloadCertificate(BuildContext context, String certificateFileName,
//   //     String courseName) async {
//   //   var url = Uri.parse(certificateFileName);
//   //   try {
//   //     var response = await http.get(url);
//   //
//   //     if (response.statusCode == 200) {
//   //       // Directory? appDocDir = await getExternalStorageDirectory();
//   //       Directory? appDocDir = Platform.isAndroid
//   //           ? await getExternalStorageDirectory() //FOR ANDROID
//   //           : await getApplicationSupportDirectory(); //FOR iOS
//   //       String? appDocPath = appDocDir?.path;
//   //
//   //       // Create a new folder if it doesn't exist
//   //       Directory folder = Directory('$appDocPath/Skillogic/$courseName');
//   //       if (!await folder.exists()) {
//   //         folder.createSync(recursive: true);
//   //       }
//   //
//   //       // Clean the courseName to make it suitable for a file name
//   //       String cleanedFileName = '$courseName/certificate.pdf';
//   //       File file = File('$appDocPath/Skillogic/$cleanedFileName');
//   //
//   //       // Check if the file already exists
//   //       int count = 1;
//   //       while (await file.exists()) {
//   //         cleanedFileName =
//   //         '$courseName/certificate($count).pdf'; // Append count to avoid overwriting
//   //         file = File('$appDocPath/Skillogic/$cleanedFileName');
//   //         count++;
//   //       }
//   //
//   //       await file.writeAsBytes(response.bodyBytes);
//   //       if (kDebugMode) {
//   //         print("Certificate downloaded at: ${file.path}");
//   //       }
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(
//   //           content: Text('Certificate downloaded at: ${file.path}'),
//   //           duration: const Duration(seconds: 5),
//   //         ),
//   //       );
//   //     } else {
//   //       if (kDebugMode) {
//   //         print("Failed to download certificate. Status code: ${response
//   //             .statusCode}");
//   //       }
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(
//   //           content: Text('Failed to download the Certificate'),
//   //           duration: Duration(seconds: 2),
//   //         ),
//   //       );
//   //     }
//   //   } catch (e) {
//   //     if (kDebugMode) {
//   //       print("Failed to download certificate: $e");
//   //     }
//   //   }
//   // }
//
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
//     loadData();
//     _getUserDetail();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xfff6f6f6),
//       appBar: CustomWidget.getSkillogicAppBar(context, userModel, 1),
//       body: Stack(
//         children: [
//           // Check if data is loaded
//           if (loaded && earnedCertificate.isEmpty)
//             Center(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   // This will center the column vertically
//                   children: [
//                     const Text("No any certificate found"),
//                     const SizedBox(
//                       height: 8,
//                     ),
//                     MaterialButton(
//                       onPressed: () {
//                         loadData();
//                       },
//                       color: MainColor.skillogicRed,
//                       child: const Text(
//                         "Refresh",
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             )
//           else
//             SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (earnedCertificate.isNotEmpty)
//                     const Padding(
//                       padding: EdgeInsets.fromLTRB(16.0, 16.0, 0, 0),
//                       child: Text(
//                         "Certificates",
//                         style: TextStyle(
//                             fontSize: 22, fontWeight: FontWeight.w600),
//                       ),
//                     ),
//                   if (loaded && earnedCertificate.isNotEmpty)
//                     for (CertificateModel certificate in earnedCertificate)
//                       GestureDetector(
//                         onTap: () {
//                           openCertificateWebView(
//                               context, certificate.certificate_file_name,
//                               certificate.course_name);
//                         },
//                         child: Container(
//                           margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
//                           padding: const EdgeInsets.all(8.0),
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(8.0),
//                             color: Colors.white,
//                           ),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Container(
//                                 width: 60,
//                                 height: 70,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(8.0),
//                                   color: Colors.grey[200],
//                                 ),
//                                 child: Image.asset(
//                                   'assets/skillogic_certificate.jpg',
//                                   fit: BoxFit.fill,
//                                 ),
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       certificate.course_name,
//                                       style: const TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                     // const SizedBox(height: 16),
//                                     // Align(
//                                     //   alignment: Alignment.centerRight,
//                                     //   child: Text(
//                                     //     certificate.created_date,
//                                     //     style: const TextStyle(
//                                     //       fontSize: 12,
//                                     //       color: Colors.grey,
//                                     //     ),
//                                     //   ),
//                                     // ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                 ],
//               ),
//             ),
//           if (loading)
//             const SizedBox(
//               width: double.infinity,
//               height: double.infinity,
//               child: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
//
// class CertificateWebView extends StatefulWidget {
//   final String certificateFileName;
//
//   CertificateWebView(this.certificateFileName);
//
//   @override
//   _CertificateWebViewState createState() => _CertificateWebViewState();
// }
//
// class _CertificateWebViewState extends State<CertificateWebView> {
//   bool _isLoading = true;
//   late final WebViewController _controller;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//     ..setNavigationDelegate(NavigationDelegate(
//       onPageFinished: (url) {
//         setState(() {
//           _isLoading = false;
//         });
//       },
//     )
//     )..loadRequest(Uri.parse("https://docs.google.com/gview?embedded=true&url=${widget.certificateFileName}"));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         WebViewWidget(
//           controller:_controller,
//           gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
//             Factory<VerticalDragGestureRecognizer>(
//                   () => VerticalDragGestureRecognizer(),
//             ),
//           },
//
//         ),
//         if (_isLoading)
//           const SizedBox(
//             width: double.infinity,
//             height: double.infinity,
//             child: Center(
//               child: CircularProgressIndicator(),
//             ),
//           )
//       ],
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skillogic/widgets/CustomWidget.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../helper/user_details.dart';
import '../../model/user_model.dart';
import '../../service/enrolled_certificate_service.dart';

class EnrolledCertificate extends StatefulWidget {
  const EnrolledCertificate({super.key});

  @override
  State<EnrolledCertificate> createState() => _EnrolledCertificateState();
}

class _EnrolledCertificateState extends State<EnrolledCertificate> {
  var userDetails = UserDetails();
  UserModel? userModel;

  _getUserDetail() async {
    userModel = await userDetails.getDetail();
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserDetail();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EnrolledCertificateProvider>(
        context,
        listen: false,
      ).getCandidateCertificate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomWidget.getSkillogicAppBar(context, userModel, 1),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Consumer<EnrolledCertificateProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return Center(child: CircularProgressIndicator());
              }
              if (provider.certificates.isEmpty) {
                return Center(
                  child: Text(
                    "No Certificates Available",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                );
              }
              final certificate = provider.certificates.first;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Certificates",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CertificateView(
                            certificateLink: certificate.certificateFileName,
                            courseName: certificate.courseName,
                          ),
                        ),
                      );
                    },
                    child:
                    certificate.courseName.isNotEmpty &&
                        certificate.certificateFileName.isNotEmpty
                        ? Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: BoxBorder.all(
                          color: Colors.black12,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          //Icon(Icons.workspace_premium_outlined,size:MediaQuery.of(context).size.height*0.08,color:Colors.redAccent),
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black12,
                                    offset: Offset(1,4),blurRadius:8
                                ),
                              ],
                            ),
                            height: 70,
                            width: 60,
                            child: ClipRRect(
                              child: Image.asset(
                                "assets/skillogic_certificate.jpg",
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              certificate.courseName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                        : SizedBox(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class CertificateView extends StatefulWidget {
  final String certificateLink;
  final String courseName;

  const CertificateView({
    super.key,
    required this.certificateLink,
    required this.courseName,
  });

  @override
  State<CertificateView> createState() => _CertificateViewState();
}

class _CertificateViewState extends State<CertificateView> {
  bool _isLoading = true;

  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(
        Uri.parse(
          "https://docs.google.com/gview?embedded=true&url=${widget.certificateLink}",
        ),
      );
  }

  void shareCertificate() {
    String text = 'Please find my certificate.\n\n${widget.certificateLink}';

    String subject = 'Certificate - ${widget.courseName}';

    if (Theme.of(context).platform == TargetPlatform.iOS) {
      // Share.share(
      //   text,
      //   subject: subject,
      // );
      SharePlus.instance.share(ShareParams(text: text, subject: subject));
    } else {
      Future.delayed(Duration.zero, () {
        // Share.share(
        //   text,
        //   subject: subject,
        // );
        SharePlus.instance.share(ShareParams(text: text, subject: subject));
      });
    }
  }

  void downloadCertificate() async {
    var url = Uri.parse(widget.certificateLink);

    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        Directory downloadsDir;

        if (Platform.isAndroid) {
          downloadsDir = Directory(
            '/storage/emulated/0/Download/Datamites/${widget.courseName}',
          );

          if (!await downloadsDir.exists()) {
            await downloadsDir.create(recursive: true);
          }
        } else {
          downloadsDir = await getApplicationDocumentsDirectory();
        }
        String filePath = '${downloadsDir.path}/certificate.pdf';
        File file = File(filePath);
        int count = 1;
        while (await file.exists()) {
          filePath = '${downloadsDir.path}/certificate($count).pdf';

          file = File(filePath);

          count++;
        }

        await file.writeAsBytes(response.bodyBytes);
        if (kDebugMode) {
          print("Certificate downloaded at: ${file.path}");
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Certificate downloaded to: ${file.path}'),
              duration: const Duration(seconds: 4),
            ),
          );
        }
        await OpenFilex.open(file.path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to download the Certificate')),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Download failed: $e");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong during download')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Certificate"),

          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: shareCertificate,
            ),
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: downloadCertificate,
            ),
          ],
        ),

        body: Stack(
          children: [
            WebViewWidget(
              controller: _controller,

              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<VerticalDragGestureRecognizer>(
                      () => VerticalDragGestureRecognizer(),
                ),
              },
            ),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
