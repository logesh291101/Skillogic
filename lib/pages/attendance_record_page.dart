import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../model/attendance_record_model.dart';
import '../service/attendance_record_service.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  DateTime today = DateTime.now();
  Map<DateTime, Color> dateColors = {};
  Schedule? selectedSchedule;

  @override
  void initState() {
    super.initState();
    // Fetch attendance data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AttendanceProvider>(context, listen: false)
          .getAttendanceDetails()
          .then((_) => _generateDateColors());
    });
  }

  void _generateDateColors() {
    final attendanceData =
        Provider.of<AttendanceProvider>(context, listen: false).attendanceData;
    if (attendanceData == null) return;

    dateColors.clear();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    for (var course in attendanceData.data) {
      for (var schedule in course.schedules) {
        final date = schedule.trainerScheduleDate;
        final normalizedDate = DateTime(date.year, date.month, date.day);
        
        // Store with normalized date as key to ensure proper matching in calendar
        // If date is in the future (after today), show grey
        if (normalizedDate.isAfter(today)) {
          dateColors[normalizedDate] = Colors.black12; // future - ash/grey
        } else {
          // Date is today or in the past, check attendance status
          if (schedule.attendanceStatus == "1") {
            dateColors[normalizedDate] = Color(0xff9bbf5d); // present - green
          } else if(schedule.attendanceStatus == "0"){
            dateColors[normalizedDate] = Color(0xffed6969); // absent - red
          }
        }
      }
    }
    setState(() {});
  }

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      today = day;
      selectedSchedule = null;

      final now = DateTime.now();
      final todayNormalized = DateTime(now.year, now.month, now.day);
      final selectedDayNormalized = DateTime(day.year, day.month, day.day);
      
      // Only set selectedSchedule if the date is today or in the past
      if (selectedDayNormalized.isAfter(todayNormalized)) {
        return; // Future date - don't show details
      }

      final attendanceData =
          Provider.of<AttendanceProvider>(context, listen: false)
              .attendanceData;
      if (attendanceData != null) {
        for (var course in attendanceData.data) {
          for (var schedule in course.schedules) {
            if (isSameDay(schedule.trainerScheduleDate, day)) {
              selectedSchedule = schedule;
              break;
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Scaffold(
            appBar: AppBar(title: Text("Attendance Records")),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final attendanceData = provider.attendanceData;

        if (attendanceData == null) {
          return Scaffold(
            appBar: AppBar(title: Text("Attendance Records")),
            body: Center(child: Text("No attendance data found.")),
          );
        }

        if (attendanceData.data.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text("Attendance Records")),
            body: Center(child: Text("No attendance records available.")),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text("Attendance Records")),
          body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TableCalendar(
                  daysOfWeekHeight:25.0,
                  focusedDay: today,
                  firstDay: DateTime.utc(2025, 1, 1),
                  lastDay: DateTime.utc(2050, 12, 31),
                  selectedDayPredicate: (day) => isSameDay(day, today),
                  onDaySelected: _onDaySelected,
                  calendarStyle: CalendarStyle(
                    markersMaxCount: 0,
                    canMarkersOverflow: false,
                    outsideDaysVisible: false,
                    cellAlignment: Alignment.center,
                    cellPadding: EdgeInsets.zero,
                    selectedDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    todayDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    defaultDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    weekendDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      // Normalize the day to match the keys in dateColors
                      final normalizedDay = DateTime(day.year, day.month, day.day);
                      final color = dateColors[normalizedDay];
                      if (color != null) {
                        return Center(
                          child: Container(
                            height: 40,
                            width: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                            ),
                            child: Text(
                              day.day.toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      final lightPurple = Color(0xFFB39DDB); // Light purple
                      final now = DateTime.now();
                      final isToday = isSameDay(day, now);
                      
                      // If selected date is today, show purple instead of light purple
                      if (isToday) {
                       // final purple = Color(0xFFA52EB6); // Purple
                        return Center(
                          child: Container(
                            height: 40,
                            width: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF9854A1),
                            ),
                            child: Text(
                              day.day.toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }
                      
                      return Center(
                        child: Container(
                          height: 40,
                          width: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: lightPurple,
                          ),
                          child: Text(
                            day.day.toString(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                    todayBuilder: (context, day, focusedDay) {
                      final purple = Color(0xFF9854A1); // Purple
                      final isSelected = isSameDay(day, today);
                      // If today is also selected, selectedBuilder will handle it
                      if (isSelected) {
                        return null;
                      }
                      
                      return Center(
                        child: Container(
                          height: 40,
                          width: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: purple,
                          ),
                          child: Text(
                            day.day.toString(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                  headerStyle: HeaderStyle(
                      titleCentered: true, formatButtonVisible: false),
                ),
                SizedBox(height:20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.circle, color: Color(0xff9bbf5d)),
                        SizedBox(width: 5),
                        Text("Present"),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.circle, color: Color(0xffed6969)),
                        SizedBox(width: 5),
                        Text("Absent"),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.circle, color: Colors.black12),
                        SizedBox(width: 5),
                        Text("Class Available"),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: _buildDetailsContainer(attendanceData),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailsContainer(AttendanceRecordModel attendanceData) {
    if (selectedSchedule == null) {
      return Center(
        child: Text(
          "No data for the selected date",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      );
    }

    final now = DateTime.now();
    final scheduleDate = selectedSchedule!.trainerScheduleDate;
    final todayNormalized = DateTime(now.year, now.month, now.day);
    final scheduleDateNormalized = DateTime(scheduleDate.year, scheduleDate.month, scheduleDate.day);
    
    // Don't show details for future dates
    if (scheduleDateNormalized.isAfter(todayNormalized)) {
      return Center(
        child: Text(
          "No data for the selected date",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      );
    }

    final course = attendanceData.data
        .firstWhere((c) => c.schedules.contains(selectedSchedule));

    final isPresent = selectedSchedule!.attendanceStatus == "1";
    final formattedDate = "${selectedSchedule!.trainerScheduleDate.day}-${selectedSchedule!.trainerScheduleDate.month}-${selectedSchedule!.trainerScheduleDate.year}";

    // Different order for absent vs present
    if (isPresent) {
      // Present: Date, Course Name, Topic, Present, Scan Date
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today),
              SizedBox(width: 5),
              Text(
                formattedDate,
                style: TextStyle(),
              ),Spacer(),
              Text(
                "Present",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          if (selectedSchedule!.scanDate != null) ...[
            SizedBox(height: 5),
            Row(
              children: [
                Text("Check-In Time: ",style:TextStyle(color:Colors.grey,fontWeight:FontWeight.bold)),
                Text(DateFormat("hh:mm a").format(DateTime.parse(selectedSchedule!.scanDate))),
              ],
            ),
          ],
          SizedBox(height: 5),
          Text(
            course.courseName,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 5),
          Column(
            crossAxisAlignment:CrossAxisAlignment.start,
            children: [
              Text("Topic Covered: ",style:TextStyle(color:Colors.grey,fontWeight:FontWeight.bold)),
              Text("${selectedSchedule!.topic ?? 'Not updated'}"),
            ],
          ),
        ],
      );
    }
    else if(selectedSchedule!.attendanceStatus == "0"){
      // Absent: Absent, Course Name, Topic, Date
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today),
              SizedBox(width: 5),
              Text(
                formattedDate,
              ),Spacer(),
              Text(
                "Absent",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Text(
            course.courseName,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 5),
          Column(
            crossAxisAlignment:CrossAxisAlignment.start,
            children: [
              Text("Topic Covered: ",style:TextStyle(color:Colors.grey,fontWeight:FontWeight.bold)),
              Text("${selectedSchedule!.topic ?? 'Not updated'}"),
            ],
          ),

        ],
      );
    }
    return Center(child:Text("No attendance data available",style:TextStyle(fontWeight:FontWeight.w500)));
  }
}
