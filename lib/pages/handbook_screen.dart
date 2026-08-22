// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
// import '../helper/user_details.dart';
// import '../model/user_model.dart';
// import '../service/handbook_service.dart';
// import '../widgets/CustomWidget.dart';
//
//
// class HandbookScreen extends StatefulWidget {
//   const HandbookScreen({super.key});
//
//   @override
//   State<HandbookScreen> createState() => _HandbookScreenState();
// }
//
// class _HandbookScreenState extends State<HandbookScreen> {
//   var userDetails = UserDetails();
//   UserModel? userModel;
//
//   _getUserDetail() async {
//     userModel = await userDetails.getDetail();
//     setState(() {});
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _getUserDetail();
//     Provider.of<HandbookProvider>(context, listen: false).fetchHandbook();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: CustomWidget.getSkillogicAppBar(context, userModel, 1),
//       body: SafeArea(
//         child: Consumer<HandbookProvider>(
//           builder: (context, value, child) {
//             if (value.handbookLink == null || value.handbookName == null) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             if (value.handbookName!.isEmpty || value.handbookLink!.isEmpty){
//               return Center(child:Text("No data available"));
//             }
//             return Padding(
//               padding: const EdgeInsets.all(10),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(16.0, 2.0, 0, 0),
//                     child: Text(
//                       "HandBooks",
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 15),
//                   Expanded(
//                     child: ListView(
//                       children: [
//                         GestureDetector(
//                           child: Container(
//                             padding: EdgeInsets.all(10),
//                             // height:MediaQuery.of(context).size.height*0.02,
//                             // width: MediaQuery.of(context).size.width*0.02,
//                             decoration: BoxDecoration(
//                               border: Border.all(
//                                 color: Colors.black12,
//                                 width: 2,
//                               ),
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Center(
//                               child: Row(
//                                 children: [
//                                   Icon(
//                                     Icons.picture_as_pdf_sharp,
//                                     size:
//                                         MediaQuery.of(context).size.height *
//                                         0.05,
//                                     color: Colors.redAccent,
//                                   ),
//                                   SizedBox(width: 10),
//                                   Text(
//                                     value.handbookName.toString(),
//                                     style: TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 17,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => PdfScreen(
//                                   link: value.handbookLink.toString(),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//
// class PdfScreen extends StatelessWidget {
//   final String link;
//
//   const PdfScreen({super.key, required this.link});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           icon: Icon(Icons.arrow_back),
//         ),
//       ),
//       body: SafeArea(child: SfPdfViewer.network(link)),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../helper/user_details.dart';
import '../model/user_model.dart';
import '../service/handbook_service.dart';
import '../widgets/CustomWidget.dart';

class HandbookScreen extends StatefulWidget {
  const HandbookScreen({super.key});

  @override
  State<HandbookScreen> createState() => _HandbookScreenState();
}

class _HandbookScreenState extends State<HandbookScreen> {
  var userDetails = UserDetails();
  UserModel? userModel;

  _getUserDetail() async {
    userModel = await userDetails.getDetail();
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserDetail();
    //Provider.of<HandbookProvider>(context, listen: false).fetchHandbook();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HandbookProvider>(context, listen: false)
          .fetchHandbook();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomWidget.getSkillogicAppBar(context, userModel, 1),
      body: SafeArea(
        child: Consumer<HandbookProvider>(
          builder: (context, provider, child) {
            if (provider.isloading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.handbooks.isEmpty){
              return Center(child:Text("No data available"));
            }
            return Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 2.0, 0, 0),
                    child: Text(
                      "HandBooks",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Expanded(
                    child: ListView.separated(
                      itemCount:provider.handbooks.length,
                      separatorBuilder:(context, index) {
                        return SizedBox(height:20);
                      },
                      itemBuilder:(context, index) {
                        final handbook = provider.handbooks[index];
                        return
                          GestureDetector(
                            child: handbook.handbookLink.isNotEmpty && handbook.handbookName.isNotEmpty ?
                            Container(
                              padding: EdgeInsets.all(10),
                              // height:MediaQuery.of(context).size.height*0.02,
                              // width: MediaQuery.of(context).size.width*0.02,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black12,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.picture_as_pdf_sharp,
                                      size:
                                      MediaQuery.of(context).size.height *
                                          0.05,
                                      color: Colors.redAccent,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      handbook.handbookName.toString(),

                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ) : SizedBox(),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PdfScreen(
                                   link: handbook.handbookLink.toString(),
                                  ),
                                ),
                              );
                            },
                          );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class PdfScreen extends StatelessWidget {
  final String link;

  const PdfScreen({super.key, required this.link});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(child: SfPdfViewer.network(link)),
    );
  }
}
