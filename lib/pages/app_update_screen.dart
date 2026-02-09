// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// class AppUpdateScreen extends StatefulWidget {
//   const AppUpdateScreen({super.key});
//
//   @override
//   State<AppUpdateScreen> createState() => _AppUpdateScreenState();
// }
//
// class _AppUpdateScreenState extends State<AppUpdateScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 // height: 400,
//                 // width: 150,
//                 child: Image(image: AssetImage("assets/datamites.png")),
//               ),
//              SizedBox(height:70),
//              Column(children: [
//                Text(
//                  "New Update Available",
//                  style: TextStyle(fontSize:MediaQuery.of(context).size.width*0.07, fontWeight: FontWeight.bold),
//                ),
//                SizedBox(height: 20),
//                Text(
//                  "   We’ve made improvements and fixed \nbugs to give you a smoother experience.",
//                  style: TextStyle(fontWeight: FontWeight.w400,fontSize:15),
//                ),
//                SizedBox(height:40),
//                MaterialButton(onPressed: () {
//                  launchUrl(Uri.parse("https://play.google.com/store/apps/details?id=com.dmrefer.mobile"));
//                }, child:Text("Update"),color:Colors.purple,textColor:Colors.white)
//              ],)
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
