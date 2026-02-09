
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:skillogic/helper/color.dart';
import 'package:skillogic/pages/forget_password.dart';
import 'package:skillogic/pages/referral/referral_widgets/neomorphism.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class PasswordChangeScreen extends StatefulWidget {
  const PasswordChangeScreen({Key? key}) : super(key: key);

  @override
  _PasswordChangeScreenState createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  String oldPassword = '';
  String newPassword = '';
  bool showProgress = false;
  final _loginFormKey = GlobalKey<FormState>();
  bool disable = true;

  final FocusNode _oldPFocusNode = new FocusNode();
  final FocusNode _newPFocusNode = new FocusNode();

  _changePassword(context, String oldPassword, String newPassword) async {
    if (kDebugMode) {
      print("changing password");
    }
    if (kDebugMode) {
      print(oldPassword + newPassword);
    }
    ChangePasswordService changePasswordService = new ChangePasswordService();
    changePasswordService.setContext = context;
    changePasswordService.setOldP = oldPassword.trim();
    changePasswordService.setnewP = newPassword.trim();
    var changed = await changePasswordService.changePassword();
    setState(() {
      showProgress = false;
      disable = true;
    });
    if (changed) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: !disable,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: const Color(0xfff6f6f6)),
                  child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back)),
                ).addNeumorphism(
                    blurRadius: 16, borderRadius: 16, offset: const Offset(2, 2)),
                const SizedBox(
                  height: 16.0,
                ),
                const SizedBox(
                  height: 32.0,
                ),
                Text("Hey,\nChange Password",
                    style: TextStyle(
                        color: MainColor.textColorConst,
                        fontSize: 24)),
                const SizedBox(height: 16.0),
                Form(
                    key: _loginFormKey,
                    child: Column(
                      children: [
                        Container(
                            margin: const EdgeInsets.fromLTRB(0, 32, 0, 0),
                            padding: const EdgeInsets.all(8.0),
                            width: double.infinity,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                color: Colors.grey[200]),
                            child: TextFormField(
                              obscureText: true,
                              focusNode: _oldPFocusNode,
                              decoration: const InputDecoration(
                                icon: Icon(Icons.lock_outline_sharp),
                                border: InputBorder.none,
                                enabledBorder: null,
                                hintText: 'Old password',
                              ),
                              onChanged: (String oldPassword) {
                                this.oldPassword = oldPassword;
                              },
                              onEditingComplete: () {
                                FocusScope.of(context)
                                    .requestFocus(_newPFocusNode);
                              },
                              validator: (String? oldPassword) {
                                return (oldPassword!.length < 4)
                                    ? 'Enter a valid password'
                                    : null;
                              },
                            )),
                        Container(
                            margin: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                            padding: const EdgeInsets.all(8.0),
                            width: double.infinity,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                color: Colors.grey[200]),
                            child: TextFormField(
                              focusNode: _newPFocusNode,
                              obscureText: true,
                              decoration: const InputDecoration(
                                icon: Icon(Icons.lock_outline_sharp),
                                border: InputBorder.none,
                                enabledBorder: null,
                                hintText: 'New password',
                              ),
                              onEditingComplete: () {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                              },
                              onChanged: (String password) {
                                // This optional block of code can be used to run
                                // code when the user saves the form.
                                newPassword = password;
                              },
                              validator: (String? value) {
                                return (value == null || value.length < 4)
                                    ? 'Enter a valid password.'
                                    : null;
                              },
                            )),
                      ],
                    )),
                const SizedBox(
                  height: 16.0,
                ),
                Row(
                  children: [
                    const Text(
                      "Forget Passcode? /",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    MaterialButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ResetScreen()),
                        );
                      },
                      child: Text(
                        "Reset",
                        style: TextStyle(color: MainColor.textColorConst),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 32,
                ),
                Center(
                  child: Visibility(
                      visible: showProgress,
                      child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                MainColor.textColorConst,
                              )))),
                ),
                MaterialButton(
                  elevation: 0,
                  color: MainColor.skillogicBlue,
                  onPressed: () async {
                    FocusScope.of(context).unfocus();

                    if (!_loginFormKey.currentState!.validate()) {
                      // If the form is valid, display a snackbar. In the real world,
                      // you'd often call a server or save the information in a database.
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Enter the valid input',
                            textAlign: TextAlign.center),
                      ));
                    } else {
                      if (!_loginFormKey.currentState!.validate()) {
                        // If the form is valid, display a snackbar. In the real world,
                        // you'd often call a server or save the information in a database.
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Enter the valid input',
                              textAlign: TextAlign.center),
                        ));
                      } else {
                        setState(() {
                          showProgress = true;
                          disable = false;
                        });
                        _changePassword(context, oldPassword, newPassword);
                      }
                    }
                  },
                  child: const Text(
                    "Change password",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  minWidth: double.infinity,
                  height: 55.0,
                ).addNeumorphism(
                  blurRadius: 8,
                  borderRadius: 8,
                  offset: const Offset(2, 2),
                ),
                const SizedBox(height: 16,),
                MaterialButton(
                  elevation: 0,
                  color: MainColor.skillogicRed,
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Go back",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  minWidth: double.infinity,
                  height: 55.0,
                ).addNeumorphism(
                  blurRadius: 8,
                  borderRadius: 8,
                  offset: const Offset(2, 2),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                  child: MaterialButton(
                    elevation: 0,
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const ResetScreen())
                      );
                    },
                    child: const SizedBox(
                      height: 48,
                      child: Center(
                        child: Text(
                          "Forget your password? RESET",
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16,),
                const SizedBox(
                  height: 32,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChangePasswordService {
  late String token;
  late String oldP;
  late String newP;
  late String authUrl;
  late String finalUrl;

  late BuildContext context;

  set setOldP(String setOldP) {
    this.oldP = setOldP;
  }

  set setnewP(String newP) {
    this.newP = newP;
  }

  set setContext(BuildContext context) {
    this.context = context;
  }

  final String apiPath = "password/reset";

  Future<bool> changePassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    authUrl = prefs.getString("auth_url") ?? "";
    token = prefs.getString("jwtToken")!;
    finalUrl = authUrl + apiPath;
    //finalUrl = "https://f18xa7ot97.execute-api.us-east-1.amazonaws.com/passwordreset";
    if (kDebugMode) {
      print(finalUrl);
    }

    http.Response res = await http.post(Uri.parse(finalUrl),
        headers: {"jwt": token}, body: {"oldpass": oldP, "newpass": newP});
    // print(res.body);
    if (res.statusCode == 200) {
      // print(res.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
        Text(json.decode(res.body)['msg'], textAlign: TextAlign.center),
      ));
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
        Text(json.decode(res.body)['msg'], textAlign: TextAlign.center),
      ));
      return false;
    }
  }
}