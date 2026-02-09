import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import '../helper/user_details.dart';
import '../model/user_model.dart';
import '../service/topics_covered_service.dart';
import 'package:provider/provider.dart';

import '../widgets/CustomWidget.dart';


class TopicsCoveredPage extends StatefulWidget {
  const TopicsCoveredPage({super.key});

  @override
  State<TopicsCoveredPage> createState() => _TopicsCoveredPageState();
}

class _TopicsCoveredPageState extends State<TopicsCoveredPage> {
  UserModel? userModel;
  var userDetails = UserDetails();

  _getUserDetail() async {
    userModel = await userDetails.getDetail();
    setState(() {});
    log("--------");
  }

  @override
  @override
  void initState() {
    super.initState();
    _getUserDetail();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TopicCoveredProvider>(context, listen: false)
          .getTopicCoveredDetails();
    });
  }


  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomWidget.getSkillogicAppBar(context, userModel, 1),
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(13),
            child: Consumer<TopicCoveredProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }
                
                if (provider.topicCoveredModel == null) {
                  return Center(child: Text("No data available"));
                }
                
                final courses = provider.topicCoveredModel?.data ?? [];
                if (courses.isEmpty) {
                  return Center(child: Text("No data available"));
                }
                // --- TODAY'S TOPIC ---
                Map<String, dynamic>? todayTopicData;

                for (var course in courses) {
                  for (var schedule in course.schedules) {
                    DateTime scheduleDate = schedule.trainerScheduleDate.toLocal();
                    if (scheduleDate.year == today.year &&
                        scheduleDate.month == today.month &&
                        scheduleDate.day == today.day) {
                      todayTopicData = {
                        "courseName": course.courseName,
                        "topic": (schedule.topic == null || schedule.topic!.isEmpty) ? "Not updated" : schedule.topic,

                        "date": scheduleDate,
                      };
                      break;
                    }
                  }
                  if (todayTopicData != null) break;
                }

                // --- PAST TOPICS ---
                final pastSchedules = <Map<String, dynamic>>[];

                for (var course in courses) {
                  for (var schedule in course.schedules) {
                    DateTime scheduleDate = schedule.trainerScheduleDate.toLocal();
                    if (scheduleDate.isBefore(today)) {
                      pastSchedules.add({
                        "courseName": course.courseName,
                        "topic": (schedule.topic == null || schedule.topic!.isEmpty) ? "Not updated" : schedule.topic,

                        "date": scheduleDate,
                      });
                    }
                  }
                }

                // Sort past schedules by date descending
                pastSchedules.sort((a, b) =>
                    (b["date"] as DateTime).compareTo(a["date"] as DateTime));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Learning Journey - Daily Progress",
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    if (todayTopicData != null)
                    Text(
                      "Today's Topic",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold, color: Colors.redAccent
                      ),
                    ),
                    todayTopicData != null ? SizedBox(height: 10): SizedBox.shrink(),

                    if(todayTopicData != null)
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Row(
                              children: [
                                Expanded(child: Text(todayTopicData["courseName"],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                                Text(DateFormat("MMM, dd").format(
                                    DateTime.parse(
                                        todayTopicData["date"]
                                            .toString())),
                                    ),
                              ],
                            ),

                            SizedBox(height: 10),
                            Column(crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Topic:",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,color:Colors.grey
                                  ),
                                ), SizedBox(width: 10),
                                Text(
                                  todayTopicData != null && todayTopicData["topic"] != null && todayTopicData["topic"].toString().isNotEmpty
                                      ? todayTopicData["topic"]
                                      : "Not updated",
                                ),
                              ],
                            ),

                          ],
                        ),
                      ),
                    todayTopicData != null ? SizedBox(height: 20) : SizedBox.shrink(),
                    Text(
                      "Past Topics",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold, color: Colors.redAccent),
                    ),
                    SizedBox(height: 5),
                    Expanded(
                      child: ListView
                          .separated(separatorBuilder:(context, index) =>Divider(color:Colors.white), itemCount:pastSchedules.length,itemBuilder: (context, index) {
                            final item = pastSchedules[index];
                            return Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey),
                              ),
                              child:Column(
                                crossAxisAlignment:CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat("MMMM, dd yyyy").format(DateTime.parse(item["date"].toString())),
                                    style: const TextStyle(
                                       fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    item["courseName"],
                                    style: const TextStyle(
                                       fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  Column(
                                    crossAxisAlignment:CrossAxisAlignment.start,
                                    children: [
                                      Text("Topic Covered: ",style:TextStyle(fontWeight:FontWeight.bold,color:Colors.grey)),
                                      Text(
                                        "${item["topic"]}",
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },),
                    ),
                  ],
                );
              },
            )
        ),
      ),
    );
  }
}
