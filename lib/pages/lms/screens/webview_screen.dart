import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:webview_flutter/webview_flutter.dart' as webview;
import 'package:webview_flutter/webview_flutter.dart';
import '../constants.dart';
import '../lms_model/app_logo.dart';

class WebViewScreen extends StatefulWidget {
  static const routeName = '/webview';

  final String url;

  const WebViewScreen({Key? key, required this.url}) : super(key: key);

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  final _controllerTwo = StreamController<AppLogo>();

  fetchMyLogo() async {
    var url = '$BASE_URL/api/app_logo';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var logo = AppLogo.fromJson(jsonDecode(response.body));
        _controllerTwo.add(logo);
      }
    } catch (error) {
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMyLogo();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        elevation: 0.3,
        iconTheme: const IconThemeData(
          color: kSecondaryColor,
        ),
        title: StreamBuilder<AppLogo>(
          stream: _controllerTwo.stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            } else {
              if (snapshot.error != null) {
                return const Text("Error Occurred");
              } else {
                return CachedNetworkImage(
                  imageUrl: snapshot.data!.darkLogo.toString(),
                  fit: BoxFit.contain,
                  height: 27,
                );
              }
            }
          },
        ),
        actions: <Widget>[
          NavigationControls(),
        ],
        backgroundColor: kBackgroundColor,
      ),
      body: WebViewWidget(
        controller:_controller,
      )
    );
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Back button pressed')),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Forward button pressed')),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.replay),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reload button pressed')),
            );
          },
        ),
      ],
    );
  }
}

//   @override
//   void initState() {
//     super.initState();
//     fetchMyLogo();
//
//     // #docregion platform_features
//     late final PlatformWebViewControllerCreationParams params;
//     params = const PlatformWebViewControllerCreationParams();
//
//     final WebViewController controller =
//         WebViewController.fromPlatformCreationParams(params);
//     // #enddocregion platform_features
//
//     controller
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setBackgroundColor(const Color(0xFFFFFFFF))
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onProgress: (int progress) {
//             debugPrint('WebView is loading (progress : $progress%)');
//           },
//           onPageStarted: (String url) {
//             debugPrint('Page started loading: $url');
//           },
//           onPageFinished: (String url) {
//             debugPrint('Page finished loading: $url');
//           },
//           onWebResourceError: (WebResourceError error) {
//             debugPrint('''
// Page resource error:
//   code: ${error.errorCode}
//   description: ${error.description}
//   errorType: ${error.errorType}
//   isForMainFrame: ${error.isForMainFrame}
//           ''');
//           },
//         ),
//       )
//       ..addJavaScriptChannel(
//         'Toaster',
//         onMessageReceived: (JavaScriptMessage message) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(message.message)),
//           );
//         },
//       )
//       ..loadRequest(Uri.parse(widget.url));
//     // #enddocregion platform_features
//
//     _controller = controller;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.green,
//       appBar:AppBar(
//         elevation: 0.3,
//         iconTheme: const IconThemeData(
//           color: kSecondaryColor, //change your color here
//         ),
//         title: StreamBuilder<AppLogo>(
//           stream: _controllerTwo.stream,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Container();
//             } else {
//               if (snapshot.error != null) {
//                 return const Text("Error Occured");
//               } else {
//                 return CachedNetworkImage(
//                   imageUrl: snapshot.data!.darkLogo.toString(),
//                   fit: BoxFit.contain,
//                   height: 27,
//                 );
//               }
//             }
//           },
//         ),
//         actions: <Widget>[
//           NavigationControls(webViewController: _controller),
//         ],
//         backgroundColor: kBackgroundColor,
//       ),
//       body: WebViewWidget(controller: _controller,),
//     );
//   }
//
//   Widget favoriteButton() {
//     return FloatingActionButton(
//       onPressed: () async {
//         final String? url = await _controller.currentUrl();
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Favorited $url')),
//           );
//         }
//       },
//       child: const Icon(Icons.favorite),
//     );
//   }
// }
//
// class NavigationControls extends StatelessWidget {
//   const NavigationControls({super.key, required this.webViewController});
//
//   final WebViewController webViewController;
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: <Widget>[
//         IconButton(
//           icon: const Icon(Icons.arrow_back_ios),
//           onPressed: () async {
//             if (await webViewController.canGoBack()) {
//               await webViewController.goBack();
//             } else {
//               if (context.mounted) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('No back history item')),
//                 );
//               }
//             }
//           },
//         ),
//         IconButton(
//           icon: const Icon(Icons.arrow_forward_ios),
//           onPressed: () async {
//             if (await webViewController.canGoForward()) {
//               await webViewController.goForward();
//             } else {
//               if (context.mounted) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('No forward history item')),
//                 );
//               }
//             }
//           },
//         ),
//         IconButton(
//           icon: const Icon(Icons.replay),
//           onPressed: () => webViewController.reload(),
//         ),
//       ],
//     );
//   }
// }
