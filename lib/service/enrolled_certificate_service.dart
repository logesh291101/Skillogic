import 'dart:convert';
import 'dart:core';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/candidate_portal/data_model/CertificateModel.dart';

class EnrolledCertificateProvider extends ChangeNotifier{
  List<CertificateModel> _certificate = [];
  bool _isLoading = false;
  List<CertificateModel> get certificates => _certificate;
  bool get isLoading => _isLoading;

  Future<void> getCandidateCertificate() async{
    _isLoading = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    var candidate_portal_url = prefs.getString("candidate_portal_url");
    var enrollment_number = prefs.getString("enrollment_number");
    try{
      final url = Uri.parse("${candidate_portal_url}dm-api/CandidateCertifications?enrollment_number=$enrollment_number");
      final response = await http.get(url);
      if(response.statusCode == 200){
        log("certificate api --- ${response.body}");
        // final Map<String, dynamic> data =
        // jsonDecode(response.body);
        // CertificateResponseModel responseModel = CertificateResponseModel.fromJson(data);
        final data = jsonDecode(response.body);
        _certificate = CertificateResponseModel.fromJson(data).data;
        notifyListeners();
      }
      else{
        log("Certificate Api failed");
        _certificate = [];
      }
    }
    catch(e){
      _certificate = [];
      throw Exception("Error: $e");
    }
    finally{
      _isLoading = false;
      notifyListeners();
    }
  }
}