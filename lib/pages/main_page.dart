import 'dart:convert';
import 'dart:developer';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:skillogic/helper/notification_navigation_helper.dart';
import 'package:skillogic/helper/user_details.dart';
import 'package:skillogic/model/user_model.dart';
import 'package:skillogic/pages/account_page.dart';
import 'package:skillogic/pages/home_page.dart';
import 'package:skillogic/pages/join_code/join_code_v2.dart';
import 'package:skillogic/pages/qr_scanner/qr_scanner.dart';
import 'package:skillogic/pages/referral/referral_page.dart';
import 'package:skillogic/provider/rating_provider_all.dart';
import 'package:skillogic/widgets/CustomWidget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../helper/auth.dart';
import '../helper/color.dart';
import '../helper/connection.dart';
import '../model/RemoteConfigModel.dart';
import '../widgets/custom_bottom_bar.dart';
import 'NotificationHelperPage.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final UserAuth _userAuth = UserAuth();
  UserDetails userDetails = UserDetails();
  UserModel? userModel;
  bool refreshing = true;
  int _selectedIndex = 0;
  String searchText = "";
  int refreshed = 0;
  bool showUpdateDialog = false;
  bool forceUpdate = false;
  bool showPopup = false;
  String? currentVersion;
  String? jwt_token;

  static List<Widget> _navigationOptions = <Widget>[
    const HomePage(),
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => RatingProviderAll())],
      child: const JoinCodeV2(),
    ),
  ];

  _firebaseMessaging() async {
    // var topic = "dm-test-2023-04-13";
    // if (kDebugMode) {
    //   print("Subscribing to topic $topic");
    // }
    // await FirebaseMessaging.instance.subscribeToTopic(topic);
    FirebaseMessaging.onMessage.listen((event) async {
      if (kDebugMode) {
        print(event);
      }
    });
  }

  Future<RemoteConfigModel> getConfig(BuildContext context) async {
    // await FirebaseMessaging.instance.subscribeToTopic("v3-test-feb-10");

    final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(
          minutes: 5,
        ), // fetch parameters will be cached for a maximum of 1 hour
      ),
    );

    await FirebaseRemoteConfig.instance.activate();
    await _remoteConfig.fetchAndActivate();
    return RemoteConfigModel(
      appstore_url: _remoteConfig.getString('appstore_url_v3'),
      auth_url: _remoteConfig.getString('auth_url_v3'),
      auth_url_tm: _remoteConfig.getString('auth_url_tm'),
      base_url: _remoteConfig.getString('base_url_v3'),
      candidate_portal_url: _remoteConfig.getString("candidate_portal_v3"),
      cash_credit: _remoteConfig.getString('cash_credit'),
      course_credit: _remoteConfig.getString('course_credit'),
      force_update: _remoteConfig.getString('force_update'),
      ios_version: _remoteConfig.getString('ios_version'),
      new_version: _remoteConfig.getString('new_version'),
      playstore_url: _remoteConfig.getString('playstore_url'),
      privacy_policy: _remoteConfig.getString('privacy_policy'),
      tel: _remoteConfig.getString('tel'),
      tos: _remoteConfig.getString('tos'),
      freshdesk_key: _remoteConfig.getString('freshdesk_key'),
      add_firebase_token: _remoteConfig.getString('add_firebase_token'),
      update_reason: _remoteConfig.getString('update_reason'),
      certificate_text: _remoteConfig.getString('certificate_text'),
      certificate_subject: _remoteConfig.getString('certificate_subject'),

      android_forceUpdate: _remoteConfig.getString('android_forceUpdate'),
      android_updateReason: _remoteConfig.getString('android_updateReason'),
      android_version: _remoteConfig.getString('android_version'),
      ios_forceUpdate: _remoteConfig.getString('ios_forceUpdate'),
      ios_updateReason: _remoteConfig.getString('ios_updateReason'),

    );
  }

  _proceedFurther() async {
    await _checkLogin();
    getCandidateDetails();
  }

  storeFirebaseToken(String firebaseToken) async {
    if (kDebugMode) {
      print("Token example");
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var add_firebase_token = prefs.getString("add_firebase_token")!;
    var token = prefs.getString("jwtToken") ?? "";
    if (token.isNotEmpty) {
      String json = '{"firebaseToken": "$firebaseToken"}';
      if (kDebugMode) {
        print(add_firebase_token);
        print(token);
        print("Token example");
        print(json);
      }
      Map<String, String> header = {
        "jwt": token,
        "Content-Type": "application/json",
      };
      Response res = await post(
        Uri.parse(add_firebase_token),
        headers: header,
        body: json,
      );

      if (kDebugMode) {
        print("Response in token for firebase ${res.statusCode}");
      }
    }
  }

  getCurrentVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    currentVersion = packageInfo.version.replaceAll(" ", "").trim();
  }

  _getConfig() async {
    getCurrentVersion();
    RemoteConfigModel remoteConfigModel = await getConfig(context);
    await remoteConfigModel.saveConfigToPrefs(context);
    await setupMessaging();
    if (remoteConfigModel.android_version != currentVersion) {
      showUpdateDialog = true;
      if (remoteConfigModel.android_forceUpdate == "true") {
        forceUpdate = true;
      }
    }

    try{
      FirebaseMessaging.instance.getToken().then((token) {
        storeFirebaseToken(token!);
      });
    }
    catch(e,s){
      log("FCM Token Error", error: e, stackTrace: s);
    }

    if (showUpdateDialog) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Visibility(
            visible: true,
            child: Dialog(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.25,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.15,
                            width: MediaQuery.of(context).size.width * 0.15,
                            child: SvgPicture.asset("assets/start-up.svg"),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "New version available ${remoteConfigModel.android_version}",
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${remoteConfigModel.android_updateReason}",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (!forceUpdate)
                          MaterialButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await _proceedFurther();
                            },
                            child: const Text("Update Later"),
                          ),
                        MaterialButton(
                          onPressed: () {
                            launchUrl(
                              Uri.parse(remoteConfigModel.playstore_url),
                            );
                          },
                          child: const Text(
                            "Update",
                            style: TextStyle(color: Colors.white),
                          ),
                          color: MainColor.skillogicRed,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else {
      await _proceedFurther();
    }
  }

  _checkLogin() async {
    setState(() {
      refreshing = true;
    });
    refreshed = await _userAuth.tokenLogin(context);
    log("------tokenLogin refreshed = $refreshed");
    final prefs = await SharedPreferences.getInstance();
    final userSession = prefs.getString('userSession');
    final session = prefs.getString('session');
    log("session = ${prefs.getString('session')}");
    log("userSession = ${prefs.getString('userSession')}");
    log("jwtToken = ${prefs.getString('jwtToken')}");

    if (userSession == null || session == null || userSession != session) {
      UserDetails userDetails = UserDetails();
      await userDetails.logoutOnly(context);
      setState(() {
        refreshed = 0;
        refreshing = false;
      });
      return;
    }

    if (refreshed == 1) {
      _navigationOptions = <Widget>[
        const HomePage(),
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => RatingProviderAll()),
          ],
          child: const JoinCodeV2(),
        ),
        const ReferralScreen(),
        const AccountScreen(),
      ];
    } else {
      refreshed = await _userAuth.tokenRefresh(context);
      if (refreshed == 1) {
        final prefs = await SharedPreferences.getInstance();
        final userSession = prefs.getString('userSession');
        final session = prefs.getString('session');

        if (userSession == null || session == null || userSession != session) {
          UserDetails userDetails = UserDetails();
          await userDetails.logoutOnly(context);
          setState(() {
            refreshed = 0;
            refreshing = false;
          });
          return;
        }
        _checkLogin();
      } else {
        UserDetails userDetails = UserDetails();
        await userDetails.logoutOnly(context);
        setState(() {
          refreshed = 0;
        });
      }
    }

    refreshing = false;
    _firebaseMessaging();
    setState(() {});
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Check rating status for QR scanner context
  Future<bool> _checkQRRatingStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String candidate_portal_url =
          prefs.getString("candidate_portal_url") ?? "";
      String token = prefs.getString("jwtToken") ?? "";

      if (candidate_portal_url.isEmpty || token.isEmpty) {
        return false;
      }

      var finalUrl =
          "${candidate_portal_url}dm-api/lma/getLastRatedTrainingDetails/";

      http.Response res = await http.get(
        Uri.parse(finalUrl),
        headers: {"jwt": token},
      );

      if (res.statusCode == 200) {
        var response = json.decode(res.body);
        // Check if rating is needed
        if (response['is_rating_needed'] != null) {
          return int.parse(response['is_rating_needed'].toString()) == 1;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error checking QR rating status: $e");
      }
    }
    return false;
  }

  void getCandidateDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("candidate_id", "");
    String authUrl = prefs.getString("auth_url") ?? "";
    String apiPath = 'Candidate/';
    String finalUrl =
        "$authUrl${apiPath}getCandidateByEmail?email=${prefs.getString("user_email") ?? ""}";

    http.Response response = await http.get(Uri.parse(finalUrl));
    print("Test");
    print(response.body);

    try {
      var responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        prefs.setString("candidate_id", responseBody["data"]["candidate_id"]);
        prefs.setString(
          "candidate_number",
          responseBody["data"][0]["CandidateNumber"],
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseBody['msg'], textAlign: TextAlign.center),
          ),
        );
      }
    } catch (err) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text(err.toString(), textAlign: TextAlign.center)),
      // );
    }
  }

  _getUserDetail() async {
    userModel = await userDetails.getDetail();
    setState(() {});
  }

  @pragma('vm:entry-point')
  Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    await Firebase.initializeApp();
    await setupFlutterNotifications();
    showFlutterNotification(message);
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    if (kDebugMode) {
      print('Handling a background message ${message.messageId}');
    }
  }

  /// Create a [AndroidNotificationChannel] for heads up notifications
  late AndroidNotificationChannel channel;

  bool isFlutterLocalNotificationsInitialized = false;

  Future<void> setupFlutterNotifications() async {
    if (isFlutterLocalNotificationsInitialized) {
      return;
    }
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
    isFlutterLocalNotificationsInitialized = true;
  }

  void showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            playSound: true,
            tag: message.data["key"],
            subText: message.data["value"],
            icon: 'launch_background',
          ),
        ),
      );
    }
  }

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  setupMessaging() async {
    // Set the background messaging handler early on, as a named top-level function
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    if (!kIsWeb) {
      await setupFlutterNotifications();
    }

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        if (kDebugMode) {
          print('A new onMessageOpenedApp event was published!');
        }
        if (kDebugMode) {
          print(message.data);
        }
        NotificationNavigationHelper navigationHelper =
            NotificationNavigationHelper();
        navigationHelper.context = context;
        navigationHelper.action = message.data['action'];
        navigationHelper.sub_action = message.data['sub_action'];
        navigationHelper.external_url = message.data['external_url'];
        navigationHelper.external_action = message.data['external_action'];

        navigationHelper.processNotification(false);
      }
    });

    // FirebaseMessaging.onMessage.listen(showFlutterNotification);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NotificationHelperPage(remoteMessage: message),
        ),
      );
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        if (kDebugMode) {
          print('A new onMessageOpenedApp event was published!');
        }
        if (kDebugMode) {
          print(message.data);
        }
        NotificationNavigationHelper navigationHelper =
            NotificationNavigationHelper();
        navigationHelper.context = context;
        navigationHelper.action = message.data['action'];
        navigationHelper.sub_action = message.data['sub_action'];
        navigationHelper.external_url = message.data['external_url'];
        navigationHelper.external_action = message.data['external_action'];

        navigationHelper.processNotification(false);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('A new onMessageOpenedApp event was published!');
      }
      if (kDebugMode) {
        print(message.data);
      }
      NotificationNavigationHelper navigationHelper =
          NotificationNavigationHelper();
      navigationHelper.context = context;
      navigationHelper.action = message.data['action'];
      navigationHelper.sub_action = message.data['sub_action'];
      navigationHelper.external_url = message.data['external_url'];
      navigationHelper.external_action = message.data['external_action'];

      navigationHelper.processNotification(false);
    });
  }

  _doInitialization() async {
    bool connected = await ConnectionCheck.isAvailable();
    if (!connected) {
      CustomWidget.showInternetDialog(context);
      // showDialog(
      //   context: context,
      //   builder: (context) {
      //     return AlertDialog(
      //       title: const Text("Connection Lost"),
      //       content: const Text("Please check your internet connection"),
      //       actions: [
      //         MaterialButton(
      //           onPressed: () {
      //             Navigator.pushAndRemoveUntil(
      //               context,
      //               MaterialPageRoute(builder: (context) => const MainPage()),
      //               (route) => false,
      //             );
      //           },
      //           child: const Text("Ok"),
      //         ),
      //       ],
      //     );
      //   },
      // );
    } else {
      await _getConfig();
    }
  }

  // Future<void> getUserContacts() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String email = prefs.getString("userEmail") ?? "";
  //   final isContactsSent = prefs.getString("isContactsSent");
  //   List<Map<String, String>> contactList = [];
  //   if (isContactsSent == "false") {
  //     log("-----Contacts function called");
  //     var status = await Permission.contacts.status;
  //
  //     if (status.isDenied || status.isPermanentlyDenied) {
  //       status = await Permission.contacts.request();
  //     }
  //
  //     if (!status.isGranted) {
  //       log("Permission denied");
  //       return;
  //     }
  //     log("----getUserContacts function call");
  //     final contacts = await FlutterContacts.getAll(
  //       properties: {ContactProperty.name, ContactProperty.phone},
  //     );
  //     log("contacts-----$contacts");
  //    for(var contact in contacts){
  //     if(contact.phones.isNotEmpty){
  //       for(var phone in contact.phones){
  //         contactList.add({
  //           "name": contact.displayName ?? "",
  //           "mobile": phone.number
  //         });
  //       }
  //     }
  //    }
  //     final body = {
  //       "email": email,
  //       "contacts": contactList,
  //     };
  //     try {
  //       final url = Uri.parse("");
  //       final response = await http.post(
  //         url,
  //         headers: {'Content-Type': 'application/json'},
  //         body: jsonEncode(body),
  //       );
  //       if (response.statusCode == 201) {
  //         prefs.setString("isContactsSent", "true");
  //       } else {
  //         log("Failed to add contacts ${response.statusCode}");
  //         prefs.setString("isContactsSent", "false");
  //       }
  //     } catch (e) {
  //       throw Exception("Error: $e");
  //     }
  //   } else {
  //     log("User contacts has been already sent");
  //   }
  // }

  //popup
  Future<void> checkOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool formFilled = prefs.getBool('form_filled') ?? false;
    if (!formFilled) {
      setState(() {
        showPopup = true;
      });
    }
  }

  void dismissPopup() {
    setState(() {
      showPopup = false;
    });
  }

  @override
  void initState() {
    _doInitialization();
    //getUserContacts();
    super.initState();
    setState(() {
      showPopup = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _getUserDetail();
    return (refreshing)
        ? Scaffold(
            body: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: Image.asset(
                    "assets/skillogic_icon.png",
                    height: 80,
                    width: 80,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          )
        : Scaffold(
            appBar: CustomWidget.getSkillogicAppBar(
              context,
              userModel,
              refreshed,
            ),
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                IndexedStack(
                  index: _selectedIndex,
                  children: _navigationOptions,
                ),
                if (showPopup)
                  Container(
                    color: Colors.white.withOpacity(0.5),
                    child: Center(
                      child: AlertDialog(
                        title: const Text('Candidate Onboarding Form'),
                        content: const Text(
                          'Would you like to fill the form now or ignore?',
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) =>
                              //         const CandidateOnboardingForm(),
                              //   ),
                              // );
                            },
                            child: const Text('Fill Form'),
                          ),
                          TextButton(
                            onPressed: () {
                              dismissPopup();
                            },
                            child: const Text('Ignore'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            bottomNavigationBar: CustomBottomNavBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
              refreshed: refreshed,
            ),
            floatingActionButton: refreshed == 1
                ? FloatingActionButton(
                    onPressed: () async {
                      LocationPermission permission =
                          await Geolocator.checkPermission();
                      if (permission == LocationPermission.always ||
                          permission == LocationPermission.whileInUse) {
                        // Check rating status independently for QR scanner
                        bool qrRatingNeeded = await _checkQRRatingStatus();
                        if (qrRatingNeeded) {
                          // Show rating page, and after submission navigate to QRScanner
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChangeNotifierProvider(
                                create: (context) => RatingProviderAll(),
                                child: MaterialApp(
                                  debugShowCheckedModeBanner: false,
                                  home: Scaffold(
                                    appBar: CustomWidget.getSkillogicAppBar(
                                      context,
                                      userModel,
                                      1,
                                    ),
                                    body: SafeArea(
                                      child: JoinCodeV2(
                                        onRatingSubmitted: () {
                                          // After rating submission, navigate to QRScanner
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => QRScanner(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          // No rating needed, go directly to QRScanner
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QRScanner(),
                            ),
                          );
                        }
                      } else {
                        Fluttertoast.showToast(
                          msg: "Location Permission Required",
                        );
                      }
                    },
                    backgroundColor: Colors.purple,
                    child: const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                    ),
                  )
                : null,
            // No FAB if refreshed != 1
            floatingActionButtonLocation: refreshed == 1
                ? FloatingActionButtonLocation.centerDocked
                : null,
          );
  }
}

// import 'dart:convert';
// import 'package:flutter_svg/svg.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:skillogic/helper/notification_navigation_helper.dart';
// import 'package:skillogic/helper/user_details.dart';
// import 'package:skillogic/model/user_model.dart';
// import 'package:skillogic/pages/account_page.dart';
// import 'package:skillogic/pages/home_page.dart';
// import 'package:skillogic/pages/join_code/join_code_v2.dart';
// import 'package:skillogic/pages/qr_scanner/qr_scanner.dart';
// import 'package:skillogic/pages/referral/referral_page.dart';
// import 'package:skillogic/provider/rating_provider_all.dart';
// import 'package:skillogic/widgets/CustomWidget.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_remote_config/firebase_remote_config.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_html/flutter_html.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:http/http.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:http/http.dart' as http;
//
//
// import '../global.dart';
// import '../helper/auth.dart';
// import '../helper/color.dart';
// import '../helper/connection.dart';
// import '../model/RemoteConfigModel.dart';
// import '../widgets/custom_bottom_bar.dart';
// import 'NotificationHelperPage.dart';
// import 'candidate_analysis_form.dart';
//
//
// class MainPage extends StatefulWidget {
//   const MainPage({Key? key}) : super(key: key);
//
//
//   @override
//   State<MainPage> createState() => _MainPageState();
// }
//
//
// class _MainPageState extends State<MainPage> {
//   final UserAuth _userAuth = UserAuth();
//   UserDetails userDetails = UserDetails();
//   UserModel? userModel;
//   bool refreshing = true;
//   int _selectedIndex = 0;
//   String searchText = "";
//   int refreshed = 0;
//   bool showUpdateDialog = false;
//   bool showPopup = false;
//   bool forceUpdate = false;
//   String? currentVersion;
//   String? jwt_token;
//
//
//
//
//   static List<Widget> _navigationOptions = <Widget>[
//     const HomePage(),
//     MultiProvider(providers: [
//       ChangeNotifierProvider(create: (_) => RatingProviderAll()),
//     ], child: const JoinCodeV2()),
//   ];
//
//
//
//
//   _firebaseMessaging() async {
//     // var topic = "dm-test-2023-04-13";
//     // if (kDebugMode) {
//     //   print("Subscribing to topic $topic");
//     // }
//     // await FirebaseMessaging.instance.subscribeToTopic(topic);
//     FirebaseMessaging.onMessage.listen((event) async {
//       if (kDebugMode) {
//         print(event);
//       }
//     });
//   }
//
//
//
//
//
//
//   Future<RemoteConfigModel> getConfig(BuildContext context) async {
//
//
//     // await FirebaseMessaging.instance.subscribeToTopic("v3-test-feb-10");
//
//
//
//
//     final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
//     await _remoteConfig.setConfigSettings(RemoteConfigSettings(
//       fetchTimeout: const Duration(seconds: 10),
//       minimumFetchInterval: const Duration(
//           minutes:
//           5), // fetch parameters will be cached for a maximum of 1 hour
//     ));
//
//
//     await FirebaseRemoteConfig.instance.activate();
//     await _remoteConfig.fetchAndActivate();
//     return RemoteConfigModel(
//         appstore_url: _remoteConfig.getString('appstore_url_v3'),
//         auth_url: _remoteConfig.getString('auth_url_v3'),
//         auth_url_tm: _remoteConfig.getString('auth_url_tm'),
//         base_url: _remoteConfig.getString('base_url_v3'),
//         candidate_portal_url: _remoteConfig.getString("candidate_portal_v3"),
//         cash_credit: _remoteConfig.getString('cash_credit'),
//         course_credit: _remoteConfig.getString('course_credit'),
//         force_update: _remoteConfig.getString('force_update'),
//         ios_version: _remoteConfig.getString('ios_version'),
//         new_version: _remoteConfig.getString('new_version'),
//         playstore_url: _remoteConfig.getString('playstore_url'),
//         privacy_policy: _remoteConfig.getString('privacy_policy'),
//         tel: _remoteConfig.getString('tel'),
//         tos: _remoteConfig.getString('tos'),
//         freshdesk_key: _remoteConfig.getString('freshdesk_key'),
//         add_firebase_token: _remoteConfig.getString('add_firebase_token'),
//         update_reason: _remoteConfig.getString('update_reason'),
//         certificate_text: _remoteConfig.getString('certificate_text'),
//         certificate_subject: _remoteConfig.getString('certificate_subject'));
//   }
//
//
//
//
//
//
//   _proceedFurther() async {
//     await _checkLogin();
//     getCandidateDetails();
//   }
//
//
//   storeFirebaseToken(String firebaseToken) async {
//     if (kDebugMode) {
//       print("Token example");
//     }
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     var add_firebase_token = prefs.getString("add_firebase_token")!;
//     var token = prefs.getString("jwtToken")??"";
//     if (token.isNotEmpty){
//       String json = '{"firebaseToken": "$firebaseToken"}';
//       if (kDebugMode) {
//
//
//         print(add_firebase_token);
//         print(token);
//         print("Token example");
//         print(json);
//       }
//       Map<String, String> header = {"jwt": token, "Content-Type":"application/json"};
//       Response res = await post(Uri.parse(add_firebase_token), headers: header, body: json);
//
//
//       if (kDebugMode) {
//         print("Response in token for firebase ${res.statusCode}");
//       }
//     }
//
//
//   }
//
//
//   getCurrentVersion() async {
//     PackageInfo packageInfo = await PackageInfo.fromPlatform();
//     currentVersion = packageInfo.version;
//   }
//
//
//
//
//
//
//   _getConfig() async {
//     getCurrentVersion();
//     RemoteConfigModel remoteConfigModel = await getConfig(context);
//     await remoteConfigModel.saveConfigToPrefs(context);
//     await setupMessaging();
//     if (remoteConfigModel.ios_version != currentVersion){
//       showUpdateDialog = true;
//       if (remoteConfigModel.force_update == "true"){
//         forceUpdate = true;
//       }
//     }
//
//
//     FirebaseMessaging.instance.getToken().then((token) {
//       // if (kDebugMode) print("token $token");
//       storeFirebaseToken(token!);
//     });
//
//
//     // // Android version check
//     // if (remoteConfigModel.new_version != "16.0.0") {
//     //   showUpdateDialog = true;
//     //   if (remoteConfigModel.force_update == "true") {
//     //     forceUpdate = true;
//     //   }
//     // }
//     //
//     // FirebaseMessaging.instance.getToken().then((token) {
//     //   storeFirebaseToken(token!);
//     // });
//
//
//     if (showUpdateDialog){
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return Visibility(
//             visible: true,
//             child: Dialog(
//               child: Container(
//                 height: MediaQuery.of(context).size.height * 0.25,
//                 //width: MediaQuery.of(context).size.width * 0.4,
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                       child: Row(
//                         children: [
//                           Container(
//                             height: MediaQuery.of(context).size.height * 0.15,
//                             width: MediaQuery.of(context).size.width * 0.15,
//                             child: SvgPicture.asset("assets/start-up.svg"),
//                           ),
//                           SizedBox(width: 10),
//                           Text(
//                             "New version available",
//                             style: TextStyle(
//                               fontSize:
//                               MediaQuery.of(context).size.width * 0.04,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height:10),
//                     Text(
//                       //"${remoteConfigModel.update_reason}",
//                       "Update now to get the latest features and updates.",
//                       style: TextStyle(
//                         fontSize:17,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                     const SizedBox(height:10),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         if (!forceUpdate)
//                           MaterialButton(
//                             onPressed: () async {
//                               Navigator.pop(context);
//                               await _proceedFurther();
//                             },
//                             child: const Text("Update Later"),
//                           ),
//                         MaterialButton(
//                           onPressed: () {
//                             // launchUrl(
//                             //   Uri.parse(remoteConfigModel.playstore_url),
//                             // );
//                             launchUrl(Uri.parse(remoteConfigModel.appstore_url),);
//                           },
//                           child: const Text(
//                             "Update",
//                             style: TextStyle(color: Colors.white),
//                           ),
//                           color: MainColor.skillogicRed,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//
//
//
//
//
//           );
//         },
//       );
//     } else{
//       await _proceedFurther();
//     }
//   }
//
//
//
//
//   // _checkLogin() async {
//   //   setState(() {
//   //     refreshing = true;
//   //   });
//   //   refreshed = await _userAuth.tokenLogin(context);
//   //   if (refreshed == 1) {
//   //     _navigationOptions = <Widget>[
//   //       const HomePage(),
//   //       MultiProvider(providers: [
//   //         ChangeNotifierProvider(create: (_) => RatingProviderAll()),
//   //       ], child: const JoinCodeV2()),
//   //       // DTribePage(),
//   //       // const ReferralScreen(),
//   //       const AccountScreen()
//   //     ];
//   //   } else{
//   //     refreshed = await _userAuth.tokenRefresh(context);
//   //     if(refreshed == 1) {
//   //       _checkLogin();
//   //     } else {
//   //       UserDetails userDetails = UserDetails();
//   //       await userDetails.logoutOnly(context);
//   //     }
//   //   }
//   //   refreshing = false;
//   //   _firebaseMessaging();
//   //   setState(() {});
//   // }
//
//
//   _checkLogin() async {
//     setState(() {
//       refreshing = true;
//     });
//     refreshed = await _userAuth.tokenLogin(context);
//     final prefs = await SharedPreferences.getInstance();
//     final userSession = prefs.getString('userSession');
//     final session = prefs.getString('session');
//
//
//     if (userSession == null || session == null || userSession != session) {
//       UserDetails userDetails = UserDetails();
//       await userDetails.logoutOnly(context);
//       setState(() {
//         refreshed = 0;
//         refreshing = false;
//       });
//       return;
//     }
//
//
//     if (refreshed == 1) {
//       _navigationOptions = <Widget>[
//         const HomePage(),
//         MultiProvider(
//           providers: [
//             ChangeNotifierProvider(create: (_) => RatingProviderAll()),
//           ],
//           child: const JoinCodeV2(),
//         ),
//         const ReferralScreen(),
//         const AccountScreen(),
//       ];
//     }
//     else {
//       refreshed = await _userAuth.tokenRefresh(context);
//       if (refreshed == 1) {
//         final prefs = await SharedPreferences.getInstance();
//         final userSession = prefs.getString('userSession');
//         final session = prefs.getString('session');
//
//
//         if (userSession == null || session == null || userSession != session) {
//           UserDetails userDetails = UserDetails();
//           await userDetails.logoutOnly(context);
//           setState(() {
//             refreshed = 0;
//             refreshing = false;
//           });
//           return;
//         }
//         _checkLogin();
//       }
//       else {
//         UserDetails userDetails = UserDetails();
//         await userDetails.logoutOnly(context);
//         setState(() {
//           refreshed = 0;
//         });
//       }
//     }
//
//
//     refreshing = false;
//     _firebaseMessaging();
//     setState(() {});
//   }
//
//
//   void _onItemTapped(int index) {
//     // _getSession();
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//
//   void getCandidateDetails() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setString("candidate_id","");
//     String authUrl = prefs.getString("auth_url") ?? "";
//     String apiPath = 'Candidate/';
//     String finalUrl =
//         "$authUrl${apiPath}getCandidateByEmail?email=${prefs.getString("user_email") ?? ""}";
//
//
//     http.Response response = await http.get(Uri.parse(finalUrl));
//     print("Test");
//     print(response.body);
//
//
//     try {
//       var responseBody = json.decode(response.body);
//       if (response.statusCode == 200) {
//         prefs.setString("candidate_id", responseBody["data"]["candidate_id"]);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text(responseBody['msg'], textAlign: TextAlign.center),
//         ));
//       }
//     } catch (err) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text(err.toString(), textAlign: TextAlign.center),
//       ));
//     }
//   }
//
//
//   _getUserDetail() async {
//     userModel = await userDetails.getDetail();
//     setState(() {});
//   }
//
//
//
//
//   @pragma('vm:entry-point')
//   Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//     await Firebase.initializeApp();
//     await setupFlutterNotifications();
//     showFlutterNotification(message);
//     // If you're going to use other Firebase services in the background, such as Firestore,
//     // make sure you call `initializeApp` before using other Firebase services.
//     if (kDebugMode) {
//       print('Handling a background message ${message.messageId}');
//     }
//   }
//
//
//   /// Create a [AndroidNotificationChannel] for heads up notifications
//   late AndroidNotificationChannel channel;
//
//
//   bool isFlutterLocalNotificationsInitialized = false;
//
//
//   Future<void> setupFlutterNotifications() async {
//     if (isFlutterLocalNotificationsInitialized) {
//       return;
//     }
//     channel = const AndroidNotificationChannel(
//       'high_importance_channel', // id
//       'High Importance Notifications', // title
//       description:
//       'This channel is used for important notifications.', // description
//       importance: Importance.high,
//     );
//
//
//     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
//
//     /// Create an Android Notification Channel.
//     ///
//     /// We use this channel in the `AndroidManifest.xml` file to override the
//     /// default FCM channel to enable heads up notifications.
//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);
//
//
//     /// Update the iOS foreground notification presentation options to allow
//     /// heads up notifications.
//     await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//     isFlutterLocalNotificationsInitialized = true;
//   }
//
//
//   void showFlutterNotification(RemoteMessage message) {
//     RemoteNotification? notification = message.notification;
//     AndroidNotification? android = message.notification?.android;
//     if (notification != null && android != null && !kIsWeb) {
//       flutterLocalNotificationsPlugin.show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         NotificationDetails(
//           android: AndroidNotificationDetails(
//             channel.id,
//             channel.name,
//             channelDescription: channel.description,
//             playSound: true,
//             tag: message.data["key"],
//             subText: message.data["value"],
//             icon: 'launch_background',
//           ),
//         ),
//       );
//     }
//   }
//
//
//   /// Initialize the [FlutterLocalNotificationsPlugin] package.
//   late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
//
//
//   setupMessaging() async {
//     // Set the background messaging handler early on, as a named top-level function
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//
//
//     if (!kIsWeb) {
//       await setupFlutterNotifications();
//     }
//
//
//     FirebaseMessaging.instance.getInitialMessage().then((message) {
//       if (message != null) {
//         if (kDebugMode) {
//           print('A new onMessageOpenedApp event was published!');
//         }
//         if (kDebugMode) {
//           print(message.data);
//         }
//         NotificationNavigationHelper navigationHelper =
//         NotificationNavigationHelper();
//         navigationHelper.context = context;
//         navigationHelper.action = message.data['action'];
//         navigationHelper.sub_action = message.data['sub_action'];
//         navigationHelper.external_url = message.data['external_url'];
//         navigationHelper.external_action = message.data['external_action'];
//
//
//         navigationHelper.processNotification(false);
//       }
//     });
//
//
//     // FirebaseMessaging.onMessage.listen(showFlutterNotification);
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       Navigator.of(context).push(MaterialPageRoute(
//           builder: (context) =>
//               NotificationHelperPage(remoteMessage: message)));
//     });
//
//
//     FirebaseMessaging.instance.getInitialMessage().then((message) {
//       if (message != null) {
//         if (kDebugMode) {
//           print('A new onMessageOpenedApp event was published!');
//         }
//         if (kDebugMode) {
//           print(message.data);
//         }
//         NotificationNavigationHelper navigationHelper =
//         NotificationNavigationHelper();
//         navigationHelper.context = context;
//         navigationHelper.action = message.data['action'];
//         navigationHelper.sub_action = message.data['sub_action'];
//         navigationHelper.external_url = message.data['external_url'];
//         navigationHelper.external_action = message.data['external_action'];
//
//
//         navigationHelper.processNotification(false);
//       }
//     });
//
//
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       if (kDebugMode) {
//         print('A new onMessageOpenedApp event was published!');
//       }
//       if (kDebugMode) {
//         print(message.data);
//       }
//       NotificationNavigationHelper navigationHelper =
//       NotificationNavigationHelper();
//       navigationHelper.context = context;
//       navigationHelper.action = message.data['action'];
//       navigationHelper.sub_action = message.data['sub_action'];
//       navigationHelper.external_url = message.data['external_url'];
//       navigationHelper.external_action = message.data['external_action'];
//
//
//       navigationHelper.processNotification(false);
//     });
//   }
//
//
//
//
//   _doInitialization() async {
//     bool connected = await ConnectionCheck.isAvailable();
//     if (!connected) {
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
//       await _getConfig();
//     }
//   }
// //popup
//   Future<void> checkOnboardingStatus() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool formFilled = prefs.getBool('form_filled') ?? false;
//     if (!formFilled) {
//       setState(() {
//         showPopup = true;
//       });
//     }
//   }
//
//
//
//
//   void dismissPopup() {
//     setState(() {
//       showPopup = false;
//     });
//   }
//
//
//
//
//   @override
//   void initState() {
//     _doInitialization();
//     super.initState();
//     setState(() {
//       showPopup = false;
//     });
//   }
//
//
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     _getUserDetail();
//     return (refreshing) ? Scaffold(
//       body: SafeArea(
//         child: SizedBox(
//             width: double.infinity,
//             height: double.infinity,
//             child: Center(
//               child: Image.asset(
//                 "assets/skillogic_icon.png",
//                 height: 80,
//                 width: 80,
//                 fit: BoxFit.contain,
//               ),
//             )
//         ),
//       ),
//     ):
//
//
//
//
//
//
//     Scaffold(
//       appBar: CustomWidget.getSkillogicAppBar(
//         context,
//         userModel,
//         refreshed,
//       ),
//       backgroundColor: Colors.white,
//       body: Stack(
//         children: [
//           IndexedStack(
//             index: _selectedIndex,
//             children: _navigationOptions,
//           ),
//           if (showPopup)
//             Container(
//               color: Colors.white.withOpacity(0.5),
//               child: Center(
//                 child: AlertDialog(
//                   title: const Text('Candidate Onboarding Form'),
//                   content: const Text(
//                     'Would you like to fill the form now or ignore?',
//                   ),
//                   actions: <Widget>[
//                     TextButton(
//                       onPressed: () {
//                         // Navigator.push(
//                         //   context,
//                         //   MaterialPageRoute(
//                         //     builder: (context) =>
//                         //     const CandidateOnboardingForm(),
//                         //   ),
//                         // );
//                       },
//                       child: const Text('Fill Form'),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         dismissPopup();
//                       },
//                       child: const Text('Ignore'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//       bottomNavigationBar: CustomBottomNavBar(
//         selectedIndex: _selectedIndex,
//         onItemTapped: _onItemTapped,
//         refreshed: refreshed,
//       ),
//       floatingActionButton: refreshed == 1
//           ? FloatingActionButton(
//         onPressed: () {
//           print("-----------$showFeedback");
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => showFeedback
//                   ? ChangeNotifierProvider(
//                 create: (context) => RatingProviderAll(),
//                 child: MaterialApp(
//                   debugShowCheckedModeBanner: false,
//                   home: Scaffold(
//                     appBar: CustomWidget.getSkillogicAppBar(
//                       context,
//                       userModel,
//                       1,
//                     ),
//                     body: SafeArea(child: JoinCodeV2()),
//                   ),
//                 ),
//               )
//                   : QRScanner(),
//             ),
//           );
//         },
//         backgroundColor: Colors.purple,
//         child: const Icon(
//           Icons.qr_code_scanner,
//           color: Colors.white,
//         ),
//       )
//           : null,
//       // No FAB if refreshed != 1
//       floatingActionButtonLocation: refreshed == 1
//           ? FloatingActionButtonLocation.centerDocked
//           : null,
//     );
//
//
//
//
//
//
//
//
//   }
// }
//
