// import 'package:flutter/material.dart';
// import 'package:flutter_contacts/flutter_contacts.dart';
//
// class GetContacts extends StatefulWidget {
//   const GetContacts({super.key});
//
//   @override
//   State<GetContacts> createState() => _GetContactsState();
// }
//
// class _GetContactsState extends State<GetContacts> {
//   List<Contact> contacts = [];
//
//   Future<void> getContacts() async {
//     final contactList = await FlutterContacts.getContacts(withProperties: true);
//     setState(() {
//       contacts = contactList;
//     });
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     getContacts();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             Text("Contacts"),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: contacts.length,
//                 itemBuilder: (context, index) {
//                   final contact = contacts[index];
//                   return ListTile(
//                     title: Text(contact.displayName.toString()),
//                     subtitle: Text(contact.phones.map((phone) => phone.number).join(', ')),
//
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
