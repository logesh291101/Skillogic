//
// import 'dart:convert';
//
// import 'package:skillogic/helper/auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:sembast/sembast.dart';
// import 'package:sembast/sembast_io.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../model/Credit/segmented_credit_response_model.dart';
// import '../../../model/Referral/campaign_model.dart';
// import '../../../model/Referral/referral_model.dart';
// import '../../../model/Referral/segmented_referral_response_model.dart';
// import 'package:http/http.dart' as http;
// import 'dart:io';
// import 'dart:async';
//
//
//
// _getDb(String dbPath) async {
//   // print("Initializing db");
//   var store = StoreRef.main();
//   final appDocDir = await getApplicationDocumentsDirectory();
//   Database db = await databaseFactoryIo
//       .openDatabase("${appDocDir.path}/$dbPath", version: 1);
//   // print("Successfully initialized db");
//   return db;
// }
//
// Future<void> _refreshToken(BuildContext context) async {
//   UserAuth _userAuth = UserAuth();
//   int refreshed = await _userAuth.tokenRefresh(context);
//   if (refreshed == 1) refreshed = await _userAuth.tokenLogin(context);
// }
//
// class SegmentedReferralTransactionsService {
//   late int statusId;
//   late int referralSortAsc;
//   late String jwt;
//   late BuildContext context;
//   late SharedPreferences prefs;
//   late String authUrl, finalUrl;
//   late Uri finalUri;
//
//   set setContext(BuildContext context) {
//     this.context = context;
//   }
//
//   set setStatusId(int statusId) {
//     this.statusId = statusId;
//   }
//
//   set setReferralSortAsc(int referralSortAsc) {
//     this.referralSortAsc = referralSortAsc;
//   }
//
//   set setPhone(String phone) {
//     if (kDebugMode) {
//       print(phone);
//     }
//   }
//
//   String apiPath = '';
//
//
//
//   // Future<SegmentedReferralResponseModel?> get getSegmented async {
//   //   await _refreshToken(context);
//   //   SegmentedReferralResponseModel? segRefModel;
//   //   // if (kDebugMode) {
//   //   //   print("Getting segmented");
//   //   // }
//   //   prefs = await SharedPreferences.getInstance();
//   //   authUrl = prefs.getString("auth_url")??"";
//   //   finalUrl = '${authUrl}candidate/gettingSegmentedReferral?status_id=$statusId&referral_sort_asc=$referralSortAsc';
//   //   //finalUrl = "https://f18xa7ot97.execute-api.us-east-1.amazonaws.com/gettingSegmentedReferral?status_id=$statusId&referral_sort_asc=$referralSortAsc";
//   //
//   //   Map<String, String> qParams = {
//   //     'status_id': statusId.toString(),
//   //     'referral_sort_asc': referralSortAsc.toString()
//   //   };
//   //
//   //   //Uri uri = Uri.parse(finalUrl);
//   //   // finalUri = uri.replace(queryParameters: qParams); //USE THIS
//   //
//   //   http.Response response = await http.get(Uri.parse(finalUrl),
//   //       headers: {"jwt": prefs.getString("jwtToken")!});
//   //   var segRef;
//   //   Database db = await _getDb('skillogic.db');
//   //   var store = StoreRef.main();
//   //   if (response.statusCode == 200) {
//   //     segRef = json.decode(response.body);
//   //     await store
//   //         .record('referral_cash_$statusId')
//   //         .put(db, segRef);
//   //     // print("referral_cash_" + statusId.toString() + " written");
//   //     segRefModel = SegmentedReferralResponseModel.fromJson(segRef);
//   //   } else if (response.statusCode == 404) {
//   //     // print("referral_cash_" + statusId.toString() + " writing");
//   //     var dataToSave = json.decode(
//   //         '{"referralData":[], "success":false, "message":"Data unavailable", "referral_amount":0, "final_status":$statusId}');
//   //     await store
//   //         .record('referral_cash_$statusId')
//   //         .put(db, dataToSave);
//   //     // print("referral_cash_" + statusId.toString() + " written");
//   //     // print("Returning null");
//   //     return segRefModel;
//   //   } else if (response.statusCode == 403) {
//   //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//   //       content: Text(json.decode(response.body)['msg'],
//   //           textAlign: TextAlign.center),
//   //     ));
//   //   } else {
//   //     return getSegmented;
//   //   }
//   //
//   //   return segRefModel;
//   // }
//   Future<SegmentedReferralResponseModel?> get getSegmented async {
//     try {
//       await _refreshToken(context);
//
//       SegmentedReferralResponseModel? segRefModel;
//
//       prefs = await SharedPreferences.getInstance();
//
//       authUrl = prefs.getString("auth_url") ?? "";
//
//       finalUrl =
//       '${authUrl}candidate/gettingSegmentedReferral?status_id=$statusId&referral_sort_asc=$referralSortAsc';
//
//       http.Response response = await http
//           .get(
//         Uri.parse(finalUrl),
//         headers: {
//           "jwt": prefs.getString("jwtToken") ?? "",
//         },
//       )
//           .timeout(const Duration(seconds: 30));
//
//       var segRef;
//
//       Database db = await _getDb('skillogic.db');
//       var store = StoreRef.main();
//
//       if (response.statusCode == 200) {
//         segRef = json.decode(response.body);
//
//         await store.record('referral_cash_$statusId').put(db, segRef);
//
//         segRefModel = SegmentedReferralResponseModel.fromJson(segRef);
//
//         return segRefModel;
//       } else if (response.statusCode == 404) {
//         var dataToSave = {
//           "referralData": [],
//           "success": false,
//           "message": "Data unavailable",
//           "referral_amount": 0,
//           "final_status": statusId
//         };
//
//         await store.record('referral_cash_$statusId').put(db, dataToSave);
//
//         return null;
//       } else if (response.statusCode == 403) {
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 json.decode(response.body)['msg'],
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           );
//         }
//
//         return null;
//       } else {
//         return null;
//       }
//     } on SocketException catch (e) {
//       debugPrint("Socket Exception: $e");
//       return null;
//     } on TimeoutException catch (e) {
//       debugPrint("Timeout Exception: $e");
//       return null;
//     } on http.ClientException catch (e) {
//       debugPrint("Client Exception: $e");
//       return null;
//     } catch (e, stackTrace) {
//       debugPrint("Unexpected Error: $e");
//       debugPrintStack(stackTrace: stackTrace);
//       return null;
//     }
//   }
// }
//
// class SegmentedCreditTransactionService {
//   late int statusId;
//   late int creditSortAsc;
//   late String jwt;
//   late BuildContext context;
//   late SharedPreferences prefs;
//   late String authUrl, finalUrl;
//   late Uri finalUri;
//
//   set setContext(BuildContext context) {
//     this.context = context;
//   }
//
//   set setStatusId(int statusId) {
//     this.statusId = statusId;
//   }
//
//   set setCreditSortAsc(int creditSortAsc) {
//     this.creditSortAsc = creditSortAsc;
//   }
//
//   set setPhone(String phone) {
//     if (kDebugMode) {
//       print(phone);
//     }
//   }
//
//   String apiPath = '';
//
//
//
//   Future<SegmentedCreditResponseModel?> get getSegmented async {
//     await _refreshToken(context);
//     SegmentedCreditResponseModel? segCreModel;
//     if (kDebugMode) {
//       print("Getting segmented");
//     }
//     prefs = await SharedPreferences.getInstance();
//     authUrl = prefs.getString("auth_url")??"";
//     finalUrl = '${authUrl}candidate/gettingSegmentedCredit?status_id=$statusId&credit_sort_asc=$creditSortAsc';
//     //finalUrl = "https://f18xa7ot97.execute-api.us-east-1.amazonaws.com/gettingSegmentedCredit?status_id=$statusId&credit_sort_asc=$creditSortAsc";
//
//     Uri uri = Uri.parse(finalUrl);
//
//     http.Response response = await http.get(Uri.parse(finalUrl),
//         headers: {"jwt": prefs.getString("jwtToken")!});
//     // print("candidate/gettingSegmentedCredit?status_id=" +
//     //     statusId.toString());
//     var segRef;
//     // print(response.statusCode);
//     // print(response.body);
//     Database db = await _getDb('skillogic.db');
//     var store = StoreRef.main();
//     // print("cash reponse ");
//     // print(statusId);
//     // print(response.statusCode.toString());
//     if (response.statusCode == 200) {
//       segRef = json.decode(response.body);
//       await store
//           .record('referral_credit_$statusId')
//           .put(db, segRef);
//       // print(finalUrl);
//       // print("referral_credit_" + this.statusId.toString() + " written");
//       segCreModel = SegmentedCreditResponseModel.fromJson(segRef);
//
//       // segRefModel = segRef.map(
//       //   (dynamic item) => SegmentedReferralResponseModel.fromJson(item),
//       // ) as SegmentedReferralResponseModel;
//     } else if (response.statusCode == 404) {
//       if (kDebugMode) {
//         print(response.body);
//       }
//       // print("referral_credit_" + statusId.toString() + " writing");
//       var dataToSave = json.decode(
//           '{"creditData":[], "success":false, "message":"Data unavailable", "credit_amount":0, "final_status":$statusId}');
//       // print(dataToSave);
//       await store
//           .record('referral_credit_' + statusId.toString())
//           .put(db, dataToSave);
//       // print("referral_credit_" + statusId.toString() + " written");
//     } else if (response.statusCode == 403) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text(json.decode(response.body)['msg'],
//             textAlign: TextAlign.center),
//       ));
//     } else {
//       try {
//         // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         //   content: Text(json.decode(response.body)['msg'],
//         //       textAlign: TextAlign.center),
//         // ));
//         return null;
//       } catch (e) {
//         if (kDebugMode) {
//           print("Exception $e");
//         }
//         return null;
//       }
//     }
//
//     // try {
//     //   print(segRefModel.msg);
//     // } catch (err) {
//     //   print(segRef);
//     // }
//
//     return segCreModel;
//   }
// }
//
// class ReferralListService {
//   late http.Response resp;
//   late String base_url;
//   late String final_url;
//   late String token;
//   late String query_string;
//   late String referral_sort_asc;
//   late BuildContext context;
//
//   set setQuery_string(query_string) {
//     this.query_string = query_string;
//   }
//
//   set setBuildContext(BuildContext context){
//     this.context = context;
//   }
//
//   set setRererralSort(bool referral_sort_asc) {
//     if (referral_sort_asc) {
//       this.referral_sort_asc = '1';
//     } else {
//       this.referral_sort_asc = '0';
//     }
//   }
//
//   Future<List<ReferralModel>?> get getReferralList async {
//     await _refreshToken(context);
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setString("access_token", prefs.getString("jwtToken")??"");
//     base_url = prefs.getString("auth_url")??"";
//     var token = prefs.getString("token");
//     token = prefs.getString("access_token")!;
//     // print(token);
//
//     List<ReferralModel> referralList = [];
//
//     resp = await http.get(
//         Uri.parse("${base_url}candidate/getTotalRef?query_string=$query_string&sort_asc=$referral_sort_asc"),
//         headers: {"jwt": token});
//
//     // resp = await http.get(
//     //     Uri.parse("https://f18xa7ot97.execute-api.us-east-1.amazonaws.com/getTotalRef?query_string=$query_string&sort_asc=$referral_sort_asc"),
//     //     headers: {"jwt": token});
//
//     if (resp.statusCode == 200) {
//       var referralData = json.decode(resp.body);
//       List<dynamic> body = referralData['referralData'] as List;
//
//       // print(body);
//
//       try {
//         referralList = body
//             .map(
//               (dynamic item) => ReferralModel.fromJson(item),
//         )
//             .toList();
//
//         return referralList;
//       } catch (e) {
//         if (kDebugMode) {
//           print("Exception $e");
//         }
//         return getReferralList;
//       }
//     } else if (resp.statusCode == 404) {
//       return referralList;
//     } else {
//       return getReferralList;
//       // throw "Can't get referrals.";
//     }
//     return referralList;
//   }
// }
//
// class GetCampaignService {
//   late BuildContext context;
//
//   void set contextLogin(BuildContext context) {
//     this.context = context;
//   }
//
//   List<Campaign> campaignList = [];
//
//   Future<List<Campaign>> get getCampaign async {
//     await _refreshToken(context);
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     var auth_url = prefs.getString("auth_url")??"";
//      http.Response res = await http.get(Uri.parse("${auth_url}campaign"));
//     //http.Response res = await http.get(Uri.parse("https://f18xa7ot97.execute-api.us-east-1.amazonaws.com/campaign"));
//
//
//     if (res.statusCode == 200) {
//       var campaigns = json.decode(res.body);
//       var rest = campaigns["campaign"] as List;
//       List<dynamic> body = rest;
//
//       campaignList = body
//           .map(
//             (dynamic item) => Campaign.fromJson(item),
//       )
//           .toList();
//       // print("Campaign list " + campaignList.toString());
//
//       return campaignList;
//     } else {
//       // throw "Can't get referrals.";
//       if (kDebugMode) {
//         print("Error in getting referrals");
//       }
//       return getCampaign;
//     }
//     return campaignList;
//   }
// }

import 'dart:convert';

import 'package:skillogic/helper/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../model/Credit/segmented_credit_response_model.dart';
import '../../../model/Referral/campaign_model.dart';
import '../../../model/Referral/referral_model.dart';
import '../../../model/Referral/segmented_referral_response_model.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';

_getDb(String dbPath) async {
  var store = StoreRef.main();
  final appDocDir = await getApplicationDocumentsDirectory();
  Database db =
  await databaseFactoryIo.openDatabase("${appDocDir.path}/$dbPath", version: 1);
  return db;
}

Future<void> _refreshToken(BuildContext context) async {
  UserAuth _userAuth = UserAuth();
  int refreshed = await _userAuth.tokenRefresh(context);
  if (refreshed == 1) refreshed = await _userAuth.tokenLogin(context);
}

/// ===================== REFERRAL SERVICE =====================
class SegmentedReferralTransactionsService {
  late int statusId;
  late int referralSortAsc;
  late BuildContext context;

  late SharedPreferences prefs;
  late String authUrl, finalUrl;

  set setContext(BuildContext context) => this.context = context;
  set setStatusId(int statusId) => this.statusId = statusId;
  set setReferralSortAsc(int referralSortAsc) => this.referralSortAsc = referralSortAsc;

  Future<SegmentedReferralResponseModel?> get getSegmented async {
    try {
      await _refreshToken(context);

      prefs = await SharedPreferences.getInstance();
      authUrl = prefs.getString("auth_url") ?? "";

      finalUrl =
      '${authUrl}candidate/gettingSegmentedReferral?status_id=$statusId&referral_sort_asc=$referralSortAsc';

      final response = await http
          .get(
        Uri.parse(finalUrl),
        headers: {
          "jwt": prefs.getString("jwtToken") ?? "",
        },
      )
          .timeout(const Duration(seconds: 30));

      final db = await _getDb('skillogic.db');
      final store = StoreRef.main();

      if (response.statusCode == 200) {
        final segRef = json.decode(response.body);

        await store.record('referral_cash_$statusId').put(db, segRef);

        return SegmentedReferralResponseModel.fromJson(segRef);
      }

      if (response.statusCode == 404) {
        final dataToSave = {
          "referralData": [],
          "success": false,
          "message": "Data unavailable",
          "referral_amount": 0,
          "final_status": statusId
        };

        await store.record('referral_cash_$statusId').put(db, dataToSave);
        return null;
      }

      if (response.statusCode == 403) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(json.decode(response.body)['msg']),
            ),
          );
        }
        return null;
      }

      return null;
    } on SocketException catch (e) {
      debugPrint("SocketException Referral: $e");
      return null;
    } on TimeoutException catch (e) {
      debugPrint("Timeout Referral: $e");
      return null;
    } catch (e) {
      debugPrint("Referral Error: $e");
      return null;
    }
  }
}

/// ===================== CREDIT SERVICE =====================
class SegmentedCreditTransactionService {
  late int statusId;
  late int creditSortAsc;
  late BuildContext context;

  late SharedPreferences prefs;
  late String authUrl, finalUrl;

  set setContext(BuildContext context) => this.context = context;
  set setStatusId(int statusId) => this.statusId = statusId;
  set setCreditSortAsc(int creditSortAsc) => this.creditSortAsc = creditSortAsc;

  Future<SegmentedCreditResponseModel?> get getSegmented async {
    try {
      await _refreshToken(context);

      prefs = await SharedPreferences.getInstance();
      authUrl = prefs.getString("auth_url") ?? "";

      finalUrl =
      '${authUrl}candidate/gettingSegmentedCredit?status_id=$statusId&credit_sort_asc=$creditSortAsc';

      final response = await http
          .get(
        Uri.parse(finalUrl),
        headers: {
          "jwt": prefs.getString("jwtToken") ?? "",
        },
      )
          .timeout(const Duration(seconds: 30));

      final db = await _getDb('skillogic.db');
      final store = StoreRef.main();

      if (response.statusCode == 200) {
        final segRef = json.decode(response.body);

        await store.record('referral_credit_$statusId').put(db, segRef);

        return SegmentedCreditResponseModel.fromJson(segRef);
      }

      if (response.statusCode == 404) {
        final dataToSave = {
          "creditData": [],
          "success": false,
          "message": "Data unavailable",
          "credit_amount": 0,
          "final_status": statusId
        };

        await store
            .record('referral_credit_$statusId')
            .put(db, dataToSave);
      }

      if (response.statusCode == 403) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(json.decode(response.body)['msg'])),
          );
        }
      }

      return null;
    } on SocketException catch (e) {
      debugPrint("SocketException Credit: $e");
      return null;
    } on TimeoutException catch (e) {
      debugPrint("Timeout Credit: $e");
      return null;
    } catch (e) {
      debugPrint("Credit Error: $e");
      return null;
    }
  }
}

/// ===================== OTHER SERVICES (UNCHANGED LOGIC, SAFE ACCESS) =====================

class ReferralListService {
  late http.Response resp;
  late String base_url;
  late String query_string;
  late String referral_sort_asc;
  late BuildContext context;

  set setQuery_string(query_string) => this.query_string = query_string;

  set setBuildContext(BuildContext context) => this.context = context;

  set setRererralSort(bool referral_sort_asc) {
    this.referral_sort_asc = referral_sort_asc ? '1' : '0';
  }

  Future<List<ReferralModel>?> get getReferralList async {
    try {
      await _refreshToken(context);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      base_url = prefs.getString("auth_url") ?? "";

      final token = prefs.getString("jwtToken") ?? "";

      resp = await http
          .get(
        Uri.parse(
            "${base_url}candidate/getTotalRef?query_string=$query_string&sort_asc=$referral_sort_asc"),
        headers: {"jwt": token},
      )
          .timeout(const Duration(seconds: 30));

      if (resp.statusCode == 200) {
        var referralData = json.decode(resp.body);
        List<dynamic> body = referralData['referralData'] ?? [];

        return body.map((e) => ReferralModel.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      debugPrint("ReferralList Error: $e");
      return [];
    }
  }
}

class GetCampaignService {
  late BuildContext context;

  void set contextLogin(BuildContext context) => this.context = context;

  Future<List<Campaign>> get getCampaign async {
    try {
      await _refreshToken(context);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      var auth_url = prefs.getString("auth_url") ?? "";

      final res = await http.get(Uri.parse("${auth_url}campaign"));

      if (res.statusCode == 200) {
        var campaigns = json.decode(res.body);
        var list = campaigns["campaign"] as List;

        return list.map((e) => Campaign.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      debugPrint("Campaign Error: $e");
      return [];
    }
  }
}