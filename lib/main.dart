import 'package:firebase_analytics/firebase_analytics.dart';
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

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDquuyNNSCkcEo2tfm0ZiBR0Ki6HecQKfg",
      appId: "1:1048427097869:android:f31d5d4d08eb41589f0a44",
      messagingSenderId: "1048427097869",
      projectId: "skillogic-a5248",
    ),
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

  var topic = "datamites-v3-app-ios";
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