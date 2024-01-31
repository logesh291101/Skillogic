import 'dart:developer';
import 'dart:io';

import 'package:datamites/pages/qr_scanner/success_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../helper/color.dart';
import '../main_page.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({Key? key}) : super(key: key);

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool showPlay = false;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  void didUpdateWidget(covariant QRScanner oldWidget) {
    startCamera();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
              flex: 4,
              child: Stack(
                children: [
                  _buildQrView(context),
                  if(showPlay) Container(
                    height: double.infinity,
                    width: double.infinity,
                    child: Center(
                      child: FloatingActionButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100)),
                          onPressed: () async {
                            await controller?.resumeCamera();
                            showPlay = false;
                            setState(() {});
                          },
                          backgroundColor: MainColor.darkOrange,
                          child: const Icon(
                            Icons.play_arrow,
                            size: 24,
                          )),
                    ),
                  ),
                  SizedBox(
                    height: double.infinity,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          margin: const EdgeInsets.all(16),
                          child: FloatingActionButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100)),
                              backgroundColor: MainColor.darkOrange,
                              onPressed: () async {
                                await controller?.toggleFlash();
                                setState(() {});
                              },
                              child: FutureBuilder(
                                future: controller?.getFlashStatus(),
                                builder: (context, snapshot) {
                                  return Icon(
                                      snapshot.data == true
                                          ? Icons.flash_on
                                          : Icons.flash_off,
                                      size: 24);
                                  // Text('Flash: ${snapshot.data}');
                                },
                              )),
                        ),
                        Container(
                          height: 60,
                          width: 60,
                          margin: const EdgeInsets.all(16),
                          child: FloatingActionButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100)),
                              onPressed: () async {
                                await controller?.flipCamera();
                                setState(() {});
                              },
                              backgroundColor: MainColor.darkOrange,
                              child: FutureBuilder(
                                future: controller?.getCameraInfo(),
                                builder: (context, snapshot) {
                                  if (snapshot.data != null) {
                                    return const Icon(
                                      Icons.flip_camera_ios_outlined,
                                      size: 24,
                                    );
                                    // Text(
                                    //   'Camera facing ${describeEnum(snapshot.data!)}');
                                  } else {
                                    return const CircularProgressIndicator();
                                  }
                                },
                              )),
                        ),

                      ],
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 300.0
        : 400.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlayMargin: EdgeInsets.zero,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.pauseCamera();
    controller.resumeCamera();
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        if (result != null) {
          goToSuccessPage(scanData);
        }
      });
    });
  }

  void startCamera(){
    print("Screen started");
    controller?.resumeCamera();
    setState(() {
      showPlay = false;
    });
  }

  void goToSuccessPage(Barcode scanData) async {
    String? code = scanData.code;

    if (code != null) {
      print('Scanned result ${result!.code}');
      if (code.contains("https://www.datamites.com") || true) {
        controller?.pauseCamera();
        setState(() {
          showPlay = true;
        });
        await Navigator.push(context,
            MaterialPageRoute(builder: (context) => SuccessScreen(code: code)));
        startCamera();
      }
    }
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
          (route) => false);
      dispose();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
    super.dispose();
  }
}
