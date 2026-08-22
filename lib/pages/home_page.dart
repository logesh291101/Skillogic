// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skillogic/helper/user_details.dart';
import 'package:skillogic/model/category_model.dart';
import 'package:skillogic/model/course/course_list_model.dart';
import 'package:skillogic/model/user_model.dart';
import 'package:skillogic/pages/candidate_portal/enrolled_course.dart';
import 'package:skillogic/pages/doubtClearance_screen.dart';
import 'package:skillogic/pages/freshdesk/ticket_page.dart';
import 'package:skillogic/pages/handbook_screen.dart';
import 'package:skillogic/pages/project_statusCall_screen.dart';
import 'package:skillogic/pages/referral/new_referral.dart';
import 'package:skillogic/pages/referral/referral_page_scaffold.dart';
import 'package:skillogic/pages/sub_page/course/course_list_page.dart';
import 'package:skillogic/pages/topics_covered_page.dart';
import 'package:skillogic/provider/rating_provider_all.dart';
import 'package:skillogic/widgets/card_course_preview_shimmer.dart';
import 'package:skillogic/widgets/carousel.dart';
import 'package:skillogic/widgets/carousel_shimmer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../helper/color.dart';
import '../helper/connection.dart';
import '../model/carousel_model.dart';
import '../model/carousel_response_model.dart';
import '../service/attendance_record_service.dart';
import '../service/course_percentage_service.dart';
import '../service/homeScreen_message_service.dart';
import '../service/topics_covered_service.dart';
import '../widgets/CustomWidget.dart';
import 'attendance_record_page.dart';
import 'candidate_portal/candidate_rest_request.dart';
import 'candidate_portal/enrolled_certificate.dart';
import 'candidate_portal/rating_page.dart';
import 'main_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var userDetails = UserDetails();
  List<CarouselModel> carouselList = [];
  List<CourseListModel> coursesList = [];
  List<CategoryModel> categoryList = [];
  bool showSignIn = false;
  UserModel? userModel;
  String greeting = "Good Morning,";
  String date = "";
  String userName = "";

  //final searchController = TextEditingController();
  bool loggedIn = false;

  // String userImage =
  //     "https://www.sciencefriday.com/wp-content/uploads/2019/09/face-recognition-resized.png";
  String? sessionId;
  String? ipAddress;
  String? brand, model,platform_version;
  double? lat, long;
  String? timeStamp;
  String? email;
  String? appName, version;
  String jwtToken = "";
  bool isChecked = false;
  String? platform;

  Future<void> _getUserDetail() async {
    userModel = await userDetails.getDetail();
    setState(() {
      userName = userModel!.getUserName == ""
          ? "Stranger"
          : userModel!.getUserName;
      loggedIn = userModel!.getUserName != "";
      var currentDate = DateTime.now();
      if (kDebugMode) {
        print(currentDate);
      }
      date = "${currentDate.year}-${currentDate.month}-${currentDate.day}";
      if (currentDate.hour > 18) {
        greeting = "Good Evening,";
      } else if (currentDate.hour >= 12) {
        greeting = "Good Afternoon,";
      }
    });
  }

  Future<void> _getCarousel() async {
    CarouselResponseModel responseModel = CarouselResponseModel(
      msg: "",
      statuscode: 0,
      carouselList: [],
    );
    var prefs = await SharedPreferences.getInstance();
    var authUrl = prefs.getString("auth_url") ?? "";
    String url = "${authUrl}carousels?class_id=1";
    //String url = "https://f18xa7ot97.execute-api.us-east-1.amazonaws.com/carousels?class_id=1";
    http.Response response = await http.get(
      Uri.parse(url),
      headers: {"jwt": prefs.getString("jwtToken") ?? ""},
    );
    if (kDebugMode) {
      print(prefs.getString("jwtToken"));
    }
    // ignore: prefer_typing_uninitialized_variables
    var segRef;
    if (response.statusCode == 200) {
      log("_getCarousel STATUS: ${response.statusCode}");
      log("BODY: ${response.body}");
      segRef = json.decode(response.body);
      responseModel = CarouselResponseModel.fromJson(segRef);
      showSignIn = false;
    } else if (response.statusCode == 404) {
      log("STATUS: ${response.statusCode}");
      log("BODY: ${response.body}");
      responseModel = CarouselResponseModel.fromJson(json.decode('[]'));
    } else {
      log("STATUS: ${response.statusCode}");
      log("BODY: ${response.body}");
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text(json.decode(response.body)['msg'],
      //       textAlign: TextAlign.center),
      // ));
      showSignIn = true;
    }

    carouselList = responseModel.carouselList;
    setState(() {});
  }

  // _getCourses() async {
  //   var prefs = await SharedPreferences.getInstance();
  //   var baseUrl = prefs.getString("base_url") ?? "";
  //   String url = "${baseUrl}api/datamiteCourse/allCourse";
  //
  //   http.Response response = await http.get(Uri.parse(url));
  //   // ignore: prefer_typing_uninitialized_variables
  //   var resp;
  //   if (response.statusCode == 200) {
  //     resp = json.decode(response.body)['courses'];
  //     var test = resp
  //         .map(
  //           (dynamic item) => CourseListModel.fromJson(item),
  //     )
  //         .toList();
  //     coursesList = test.cast<CourseListModel>();
  //   }
  //   setState(() {});
  // }
  //
  // _getCategory() async {
  //   var prefs = await SharedPreferences.getInstance();
  //   var baseUrl = prefs.getString("base_url") ?? "";
  //   String finalUrl = "${baseUrl}api/datamiteCourse/courseCategory";
  //   var resp = await http.get(Uri.parse(finalUrl));
  //   if (resp.statusCode == 200) {
  //     var categories = json.decode(resp.body);
  //     if (categories['success'] == true) {
  //       List<dynamic> body = categories['category'] as List;
  //
  //       categoryList = body
  //           .map(
  //             (dynamic item) => CategoryModel.fromJson(item),
  //       )
  //           .toList();
  //     }
  //   }
  //
  //   setState(() {});
  // }

  Future<void> _refresh() async {
    await _getUserDetail();
    await _getCarousel();
    final snackBar = SnackBar(
      content: const Text('Home Refreshed Successfully'),
      action: SnackBarAction(
        label: 'Refresh Again',
        onPressed: () {
          _refresh();
          // Some code to undo the change.
        },
      ),
    );

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    // ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  String bannerUrl = "";
  String bannerLink = "";

  Future<void> _getBanner() async {
    var prefs = await SharedPreferences.getInstance();
    var authUrl = prefs.getString("auth_url") ?? "";
    if (kDebugMode) {
      print("Auth url is ${authUrl}banner");
    }
    var response = await http.get(Uri.parse("${authUrl}banner"));
    //var response = await http.get(Uri.parse("https://f18xa7ot97.execute-api.us-east-1.amazonaws.com/banner"));

    if (kDebugMode) {
      print("Got banner code ${response.statusCode}");
    }
    if (response.statusCode == 200) {
      log("_get banner STATUS: ${response.statusCode}");
      log("BODY: ${response.body}");
      setState(() {
        bannerUrl = json.decode(response.body)["banner"];
        bannerLink = json.decode(response.body)["url"];
      });
    }
  }

  _gotoUrl(String url) async {
    // ignore: deprecated_member_use
    launch(url);
  }

  Widget _futureBanner() {
    if (bannerUrl.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: MaterialButton(
          splashColor: Colors.green,
          padding: EdgeInsets.zero,
          onPressed: () {
            if (kDebugMode) {
              print(bannerLink);
            }
            _gotoUrl(bannerLink);
          },
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              image: DecorationImage(
                image: NetworkImage(bannerUrl),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _futureBanner1() {
    return MaterialButton(
      splashColor: Colors.green,
      padding: EdgeInsets.zero,
      onPressed: () {
        // _gotoUrl("https://skillogic.com");
      },
      child: Container(
        height: 280,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://firebasestorage.googleapis.com/v0/b/skillogic-a5248.appspot.com/o/footer.png?alt=media&token=5fb20922-0519-48f0-9a7d-3d9f662ab3ae',
            ),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }

  Widget topbanner() {
    final DateTime now = DateTime.now();
    final int hour = now.hour;
    String bannerAsset;

    if (hour >= 5 && hour < 12) {
      // Good Morning
      bannerAsset = 'assets/morning_banner.png';
    } else if (hour >= 12 && hour < 17) {
      // Good Afternoon
      bannerAsset = 'assets/morning_banner.png';
    } else if (hour >= 17 && hour < 21) {
      // Good Evening
      bannerAsset = 'assets/morning_banner.png';
    } else {
      // Night
      bannerAsset = 'assets/night_banner.png';
    }
    return MaterialButton(
      splashColor: Colors.green,
      padding: EdgeInsets.zero,
      onPressed: () {
        _gotoUrl(bannerLink);
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(bannerAsset),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }

  Widget _futureCarouselBuilder() {
    if (showSignIn) {
      return Container();
    } else {
      return FutureBuilder<String>(
        future: null,
        builder: (context, snapshot) {
          if (carouselList.isNotEmpty) {
            return FutureBuilder(
              future: null,
              builder: (BuildContext context, snapshot) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Carousel(carouselList: carouselList),
                );
              },
            );
          } else {
            return const CarouselShimmer();
          }
          return const Text("no data yet");
        },
      );
    }
  }

  Widget _futureSuccessStories() {
    CarouselModel succesStory1 = CarouselModel(
      id: "1",
      image: "https://img.youtube.com/vi/gOLTcIsiwv4/maxresdefault.jpg",
      action: "3",
      sub_action: "",
      external_url:
          "https://www.youtube.com/watch?v=gOLTcIsiwv4&list=PLg9Hha4rflelJ7Ts7ra0GhN_B0x5kT_zB&index=1",
      external_action: "1",
    );
    // CarouselModel succesStory2 = CarouselModel(
    //     id: "2",
    //     image: "https://img.youtube.com/vi/vOqDyOZL71E/maxresdefault.jpg",
    //     action: "3",
    //     sub_action: "",
    //     external_url:
    //     "https://www.youtube.com/watch?v=vOqDyOZL71E&list=PLg9Hha4rflekclpfab8ewDN-1HRAiAqyP&index=1",
    //     external_action: "1");
    var carouselsList = [succesStory1];
    return FutureBuilder<String>(
      future: null,
      builder: (context, snapshot) {
        if (showSignIn) {
          return FutureBuilder(
            future: null,
            builder: (BuildContext context, snapshot) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Carousel(carouselList: carouselsList),
              );
            },
          );
        } else {
          return Container();
        }
      },
    );
    return Container();
  }

  Widget _futureCourseBuilder() {
    return FutureBuilder<String>(
      future: null,
      builder: (context, snapshot) {
        if (coursesList.isNotEmpty) {
          return FutureBuilder(
            future: null,
            builder: (BuildContext context, snapshot) {
              return CourseListPage(
                coursesList: coursesList,
                title: "Our Courses",
              );
            },
          );
        } else {
          return const CardCoursePreviewShimmer();
        }
        return const Text("no data yet");
      },
    );
  }

  Widget _userActivityBuilder() {
    //double itemWidth = (MediaQuery.of(context).size.width - 48) / 2 - 8;
    double itemWidth = ((MediaQuery.of(context).size.width - 48) / 2 - 8) * 0.8;
    double itemHeight = itemWidth; // Making height proportional to width

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.18,
          child: ListView(
            padding: EdgeInsets.all(5),
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            children: [
              MaterialButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EnrolledCourse(),
                    ),
                  );
                },
                child: Container(
                  height: itemHeight,
                  width: itemWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: const Color(0xffd9ebf2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(
                          0,
                          3,
                        ), // changes position of shadow
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: SvgPicture.asset(
                      'assets/Enrollment.svg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.05),
              MaterialButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MultiProvider(
                        providers: [
                          ChangeNotifierProvider(
                            create: (_) => RatingProviderAll(),
                          ),
                        ],
                        child: const RatingPage(pageTitle: "My Ratings"),
                      ),
                    ),
                  );
                },
                child: Container(
                  height: itemHeight,
                  width: itemWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: const Color(0xffd9ebf2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(
                          0,
                          3,
                        ), // changes position of shadow
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: SvgPicture.asset(
                      'assets/RATINGS.svg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.05),
              MaterialButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EnrolledCertificate(),
                    ),
                  );
                },
                child: Container(
                  height: itemHeight,
                  width: itemWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: const Color(0xfffbeaef),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(
                          0,
                          3,
                        ), // changes position of shadow
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: SvgPicture.asset(
                      'assets/CERTIFICATES.svg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.05),
              MaterialButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReferralScreenScaffold(),
                    ),
                  );
                },
                child: Container(
                  height: itemHeight,
                  width: itemWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: const Color(0xfffbeaef),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(
                          0,
                          3,
                        ), // changes position of shadow
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: SvgPicture.asset(
                      'assets/Referral.svg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.18,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.all(5),
            children: [
              MaterialButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TicketPage()),
                  );
                },
                child: Container(
                  height: itemHeight,
                  width: itemWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: const Color(0xfffbeaef),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(
                          0,
                          3,
                        ), // changes position of shadow
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: SvgPicture.asset(
                      'assets/TICKETS.svg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.05),
              MaterialButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DoubtClearScreen(),
                    ),
                  );
                },
                child: Container(
                  height: itemHeight,
                  width: itemWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: const Color(0xfffbeaef),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(
                          0,
                          3,
                        ), // changes position of shadow
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: SvgPicture.asset(
                      'assets/Doubt clear session.svg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.05),
              MaterialButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProjectStatusScreen(),
                    ),
                  );
                },
                child: Container(
                  height: itemHeight,
                  width: itemWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: const Color(0xfffbeaef),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(
                          0,
                          3,
                        ), // changes position of shadow
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: SvgPicture.asset(
                      'assets/project status call.svg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.05),
              MaterialButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HandbookScreen(),
                    ),
                  );
                },
                child: Container(
                  height: itemHeight,
                  width: itemWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: const Color(0xfffbeaef),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(
                          0,
                          3,
                        ), // changes position of shadow
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: SvgPicture.asset(
                      'assets/Candidate handbook.svg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.18,
          child: ListView(
            padding: EdgeInsets.all(5),
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            children: [
              MaterialButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MultiProvider(
                        providers: [
                          ChangeNotifierProvider(
                            create: (context) => TopicCoveredProvider(),
                          ),
                        ],
                        child: TopicsCoveredPage(),
                      ),
                    ),
                  );
                },
                child: Container(
                  height: itemHeight,
                  width: itemWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: const Color(0xffd9ebf2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(
                          0,
                          3,
                        ), // changes position of shadow
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: SvgPicture.asset(
                      'assets/Topics Covered.svg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.05),
              MaterialButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MultiProvider(
                        providers: [
                          ChangeNotifierProvider(
                            create: (context) => AttendanceProvider(),
                          ),
                        ],
                        child: AttendancePage(),
                      ),
                    ),
                  );
                },
                child: Container(
                  height: itemHeight,
                  width: itemWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: const Color(0xffd9ebf2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(
                          0,
                          3,
                        ), // changes position of shadow
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: SvgPicture.asset(
                      'assets/Attendance.svg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            MaterialButton(
              padding: const EdgeInsets.all(0),
              onPressed: () {
                // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                //   content: Text("Coming soon", textAlign: TextAlign.center),
                // ));
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => const LmsHomeScreen()));
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                width: MediaQuery.of(context).size.width - 32,
                // Full screen width
                padding: const EdgeInsets.fromLTRB(4, 16, 4, 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: const Color(0xffe2cdef),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.video_library_outlined,
                      color: Color(0xff9f43ee),
                      size: 100, // Increased icon size further
                    ),
                    SizedBox(
                      width: 4.0, // Increased space between icon and text
                    ),
                    Expanded(
                      child: Text(
                        "Skillogic LMS\n(Coming Soon)",
                        style: TextStyle(
                          fontSize: 25, // Increased text size further
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                          color: Color(0xff9f43ee),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget _futureCategoryBuilder() {
  //   return FutureBuilder<String>(builder: (context, snapshot) {
  //     if (categoryList.isNotEmpty) {
  //       return FutureBuilder(builder: (BuildContext context, snapshot) {
  //         return CategoryPage(categoryList: categoryList);
  //       });
  //     } else {
  //       return Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Container(
  //               margin: const EdgeInsets.fromLTRB(16, 0, 0, 8),
  //               width: 200.0,
  //               height: 20.0,
  //               decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(6.0),
  //                   color: const Color(0x45b6b6b6))),
  //           Container(
  //             height: 80,
  //             padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
  //             child: ListView(
  //               scrollDirection: Axis.horizontal,
  //               children: [1, 2, 3, 4, 5]
  //                   .map((test) => const CardCategoryShimmer())
  //                   .toList(),
  //             ),
  //           )
  //         ],
  //       );
  //     }
  //   });
  // }

  _refreshMain() async {
    bool connected = await ConnectionCheck.isAvailable();
    if (!connected) {
      CustomWidget.showInternetDialog(context);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Connection Lost"),
            content: const Text("Please check your internet connection"),
            actions: [
              MaterialButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainPage()),
                    (route) => false,
                  );
                },
                child: const Text("Ok"),
              ),
            ],
          );
        },
      );
    } else {
      await Future.wait([_getUserDetail(), _getCarousel(), _getBanner()]);
      await requestNotificationPermission();
      //await goTOQRCheck();
      await getLatLong();
      await initUserDatas();
    }
  }

  // //QR code
  // getCameraPermissionStatus() async {
  //   return Permission.camera.status.isGranted;
  // }
  //
  // goTOQRCheck() async {
  //   log("camera permission----");
  //   if (kDebugMode) {
  //     print(await Permission.camera.status);
  //   }
  //
  //   bool status = await getCameraPermissionStatus();
  //   if (kDebugMode) {
  //     print("Status is $status");
  //   }
  //   if (await getCameraPermissionStatus()) {
  //     return true;
  //   } else {
  //     await Permission.camera.request();
  //     if (await Permission.camera.isDenied ||
  //         await Permission.camera.isPermanentlyDenied) {
  //       showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return AlertDialog(
  //             title: const Text("Message"),
  //             content: const Text(
  //               "You need to give permission from system setting.",
  //             ),
  //             actions: [
  //               MaterialButton(
  //                 child: const Text("Cancel"),
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                 },
  //               ),
  //               MaterialButton(
  //                 color: Colors.green,
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                   openAppSettings();
  //                 },
  //                 child: const Text("Ok"),
  //               ),
  //             ],
  //             elevation: 5,
  //           );
  //         },
  //       );
  //     } else {
  //       await Permission.camera.request();
  //     }
  //   }
  //   return await getCameraPermissionStatus();
  // }

  // goToQR() async {
  //   // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>QRScanner()));
  //   bool status = await goTOQRCheck();
  //   if (kDebugMode) {
  //     print("Final Status is $status");
  //   }
  //   if (status) {
  //     Navigator.of(
  //       context,
  //     ).push(MaterialPageRoute(builder: (context) => const QRScanner()));
  //   }
  // }

  //notification permission
  Future<void> requestNotificationPermission() async {
    bool permissionGranted = false;

    while (!permissionGranted) {
      PermissionStatus status = await Permission.notification.request();

      if (status.isGranted) {
        permissionGranted = true; // Exit the loop if permission is granted
      } else {
        await showDialog(
          context: context,
          barrierDismissible: false,
          // Prevent closing the dialog by tapping outside
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Notification Permission Required"),
              content: const Text(
                "To proceed, you must allow notification permissions. Please allow it to continue.",
              ),
              actions: [
                MaterialButton(
                  onPressed: () async {
                    // Request permission again
                    PermissionStatus newStatus =
                        (await openAppSettings()) as PermissionStatus;

                    if (newStatus.isGranted) {
                      permissionGranted = true; // Update the loop condition
                      Navigator.pop(
                        context,
                      ); // Close the dialog if permission is granted
                    }
                  },
                  color: MainColor.skillogicRed,
                  child: const Text(
                    "Allow",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: const Text("Exit"),
                ),
              ],
              elevation: 5,
            );
          },
        );
      }
    }
  }

  Future<void> initUserDatas() async {
    await Future.wait([
      getIp(),
      getMobileInfo(),
      getSessionId(),
      getAppDetails(),
      CandidateRestRequest().getCourseEnrollment(context),
      //CandidateRestRequest().getUserContacts()
    ]);
    if (loggedIn) {
      log(" ");
      sendUserInfo();
      CandidateRestRequest().getUserContacts();
    }
  }

  Future<void> getIp() async {
    try {
      final response = await http
          .get(Uri.parse("https://api.ipify.org"))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 && response.body.trim().isNotEmpty) {
        ipAddress = response.body.trim();
        log("Public IP----- $ipAddress");
      } else {
        log("Failed to fetch IP: ${response.statusCode}");
      }
    } catch (e) {
      log("Public IP fetch failed: $e");
      //rethrow;
    }
  }

  Future<void> getLatLong() async {
    if (loggedIn) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return Dialog(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Permission Required",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Location permission is mandatory to mark attendance",
                      ),
                      SizedBox(height: 10),
                      MaterialButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          permission = await Geolocator.requestPermission();
                          if (permission == LocationPermission.deniedForever) {
                            getLatLong();
                          }
                        },
                        child: Text("Enable"),
                        color: Colors.blueGrey,
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return Dialog(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Open Settings",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text("Enable your location permission to mark attendance"),
                    SizedBox(height: 10),
                    MaterialButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await openAppSettings();
                      },
                      child: Text("Settings"),
                      color: Colors.blueGrey,
                      textColor: Colors.white,
                    ),
                  ],
                ),
              ),
            );
          },
        );
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      lat = position.latitude;
      long = position.longitude;
      timeStamp = position.timestamp.toIso8601String();
      log("not login---${position.latitude.toString()}");
      log("not login---${position.longitude.toString()}");
      log("not login---${position.timestamp.toString()}");
    }
  }

  Future<void> getMobileInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      setState(() {
        platform = "Android";
      });
      AndroidDeviceInfo android = await deviceInfo.androidInfo;
      brand = android.brand;
      model = android.model;
      platform_version = android.version.release;
      log("$platform $brand $model $platform_version");
    } else if (Platform.isIOS) {
      setState(() {
        platform = "IOS";
      });
      IosDeviceInfo ios = await deviceInfo.iosInfo;
      brand = ios.name;
      model = ios.model;
      platform_version = ios.modelName;
      log("$platform $model $brand $ios.modelName");
    }
  }

  Future<void> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    //jwtToken = prefs.getString("jwtToken") ?? "";
    email = prefs.getString("userEmail");
    //sessionId = jwtToken.split('.').last;
    //log("sessionId---- $sessionId");
    log("email---- $email");
    //log("agreement_sent-----${prefs.getBool('agreement_sent').toString()}");
  }

  Future<void> getAppDetails() async {
    PackageInfo info = await PackageInfo.fromPlatform();
    appName = info.appName;
    version = info.version;
    log("$appName,$version");
  }

  Future<void> checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    String jwt_Token = prefs.getString("jwtToken") ?? "";
    final showAgreement = prefs.getBool('agreement_sent');
    log("jwtToken------$jwt_Token");
    log("agreement_sent-------$showAgreement");
    if (showAgreement == false && jwt_Token.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        agreementDialog();
      });
    }
  }

  Future<void> sendUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isUserInfoSent = prefs.getBool("isUserInfoSent") ?? false;
    log("Get user info = $isUserInfoSent");
    if (!isUserInfoSent) {
      log("after login user data is fetched");
      log(
        "$email,$lat,$long,$timeStamp,$appName,$version,$platform,$brand,$model,$ipAddress",
      );
      final body = {
        "email": email,
        "location": {
          "latitude": lat,
          "longitude": long,
          "timestamp": timeStamp,
        },
        "app_details": {"name": appName, "version": version},
        "system_generated_from": {
          "platform": platform,
          "brand": brand,
          "platform_version": platform_version,
          "model": model,
        },
        "ip_address": ipAddress,
      };
      try {
        final url = Uri.parse("https://erp.akshayacorp.com/dm-api/User_device_info_api/save_device_info");
        //final url = Uri.parse("http://192.168.1.51/akshayacorp/sudhanshu-erp/dm-api/User_device_info_api/save_device_info");
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );
        if (response.statusCode == 200) {
          prefs.setBool("isUserInfoSent", true);
          log("user info api body --${response.body}");
          log("-----User data posted successfully");
        } else {
          prefs.setBool("isUserInfoSent", false);
          log("-----Failed to post User data");
        }
      } catch (e) {
        log("Error: $e");
      }
    } else {
      log("-----User Info has been already sent");
      print("testing");
    }
  }

  Future<void> sendAgreementData() async {
    final url = Uri.parse(
      "http://13.232.222.140/aks-stage/dm-api/Learners_agreement_api",
    );
    try {
      log("----try works");
      final response = await http.post(
        url,
        headers: {'content-type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "agree": isChecked,
          "location": {
            "latitude": lat,
            "longitude": long,
            "timestamp": timeStamp,
          },
          "app_details": {"name": appName, "version": version},
          "system_generated_from": {"brand": brand, "model": model},
          "session_id": sessionId,
          "ip_address": ipAddress,
        }),
      );
      if (response.statusCode == 200) {
        // final json = jsonDecode(response.body);
        // log("API Response JSON: $json");
        // bool isagreed = (json['agreement_sent']);
        // final prefs= await SharedPreferences.getInstance();
        // await prefs.setBool('agreement_sent',isagreed);
        // log(prefs.getBool('agreement_sent').toString());
        // log("-----${response.body}");
        Fluttertoast.showToast(msg: "Agreed", gravity: ToastGravity.BOTTOM);
      } else {
        log("Submission failed: ${response.statusCode}");
      }
    } catch (e) {
      log("Exception: $e");
    }
  }

  Future<void> agreementDialog() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.white,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                //margin:EdgeInsetsGeometry.all(10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "DataMites – Learner Agreement",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(height: 5),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text('''
                       By enrolling in the training program offered by DataMites, a brand of Skillfloor Solutions Pvt. Ltd., the learner
(hereinafter referred to as "Student") agrees to the following terms and conditions. This agreement outlines
the mutual understanding of the program structure, student responsibilities, and the services provided as a
bundle.
1. Commitment to Learning Hours
The  Student  acknowledges  that  the  program  requires  a  minimum  of  10  to  15  hours  of  learning  per  week,
inclusive  of  live  instructor-led  sessions,  self-paced  content,  and  practice  time.  The  Student  commits  to
investing the necessary time and effort to benefit from the program fully.
2. Mandatory Attendance for Phase 2
The Student understands that a minimum of 80% attendance is mandatory in Phase 2 of the program, which
consists of live instructor-led training. Failure to meet this attendance requirement may result in ineligibility to
progress to Phase 3, which includes project work, internship opportunities, and placement assistance.
3. Placement Assistance
DataMites supports placement assistance programs from softskills training, resume support, revision skills
areas,  and  support  in  the  placement.  But  DataMites  does  not  offer  any  placement  guarantee  or  100%
placement assurance. This has been clearly communicated and never misrepresented by the Institute either
directly or indirectly. The Student confirms they are fully aware of this before enrollment.
4. Assessment Criteria for Job Interviews
To be eligible for job interview opportunities coordinated by the Institute, the Student must successfully clear
the Job Readiness Assessment with a minimum score of 6.0 out of 10.
5. Batch Transfers and Program Pauses
The  Student  agrees  that  batch  transfers,  breaks,  or  program  rescheduling  are  subject  to  availability.
DataMites will make reasonable efforts to accommodate such requests, but does not guarantee immediate
or customized resolutions.
6. Academic Integrity
The Student agrees to submit all assignments on time and maintain academic integrity. Submissions found
to be plagiarized, including AI-generated or copied from peers, may result in immediate disqualification from
internship.
7. Code of Conduct
The Student is expected to maintain a respectful and collaborative learning environment. Any behavior that
disrupts the learning experience of peers or instructors may lead to disciplinary action or exclusion from parts
of the program.
8. Centralized Communication and Support
All  formal  queries,  suggestions,  or  complaints  must  be  directed  to  the  central  service  desk  via  email  at
care@datamites.com.  A  ticket  number  will  be  generated  and  must  be  quoted  for  all  follow-ups  and
departmental  escalations.  This  centralized  system  applies  to  concerns  related  to  classes,  mentorship,
finance, invoices, batch changes, or placement services.
9. Refund Policy
The refund policy of DataMites is governed by the terms outlined on the official website:
https://datamites.com/refund-policy.  By  enrolling,  the  Student  agrees  to  adhere  to  these  terms,  including
eligibility  conditions,  applicable  timelines,  and  non-refundable  components.  Additionally,  if  the  Student  is
unable to complete the course due to violations related to attendance, conduct, academic integrity, or any
other breach of this agreement, they shall not be eligible to claim a refund under any circumstances.
10. Brand Reputation and Social Media Conduct
The Student agrees not to defame, misrepresent, or publicly malign DataMites or its affiliates on social media
or public platforms. If the Student has any concerns or grievances, they agree to communicate them via the
proper support channels and work constructively with the Institute towards resolution.

By  proceeding  with  enrollment,  the  Student  confirms  having  read,  understood,  and  agreed  to  the  above
terms and conditions in full.
'''),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Checkbox(
                          value: isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              isChecked = value!;
                            });
                          },
                        ),
                        SizedBox(width: 10),
                        // MaterialButton(
                        //   onPressed: () async{
                        //     if(isChecked){
                        //       await postData();
                        //       Navigator.pop(context);
                        //       log("-----$isChecked");
                        //     }
                        //
                        //   },
                        //   child: Text("Agree"),
                        //   color: const Color(0xffe8e8e8),
                        // ),
                        MaterialButton(
                          onPressed: () async {
                            if (isChecked) {
                              try {
                                await sendAgreementData();
                              } catch (e, st) {
                                log("postData failed: $e");
                              } finally {
                                Navigator.pop(context);
                                log("-----$isChecked");
                              }
                            }
                          },
                          child: Text("Agree"),
                          color: const Color(0xffe8e8e8),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _refreshMain();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CoursePercentageService>(
        context,
        listen: false,
      ).getCoursePercentage();
      Provider.of<HomeScreenMessageService>(
        context,
        listen: false,
      ).getMessage();
    });
  }

  String searchText = "";

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    if (kDebugMode) {
      print("Updated");
    }
    // searchText = "";
    // searchController.text = "";
    setState(() {});
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            if (!loggedIn)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Text(
                      "Review Stories",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _futureSuccessStories(),
                  // const SizedBox(
                  //   height: 16,
                  // ),
                ],
              ),
            if (loggedIn)
              // topbanner(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 10),
                    child: Text(
                      "Welcome, $userName !",

                      style: TextStyle(
                        shadows: [
                          Shadow(
                            color: Color(0xffededed),
                            blurRadius: 1,
                            offset: Offset(2, 1),
                          ),
                        ],
                        color: Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Consumer<CoursePercentageService>(
                      builder: (context, provider, child) {
                        if (provider.isLoading) {
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 0.5,
                              color: Colors.blue,
                            ),
                          );
                        }
                        if (provider.courseData.isEmpty) {
                          log(".....-----${provider.courseData}");
                          return SizedBox.shrink();
                        }
                        final courseDetails = provider.courseData[0];
                        final double percentValue =
                            (courseDetails.completionPercentage) / 100;
                        return Container(
                          padding: EdgeInsets.all(5),
                          //height: 130,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(5),
                            //gradient:LinearGradient(colors:[Colors.lightBlueAccent,Colors.white],begin:Alignment.topLeft,end:Alignment.bottomRight)
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Text(
                                        courseDetails.bundleEventName,
                                        style: TextStyle(
                                          color: Colors.white,
                                          //fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  LinearPercentIndicator(
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    animation: true,
                                    lineHeight: 15,
                                    percent: percentValue,
                                    //center:Text("${courseDetails.completionPercentage.toString()}%"),
                                    linearStrokeCap: LinearStrokeCap.roundAll,
                                    progressColor: Colors.white,
                                    backgroundColor: Colors.white60,
                                    barRadius: Radius.circular(20),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      SizedBox(width: 5),
                                      Text(
                                        courseDetails.matchedLocation,
                                        style: TextStyle(
                                          color: Colors.white,
                                          //fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Consumer<HomeScreenMessageService>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 0.5,
                            color: Colors.blue,
                          ),
                        );
                      }
                      return provider.message?.isNotEmpty == true
                          ? Padding(
                              padding: EdgeInsets.only(right: 20, left: 20),
                              child: Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      provider.message!,
                                      maxLines: 3,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SizedBox.shrink();
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: _userActivityBuilder(),
                  ),
                  const SizedBox(height: 16.0),
                  _futureCarouselBuilder(),
                  const SizedBox(height: 16.0),
                ],
              ),

            // _futureCategoryBuilder(),
            // const SizedBox(
            //   height: 16.0,
            // ),
            _futureBanner(),
            const SizedBox(height: 16.0),
            _futureBanner1(),
            if (loggedIn)
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16, 16, 0),
                child: MaterialButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: () {
                    Route route = MaterialPageRoute(
                      builder: (context) => AddReferral(),
                    );
                    Navigator.push(context, route);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    //height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: MainColor.skillogicRed,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(Icons.person_add, color: Colors.white),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  "Refer your friends and family. Win exciting prices and cash backs.",
                                  textAlign: TextAlign.start,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Click here to know more",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // _futureCarouselBuilder(),
            // _futureCourseBuilder()
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

//
// import 'dart:convert';
// import 'package:flutter_svg/svg.dart';
// import 'package:skillogic/helper/user_details.dart';
// import 'package:skillogic/model/category_model.dart';
// import 'package:skillogic/model/course/course_list_model.dart';
// import 'package:skillogic/model/user_model.dart';
// import 'package:skillogic/pages/candidate_portal/enrolled_course.dart';
// import 'package:skillogic/pages/project_statusCall_screen.dart';
// import 'package:skillogic/pages/referral/new_referral.dart';
// import 'package:skillogic/pages/referral/referral_page_scaffold.dart';
// import 'package:skillogic/pages/sub_page/course/course_list_page.dart';
// import 'package:skillogic/provider/rating_provider_all.dart';
// import 'package:skillogic/service/handbook_service.dart';
// import 'package:skillogic/widgets/card_course_preview_shimmer.dart';
// import 'package:skillogic/widgets/carousel.dart';
// import 'package:skillogic/widgets/carousel_shimmer.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
//
//
// import '../helper/color.dart';
// import '../helper/connection.dart';
// import '../model/carousel_model.dart';
// import '../model/carousel_response_model.dart';
// import '../widgets/CustomWidget.dart';
// import 'candidate_portal/enrolled_certificate.dart';
// import 'candidate_portal/payment_page.dart';
// import 'candidate_portal/rating_page.dart';
// import 'doubtClearance_screen.dart';
// import 'freshdesk/ticket_page.dart';
// import 'handbook_screen.dart';
// import 'main_page.dart';
//
//
// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);
//
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
//
// class _HomePageState extends State<HomePage> {
//   var userDetails = UserDetails();
//   List<CarouselModel> carouselList = [];
//   List<CourseListModel> coursesList = [];
//   List<CategoryModel> categoryList = [];
//   bool showSignIn = false;
//   UserModel? userModel;
//   String greeting = "Good Morning,";
//   String date = "";
//   String userName = "";
//   final searchController = TextEditingController();
//   bool loggedIn = false;
//   String userImage =
//       "https://www.sciencefriday.com/wp-content/uploads/2019/09/face-recognition-resized.png";
//
//
//   _getUserDetail() async {
//     userModel = await userDetails.getDetail();
//     setState(() {
//       userName =
//       userModel!.getUserName == "" ? "Stranger" : userModel!.getUserName;
//       loggedIn = userModel!.getUserName != "";
//       var currentDate = DateTime.now();
//       if (kDebugMode) {
//         print(currentDate);
//       }
//       date = "${currentDate.year}-${currentDate.month}-${currentDate.day}";
//       if (currentDate.hour > 18) {
//         greeting = "Good Evening,";
//       } else if (currentDate.hour >= 12) {
//         greeting = "Good Afternoon,";
//       }
//     });
//   }
//
//
//   _getCarousel() async {
//     CarouselResponseModel responseModel =
//     CarouselResponseModel(msg: "", statuscode: 0, carouselList: []);
//     var prefs = await SharedPreferences.getInstance();
//     var authUrl = prefs.getString("auth_url") ?? "";
//     String url = "${authUrl}carousels?class_id=1";
//     http.Response response = await http.get(Uri.parse(url),
//         headers: {"jwt": prefs.getString("jwtToken") ?? ""});
//     if (kDebugMode) {
//       print(prefs.getString("jwtToken"));
//     }
//     // ignore: prefer_typing_uninitialized_variables
//     var segRef;
//     if (response.statusCode == 200) {
//       segRef = json.decode(response.body);
//       responseModel = CarouselResponseModel.fromJson(segRef);
//       showSignIn = false;
//     } else if (response.statusCode == 404) {
//       responseModel = CarouselResponseModel.fromJson(json.decode('[]'));
//     } else {
//       // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       //   content: Text(json.decode(response.body)['msg'],
//       //       textAlign: TextAlign.center),
//       // ));
//       showSignIn = true;
//     }
//
//
//     carouselList = responseModel.carouselList;
//     setState(() {});
//   }
//
//
//   _getCourses() async {
//     var prefs = await SharedPreferences.getInstance();
//     var baseUrl = prefs.getString("base_url") ?? "";
//     String url = "${baseUrl}api/datamiteCourse/allCourse";
//
//
//     http.Response response = await http.get(Uri.parse(url));
//     // ignore: prefer_typing_uninitialized_variables
//     var resp;
//     if (response.statusCode == 200) {
//       resp = json.decode(response.body)['courses'];
//       var test = resp
//           .map(
//             (dynamic item) => CourseListModel.fromJson(item),
//       )
//           .toList();
//       coursesList = test.cast<CourseListModel>();
//     }
//     setState(() {});
//   }
//
//
//   _getCategory() async {
//     var prefs = await SharedPreferences.getInstance();
//     var baseUrl = prefs.getString("base_url") ?? "";
//     String finalUrl = "${baseUrl}api/datamiteCourse/courseCategory";
//     var resp = await http.get(Uri.parse(finalUrl));
//     if (resp.statusCode == 200) {
//       var categories = json.decode(resp.body);
//       if (categories['success'] == true) {
//         List<dynamic> body = categories['category'] as List;
//
//
//         categoryList = body
//             .map(
//               (dynamic item) => CategoryModel.fromJson(item),
//         )
//             .toList();
//       }
//     }
//
//
//     setState(() {});
//   }
//
//
//   Future<void> _refresh() async {
//     await _getUserDetail();
//     await _getCarousel();
//     final snackBar = SnackBar(
//       content: const Text('Home Refreshed Succesfully'),
//       action: SnackBarAction(
//         label: 'Refresh Again',
//         onPressed: () {
//           _refresh();
//           // Some code to undo the change.
//         },
//       ),
//     );
//
//
//     // Find the ScaffoldMessenger in the widget tree
//     // and use it to show a SnackBar.
//     // ignore: use_build_context_synchronously
//     // ScaffoldMessenger.of(context).showSnackBar(snackBar);
//   }
//
//
//   String bannerUrl = "";
//   String bannerLink = "";
//
//
//   _getBanner() async {
//     var prefs = await SharedPreferences.getInstance();
//     var authUrl = prefs.getString("auth_url") ?? "";
//     if (kDebugMode) {
//       print("Auth url is ${authUrl}banner");
//     }
//     var response = await http.get(Uri.parse("${authUrl}banner"));
//     if (kDebugMode) {
//       print("Got banner code ${response.statusCode}");
//     }
//     if (response.statusCode == 200) {
//       setState(() {
//         bannerUrl = json.decode(response.body)["banner"];
//         bannerLink = json.decode(response.body)["url"];
//       });
//     }
//   }
//
//
//   _gotoUrl(String url) async {
//     // ignore: deprecated_member_use
//     launch(url);
//   }
//
//
//   Widget _futureBanner() {
//     if (bannerUrl.isNotEmpty) {
//       return Container(
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//           child: MaterialButton(
//             splashColor: Colors.green,
//             padding: EdgeInsets.zero,
//             onPressed: () {
//               if (kDebugMode) {
//                 print(bannerLink);
//               }
//               _gotoUrl(bannerLink);
//             },
//             child: Container(
//               height: 120,
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10.0),
//                   image: DecorationImage(
//                       image: NetworkImage(
//                         bannerUrl,
//                       ),
//                       fit: BoxFit.fill)),
//             ),
//           ));
//     } else {
//       return Container();
//     }
//   }
//
//
//   Widget _futureBanner1() {
//     return MaterialButton(
//       splashColor: Colors.green,
//       padding: EdgeInsets.zero,
//       onPressed: () {
//         // _gotoUrl("https://skillogic.com");
//       },
//       child: Container(
//         height: 280,
//         decoration: const BoxDecoration(
//             image:
//             DecorationImage(
//               image: NetworkImage('https://firebasestorage.googleapis.com/v0/b/skillogic-a5248.appspot.com/o/footer.png?alt=media&token=5fb20922-0519-48f0-9a7d-3d9f662ab3ae'),
//               fit: BoxFit.fill,
//             )),
//       ),
//     );
//   }
//
//
//
//
//   Widget topbanner() {
//     final DateTime now = DateTime.now();
//     final int hour = now.hour;
//     String bannerAsset;
//
//
//     if (hour >= 5 && hour < 12) {
//       // Good Morning
//       bannerAsset = 'assets/morning_banner.png';
//     } else if (hour >= 12 && hour < 17) {
//       // Good Afternoon
//       bannerAsset = 'assets/morning_banner.png';
//     } else if (hour >= 17 && hour < 21) {
//       // Good Evening
//       bannerAsset = 'assets/morning_banner.png';
//     } else {
//       // Night
//       bannerAsset = 'assets/night_banner.png';
//     }
//     return MaterialButton(
//       splashColor: Colors.green,
//       padding: EdgeInsets.zero,
//       onPressed: () {
//         _gotoUrl(bannerLink);
//       },
//       child: Container(
//         height: 100,
//         decoration: BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage(bannerAsset),
//               fit: BoxFit.fill,
//             )),
//       ),
//     );
//   }
//
//
//   Widget _futureCarouselBuilder() {
//     if (showSignIn) {
//       return Container();
//     } else {
//       return FutureBuilder<String>(future:null,builder: (context, snapshot) {
//         if (carouselList.isNotEmpty) {
//           return FutureBuilder(future:null,builder: (BuildContext context, snapshot) {
//             return Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
//                 child: Carousel(carouselList: carouselList));
//           });
//         } else {
//           return const CarouselShimmer();
//         }
//         return const Text("no data yet");
//       });
//     }
//   }
//
//
//   Widget _futureSuccessStories() {
//     CarouselModel succesStory1 = CarouselModel(
//         id: "1",
//         image: "https://img.youtube.com/vi/gOLTcIsiwv4/maxresdefault.jpg",
//         action: "3",
//         sub_action: "",
//         external_url:
//         "https://www.youtube.com/watch?v=gOLTcIsiwv4&list=PLg9Hha4rflelJ7Ts7ra0GhN_B0x5kT_zB&index=1",
//         external_action: "1");
//     CarouselModel succesStory2 = CarouselModel(
//         id: "2",
//         image: "https://img.youtube.com/vi/vOqDyOZL71E/maxresdefault.jpg",
//         action: "3",
//         sub_action: "",
//         external_url:
//         "https://www.youtube.com/watch?v=vOqDyOZL71E&list=PLg9Hha4rflekclpfab8ewDN-1HRAiAqyP&index=1",
//         external_action: "1");
//     var carouselsList = [succesStory1, succesStory2];
//     return FutureBuilder<String>(future:null,builder: (context, snapshot) {
//       if (showSignIn) {
//         return FutureBuilder(future:null,builder: (BuildContext context, snapshot) {
//           return Padding(
//               padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
//               child: Carousel(carouselList: carouselsList));
//         });
//       } else {
//         return Container();
//       }
//     });
//     return Container();
//   }
//
//
//   Widget _futureCourseBuilder() {
//     return FutureBuilder<String>(future:null,builder: (context, snapshot) {
//       if (coursesList.isNotEmpty) {
//         return FutureBuilder(future:null,builder: (BuildContext context, snapshot) {
//           return CourseListPage(
//             coursesList: coursesList,
//             title: "Our Courses",
//           );
//         });
//       } else {
//         return const CardCoursePreviewShimmer();
//       }
//       return const Text("no data yet");
//     });
//   }
//
//
//   Widget _userActivityBuilder() {
//     //double itemWidth = (MediaQuery.of(context).size.width - 48) / 2 - 8;
//     double itemWidth = ((MediaQuery.of(context).size.width - 48) / 2 - 8) * 0.8;
//     double itemHeight = itemWidth; // Making height proportional to width
//
//
//
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         SizedBox(height:10),
//         SizedBox(height: MediaQuery.of(context).size.height * 0.18,
//           child: ListView( padding:EdgeInsets.all(5),physics:BouncingScrollPhysics(),
//             scrollDirection:Axis.horizontal,
//             children: [
//               MaterialButton(
//                 padding: EdgeInsets.zero,
//                 onPressed: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const EnrolledCourse()));
//                 },
//                 child: Container(
//                   height: itemHeight,
//                   width: itemWidth,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10.0),
//                     color: const Color(0xffd9ebf2),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.5),
//                         spreadRadius: 2,
//                         blurRadius: 5,
//                         offset: const Offset(0, 3), // changes position of shadow
//                       ),
//                     ],
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(10.0),
//                     child: SvgPicture.asset(
//                       'assets/enroll_icon.svg',
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(width:MediaQuery.of(context).size.width*0.05),
//               MaterialButton(
//                 padding: EdgeInsets.zero,
//                 onPressed: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => MultiProvider(
//                             providers: [
//                               ChangeNotifierProvider(
//                                   create: (_) => RatingProviderAll()),
//                             ],
//                             child: const RatingPage(pageTitle: "My Ratings"),
//                           )));
//                 },
//                 child: Container(
//                   height: itemHeight,
//                   width: itemWidth,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10.0),
//                     color: const Color(0xffd9ebf2),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.5),
//                         spreadRadius: 2,
//                         blurRadius: 5,
//                         offset: const Offset(0, 3), // changes position of shadow
//                       ),
//                     ],
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(10.0),
//                     child: SvgPicture.asset(
//                       'assets/rating_icon.svg',
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(width:MediaQuery.of(context).size.width*0.05),
//               MaterialButton(
//                 padding: const EdgeInsets.all(0),
//                 onPressed: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const EnrolledCertificate()));
//                 },
//                 child: Container(
//                   height: itemHeight,
//                   width: itemWidth,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10.0),
//                     color: const Color(0xfffbeaef),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.5),
//                         spreadRadius: 2,
//                         blurRadius: 5,
//                         offset: const Offset(0, 3), // changes position of shadow
//                       ),
//                     ],
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(10.0),
//                     child: SvgPicture.asset(
//                       'assets/certificate_icon.svg',
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(width:MediaQuery.of(context).size.width*0.05),
//               MaterialButton(
//                 padding: const EdgeInsets.all(0),
//                 onPressed: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const ReferralScreenScaffold()));
//                 },
//                 child: Container(
//                   height: itemHeight,
//                   width: itemWidth,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10.0),
//                     color: const Color(0xfffbeaef),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.5),
//                         spreadRadius: 2,
//                         blurRadius: 5,
//                         offset: const Offset(0, 3), // changes position of shadow
//                       ),
//                     ],
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(10.0),
//                     child: SvgPicture.asset(
//                       'assets/My Referral.svg',
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         SizedBox(
//           height: MediaQuery.of(context).size.height * 0.18,
//           child: ListView(scrollDirection:Axis.horizontal,
//             physics:BouncingScrollPhysics(),
//             padding:EdgeInsets.all(5),
//             children: [
//               MaterialButton(
//                 padding: const EdgeInsets.all(0),
//                 onPressed: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const TicketPage()));
//                 },
//                 child: Container(
//                   height: itemHeight,
//                   width: itemWidth,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10.0),
//                     color: const Color(0xfffbeaef),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.5),
//                         spreadRadius: 2,
//                         blurRadius: 5,
//                         offset: const Offset(0, 3), // changes position of shadow
//                       ),
//                     ],
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(10.0),
//                     child: SvgPicture.asset(
//                       'assets/Your Ticket.svg',
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(width:MediaQuery.of(context).size.width*0.05),
//               MaterialButton(
//                 padding: const EdgeInsets.all(0),
//                 onPressed: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const DoubtClearScreen()));
//                 },
//                 child: Container(
//                   height: itemHeight,
//                   width: itemWidth,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10.0),
//                     color: const Color(0xfffbeaef),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.5),
//                         spreadRadius: 2,
//                         blurRadius: 5,
//                         offset: const Offset(0, 3), // changes position of shadow
//                       ),
//                     ],
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(10.0),
//                     child: SvgPicture.asset(
//                       'assets/Doubt clear session.svg',
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(width:MediaQuery.of(context).size.width*0.05),
//               MaterialButton(
//                 padding: const EdgeInsets.all(0),
//                 onPressed: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const ProjectStatusScreen()));
//                 },
//                 child: Container(
//                   height: itemHeight,
//                   width: itemWidth,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10.0),
//                     color: const Color(0xfffbeaef),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.5),
//                         spreadRadius: 2,
//                         blurRadius: 5,
//                         offset: const Offset(0, 3), // changes position of shadow
//                       ),
//                     ],
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(10.0),
//                     child: SvgPicture.asset(
//                       'assets/project status call.svg',
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(width:MediaQuery.of(context).size.width*0.05),
//               MaterialButton(
//                 padding: const EdgeInsets.all(0),
//                 onPressed: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => ChangeNotifierProvider(create:(context) => HandbookProvider(),child:HandbookScreen())));
//                 },
//                 child: Container(
//                   height: itemHeight,
//                   width: itemWidth,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10.0),
//                     color: const Color(0xfffbeaef),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.5),
//                         spreadRadius: 2,
//                         blurRadius: 5,
//                         offset: const Offset(0, 3), // changes position of shadow
//                       ),
//                     ],
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(10.0),
//                     child: SvgPicture.asset(
//                       'assets/Candidate handbook.svg',
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             MaterialButton(
//               padding: const EdgeInsets.all(0),
//               onPressed: () {
//                 // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                 //   content: Text("Coming soon", textAlign: TextAlign.center),
//                 // ));
//                 // Navigator.push(
//                 //     context,
//                 //     MaterialPageRoute(
//                 //         builder: (context) => const LmsHomeScreen()));
//               },
//               child: Container(
//                 margin: const EdgeInsets.fromLTRB(0, 16, 0, 0),
//                 width: MediaQuery.of(context).size.width - 32,
//                 // Full screen width
//                 padding: const EdgeInsets.fromLTRB(4, 16, 4, 16),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10.0),
//                   color: const Color(0xffe2cdef),
//                 ),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: const [
//                     Icon(
//                       Icons.video_library_outlined,
//                       color: Color(0xff9f43ee),
//                       size: 100, // Increased icon size further
//                     ),
//                     SizedBox(
//                       width: 4.0, // Increased space between icon and text
//                     ),
//                     Expanded(
//                       child: Text(
//                         "Skillogic LMS\n(Coming Soon)",
//                         style: TextStyle(
//                           fontSize: 25, // Increased text size further
//                           fontWeight: FontWeight.w500,
//                           fontStyle: FontStyle.normal,
//                           color: Color(0xff9f43ee),
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//
//
//
//
//
//   _refreshMain() async {
//     bool connected = await ConnectionCheck.isAvailable();
//     if (!connected) {
//       CustomWidget.showInternetDialog(context);
//       showDialog(
//           context: context,
//           builder: (context) {
//             return AlertDialog(
//               title: const Text("Connection Lost"),
//               content: const Text("Please check your internet connection"),
//               actions: [
//                 MaterialButton(
//                   onPressed: () {
//                     Navigator.pushAndRemoveUntil(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const MainPage()),
//                             (route) => false);
//                   },
//                   child: const Text("Ok"),
//                 )
//               ],
//             );
//           });
//     } else {
//       _getUserDetail();
//       _getCarousel();
//       _getCourses();
//       _getCategory();
//       _getBanner();
//     }
//   }
//
//
//   @override
//   void initState() {
//     _refreshMain();
//     super.initState();
//   }
//
//
//   String searchText = "";
//
//
//   @override
//   void didUpdateWidget(covariant HomePage oldWidget) {
//     if (kDebugMode) {
//       print("Updated");
//     }
//     searchText = "";
//     searchController.text = "";
//     setState(() {});
//     super.didUpdateWidget(oldWidget);
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return RefreshIndicator(
//       onRefresh: _refresh,
//       child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (!loggedIn)
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Padding(
//                       padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
//                       child: Text(
//                         "Review Stories",
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.w700),
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 4,
//                     ),
//                     _futureSuccessStories(),
//                     // const SizedBox(
//                     //   height: 16,
//                     // ),
//                   ],
//                 ),
//               if (loggedIn)
//               // topbanner(),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
//                       child: _userActivityBuilder(),
//                     ),
//                     const SizedBox(
//                       height: 16.0,
//                     ),
//                     _futureCarouselBuilder(),
//                     // const SizedBox(
//                     //   height: 16.0,
//                     // ),
//                   ],
//                 ),
//
//
//
//
//               // _futureCategoryBuilder(),
//               // const SizedBox(
//               //   height: 16.0,
//               // ),
//               _futureBanner(),
//               const SizedBox(
//                 height: 16.0,
//               ),
//               _futureBanner1(),
//               if (loggedIn)
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(16.0, 16, 16, 0),
//                   child: MaterialButton(
//                     padding: const EdgeInsets.all(0),
//                     onPressed: () {
//                       Route route = MaterialPageRoute(
//                           builder: (context) => AddReferral());
//                       Navigator.push(context, route);
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.all(16),
//                       //height: 120,
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all()),
//                       child: Row(
//                         children: [
//                           Container(
//                             width: 88,
//                             height: 88,
//                             decoration: BoxDecoration(
//                                 color: MainColor.skillogicRed,
//                                 borderRadius: BorderRadius.circular(8)),
//                             child: const Center(
//                               child: Icon(
//                                 Icons.person_add,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                               child: Padding(
//                                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: const [
//                                     Text(
//                                       "Refer your friends and family. Win exciting prices and cashbacks.",
//                                       textAlign: TextAlign.start,
//                                     ),
//                                     SizedBox(height:5),
//                                     Text(
//                                       "Click here to know more",
//                                       style: TextStyle(fontWeight: FontWeight.w600),
//                                     )
//                                   ],
//                                 ),
//                               ))
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               const SizedBox(
//                 height: 30,
//               ),
//               // _futureCarouselBuilder(),
//               // _futureCourseBuilder()
//             ],
//           )),
//     );
//   }
// }
//
