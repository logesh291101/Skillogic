import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../model/user_model.dart';
import '../../../widgets/CustomWidget.dart';

class VimeoIframe extends StatefulWidget {
  static const routeName = '/vimeo-iframe';

  final String? url;

  const VimeoIframe({Key? key, required this.url}) : super(key: key);

  @override
  State<VimeoIframe> createState() => _VimeoIframeState();
}

class _VimeoIframeState extends State<VimeoIframe> {
  late final WebViewController _controller;
  var loadingPercentage = 0;
  UserModel? userModel;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white);
    _loadVimeoIframe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomWidget.getSkillogicAppBar(context, userModel, 1),
      body: Stack(
        children: [
          WebViewWidget(
           controller:_controller,
          ),
        ],
      ),
    );
  }

  void _loadVimeoIframe() {
    String iframeUrl = widget.url!;
    String htmlContent = '''
      <html>
      <head>
        <style>
          body, html, iframe {
            height: 100%;
            width: 100%;
            margin: 0;
            padding: 0;
          }
        </style>
      </head>
      <body>
        <iframe src="$iframeUrl?loop=0&autoplay=0" frameborder="0" allow="fullscreen" allowfullscreen></iframe>
      </body>
      </html>
    ''';

    _controller.loadHtmlString(htmlContent);

    // _controller.loadUrl(Uri.dataFromString(
    //   htmlContent,
    //   mimeType: 'text/html',
    //   encoding: Encoding.getByName('utf-8')!,
    // ).toString());
  }
}
