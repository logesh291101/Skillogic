// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:skillogic/pages/sub_page/internship_notEligible_screen.dart';
// import '../helper/color.dart';
// import '../helper/user_details.dart';
// import '../model/user_model.dart';
// import '../service/internship_batchDetails_service.dart';
// import '../widgets/CustomWidget.dart';
//
//
// class InternshipApplicationForm extends StatefulWidget {
//   const InternshipApplicationForm({super.key});
//
//   @override
//   _InternshipApplicationFormState createState() =>
//       _InternshipApplicationFormState();
// }
//
// class _InternshipApplicationFormState extends State<InternshipApplicationForm> {
//   final _formKey = GlobalKey<FormState>();
//   TextEditingController emailController = TextEditingController();
//   TextEditingController nameController = TextEditingController();
//   TextEditingController phoneController = TextEditingController();
//   TextEditingController batchController = TextEditingController();
//   TextEditingController linkedinController = TextEditingController();
//   TextEditingController experienceController = TextEditingController();
//   TextEditingController graduationResultController = TextEditingController();
//   TextEditingController postGraduationResultController =
//       TextEditingController();
//   TextEditingController ctcController = TextEditingController();
//
//   String? addressProof;
//   String? nocFile;
//   int? eduBackground;
//   String? selectedFilePath;
//   String? selectedFileName;
//
//   void _addFile() async {
//     FilePickerResult? results = await FilePicker.platform.pickFiles();
//     if (results != null) {
//       PlatformFile file = results.files.first;
//       log("------${file.name} , ${file.path}");
//       setState(() {
//         selectedFilePath = file.path;
//         selectedFileName = file.name;
//       });
//     }
//   }
//
//   int? leadId;
//   int? bundleId;
//   int? enrollmentId;
//
//   Future<void> getIds() async {
//     final provider =
//         Provider.of<InternshipBatchProvider>(context, listen: false);
//     await provider.fetchBatchDetails();
//     final ids = provider.batchDetails?.data.first;
//     if (ids != null) {
//       leadId = int.parse(ids.leadId);
//       bundleId = int.parse(ids.bundleEventId);
//       enrollmentId = int.parse(ids.enrollmentId);
//     }
//
//     log("leadId-${leadId}");
//     log("bundleId-${bundleId}");
//     log("enrollmentId-${enrollmentId}");
//   }
//
//
//   int refreshed = 0;
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
//     print("🔥 Loaded InternshipApplicationForm from HERE");
//     _getUserDetail();
//     super.initState();
//     getIds();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: CustomWidget.getSkillogicAppBar(context, userModel, 1),
//       body: Consumer<InternshipBatchProvider>(
//           builder: (context, provider, child) {
//         if (provider.batchDetails == null) {
//           return Center(child: CircularProgressIndicator());
//         }
//         if (provider.batchDetails!.eligibilityStatus == 0) {
//           return NotEligibleScreen();
//         }
//         final batchDetail = provider.batchDetails!.data;
//         return SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Form(
//               key: _formKey,
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       "Internship Application Form",
//                       style:
//                           TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
//                     ),
//                     const SizedBox(height: 20),
//                     Container(
//                         child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         RichText(
//                             text: TextSpan(children: [
//                           TextSpan(
//                               text: "Name: ",
//                               style: TextStyle(
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.black,
//                                   fontSize: 17)),
//                           TextSpan(
//                               text: batchDetail.first.name,
//                               style: TextStyle(
//                                   color: Colors.black54, fontSize: 17))
//                         ])),
//                         SizedBox(height: 8),
//                         RichText(
//                             text: TextSpan(children: [
//                           TextSpan(
//                               text: "Email: ",
//                               style: TextStyle(
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.black,
//                                   fontSize: 17)),
//                           TextSpan(
//                               text: batchDetail.first.email,
//                               style: TextStyle(
//                                   color: Colors.black54, fontSize: 17))
//                         ])),
//                         SizedBox(height: 8),
//                         RichText(
//                             text: TextSpan(children: [
//                           TextSpan(
//                               text: "Phone: ",
//                               style: TextStyle(
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.black,
//                                   fontSize: 17)),
//                           TextSpan(
//                               text:
//                                   "${batchDetail.first.isoCode} ${batchDetail.first.phoneNumber}",
//                               style: TextStyle(
//                                   color: Colors.black54, fontSize: 17))
//                         ])),
//                         SizedBox(height: 8),
//                         RichText(
//                             text: TextSpan(children: [
//                           TextSpan(
//                               text: "Batch code: ",
//                               style: TextStyle(
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.black,
//                                   fontSize: 17)),
//                           TextSpan(
//                               text: batchDetail.first.batchDetails,
//                               style: TextStyle(
//                                   color: Colors.black54, fontSize: 17))
//                         ])),
//
//                         // Text("Name: ${batchDetail!.first.name}"),
//                         // SizedBox(height: 5),
//                         // Text("Email: ${batchDetail.first.email}"),
//                         // SizedBox(height: 5),
//                         // Text("Phone: ${batchDetail.first.isoCode} ${batchDetail.first.phoneNumber}"),
//                         // SizedBox(height: 5),
//                         // Text("Batch code: ${batchDetail.first.batchDetails}")
//                       ],
//                     )),
//                     SizedBox(height: 10),
//                     Text("Please fill the below details",
//                         style: TextStyle(color: Colors.red)),
//                     // TextFormField(
//                     //   readOnly:true,
//                     //   controller:emailController,
//                     //   decoration: const InputDecoration(
//                     //       labelText: 'Email',
//                     //       hintText: 'Enter your email address',
//                     //       border: OutlineInputBorder(),
//                     //       contentPadding:
//                     //           EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
//                     //   keyboardType: TextInputType.emailAddress,
//                     //   validator: (value) =>
//                     //       value!.isEmpty ? 'Please enter your Email' : null,
//                     //   autovalidateMode: AutovalidateMode.onUserInteraction,
//                     // ),
//                     // const SizedBox(height: 20),
//                     // TextFormField(
//                     //   readOnly:true,
//                     //   controller: nameController,
//                     //   decoration: const InputDecoration(
//                     //       labelText: 'Name',
//                     //       hintText: 'Enter your full name',
//                     //       border: OutlineInputBorder(),
//                     //       contentPadding:
//                     //           EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
//                     //   validator: (value) =>
//                     //       value!.isEmpty ? 'Please enter your Name' : null,
//                     //   autovalidateMode: AutovalidateMode.onUserInteraction,
//                     // ),
//                     // const SizedBox(height: 20),
//                     // IntlPhoneField(
//                     //   controller:phoneController,
//                     //   readOnly:true,
//                     //   },
//                     //   decoration: InputDecoration(
//                     //       labelText: 'Phone Number',
//                     //       hintText: 'Enter your mobile number',
//                     //       border: OutlineInputBorder(),
//                     //   onChanged:(phone) {
//                     //       contentPadding:
//                     //           EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
//                     //   initialCountryCode: "IN",
//                     //   keyboardType: TextInputType.phone,
//                     // ),
//                     // const SizedBox(height: 20),
//                     // TextFormField(
//                     //   readOnly:true,
//                     //   controller:batchController,
//                     //   decoration: const InputDecoration(
//                     //       labelText: 'Batch Details',
//                     //       hintText: 'Enter your batch code',
//                     //       border: OutlineInputBorder(),
//                     //       contentPadding:
//                     //           EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
//                     //   validator: (value) =>
//                     //       value!.isEmpty ? "Please enter your Batch details" : null,
//                     //   autovalidateMode: AutovalidateMode.onUserInteraction,
//                     // ),
//                     const SizedBox(height: 20),
//                     TextFormField(
//                       controller: linkedinController,
//                       decoration: const InputDecoration(
//                           labelText: 'LinkedIn Profile',
//                           hintText: 'https://www.linkedin.com/in/your-profile',
//                           border: OutlineInputBorder(),
//                           contentPadding: EdgeInsets.symmetric(
//                               horizontal: 20, vertical: 15)),
//                       validator: (value) {
//                         if (value!.isEmpty) {
//                           return 'Please enter your LinkedIn Profile URL';
//                         }
//                         if (!value.startsWith("https://www.linkedin.com/")) {
//                           return 'Enter a valid URL';
//                         }
//                       },
//                       autovalidateMode: AutovalidateMode.onUserInteraction,
//                     ),
//                     const SizedBox(height: 20),
//                     Text("Educational Background"),
//                     Row(
//                       children: [
//                         Radio(
//                           value: 1,
//                           groupValue: eduBackground,
//                           onChanged: (value) {
//                             setState(() {
//                               eduBackground = value;
//                             });
//                           },
//                         ),
//                         Text("IT", style: TextStyle(fontSize: 17))
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         Radio(
//                           value: 2,
//                           groupValue: eduBackground,
//                           onChanged: (value) {
//                             setState(() {
//                               eduBackground = value;
//                             });
//                           },
//                         ),
//                         Text("Non IT", style: TextStyle(fontSize: 17)),
//                       ],
//                     ),
//                     const SizedBox(height: 5),
//                     eduBackground == null
//                         ? Text("Please select Educational Background",
//                             style: TextStyle(color: Colors.red))
//                         : SizedBox.shrink(),
//                     const SizedBox(height: 20),
//
//                     TextFormField(
//                       controller: graduationResultController,
//                       decoration: const InputDecoration(
//                           labelText: 'Under Graduation Result',
//                           hintText: 'Mention CGPA / Percentage',
//                           border: OutlineInputBorder(),
//                           contentPadding: EdgeInsets.symmetric(
//                               horizontal: 20, vertical: 15)),
//                       keyboardType: TextInputType.number,
//                       validator: (value) {
//                         if (value!.isEmpty) {
//                           return "Please enter your UG Result";
//                         }
//                         final num? parsed = num.tryParse(value);
//                         if (parsed == null) {
//                           return "Please enter a valid number";
//                         }
//                       },
//                       //value!.isEmpty ? "Please enter your UG Result" : null,
//                       autovalidateMode: AutovalidateMode.onUserInteraction,
//                     ),
//                     const SizedBox(height: 20),
//                     TextFormField(
//                       controller: postGraduationResultController,
//                       decoration: const InputDecoration(
//                           labelText: 'Post Graduation Result',
//                           hintText: 'Mention CGPA / Percentage',
//                           border: OutlineInputBorder(),
//                           contentPadding: EdgeInsets.symmetric(
//                               horizontal: 20, vertical: 15)),
//                       keyboardType: TextInputType.number,
//                       validator: (value) {
//                         if (value != null && value.isNotEmpty) {
//                           final num? parsed = num.tryParse(value);
//                           if (parsed == null) {
//                             return "Please enter a valid number";
//                           }
//                         }
//                       },
//                       autovalidateMode: AutovalidateMode.onUserInteraction,
//                     ),
//                     const SizedBox(height: 20),
//                     TextFormField(
//                       controller: experienceController,
//                       decoration: const InputDecoration(
//                           labelText: 'Experience',
//                           hintText: "Mention in years (e.g. 2.5)",
//                           border: OutlineInputBorder(),
//                           contentPadding: EdgeInsets.symmetric(
//                               horizontal: 20, vertical: 15)),
//                       keyboardType: TextInputType.number,
//                       validator: (value) {
//                         if (value != null && value.isNotEmpty) {
//                           final num? parsed = num.tryParse(value);
//                           if (parsed == null) {
//                             return "Please enter a valid number";
//                           }
//                         }
//                       },
//                       autovalidateMode: AutovalidateMode.onUserInteraction,
//                     ),
//                     const SizedBox(height: 20),
//                     TextFormField(
//                       controller: ctcController,
//                       decoration: const InputDecoration(
//                           labelText: 'Current Annual Salary',
//                           hintText: 'Mention in lakhs (e.g. 3.5)',
//                           border: OutlineInputBorder(),
//                           contentPadding: EdgeInsets.symmetric(
//                               horizontal: 20, vertical: 15)),
//                       keyboardType: TextInputType.number,
//                       validator: (value) {
//                         if (value != null && value.isNotEmpty) {
//                           final num? parsed = num.tryParse(value);
//                           if (parsed == null) {
//                             return "Please enter a valid number";
//                           }
//                         }
//                       },
//                       autovalidateMode: AutovalidateMode.onUserInteraction,
//                     ),
//                     const SizedBox(height: 20),
//                     // ListTile(
//                     //   title: const Text(
//                     //       'Upload Address Proof (Aadhar/Driving License)'),
//                     //   subtitle: Text(addressProof ?? 'No file selected'),
//                     //   trailing: const Icon(Icons.upload_file),
//                     //   onTap: () => _pickFile(true),
//                     // ),
//                     // ListTile(
//                     //   title: const Text('Upload NOC from Exam Team (PDF)'),
//                     //   subtitle: Text(nocFile ?? 'No file selected'),
//                     //   trailing: const Icon(Icons.upload_file),
//                     //   onTap: () => _pickFile(false),
//                     // ),
//                     GestureDetector(
//                       onTap: () {
//                         _addFile();
//                       },
//                       child: LayoutBuilder(builder: (context, constrains) {
//                         double iconSize = constrains.maxWidth * 0.09;
//                         return Container(
//                           padding: EdgeInsets.all(5),
//                           decoration: BoxDecoration(
//                               border: Border.all(color: Colors.black45),
//                               borderRadius: BorderRadius.circular(10)),
//                           // height: MediaQuery.of(context).size.height*0.13,
//                           // width: MediaQuery.of(context).size.width*.80,
//                           child: Row(
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.only(left: 20),
//                                 child: Icon(Icons.upload_file, size: iconSize),
//                               ),
//                               SizedBox(width: 20),
//                               Column(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceEvenly,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                       'Upload Address Proof \n(Aadhar/Driving License)'),
//                                   //Text(selectedFile != null ? ${selectedFile} : 'No file selected',style:TextStyle(color:Colors.red)),
//                                   selectedFilePath != null
//                                       ? Text(selectedFileName.toString(),
//                                           style: TextStyle(color: Colors.red))
//                                       : Text('No file selected',
//                                           style: TextStyle(color: Colors.red))
//                                 ],
//                               ),
//                             ],
//                           ),
//                         );
//                       }),
//                     ),
//                     const SizedBox(height: 20),
//                     Center(
//                       child: ElevatedButton(
//                         onPressed: () {
//                           if (_formKey.currentState!.validate())
//                             showDialog(
//                               context: context,
//                               barrierDismissible: false,
//                               builder: (BuildContext context) {
//                                 return const Center(child: CircularProgressIndicator(color:Colors.white,strokeWidth:5));
//                               },
//                             );
//                             Provider.of<InternshipBatchProvider>(context,
//                                     listen: false)
//                                 .PostInternshipDetails(
//                                     leadId!,
//                                     bundleId!,
//                                     enrollmentId!,
//                                     selectedFilePath!,
//                                     linkedinController.text,
//                                     eduBackground!,
//                                     num.parse(graduationResultController.text),
//                                     postGraduationResultController.text.isEmpty
//                                         ? null
//                                         : num.parse(
//                                             postGraduationResultController
//                                                 .text),
//                                     experienceController.text.isEmpty
//                                         ? null
//                                         : num.parse(experienceController.text),
//                                     ctcController.text.isEmpty
//                                         ? null
//                                         : num.parse(ctcController.text),
//                                     context);
//
//                           // ScaffoldMessenger.of(context).showSnackBar(
//                           //   const SnackBar(
//                           //       content: Text('Form Submitted Successfully')),
//                           // );
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: MainColor.datamiteOrange,
//                           minimumSize: const Size(150, 50),
//                         ),
//                         child: const Text('Submit',
//                             style:
//                                 TextStyle(color: Colors.white, fontSize: 20)),
//                       ),
//                     ),
//                     // MaterialButton(onPressed: () {
//                     //   Navigator.push(context,MaterialPageRoute(builder: (context) => NotEligibleScreen()));
//                     // },child:Text("eligible")),
//                     SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       }),
//     );
//   }
// }
