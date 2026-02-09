import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../helper/user_details.dart';
import '../model/doubuClearance_Model.dart';
import '../model/user_model.dart';
import '../service/doubtClearance_service.dart';
import '../service/internship_batchDetails_service.dart';
import '../widgets/CustomWidget.dart';


class DoubtClearScreen extends StatefulWidget {
  const DoubtClearScreen({super.key});

  @override
  State<DoubtClearScreen> createState() => _DoubtClearScreenState();
}

class _DoubtClearScreenState extends State<DoubtClearScreen> {
  var userDetails = UserDetails();
  int? enrollmentId;
  UserModel? userModel;
  late Future<List<Schedule>> doubtClearenceData;
  final DoubtClearanceService doubtClearanceService = DoubtClearanceService();

  _getUserDetail() async {
    userModel = await userDetails.getDetail();
    setState(() {});
    log("--------");
  }

  Future<void> getIds() async {
    final provider =
    Provider.of<InternshipBatchProvider>(context, listen: false);
    await provider.fetchBatchDetails();
    final ids = provider.batchDetails?.data.first;
    if (ids != null) {
      enrollmentId = int.parse(ids.enrollmentId);
    }
    log("enrollmentId----$enrollmentId");
  }

  @override
  void initState() {
    _getUserDetail();
    super.initState();
    getIds();
    doubtClearenceData = doubtClearanceService.fetchDoubtSession();
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
                  "Doubt Clear Session",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: 15),
              Expanded(
                child: FutureBuilder<List<Schedule>>(
                    future: doubtClearenceData,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text("No data available"));
                      }
                      return ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          separatorBuilder: (context, index) {
                            return Divider(color: Colors.white, thickness: 0);
                          },
                          itemBuilder: (context, index) {
                            return Details(schedule: snapshot.data![index]);
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
      TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black);
  TextStyle date = TextStyle(color: Colors.black, fontSize: 15);
  TextStyle name = TextStyle(color: Colors.black, fontSize: 15);
}

class Details extends StatelessWidget {
  final Schedule schedule;

  Details({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10),
        //height: MediaQuery.of(context).size.height * 0.27,
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 3,
                offset: Offset(1, 3),
              ),
            ],
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          child: Icon(
                            CupertinoIcons.calendar_today,
                            color: Color(0xff0092ff),
                          ),
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Color(0xffd1e8ff)),
                        ),
                        SizedBox(width: 8),
                        Text(schedule.day, style: Style().day),
                      ],
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Row(children: [
                        Container(
                            height: MediaQuery.of(context).size.height * 0.09,
                            width: 4,
                            color: Colors.black12),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.menu_book,
                                    color: Colors.black26),
                                SizedBox(width: 8),
                                // Space between icon and text
                               Text( schedule.course,style:Style().name)


                              ],
                            ), SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(Icons.person, color: Colors.black26),
                                SizedBox(width: 8),
                                // Space between icon and text
                                Text(schedule.trainerName, style: Style().name),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(Icons.watch_later_outlined,
                                    color: Colors.black26),
                                SizedBox(width: 8),
                                // Space between icon and text
                                Text(schedule.date),
                                SizedBox(width: 8),
                                Container(
                                    height: 20,
                                    width: 3,
                                    color: Colors.black12),
                                SizedBox(width: 8),
                                Text("${schedule.time}", style: Style().date),
                              ],
                            ),
                          ],
                        )
                      ]),
                    ),
                   const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Meeting Link:"),
                              SizedBox(height: 3),
                              Container(
                                //height: MediaQuery.of(context).size.height * 0.05,
                                width: MediaQuery.of(context).size.width * 0.5,
                                //padding: EdgeInsets.only(),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  //color: Color(0xfff3f1f1)
                                ),
                                child: SelectableText(
                                    (schedule.meetingLink != null && schedule.meetingLink.toString().isNotEmpty)
                                        ? "${schedule.meetingLink}"
                                        : "Link not available",
                                    //overflow: TextOverflow.ellipsis,
                                    toolbarOptions: ToolbarOptions(
                                        copy: true, selectAll: true),
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.blue)),
                              ),
                            ]),
                        if (schedule.meetingLink != null &&
                            schedule.meetingLink.toString().isNotEmpty)
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(
                                      text: schedule.meetingLink));
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
                                    padding: EdgeInsets.all(9),
                                    child: Icon(Icons.copy, color: Colors.red),
                                    decoration: BoxDecoration(
                                        color: Color(0xfffbe3e3),
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                            color: Color(0xfffbb9b9)))),
                              ),
                              SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  Share.share(schedule.meetingLink);
                                },
                                child: Container(
                                    padding: EdgeInsets.all(9),
                                    child:
                                        Icon(Icons.share, color: Colors.green),
                                    decoration: BoxDecoration(
                                        color: Color(0xffe8f4e8),
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                            color: Color(0xff96d58b)))),
                              )
                            ],
                          )
                        else
                          SizedBox()
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
