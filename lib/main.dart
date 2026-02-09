// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:skillogic/pages/lms/providers/auth.dart';
// import 'package:skillogic/pages/lms/providers/bundles.dart';
// import 'package:skillogic/pages/lms/providers/categories.dart';
// import 'package:skillogic/pages/lms/providers/course_forum.dart';
// import 'package:skillogic/pages/lms/providers/courses.dart';
// import 'package:skillogic/pages/lms/providers/misc_provider.dart';
// import 'package:skillogic/pages/lms/providers/my_bundles.dart';
// import 'package:skillogic/pages/lms/providers/my_courses.dart';
// import 'package:skillogic/pages/lms/screens/bundle_details_screen.dart';
// import 'package:skillogic/pages/lms/screens/bundle_list_screen.dart';
// import 'package:skillogic/pages/lms/screens/course_detail_screen.dart';
// import 'package:skillogic/pages/lms/screens/courses_screen.dart';
// import 'package:skillogic/pages/lms/screens/downloaded_course_list.dart';
// import 'package:skillogic/pages/lms/screens/lms_home_screen.dart';
// import 'package:skillogic/pages/lms/screens/my_bundle_courses_list_screen.dart';
// import 'package:skillogic/pages/lms/screens/sub_category_screen.dart';
// import 'package:skillogic/pages/lms/screens/tabs_screen.dart';
// import 'package:skillogic/provider/rating_provider_all.dart';
// import 'package:skillogic/service/handbook_service.dart';
// import 'package:skillogic/service/internship_batchDetails_service.dart';
// import 'pages/main_page.dart';
// import 'package:provider/provider.dart';
//
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   if (kDebugMode) {
//     print('Handling a background message ${message.messageId}');
//   }
// }
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   await Firebase.initializeApp(
//     options: const FirebaseOptions(
//       apiKey: "AIzaSyDquuyNNSCkcEo2tfm0ZiBR0Ki6HecQKfg",
//       appId: "1:1048427097869:android:f31d5d4d08eb41589f0a44",
//       messagingSenderId: "1048427097869",
//       projectId: "skillogic-a5248",
//     ),
//   );
//
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//   await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
//
//   var topic = "datamites-v3-app-ios";
//   await FirebaseMessaging.instance.subscribeToTopic(topic);
//   if (kDebugMode) {
//     print("Subscribed to topic $topic");
//   }
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (ctx) => Auth()),
//         ChangeNotifierProvider(create: (ctx) => Categories()),
//         ChangeNotifierProxyProvider<Auth, Courses>(
//           create: (ctx) => Courses([], []),
//           update: (ctx, auth, previousCourses) => Courses(
//             previousCourses?.items ?? [],
//             previousCourses?.topItems ?? [],
//           ),
//         ),
//         ChangeNotifierProxyProvider<Auth, MyCourses>(
//           create: (ctx) => MyCourses([], []),
//           update: (ctx, auth, previousMyCourses) => MyCourses(
//             previousMyCourses?.items ?? [],
//             previousMyCourses?.sectionItems ?? [],
//           ),
//         ),
//         ChangeNotifierProvider(create: (ctx) => Bundles()),
//         ChangeNotifierProvider(create: (ctx) => MyBundles()),
//         ChangeNotifierProvider(create: (ctx) => Languages()),
//         ChangeNotifierProvider(create: (ctx) => CourseForum()),
//         ChangeNotifierProvider(create: (ctx) => InternshipBatchProvider()),
//         ChangeNotifierProvider(create: (ctx) => HandbookProvider()),
//       ],
//       child: MaterialApp(
//         title: 'Skillogic',
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//           useMaterial3: true,
//           fontFamily: 'google_sans',
//         ),
//         home: const MainPage(),
//         routes: {
//           TabsScreen.routeName: (ctx) => const TabsScreen(),
//           LmsHomeScreen.routeName: (ctx) => const LmsHomeScreen(),
//           CoursesScreen.routeName: (ctx) => const CoursesScreen(),
//           CourseDetailScreen.routeName: (ctx) => const CourseDetailScreen(),
//           DownloadedCourseList.routeName: (ctx) => const DownloadedCourseList(),
//           SubCategoryScreen.routeName: (ctx) => const SubCategoryScreen(),
//           BundleListScreen.routeName: (ctx) => const BundleListScreen(),
//           BundleDetailsScreen.routeName: (ctx) => const BundleDetailsScreen(),
//           MyBundleCoursesListScreen.routeName: (ctx) =>
//           const MyBundleCoursesListScreen(),
//         },
//       ),
//     );
// }}

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skillogic/pages/home_page.dart';

import 'package:skillogic/pages/lms/providers/auth.dart';
import 'package:skillogic/pages/lms/providers/bundles.dart';
import 'package:skillogic/pages/lms/providers/categories.dart';
import 'package:skillogic/pages/lms/providers/course_forum.dart';
import 'package:skillogic/pages/lms/providers/courses.dart';
import 'package:skillogic/pages/lms/providers/misc_provider.dart';
import 'package:skillogic/pages/lms/providers/my_bundles.dart';
import 'package:skillogic/pages/lms/providers/my_courses.dart';

import 'package:skillogic/pages/lms/screens/bundle_details_screen.dart';
import 'package:skillogic/pages/lms/screens/bundle_list_screen.dart';
import 'package:skillogic/pages/lms/screens/course_detail_screen.dart';
import 'package:skillogic/pages/lms/screens/courses_screen.dart';
import 'package:skillogic/pages/lms/screens/downloaded_course_list.dart';
import 'package:skillogic/pages/lms/screens/lms_home_screen.dart';
import 'package:skillogic/pages/lms/screens/my_bundle_courses_list_screen.dart';
import 'package:skillogic/pages/lms/screens/sub_category_screen.dart';
import 'package:skillogic/pages/lms/screens/tabs_screen.dart';
import 'package:skillogic/pages/login_page.dart';

import 'package:skillogic/provider/rating_provider_all.dart';
import 'package:skillogic/service/course_percentage_service.dart';
import 'package:skillogic/service/handbook_service.dart';
import 'package:skillogic/service/homeScreen_message_service.dart';
import 'package:skillogic/service/internship_batchDetails_service.dart';

import 'pages/main_page.dart';

/// Background handler for FCM
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

  runApp(const MyApp());

  // Setup FCM AFTER app starts
  _setupFCM();
}

/// FCM setup function (separated)
Future<void> _setupFCM() async {
  final prefs = await SharedPreferences.getInstance();

  const topic = "datamites-v3-app-ios"; // platform/topic-specific
  final alreadySubscribed = prefs.getBool('subscribed_$topic') ?? false;

  if (!alreadySubscribed) {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      if (kDebugMode) {
        print("✅ Subscribed to topic $topic");
      }
      await prefs.setBool('subscribed_$topic', true);
    } catch (e) {
      if (kDebugMode) {
        print("⚠️ FCM subscription failed: $e");
      }
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => Auth()),
        ChangeNotifierProvider(create: (ctx) => Categories()),
        ChangeNotifierProxyProvider<Auth, Courses>(
          create: (ctx) => Courses([], []),
          update: (ctx, auth, previousCourses) => Courses(
            previousCourses?.items ?? [],
            previousCourses?.topItems ?? [],
          ),
        ),
        ChangeNotifierProxyProvider<Auth, MyCourses>(
          create: (ctx) => MyCourses([], []),
          update: (ctx, auth, previousMyCourses) => MyCourses(
            previousMyCourses?.items ?? [],
            previousMyCourses?.sectionItems ?? [],
          ),
        ),
        ChangeNotifierProvider(create: (ctx) => Bundles()),
        ChangeNotifierProvider(create: (ctx) => MyBundles()),
        ChangeNotifierProvider(create: (ctx) => Languages()),
        ChangeNotifierProvider(create: (ctx) => CourseForum()),
        ChangeNotifierProvider(create: (ctx) => InternshipBatchProvider()),
        ChangeNotifierProvider(create: (ctx) => HandbookProvider()),
        ChangeNotifierProvider(create: (ctx) => CoursePercentageService()),
        ChangeNotifierProvider(create: (ctx) => HomeScreenMessageService())
      ],
      child: MaterialApp(
        title: 'Skillogic',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          fontFamily: 'google_sans',
        ),
        home: const MainPage(),
        //home:HomePage(),
        routes: {
          TabsScreen.routeName: (ctx) => const TabsScreen(),
          LmsHomeScreen.routeName: (ctx) => const LmsHomeScreen(),
          CoursesScreen.routeName: (ctx) => const CoursesScreen(),
          CourseDetailScreen.routeName: (ctx) => const CourseDetailScreen(),
          DownloadedCourseList.routeName: (ctx) => const DownloadedCourseList(),
          SubCategoryScreen.routeName: (ctx) => const SubCategoryScreen(),
          BundleListScreen.routeName: (ctx) => const BundleListScreen(),
          BundleDetailsScreen.routeName: (ctx) => const BundleDetailsScreen(),
          MyBundleCoursesListScreen.routeName: (ctx) =>
          const MyBundleCoursesListScreen(),
        },
      ),
    );
  }
}
