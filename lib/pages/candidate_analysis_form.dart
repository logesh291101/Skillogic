// // ignore_for_file: library_private_types_in_public_api
// // ignore_for_file: use_build_context_synchronously
//
// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import '../helper/color.dart';
// import '../helper/user_details.dart';
// import '../model/user_model.dart';
// import '../widgets/CustomWidget.dart';
//
// class CandidateOnboardingForm extends StatefulWidget {
//   const CandidateOnboardingForm({Key? key}) : super(key: key);
//
//   @override
//   _CandidateOnboardingFormState createState() => _CandidateOnboardingFormState();
// }
//
// class _CandidateOnboardingFormState extends State<CandidateOnboardingForm> {
//   final TextEditingController _firstnameController = TextEditingController();
//   final TextEditingController _lastnameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _mobileController = TextEditingController();
//   final TextEditingController _dobController = TextEditingController();
//   final TextEditingController _companyController = TextEditingController();
//   final TextEditingController _linkedInProfileLinkController = TextEditingController();
//   final TextEditingController _photoIdProofNumberController = TextEditingController();
//   final TextEditingController _courseNameController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   File? _selectedFile;
//   String? _selectedCity;
//   String? _maritalStatus;
//   String? _socialPlatform;
//   String? _photoIdProof;
//   String? _highestEducation;
//   String? _nativeCity;
//   String? _grad_spec;
//   String? _master_spec;
//   String? _work_exp;
//   String? _salary;
//   String? _domain;
//   String? _skill1;
//   String? _skill2;
//   String? _skill3;
//
//   final List<String> _cities = ['City A', 'City B', 'Other'];
//   final List<String> _marital= ['Single', 'Married', 'Other'];
//   final List<String> _socialSites = ['LinkedIn', 'Instagram', 'Facebook', 'Company Website'];
//   final List<String> _photoIds = ['Aadhaar Card', 'PAN Card', 'Driving License', 'Passport'];
//   final List<String> _education = ['Doctoral', 'Post Grad', 'Grad', 'Under Grad'];
//   final List<String> _nativecities = ['City1', 'City2', 'Others'];
//   final List<String> _graduationSpec = ['CS','IT','Science', 'Maths'];
//   final List<String> _masterSpec = ['CS', 'IT', 'Not Applicable'];
//   final List<String> _experience = ['0', '1', '2', '3', 'More than 3'];
//   final List<String> _salaryLevel = ['0-3L', '4-7L', '8-10L', '10-15L', '16-20L', '21-30L', '30L+'];
//   final List<String> _workDomain = ['IT', 'Manufacturing', 'Retail', 'Finance', 'Other'];
//   final List<String> _workSkill1 = ['Python', 'Flutter', 'Full Stack', 'MERN', "None"];
//   final List<String> _workSkill2 = ['Python', 'Flutter', 'Full Stack', 'MERN', "None"];
//   final List<String> _workSkill3 = ['Python', 'Flutter', 'Full Stack', 'MERN', "None"];
//
//
//   // final _FormKey = GlobalKey<FormState>(); //form key not used yet
//   int refreshed = 0;
//   var userDetails = UserDetails();
//   UserModel? userModel;
//
//   _getUserDetail() async {
//     userModel = await userDetails.getDetail();
//     setState(() {
//       _firstnameController.text = userModel?.userName ?? '';
//       _dobController.text = userModel?.userDob ?? '';
//       _mobileController.text = userModel?.userPhone ?? '';
//       _emailController.text = userModel?.userEmail ?? '';
//     });
//   }
//
//   @override
//   void initState() {
//     _getUserDetail();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: CustomWidget.getSkillogicAppBar(context, userModel, 1),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const Text(
//                 "Candidate Onboarding Form",
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
//               ),
//               const SizedBox(height: 10),
//               const Text(
//                 "Demographics",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//               ),
//               const SizedBox(height: 20),
//               _buildTextFormField(_firstnameController, 'First Name (Given Name)'),
//               const SizedBox(height: 20),
//               _buildTextFormField(_lastnameController, 'Last Name'),
//               const SizedBox(height: 20),
//               _buildTextFormField(_emailController, 'Email (Personal)'),
//               const SizedBox(height: 20),
//               _buildTextFormField(_mobileController, 'Mobile Number'),
//               const SizedBox(height: 20),
//               _buildTextFormField(_dobController, 'Date of birth'),
//               const SizedBox(height: 20),
//               // InkWell(
//               //   onTap: () => _pickDate(context),
//               //   child: InputDecorator(
//               //     decoration: const InputDecoration(
//               //       labelText: 'Date of birth',
//               //       border: OutlineInputBorder(),
//               //     ),
//               //     child: Text(
//               //       _dob != null ? '${_dob!.day}-${_dob!.month}-${_dob!.year}' : 'Select Date',
//               //       style: const TextStyle(fontSize: 16),
//               //     ),
//               //   ),
//               // ),
//               // const SizedBox(height: 10),
//               DropdownButtonFormField<String>(
//                 value: _maritalStatus,
//                 enableFeedback: true,
//                 onChanged: (newValue) {
//                   setState(() {
//                     _maritalStatus = newValue;
//                   });
//                 },
//                 items: _marital.map((marital) {
//                   return DropdownMenuItem(
//                     value: marital,
//                     child: Text(marital),
//                   );
//                 }).toList(),
//                 decoration: InputDecoration(border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10.0),
//                   ),
//                   labelText: 'Marital Status',
//                 )
//               ),
//               const SizedBox(height: 20),
//               DropdownButtonFormField<String>(
//                 value: _nativeCity,
//                 onChanged: (newValue) {
//                   setState(() {
//                     _nativeCity = newValue;
//                   });
//                 },
//                 items: _nativecities.map((nativeCity) {
//                   return DropdownMenuItem(
//                     value: nativeCity,
//                     child: Text(nativeCity),
//                   );
//                 }).toList(),
//                 decoration: InputDecoration(border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10.0),
//                 ),
//                   labelText: 'Native Place (Nearest City)',
//                 )
//               ),
//               const SizedBox(height: 20),
//               DropdownButtonFormField<String>(
//                 value: _selectedCity,
//                 onChanged: (newValue) {
//                   setState(() {
//                     _selectedCity = newValue;
//                   });
//                 },
//                 items: _cities.map((city) {
//                   return DropdownMenuItem(
//                     value: city,
//                     child: Text(city),
//                   );
//                 }).toList(),
//                   decoration: InputDecoration(border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                     labelText: 'Current Residence (Nearest City)',
//                   )
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 "Professional & Academy",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//               ),
//               const SizedBox(height: 20),
//               DropdownButtonFormField<String>(
//                 value: _highestEducation,
//                 onChanged: (newValue) {
//                   setState(() {
//                     _highestEducation = newValue;
//                   });
//                 },
//                 items: _education.map((education) {
//                   return DropdownMenuItem(
//                     value: education,
//                     child: Text(education),
//                   );
//                 }).toList(),
//                   decoration: InputDecoration(border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                     labelText: 'Highest Education',
//                   )
//               ),
//               const SizedBox(height: 20),
//               DropdownButtonFormField<String>(
//                 value: _grad_spec,
//                 onChanged: (newValue) {
//                   setState(() {
//                     _grad_spec = newValue;
//                   });
//                 },
//                 items: _graduationSpec.map((gradSpec) {
//                   return DropdownMenuItem(
//                     value: gradSpec,
//                     child: Text(gradSpec),
//                   );
//                 }).toList(),
//                   decoration: InputDecoration(border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                     labelText: 'Graduation Specialization',
//                   )
//               ),
//               const SizedBox(height: 20),
//               DropdownButtonFormField<String>(
//                 value: _master_spec,
//                 onChanged: (newValue) {
//                   setState(() {
//                     _master_spec = newValue;
//                   });
//                 },
//                 items: _masterSpec.map((masterSpec) {
//                   return DropdownMenuItem(
//                     value: masterSpec,
//                     child: Text(masterSpec),
//                   );
//                 }).toList(),
//                   decoration: InputDecoration(border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                     labelText: 'Masters Specialization (if applicable)',
//                   )
//               ),
//               const SizedBox(height: 20),
//               DropdownButtonFormField<String>(
//                 value: _work_exp,
//                 onChanged: (newValue) {
//                   setState(() {
//                     _work_exp = newValue;
//                   });
//                 },
//                 items: _experience.map((workExp) {
//                   return DropdownMenuItem(
//                     value: workExp,
//                     child: Text(workExp),
//                   );
//                 }).toList(),
//                   decoration: InputDecoration(border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                     labelText: 'Work Experience (in Years)',
//                   )
//               ),
//               const SizedBox(height: 20),
//               DropdownButtonFormField<String>(
//                 value: _salary,
//                 onChanged: (newValue) {
//                   setState(() {
//                     _salary = newValue;
//                   });
//                 },
//                 items: _salaryLevel.map((salary) {
//                   return DropdownMenuItem(
//                     value: salary,
//                     child: Text(salary),
//                   );
//                 }).toList(),
//                   decoration: InputDecoration(border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                     labelText: 'Salary Level',
//                   )
//               ),
//               const SizedBox(height: 20),
//               _buildTextFormField(_companyController, 'Current Company'),
//               const SizedBox(height: 20),
//               DropdownButtonFormField<String>(
//                 value: _domain,
//                 onChanged: (newValue) {
//                   setState(() {
//                     _domain = newValue;
//                   });
//                 },
//                 items: _workDomain.map((domain) {
//                   return DropdownMenuItem(
//                     value: domain,
//                     child: Text(domain),
//                   );
//                 }).toList(),
//                   decoration: InputDecoration(border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                     labelText: 'Work Domain',
//                   )
//               ),
//               const SizedBox(height: 20),
//               DropdownButtonFormField<String>(
//                 value: _skill1,
//                 onChanged: (newValue) {
//                   setState(() {
//                     _skill1 = newValue;
//                   });
//                 },
//                 items: _workSkill1.map((skill_1) {
//                   return DropdownMenuItem(
//                     value: skill_1,
//                     child: Text(skill_1),
//                   );
//                 }).toList(),
//                   decoration: InputDecoration(border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                     labelText: 'Work Skill 1 (Primary)',
//                   )
//               ),
//               const SizedBox(height: 20),
//               DropdownButtonFormField<String>(
//                 value: _skill2,
//                 onChanged: (newValue) {
//                   setState(() {
//                     _skill2 = newValue;
//                   });
//                 },
//                 items: _workSkill2.map((skill_2) {
//                   return DropdownMenuItem(
//                     value: skill_2,
//                     child: Text(skill_2),
//                   );
//                 }).toList(),
//                   decoration: InputDecoration(border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                     labelText: 'Work Skill 2',
//                   )
//               ),
//               const SizedBox(height: 20),
//               DropdownButtonFormField<String>(
//                 value: _skill3,
//                 onChanged: (newValue) {
//                   setState(() {
//                     _skill3 = newValue;
//                   });
//                 },
//                 items: _workSkill3.map((skill_3) {
//                   return DropdownMenuItem(
//                     value: skill_3,
//                     child: Text(skill_3),
//                   );
//                 }).toList(),
//                   decoration: InputDecoration(border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                     labelText: 'Work Skill 3',
//                   )
//               ),
//               const SizedBox(height: 20),
//               _buildTextFormField(_linkedInProfileLinkController, 'LinkedIn Profile Link'),
//               const SizedBox(height: 20),
//               const Text(
//                 "Others",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//               ),
//               const SizedBox(height: 20),
//               DropdownButtonFormField<String>(
//                 value: _socialPlatform,
//                 onChanged: (newValue) {
//                   setState(() {
//                     _socialPlatform = newValue;
//                   });
//                 },
//                 items: _socialSites.map((socialsite) {
//                   return DropdownMenuItem(
//                     value: socialsite,
//                     child: Text(socialsite),
//                   );
//                 }).toList(),
//                   decoration: InputDecoration(border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                     labelText: 'How do you come to know about Datamites?',
//                   )
//               ),
//               const SizedBox(height: 20),
//               DropdownButtonFormField<String>(
//                 value: _photoIdProof,
//                 onChanged: (newValue) {
//                   setState(() {
//                     _photoIdProof = newValue;
//                   });
//                 },
//                 items: _photoIds.map((id) {
//                   return DropdownMenuItem(
//                     value: id,
//                     child: Text(id),
//                   );
//                 }).toList(),
//                   decoration: InputDecoration(border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                     labelText: 'Photo ID Proof Type',
//                   )
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: _photoIdProofNumberController,
//                 decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Photo ID Proof Number'),
//               ),
//               const SizedBox(height: 20),
//               _buildFileSelectionButton(), //file selector
//               const SizedBox(height: 20),
//               _buildTextFormField(_courseNameController, 'Course Name'),
//               const SizedBox(height: 20),
//               _buildTextFormField(_addressController, 'Address ( With Pin Code)'),
//               const SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   ElevatedButton(
//                     onPressed: _submitForm,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: MainColor.datamiteOrange,
//                       minimumSize: const Size(150, 50),
//                     ),
//                     child: const Text('Submit',
//                     style: TextStyle(color: Colors.white,fontSize: 20)
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextFormField(TextEditingController controller, String labelText) {
//     return TextFormField(
//       controller: controller,
//       decoration: InputDecoration(
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10.0),
//         ),
//         labelText: labelText,
//       ),
//     );
//   }
//
//   Widget _buildFileSelectionButton() {
//     return Column(
//       children: [
//         ElevatedButton.icon(
//           onPressed: _selectFile,
//           icon: const Icon(Icons.attach_file),
//           label: Text(_selectedFile != null ? 'Selected File' : 'Upload a copy of ID Proof'),
//         ),
//         if (_selectedFile != null) Text(_selectedFile!.path),
//       ],
//     );
//   }
//
//   void _selectFile() async {
//     final result = await FilePicker.platform.pickFiles();
//     if (result != null) {
//       setState(() {
//         _selectedFile = File(result.files.single.path!);
//       });
//     }
//   }
//
//
//   // Method to submit the form
//   void _submitForm() async {
//     // Validate if all fields are filled
//     if (!_validateForm()) {
//       _showErrorDialog('Please fill all fields');
//       return;
//     }
//
//     // Create a multipart request
//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse('https://erp.akshayacorp.com/dm-api/CandidateAnalytics'),
//     );
//
//     // Add form fields
//     request.fields['first_name'] = _firstnameController.text;
//     request.fields['last_name'] = _lastnameController.text;
//     request.fields["email_id"]= _emailController.text;
//     request.fields["mobile_number"]=_mobileController.text;
//     request.fields["date_of_birth"]= _dobController.text;
//     request.fields["merital_status"]= _maritalStatus ?? '';
//     request.fields["native_city"]= _nativeCity ?? '';
//     request.fields["current_residency"]= _selectedCity ?? '';
//     request.fields["highest_education"]= _highestEducation ?? '';
//     request.fields["graduation_specialization"]= _grad_spec ?? '';
//     request.fields["master_specialization"]= _master_spec ?? '';
//     request.fields["work_experience"]= _work_exp ?? '';
//     request.fields["salary_level"]= _salary ?? '';
//     request.fields["current_company"]= _companyController.text;
//     request.fields["work_domain"]= _domain ?? '';
//     request.fields["work_skill1"]= _skill1 ?? '';
//     request.fields["work_skill2"]= _skill2 ?? '';
//     request.fields["work_skill3"]= _skill3 ?? '';
//     request.fields["linked_in"]= _linkedInProfileLinkController.text;
//     request.fields["info_about_datamites"]= _socialPlatform ?? '';
//     request.fields["id_proof_type"]= _photoIdProof ?? '';
//     request.fields["id_proof_number"]= _photoIdProofNumberController.text;
//     // "id_proof_file": _selectedFile,
//     request.fields["course"]= _courseNameController.text;
//     request.fields["address"]= _addressController.text;
//
//     // Add file if selected
//     if (_selectedFile != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath(
//           'id_proof_file',
//           _selectedFile!.path,
//           // filename: 'filename.txt',
//         ),
//       );
//     }
//     if (kDebugMode) {
//       print(request.fields);
//       print(request.files);
//     }
//
//     // Make a POST request
//     try {
//     var response = await request.send();
//     //   print(response.body);
//       if (response.statusCode == 200) {
//         _clearFormFields();
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: const Text('Success'),
//               content: const Text('Form submitted successfully!'),
//               actions: <Widget>[
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   child: const Text('OK'),
//                 ),
//               ],
//             );
//           },
//         );
//       } else {
//         throw Exception('Failed to submit form');
//       }
//     } catch (error) {
//       String errorMessage = 'Failed to submit form.';
//       if (error is Exception) {
//         errorMessage += '\n${error.toString()}';
//       } else {
//         errorMessage += '\nAn unknown error occurred.';
//       }
//       _showErrorDialog(errorMessage);
//     }
//
//   }
//
//   // Method to validate the form
//   bool _validateForm() {
//     return _firstnameController.text.isNotEmpty &&
//         _lastnameController.text.isNotEmpty &&
//         _emailController.text.isNotEmpty &&
//         _mobileController.text.isNotEmpty &&
//         _companyController.text.isNotEmpty &&
//         _linkedInProfileLinkController.text.isNotEmpty &&
//         _photoIdProofNumberController.text.isNotEmpty &&
//         _courseNameController.text.isNotEmpty &&
//         _dobController.text.isNotEmpty &&
//         _addressController.text.isNotEmpty;
//   }
//
//   // Method to clear form fields
//   void _clearFormFields() {
//     _firstnameController.clear();
//     _lastnameController.clear();
//     _emailController.clear();
//     _mobileController.clear();
//     _companyController.clear();
//     _linkedInProfileLinkController.clear();
//     _photoIdProofNumberController.clear();
//     _courseNameController.clear();
//     _addressController.clear();
//     _dobController.clear();
//     _selectedFile = null;
//     _selectedCity = null;
//     _maritalStatus = null;
//     _socialPlatform = null;
//     _photoIdProof = null;
//     _highestEducation = null;
//     _nativeCity = null;
//     _grad_spec = null;
//     _master_spec = null;
//     _work_exp = null;
//     _salary = null;
//     _domain = null;
//     _skill1 = null;
//     _skill2 = null;
//     _skill3 = null;
//   }
//
//   // Method to show error dialog
//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Error'),
//           content: Text(message),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
//
