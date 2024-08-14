import 'package:skillogic/pages/candidate_portal/EnrollmentPaymentCard.dart';
import 'package:skillogic/pages/candidate_portal/data_model/PaymentDetailModel.dart';
import 'package:flutter/material.dart';

import '../../helper/color.dart';
import '../../helper/connection.dart';
import '../../helper/user_details.dart';
import '../../model/user_model.dart';
import '../../widgets/CustomWidget.dart';
import '../main_page.dart';
import 'candidate_rest_request.dart';

class CandidatePaymentPage extends StatefulWidget {
  final String pageTitle;

  const CandidatePaymentPage({super.key, required this.pageTitle});

  @override
  State<CandidatePaymentPage> createState() => _CandidatePaymentPageState();
}

class _CandidatePaymentPageState extends State<CandidatePaymentPage> {
  CandidateRestRequest candidateRestRequest = CandidateRestRequest();
  List<PaymentDetailModel> candidatePaymentDetails = [];
  bool loaded = false;


  _getPayments() async {
    bool connected = await ConnectionCheck.isAvailable();
    if (!connected) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Connection Lost"),
              content: const Text("Please check your internet connection"),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MainPage()),
                        (route) => false);
                  },
                  child: const Text("Ok"),
                )
              ],
            );
          });
    } else {
      setState(() {
        loaded = false;
      });
      candidatePaymentDetails = await candidateRestRequest.getPayments(context);
      setState(() {
        loaded = true;
      });
    }
  }



  var userDetails = UserDetails();
  UserModel? userModel;

  _getUserDetail() async {
    userModel = await userDetails.getDetail();
    setState(() {});
  }

  @override
  void initState() {
    _getPayments();
    _getUserDetail();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:CustomWidget.getSkillogicAppBar(context, userModel, 1),
        body: RefreshIndicator(
          onRefresh: () async {
            await _getPayments();
          },
          child: Container(
              height: double.infinity,
              width: double.infinity,
              color: const Color(0xfff6f6f6),
              child: loaded
                  ? (candidatePaymentDetails.isEmpty)
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("No any payment found!"),
                            MaterialButton(
                                elevation: 1,

                                color: MainColor.skillogicRed,
                                onPressed: _getPayments,
                                child: const Text("Refresh", style: TextStyle(color: Colors.white),)),
                          ],
                        )
                      : SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Padding(
                                padding: const EdgeInsets.fromLTRB(16.0, 16,16,0),
                                child: Text(
                                  widget.pageTitle,
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                                ),
                              ),
                              for (PaymentDetailModel cPayment
                                  in candidatePaymentDetails)
                                EnrollmentPaymentCard(
                                    paymentDetailModel: cPayment)
                            ],
                          ),
                        )
                  : const Center(
                      child: Text("Loading"),
                    )),
        ));
  }
}
