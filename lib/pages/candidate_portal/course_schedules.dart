import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:skillogic/pages/candidate_portal/data_model/ScheduleModel.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../helper/user_details.dart';
import '../../model/user_model.dart';
import '../../widgets/CustomWidget.dart';

class CourseSchedules extends StatefulWidget {
  final String title;
  final List<ScheduleModel> courseSchedules;
  final String courseType;
  const CourseSchedules(
      {Key? key, required this.title, required this.courseSchedules,required this.courseType})
      : super(key: key);

  @override
  State<CourseSchedules> createState() => _CourseSchedulesState();
}

class _CourseSchedulesState extends State<CourseSchedules> {
  _gotoUrl(String url) async {
    // ignore: deprecated_member_use
    launch(url);
  }



  var userDetails = UserDetails();
  UserModel? userModel;

  _getUserDetail() async {
    userModel = await userDetails.getDetail();
    setState(() {});
  }



  @override
  void initState() {
    _getUserDetail();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomWidget.getSkillogicAppBar(context, userModel, 1),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              height: 16,
            ),
            for (ScheduleModel schedule in widget.courseSchedules)
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                padding: const EdgeInsets.all(8.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.black38),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_sharp, size: 16),
                        const SizedBox(width: 8,),
                        Text(
                          DateFormat('dd/MM/yyyy').format(DateTime.parse(schedule.event_start_date)),
                        ),
                        Spacer(),
                        Icon(Icons.access_time_rounded, size: 18),SizedBox(width: 8,),
                        Text("${schedule.event_start_time.length == 8 ? schedule.event_start_time.substring(0,5):schedule.event_start_time} "
                            "to ${schedule.event_end_time.length == 8 ? schedule.event_end_time.substring(0,5):schedule.event_end_time} (IST)"),
                      ],
                    ),
                    SizedBox(height:5),
                    Padding(
                        padding: EdgeInsets.fromLTRB(0,5, 0, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.person_outline,
                                  size: 18,
                                ),
                                Text(
                                    " ${schedule.trainer_name}")
                              ],
                            ),
                          ],
                        )),
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding:
                              const EdgeInsets.fromLTRB(0, 5, 0, 0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Text("Class Type: ",style:TextStyle(fontWeight:FontWeight.bold,color:Colors.redAccent)),
                                    Text(widget.courseType),
                                    Spacer(),
                                    widget.courseType == "Online" ?
                                    Icon(Icons.video_camera_front,color:Colors.blue,size: 18) :
                                    Icon(Icons.location_history,color:Colors.blue,size: 18)
                                  ]),
                                  SizedBox(height:5),
                                  widget.courseType == "Classroom" ?  Row(children: [
                                    Text("Center: "),
                                    Text(schedule.centre_name)
                                  ]) :
                                  Column(crossAxisAlignment:CrossAxisAlignment.start,
                                      children: [
                                        Text("Metting Link: ",style:TextStyle(fontWeight:FontWeight.w600)),
                                        schedule.meeting_link.isEmpty ? Text("Link not available") :
                                        Row(children: [
                                          Text(schedule.meeting_link,style:TextStyle(color:Colors.blue)),
                                          Spacer(),
                                          IconButton(onPressed:() {
                                            Clipboard.setData(ClipboardData(text:schedule.meeting_link));
                                          }, icon:Icon(Icons.copy))
                                        ],)
                                      ])
                                ],
                              )),
                        ],
                      ),
                    )
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
