import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import '../helper/user_details.dart';
import '../model/project_statusCall_model.dart';
import '../model/user_model.dart';
import '../service/project_statusCall_service.dart';
import '../widgets/CustomWidget.dart';


class ProjectStatusScreen extends StatefulWidget {
  const ProjectStatusScreen({super.key});

  @override
  State<ProjectStatusScreen> createState() => _ProjectStatusScreenState();
}

class _ProjectStatusScreenState extends State<ProjectStatusScreen> {
  var userDetails = UserDetails();
  UserModel? userModel;
  late Future<List<StatusCall>> projectStatusData;
  ProjectStatusService projectStatusService = ProjectStatusService();

  _getUserDetail() async {
    userModel = await userDetails.getDetail();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getUserDetail();
    projectStatusData = projectStatusService.fetchStatusCall();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // bottomNavigationBar:SizedBox(height:30),
        //backgroundColor: const Color(0xfff6f6f6),
        backgroundColor: Colors.white,
        appBar: CustomWidget.getSkillogicAppBar(context, userModel, 1),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 2.0, 0, 0),
                child: Text(
                  "Project Status Call",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: 15),

              Expanded(
                child: FutureBuilder<List<StatusCall>>(
                    future: projectStatusData,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text("No data available"));
                      }
                      return ListView.separated(
                          physics: BouncingScrollPhysics(),
                          separatorBuilder: (context, index) {
                            return Divider(color: Colors.white, thickness: 0);
                          },
                          itemBuilder: (context, index) {
                            return Details(statusCall: snapshot.data![index]);
                          },
                          itemCount: snapshot.data!.length);
                    }),
              ),
              SizedBox(height: 20)
            ]),
          ),
        ));
  }
}

class Style {
  TextStyle day =
      TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black);
  TextStyle date = TextStyle(color: Colors.black, fontSize: 15);
  TextStyle name = TextStyle(color: Colors.black, fontSize: 16);
}

class Details extends StatelessWidget {
  final StatusCall statusCall;
  Details({super.key, required this.statusCall});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      //height: MediaQuery.of(context).size.height * 0.29,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          border: Border.all(color: Colors.black12),
          boxShadow: [
            BoxShadow(
                blurRadius: 3,
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                offset: Offset(1, 3))
          ]),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              children: [
                Icon(Icons.circle, color: Colors.blueAccent, size: 15),
                SizedBox(width: 5),
                Text(statusCall.day, style: Style().day)
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 15),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(children: [
                    Icon(Icons.person, color: Colors.black54),
                    SizedBox(width: 5),
                    Text(statusCall.trainerName, style: Style().name)
                  ]),
                  SizedBox(height: 10),
                  Row(children: [
                    Icon(Icons.watch_later_outlined, color: Colors.black54),
                    SizedBox(width: 8), // Space between icon and text
                    Text(statusCall.date, style: Style().date),
                    SizedBox(width: 8),
                    Container(height: 20, width: 3, color: Colors.black54),
                    SizedBox(width: 8),
                    Text(statusCall.time, style: Style().date),
                  ]),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 10),
                        width: MediaQuery.of(context).size.width * 0.5,
                        //height: MediaQuery.of(context).size.height * 0.05,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Meeting Link:"),
                            SizedBox(height: 3),
                            SelectableText(
                              (statusCall.meetingLink != null &&
                                  statusCall.meetingLink.toString().isNotEmpty)
                                  ? "${statusCall.meetingLink}"
                                  : "Link not available",
                              maxLines: 1,
                              style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.blue,
                                  overflow: TextOverflow.ellipsis),
                              toolbarOptions:
                                  ToolbarOptions(copy: true, selectAll: true),
                            ),
                          ],
                        ),
                      ),
                      if (statusCall.meetingLink != null &&
                          statusCall.meetingLink.toString().isNotEmpty)
                        Row(
                          children: [
                            GestureDetector(
                                onTap: () {
                                  log("----copy");
                                  Clipboard.setData(ClipboardData(
                                      text: statusCall.meetingLink));
                                  Fluttertoast.showToast(
                                    msg: "Link Copied",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.TOP,
                                    backgroundColor: Colors.black87,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                },
                                child: Container(
                                  child: Icon(Icons.copy, color: Colors.red),
                                  padding: EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                      color: Color(0xfffbe3e3),
                                      borderRadius: BorderRadius.circular(5),
                                      border:
                                          Border.all(color: Color(0xfffbb9b9))),
                                )),
                            SizedBox(width: 10),
                            GestureDetector(
                                onTap: () {
                                  Share.share(statusCall.meetingLink);
                                },
                                child: Container(
                                  child: Icon(Icons.share, color: Colors.green),
                                  padding: EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                      color: Color(0xffe8f4e8),
                                      borderRadius: BorderRadius.circular(5),
                                      border:
                                          Border.all(color: Color(0xff96d58b))),
                                ))
                          ],
                        )
                      else
                        SizedBox(width:MediaQuery.of(context).size.width*0.2)
                    ],
                  ),
                ]),
          ),
        ],
      ),
    );
  }
}
