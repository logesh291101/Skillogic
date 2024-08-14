import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:skillogic/helper/auth.dart';
import 'package:skillogic/helper/color.dart';
import 'package:skillogic/helper/user_details.dart';
import 'package:skillogic/pages/login_page.dart';
import 'package:skillogic/pages/verify_otp.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../model/notification_response_model.dart';
import '../widgets/notification_card.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  NotificationService notificationService = new NotificationService();
  NotificationResponseModel? notModel;
  NotificationResponseModel? offlineNotModel;
  bool notLoaded = false;
  bool refreshing = true;
  bool showLogin = false;
  bool showError = false;
  bool emailNotVerified = false;

  Future<void> _refreshToken() async {
    UserAuth _userAuth = UserAuth();
    refreshing = true;
    int refreshed = await _userAuth.tokenRefresh(context);
    if (kDebugMode) {
      print("Refreshed first: $refreshed");
    }
    if (refreshed == 1) {
      refreshed = await _userAuth.tokenLogin(context);
      if (kDebugMode) {
        print("Refreshed second: $refreshed");
      }
    } else if(refreshed == 3){
      showError = false;
      showLogin = false;
      emailNotVerified= true;
    }
    if (refreshed == 0) {
      showLogin = true;
      showError = false;
    } else if (refreshed == 2) {
      showError = true;
      showLogin = false;
    } else if(refreshed == 3){
      showError = false;
      showLogin = false;
      emailNotVerified= true;
    }
    setState(() {});
  }

  _getNotification() async {
    await _refreshToken();
    if(!showError && !showLogin){
      if (kDebugMode) {
        print("refreshing");
      }
      notificationService.setContext = context;
      notModel = (await notificationService.getNotification)!;
      notLoaded = true;
    }

    setState(() {});
    if (kDebugMode) {
      print("refreshed");
    }
    _refreshController.refreshCompleted();

  }

  _getDb(String dbPath) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    Database db = await databaseFactoryIo
        .openDatabase(appDocDir.path + "/" + dbPath, version: 1);
    return db;
  }

  _fetchOfflineData() async {
    Database db = await _getDb('skillogic.db');
    var store = StoreRef.main();
    var data = await store.record('notification').get(db) as Map<String, dynamic>;
    offlineNotModel = NotificationResponseModel.fromJson(data);
    setState(() {});
  }

  @override
  void initState() {
    _fetchOfflineData();
    new Future.delayed(Duration.zero, () {
      _getNotification();
    });
    super.initState();
  }

  _verifyEmail() async {
    UserDetails userDetails = UserDetails();
    var user = await userDetails.getDetail();
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => VerifyOtp(email: user.userEmail)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.5,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(
            color: MainColor.textColorConst,
          ),
          title: Text(
            "Notification",
            style: TextStyle(color: MainColor.textColorConst),
          ),
        ),
        body: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SmartRefresher(
                enablePullDown: true,
                header: const WaterDropHeader(),
                controller: _refreshController,
                onRefresh: _getNotification,
                child: emailNotVerified?Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height - 100,
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text("Seems like you are not logged in"),
                        MaterialButton(
                          color: MainColor.skillogicBlue,
                          onPressed: () => {
                            _verifyEmail()
                          },
                          child: const Text(
                            "Verify Email",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      ],
                    )): showError
                    ? Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.white,
                        child: const Center(
                          child: Text("Something went wrong!"),
                        ),
                      )
                    : showLogin
                        ? Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height - 100,
                            color: Colors.white,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text("Seems like you are not logged in"),
                                MaterialButton(
                                  color: MainColor.skillogicBlue,
                                  onPressed: () => {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const LoginPage()))
                                  },
                                  child: const Text(
                                    "Login",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              ],
                            ))
                        : (notLoaded)
                            ? (notModel!.notificationList.length > 0)
                                ? ListView.builder(
                                    shrinkWrap: true,
                                    itemCount:
                                        notModel!.notificationList.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      if (kDebugMode) {
                                        print(index);
                                      }
                                      // access element from list using index
                                      // you can create and return a widget of your choice

                                      return NotificationCard(
                                          notification: notModel!
                                              .notificationList[index]);
                                    })
                                : const Center(
                                    child: Text("No notifications"),
                                  )
                            : (offlineNotModel != null)
                                ? ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: offlineNotModel!
                                        .notificationList.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      if (kDebugMode) {
                                        print(index);
                                      }
                                      // access element from list using index
                                      // you can create and return a widget of your choice

                                      return NotificationCard(
                                          notification: offlineNotModel!
                                              .notificationList[index]);
                                    })
                                : Container(
                                    padding: const EdgeInsets.all(16),
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )),
          ),
        ));
  }
}

class NotificationService {
  late int statusId;
  late int creditSortAsc;
  late String jwt;
  late BuildContext context;
  late SharedPreferences prefs;
  late String authUrl, finalUrl;
  late Uri finalUri;
  NotificationResponseModel? notModel;

  set setContext(BuildContext context) {
    this.context = context;
  }

  String apiPath = '';

  _getDb(String dbPath) async {
    // print("Initializing db");
    var store = StoreRef.main();
    final appDocDir = await getApplicationDocumentsDirectory();
    Database db = await databaseFactoryIo
        .openDatabase(appDocDir.path + "/" + dbPath, version: 1);
    // print("Successfully initialized db");
    return db;
  }

  Future<NotificationResponseModel?> get getNotification async {
    if (kDebugMode) {
      print("Getting segmented");
    }
    prefs = await SharedPreferences.getInstance();
    String authUrl = prefs.getString("auth_url") ?? "";
    finalUrl = '${authUrl}notification/getNotifications?page=0&limit=1000';

    http.Response response = await http.get(Uri.parse(finalUrl),
        headers: {"jwt": prefs.getString("jwtToken")!});
    var segRef;
    if (response.statusCode == 200) {
      segRef = json.decode(response.body);
      Database db = await _getDb('skillogic.db');
      var store = StoreRef.main();
      await store.record('notification').put(db, segRef);
      if (kDebugMode) {
        print("Notification written");
      }
      notModel = NotificationResponseModel.fromJson(segRef);

      // segRefModel = segRef.map(
      //   (dynamic item) => SegmentedReferralResponseModel.fromJson(item),
      // ) as SegmentedReferralResponseModel;
    } else if (response.statusCode == 404) {
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text(json.decode(response.body)['msg'],
      //       textAlign: TextAlign.center),
      // ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(json.decode(response.body)['msg'],
            textAlign: TextAlign.center),
      ));
    }
    return notModel;
  }
}
