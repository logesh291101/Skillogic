// import 'package:flutter/material.dart';
// import 'package:expansion_tile_group/expansion_tile_group.dart';
//
// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key});
//
//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//     body:SafeArea(
//       child: Column(crossAxisAlignment:CrossAxisAlignment.start,children: [
//         Padding(
//           padding: const EdgeInsets.all(16),
//           child: Text("ChatBox",style:TextStyle(fontWeight:FontWeight.bold,fontSize:17)),
//         ),
//        ExpansionTileGroup(children: [
//          ExpansionTileItem(title:Text("How do I access my live classes?"), children:[Text('''You can join live sessions from the My Classes section inside your dashboard. Links are updated before each session.''')]),
//          ExpansionTileItem(title:Text("Are class recordings available?"), children:[Text('''Yes, recordings are uploaded within 24 hours of the live class. You can watch them anytime under “Recorded Sessions.”''')]),
//          ExpansionTileItem(title:Text("Can I reschedule a missed session?"), children:[Text('''Live sessions cannot be rescheduled, but you can watch the recording and ask doubts in the discussion forum.''')]),
//          ExpansionTileItem(title:Text("How do I ask doubts during the course?"), children:[Text('''You can raise questions in the live chat, post in the student forum, or reach your mentor via email/Slack.''')]),
//          ExpansionTileItem(title:Text("What software/tools do I need for the course?"), children:[Text('''We recommend Anaconda, Jupyter Notebook, Python 3.x, and Google Colab for practice. Instructions will be shared during class.''')])
//        ],
//        )
//       ]),
//     ),
//     );
//   }
// }
