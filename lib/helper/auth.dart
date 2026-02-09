import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:skillogic/helper/user_details.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../model/user_model.dart';

class UserAuth {
  UserDetails userDetails = UserDetails();
  UserModel userModel = UserModel();

  Future<int> tokenLogin(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String authUrl = preferences.getString("auth_url") ?? "";
    String url = "${authUrl}password/tokenLogin";
    //String url = "https://f18xa7ot97.execute-api.us-east-1.amazonaws.com/tokenLogin";
    int returnValue = 0;
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("jwtToken") ?? "";
    if (token != "") {
      http.Response response =
          await http.get(Uri.parse(url), headers: {"jwt": token});
      if (response.statusCode != 403) {
        if (response.statusCode == 200) {
          var userResponse = json.decode(response.body);

          // if (kDebugMode) print("User response");
          // if (kDebugMode) print(userResponse);

          userModel.userName = userResponse["user_data"]["name"];
          userModel.userEmail = userResponse["user_data"]["email"];
          userModel.userPhone = userResponse["user_data"]["mnumber"];
          userModel.userImage = userResponse["user_data"]["profile_pic"];
          userModel.userDob = userResponse["user_data"]["dob"]??"";
          userModel.jwtKey = userResponse["jwtkey"];
          userModel.refreshKey = userResponse["refreshToken"];
          userModel.userSession = userResponse["user_data"]["current_active_session_id"]?? "";
          await userDetails.setDetail(userModel);
          returnValue = 1;
        } else if (response.statusCode == 401) {
          await userDetails.logoutUser();
          returnValue = 3;
        } else {
          await userDetails.logoutUser();
          returnValue = 2;
        }
      }
    } else {
      await userDetails.logoutUser();
    }
    return returnValue;
  }

  Future<int> tokenRefresh(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String authUrl = preferences.getString("auth_url") ?? "";
    String url = "${authUrl}refresh";
    //String url = "https://f18xa7ot97.execute-api.us-east-1.amazonaws.com/refresh";
    int returnValue = 0;
    final prefs = await SharedPreferences.getInstance();
    var refreshToken = prefs.getString("refreshToken") ?? "";
    if (refreshToken != "") {
      http.Response response = await http
          .get(Uri.parse(url), headers: {"refresh_token": refreshToken});
      if (response.statusCode != 403) {
        if (response.statusCode == 200) {
          prefs.setString("jwtToken", json.decode(response.body)["jwtkey"]);
          prefs.setString(
              "refreshToken", json.decode(response.body)["refreshToken"]);
          prefs.setString(
              "session", json.decode(response.body)["current_active_session_id"]);
          returnValue = 1;
        } else if (response.statusCode == 401) {
          returnValue = 3;
        } else {
          returnValue = 2;
        }
      } else {
        userDetails.logout(context);
      }
    }
    return returnValue;
  }
}
