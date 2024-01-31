import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'pages/main_page.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Handling a background message ${message.messageId}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Platform.isAndroid
  //     ? await Firebase.initializeApp(
  //       options: const FirebaseOptions(
  //         apiKey: AIzaSyAeA10m8WBRqTru7yuA7333o3oz0hdPGds,
  //         appId: 1:587203888035:android:71da06dd5ce7f02879d016,
  //         messagingSenderId: 587203888035,
  //         projectId: datamties-v3-a59d3
  //       ),
  //   )
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAeA10m8WBRqTru7yuA7333o3oz0hdPGds",
      appId: "1:587203888035:android:71da06dd5ce7f02879d016",
      messagingSenderId: "587203888035",
      projectId: "datamties-v3-a59d3",
    ),
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  var topic = "datamites-v3-app-ios";
  if (kDebugMode) {
    print("Subscribing to topic $topic");
  }
  await FirebaseMessaging.instance.subscribeToTopic(topic);
  if (kDebugMode) {
    print("Subscribed to topic $topic");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skillogic',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const MainPage(),
    );
  }
}