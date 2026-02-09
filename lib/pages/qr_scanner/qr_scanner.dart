// import 'dart:convert';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:skillogic/pages/qr_scanner/success_screen.dart';
//
// class QRScanner extends StatefulWidget {
//   const QRScanner({Key? key}) : super(key: key);
//
//   @override
//   State<QRScanner> createState() => _QRScannerState();
// }
//
// class _QRScannerState extends State<QRScanner> {
//   late MobileScannerController controller;
//   bool showPlay = false;
//   late AudioPlayer audioPlayer;
//   bool isHandlingCode = false;
//   TorchState torchState = TorchState.off;
//
//   @override
//   void initState() {
//     super.initState();
//     controller = MobileScannerController();
//     audioPlayer = AudioPlayer();
//   }
//
//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar:AppBar(leading:IconButton(onPressed:() {
//         Navigator.pop(context);
//       }, icon:Icon(Icons.arrow_back))),
//       body: Stack(
//         children: [
//           // QR Scanner View
//           MobileScanner(
//             controller: controller,
//             onDetect: (BarcodeCapture capture) async {
//               final barcode = capture.barcodes.first;
//               if (!isHandlingCode && barcode.rawValue != null) {
//                 isHandlingCode = true;
//                 await goToSuccessPage(barcode.rawValue!);
//                 isHandlingCode = false;
//               }
//             },
//           ),
//
//           // Multicolor rounded corner overlay
//           Align(
//             alignment: Alignment.center,
//             child: Container(
//               width: MediaQuery.of(context).size.width * 0.7,
//               height: MediaQuery.of(context).size.width * 0.7,
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.transparent),
//               ),
//               child: CustomPaint(
//                 painter: MultiColorCornerPainter(),
//               ),
//             ),
//           ),
//
//           // Floating Action Buttons
//           Positioned(
//             top: 40,
//             right: 16,
//             child: Column(
//               children: [
//                 FloatingActionButton(
//                   heroTag: 'flash',
//                   backgroundColor: Colors.orange,
//                   onPressed: () async {
//                     await controller.toggleTorch();
//                     setState(() {
//                       torchState = torchState == TorchState.off
//                           ? TorchState.on
//                           : TorchState.off;
//                     });
//                   },
//                   child: Icon(
//                     torchState == TorchState.off ? Icons.flash_off : Icons.flash_on,
//                     size: 24,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 FloatingActionButton(
//                   heroTag: 'camera',
//                   backgroundColor: Colors.orange,
//                   onPressed: () => controller.switchCamera(),
//                   child: const Icon(Icons.flip_camera_ios_outlined, size: 24, color: Colors.white),
//                 ),
//               ],
//             ),
//           ),
//
//           // Bottom Info
//           Positioned(
//             bottom: 0,
//             child: Container(
//               width: MediaQuery.of(context).size.width,
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               decoration: BoxDecoration(
//                 color: Colors.black87,
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(16),
//                   topRight: Radius.circular(16),
//                 ),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: const [
//                   Text(
//                     "Scan QR Code for Attendance",
//                     style: TextStyle(color: Colors.white, fontSize: 18),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     "Datamites",
//                     style: TextStyle(color: Colors.white70, fontSize: 16),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _playBeepSound() async {
//     await audioPlayer.play(UrlSource('https://firebasestorage.googleapis.com/v0/b/datamties-v3-a59d3.appspot.com/o/beep.mp3?alt=media&token=b2f25d28-042b-4d8a-a392-0dbd37db6596'));
//   }
//
//   Future<void> goToSuccessPage(String code) async {
//     if (kDebugMode) {
//       print('Scanned result $code');
//     }
//
//     try {
//       _playBeepSound();
//
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? userEmail = prefs.getString('userEmail');
//
//       if (userEmail != null) {
//         bool isRecorded = await recordAttendance(userEmail, code);
//         if (isRecorded) {
//           await Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => SuccessScreen(code: code)),
//           );
//         } else {
//           if (kDebugMode) print('Failed to record attendance');
//         }
//       } else {
//         if (kDebugMode) print('User email not found in shared preferences');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error in goToSuccessPage: $e');
//       }
//     }
//   }
//
//   Future<bool> recordAttendance(String userEmail, String code) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String candidate_portal_url = prefs.getString("candidate_portal_url") ?? "";
//     final url = "${candidate_portal_url}dm-api/CandidateAttendance";
//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {"Content-Type": "application/json"},
//         body: json.encode({
//           "email": userEmail,
//           "code": json.decode(code),
//         }),
//       );
//
//       var responseJson = json.decode(response.body);
//
//       if (response.statusCode == 200 && responseJson["statuscode"] == 200) {
//         Fluttertoast.showToast(
//           msg: responseJson["message"],
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.BOTTOM,
//           backgroundColor: Colors.green,
//           textColor: Colors.white,
//           fontSize: 16.0,
//         );
//         return true;
//       } else {
//         Fluttertoast.showToast(
//           msg: responseJson["message"] ?? "Unknown error",
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.BOTTOM,
//           backgroundColor: Colors.red,
//           textColor: Colors.white,
//           fontSize: 16.0,
//         );
//         return false;
//       }
//     } catch (e) {
//       Fluttertoast.showToast(
//         msg: "Error while sending request, Try Again!!",
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//         fontSize: 16.0,
//       );
//       if (kDebugMode) {
//         print('Error sending request: $e');
//       }
//       return false;
//     }
//   }
// }
//
// class MultiColorCornerPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..strokeWidth = 6
//       ..style = PaintingStyle.stroke;
//
//     paint.color = Colors.blue;
//     canvas.drawLine(Offset(0, 16), Offset(0, 0), paint);
//     canvas.drawLine(Offset(0, 0), Offset(16, 0), paint);
//
//     paint.color = Colors.orange;
//     canvas.drawLine(Offset(size.width - 16, 0), Offset(size.width, 0), paint);
//     canvas.drawLine(Offset(size.width, 0), Offset(size.width, 16), paint);
//
//     paint.color = Colors.orange;
//     canvas.drawLine(Offset(0, size.height - 16), Offset(0, size.height), paint);
//     canvas.drawLine(Offset(0, size.height), Offset(16, size.height), paint);
//
//     paint.color = Colors.blue;
//     canvas.drawLine(
//         Offset(size.width - 16, size.height), Offset(size.width, size.height),
//         paint);
//     canvas.drawLine(
//         Offset(size.width, size.height - 16), Offset(size.width, size.height),
//         paint);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }


// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:skillogic/pages/qr_scanner/success_screen.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({Key? key}) : super(key: key);

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  MobileScannerController? controller;
  bool showPlay = false;
  late AudioPlayer audioPlayer;
  bool isHandlingCode = false;
  bool isFlashOn = false;
  bool hasPermission = false;
  double? lat, long;
  double _zoomLevel = 1.0;
  double _baseScale = 1.0;

  Future<void> getCameraPermission(BuildContext context) async {
    if (!mounted) return;

    PermissionStatus status = await Permission.camera.status;
    log("Camera permission status (initial): $status");

    // On iOS, handle different permission states
    if (Platform.isIOS) {
      // iOS specific handling
      if (status.isGranted) {
        // Already granted
        log("iOS: Permission already granted");
        if (mounted) {
          setState(() {
            hasPermission = true;
          });
          if (controller != null) {
            await controller?.start();
          }
        }
      } else if (status.isLimited) {
        // iOS 14+ limited access - treat as granted
        log("iOS: Permission limited (treating as granted)");
        if (mounted) {
          setState(() {
            hasPermission = true;
          });
          if (controller != null) {
            await controller?.start();
          }
        }
      } else if (status.isPermanentlyDenied) {
        // Permanently denied - show settings dialog
        log("iOS: Permission permanently denied - showing settings dialog");
        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) => Dialog(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Camera Permission Required",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Camera permission is permanently denied. Please enable it in settings",
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        MaterialButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Cancel"),
                        ),
                        MaterialButton(
                          onPressed: () async {
                            await openAppSettings();
                            Navigator.pop(context);
                          },
                          child: Text("Open Settings"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      } else {
        // Status is denied or restricted - try to request permission
        // On iOS, if this is the first request, it will show the native dialog
        // If it was previously denied, request() won't show dialog and will return denied/permanentlyDenied
        log("iOS: Permission denied/restricted - requesting permission");

        // Store the initial status to check if it changes
        PermissionStatus initialStatus = status;

        // Request permission - this should show native dialog if never requested before
        status = await Permission.camera.request();
        log("iOS: Permission status immediately after request: $status");

        // If status didn't change and is still denied, it means the dialog didn't show
        // (permission was previously denied)
        if (status.isDenied && initialStatus.isDenied) {
          log("iOS: Permission still denied - dialog likely didn't show (previously denied)");
          // Show settings dialog since native dialog won't appear
          if (mounted) {
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Camera Permission Required"),
                content: Text(
                  "Camera access is required to scan QR codes. Please enable it in your device Settings > Privacy & Security > Camera.",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await openAppSettings();
                    },
                    child: Text("Open Settings"),
                  ),
                ],
              ),
            );
          }
        } else if (status.isGranted) {
          log("iOS: Permission granted after request");
          if (mounted) {
            setState(() {
              hasPermission = true;
            });
            if (controller != null) {
              await controller?.start();
            }
          }
        } else if (status.isLimited) {
          log("iOS: Permission limited after request");
          if (mounted) {
            setState(() {
              hasPermission = true;
            });
            if (controller != null) {
              await controller?.start();
            }
          }
        } else if (status.isPermanentlyDenied) {
          log("iOS: Permission permanently denied after request");
          if (mounted) {
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Camera Permission Required"),
                content: Text(
                  "Camera access is required to scan QR codes. Please enable it in your device Settings > Privacy & Security > Camera.",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await openAppSettings();
                    },
                    child: Text("Open Settings"),
                  ),
                ],
              ),
            );
          }
        }
      }
    } else {
      // Android handling (keep existing logic)
      if (status.isDenied) {
        status = await Permission.camera.request();
      }
      if (status.isGranted) {
        if (mounted) {
          setState(() {
            hasPermission = true;
          });
          if (controller != null) {
            await controller?.start();
          }
        }
      } else if (status.isPermanentlyDenied) {
        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) => Dialog(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Camera Permission Required",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Camera permission is permanently denied. Please enable it in settings",
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        MaterialButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Cancel"),
                        ),
                        MaterialButton(
                          onPressed: () async {
                            await openAppSettings();
                            Navigator.pop(context);
                          },
                          child: Text("Open Settings"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> getLatLong() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    lat = position.latitude;
    long = position.longitude;
    log("$lat------------------$long");
  }

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    controller = MobileScannerController();
    // Delay permission check to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        getCameraPermission(context);
      }
    });
    getLatLong();
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.stop();
    }
    controller?.start();
  }

  @override
  void dispose() {
    controller?.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  Widget _buildQrView(BuildContext context) {
    if (!hasPermission) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onScaleStart: (details) {
        // Store current zoom as base for both pinch and single-finger drag
        _baseScale = _zoomLevel;
      },
      onScaleUpdate: (details) {
        if (details.pointerCount == 2) {
          // Pinch gesture - two fingers
          setState(() {
            _zoomLevel = (_baseScale * details.scale).clamp(1.0, 4.0);
          });
        } else if (details.pointerCount == 1) {
          // Single finger drag: use vertical delta to adjust zoom
          final zoomDelta = -details.focalPointDelta.dy / 150; // drag up = zoom in
          setState(() {
            _zoomLevel = (_zoomLevel + zoomDelta).clamp(1.0, 4.0);
          });
        }

        // Apply zoom to controller
        if (controller != null) {
          try {
            controller!.setZoomScale(_zoomLevel);
            log("Zoom level: $_zoomLevel");
          } catch (e) {
            log("Zoom not available: $e");
          }
        }
      },
      onScaleEnd: (details) {
        _baseScale = _zoomLevel;
      },
      child: MobileScanner(
        controller: controller,
        onDetect: (BarcodeCapture capture) async {
          final barcode = capture.barcodes.first;
          if (!isHandlingCode && barcode.rawValue != null && mounted) {
            setState(() {
              isHandlingCode = true;
            });

            // Stop camera to prevent multiple scans
            await controller?.stop();

            try {
              await goToSuccessPage(barcode.rawValue!);
            } finally {
              // Resume camera and reset handling state
              if (mounted) {
                await controller?.start();
                setState(() {
                  isHandlingCode = false;
                });
              }
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scanAreaSize = MediaQuery.of(context).size.width * 0.7;

    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          // QR Scanner View
          _buildQrView(context),

          // Blur overlay with cutout for scanning area
          Positioned.fill(
            child: ClipPath(
              clipper: _ScanAreaClipper(
                scanAreaSize: scanAreaSize,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
          ),

          // Multicolor rounded corner overlay - centered
          Center(
            child: Container(
              width: scanAreaSize,
              height: scanAreaSize,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent),
              ),
              child: CustomPaint(
                painter: MultiColorCornerPainter(),
              ),
            ),
          ),

          // Floating Action Buttons
          Positioned(
            top: 40,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'flash',
                  backgroundColor: Colors.orange,
                  onPressed: () async {
                    await controller?.toggleTorch();
                    setState(() {
                      isFlashOn = !isFlashOn;
                    });
                  },
                  child: Icon(
                    isFlashOn ? Icons.flash_on : Icons.flash_off,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'camera',
                  backgroundColor: Colors.orange,
                  onPressed: () async {
                    await controller?.switchCamera();
                    setState(() {});
                  },
                  child: const Icon(
                      Icons.flip_camera_ios_outlined,
                      size: 24,
                      color: Colors.white),
                ),
              ],
            ),
          ),

          // Bottom Info
          Positioned(
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    "Scan QR Code for Attendance",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Skillogic",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _playBeepSound() async {
    await audioPlayer.play(UrlSource(
        'https://firebasestorage.googleapis.com/v0/b/datamties-v3-a59d3.appspot.com/o/beep.mp3?alt=media&token=b2f25d28-042b-4d8a-a392-0dbd37db6596'));
  }

  void _restartCamera() {
    if (mounted && controller != null) {
      controller!.start();
      setState(() {
        isHandlingCode = false;
      });
    }
  }

  Future<void> goToSuccessPage(String code) async {
    if (kDebugMode) {
      print('Scanned result $code');
    }

    try {
      _playBeepSound();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userEmail = prefs.getString('userEmail');

      if (userEmail != null) {
        bool isRecorded = await recordAttendance(userEmail, code);
        if (isRecorded) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SuccessScreen(code: code)),
          );
          // Camera will be resumed in the finally block of _onQRViewCreated
        } else {
          if (kDebugMode) print('Failed to record attendance');
          // Camera will be resumed in the finally block of _onQRViewCreated
        }
      } else {
        if (kDebugMode) print('User email not found in shared preferences');
        // Camera will be resumed in the finally block of _onQRViewCreated
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in goToSuccessPage: $e');
      }
      // Camera will be resumed in the finally block of _onQRViewCreated
    }
  }

  Future<bool> recordAttendance(String userEmail, String code) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? enrollmentNumber = prefs.getString("enrollment_number");
   String candidate_portal_url = prefs.getString("candidate_portal_url") ?? "";
     final url = "${candidate_portal_url}dm-api/CandidateAttendance";
    try {
      log("Before check---{$userEmail,$enrollmentNumber,$lat,$long,$code}");
      if (userEmail.isNotEmpty &&
          enrollmentNumber!.isNotEmpty &&
          code.isNotEmpty &&
          lat.toString().isNotEmpty &&
          long.toString().isNotEmpty) {
        log("After check---{$userEmail,$enrollmentNumber,$lat,$long,$code}");
        final response = await http.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            "email": userEmail,
            "brandId": 14,
            "enrollment_number": enrollmentNumber,
            "lat": lat,
            "long": long,
            "code": json.decode(code),
          }),
        );

        var responseJson = json.decode(response.body);

        if (response.statusCode == 200 && responseJson["statuscode"] == 200) {
          Fluttertoast.showToast(
            msg: responseJson["message"],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          return true;
        } else {
          Fluttertoast.showToast(
            msg: responseJson["message"] ?? "Unknown error",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          return false;
        }
      } else {
        Fluttertoast.showToast(
            msg: "Please scan the QR properly", gravity: ToastGravity.CENTER);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error while sending request, Try Again!!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      if (kDebugMode) {
        print('Error sending request: $e');
      }
      return false;
    }
    return false;
  }
}

// Clipper for creating a cutout in the blur overlay
class _ScanAreaClipper extends CustomClipper<Path> {
  final double scanAreaSize;

  _ScanAreaClipper({
    required this.scanAreaSize,
  });

  @override
  Path getClip(Size size) {
    // Calculate center position
    final scanAreaLeft = (size.width - scanAreaSize) / 2;
    final scanAreaTop = (size.height - scanAreaSize) / 2;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(scanAreaLeft, scanAreaTop, scanAreaSize, scanAreaSize),
          const Radius.circular(16),
        ),
      )
      ..fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class MultiColorCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    paint.color = Colors.blue;
    canvas.drawLine(Offset(0, 16), Offset(0, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(16, 0), paint);

    paint.color = Colors.orange;
    canvas.drawLine(Offset(size.width - 16, 0), Offset(size.width, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, 16), paint);

    paint.color = Colors.orange;
    canvas.drawLine(
        Offset(0, size.height - 16), Offset(0, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(16, size.height), paint);

    paint.color = Colors.blue;
    canvas.drawLine(Offset(size.width - 16, size.height),
        Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height - 16),
        Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
