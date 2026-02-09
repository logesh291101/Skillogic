import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../helper/user_details.dart';
import '../../../model/user_model.dart';

// class WebViewScreenIframe extends StatefulWidget {
//   static const routeName = '/webview-iframe';
//
//   final String? url;
//
//   const WebViewScreenIframe({Key? key, required this.url}) : super(key: key);
//
//   @override
//   State<WebViewScreenIframe> createState() => _WebViewScreenIframeState();
// }
//
// class _WebViewScreenIframeState extends State<WebViewScreenIframe> {
//   // final Completer<WebViewController> _controller =
//   //     Completer<WebViewController>();
//
//   late final WebViewController _controller;
//   var loadingPercentage = 0;
//   UserModel? userModel;

//   @override
//   void initState() {
//     super.initState();
//     // _controller = WebViewController()
//     //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
//     //   ..loadRequest(
//     //     Uri.dataFromString('''<html><body><iframe style="height: 100%;width:100%" src="${widget.url}" allowfullscreen></iframe></body></html>''',
//     //         mimeType: 'text/html'),
//     //   );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       appBar: CustomWidget.getDatamitesAppBar(context, userModel, 1),
//       body: Stack(
//         // children: [
//         //   WebViewWidget(
//         //     controller: _controller,
//         //   ),
//         // ],
//       ),
//     );
//   }
// }

class WebViewScreenIframe extends StatefulWidget {
  static const routeName = '/webview-iframe';

  final String? url;

  const WebViewScreenIframe({Key? key, required this.url}) : super(key: key);

  @override
  State<WebViewScreenIframe> createState() => _WebViewScreenIframeState();
}

class _WebViewScreenIframeState extends State<WebViewScreenIframe> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white);
    _loadHtml();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Iframe WebView'),
      ),
      body: WebViewWidget(
        controller: _controller,
        // initialUrl: 'about:blank',
        // onWebViewCreated: (WebViewController webViewController) {
        //   _controller = webViewController;
        //   _loadHtml();
        // },
      ),
    );
  }

  void _loadHtml() {
    String iframeUrl = widget.url ?? '';
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
        <iframe src="$iframeUrl" frameborder="0" allowfullscreen></iframe>
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
