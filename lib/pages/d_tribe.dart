import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DTribePage extends StatefulWidget {
  const DTribePage({Key? key}) : super(key: key);

  @override
  State<DTribePage> createState() => _DTribePageState();
}

class _DTribePageState extends State<DTribePage> {
  late final WebViewController _controller;
  @override
  void initState() {
    super.initState();
    // Enable virtual display.
   // if (Platform.isAndroid) WebView.platform = AndroidWebView();

  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(
        controller:_controller,
        // initialUrl: 'https://tribe.datamites.com/',
        // javascriptMode: JavascriptMode.unrestricted
        );
  }
}
