import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/topics_covered_model.dart';

class TopicCoveredProvider extends ChangeNotifier{
   TopicsCoveredModel? _topicsCoveredModel;
   bool _isLoading = false;

   TopicsCoveredModel? get topicCoveredModel => _topicsCoveredModel;
   bool get isLoading => _isLoading;

  Future<void> getTopicCoveredDetails() async{
    final prefs = await SharedPreferences.getInstance();
    var enrollment_number= prefs.getString("enrollment_number");
    log("enrollment_number---${enrollment_number}");
    _isLoading = true;
    notifyListeners();
    try{
      //final url="https://erp.akshayacorp.com/trainer_topics_api/get_topics_details?candidate_mail=$mailId&brandId=1";
      final url="https://erp.akshayacorp.com/trainer_topics_api/get_topics_details?enrollment_number=$enrollment_number";
      final res= await http.get(Uri.parse(url));
      if(res.statusCode==200){
        try {
          final data = await json.decode(res.body);
          _topicsCoveredModel=TopicsCoveredModel.fromJson(data);
          notifyListeners();
        }
        catch (parseError) {
          print("Error parsing JSON: $parseError");
          print("Response body: ${res.body}");
          _topicsCoveredModel = null;
          notifyListeners();
         // throw Exception("Error parsing response: $parseError");
        }
      }
      else{
        _topicsCoveredModel = null;
        notifyListeners();
        //throw Exception("Failed to fetch data: ${res.statusCode}");
      }
    }
    catch(e){
      print("Error in getTopicCoveredDetails: $e");
      _topicsCoveredModel = null;
      notifyListeners();
      //rethrow;
    }
    finally{
      _isLoading = false;
      notifyListeners();
    }
  }
}