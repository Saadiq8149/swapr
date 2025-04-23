import 'package:flutter/material.dart';
import 'razorpay_webview_button.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import '../util/util.dart';
import 'home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_session_jwt/flutter_session_jwt.dart';

class SwapConfirmPage extends StatefulWidget {
  final Map<String, dynamic>? pnrDetails;
  final String pnr;
  final List<Map<String, dynamic>> selectedPassengers;

  // ignore: use_key_in_widget_constructors
  const SwapConfirmPage({
    required this.pnrDetails,
    required this.pnr,
    required this.selectedPassengers,
  });

  @override
  State<SwapConfirmPage> createState() => _SwapConfirmPageState();
}

class _SwapConfirmPageState extends State<SwapConfirmPage> {
  @override
  Widget build(BuildContext context) {
    List<String> steps = ["PNR", "Select", "Confirm"];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        leading: null,
        title: Center(
          child: StepProgressIndicator(
            totalSteps: 3,
            currentStep: 3,
            size: 36,
            selectedColor: Color(0xff1B56FD),
            unselectedColor: Colors.grey,
            customStep:
                (index, color, _) =>
                    color == Color(0xff1B56FD)
                        ? Container(
                          color: color,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 12,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  steps[index],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        : Container(
                          color: Colors.grey[300],
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.remove,
                                color: Color(0xff3D3D3D),
                                size: 12,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  steps[index],
                                  style: TextStyle(
                                    color: Color(0xff3D3D3D),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.directions_subway_sharp,
                              color: Color(0xff1B56FD),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                widget.pnrDetails!['trainName'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_month, color: Colors.grey),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  widget.pnrDetails!["dateOfJourney"],
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.pin_drop_sharp, color: Colors.grey),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  widget.pnrDetails!["fromStation"] +
                                      // ignore: prefer_interpolation_to_compose_strings
                                      " to " +
                                      widget.pnrDetails!["toStation"],
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "Passenger Swap Details",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return selectedPassengerTiles(
                      index,
                      widget.selectedPassengers[index],
                      widget.pnrDetails,
                    );
                  },
                  itemCount: widget.selectedPassengers.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total Fee",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "₹${widget.selectedPassengers.length * 10}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff1B56FD),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: GestureDetector(
                  onTap: () {
                    // Handle confirm action
                  },
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            // Handle payment action
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => RazorpayWebview(
                                      amount:
                                          widget.selectedPassengers.length * 15,
                                      onPaymentSuccess: () {
                                        addSwapRequest(
                                          context,
                                          widget.pnr,
                                          widget.selectedPassengers,
                                          widget.pnrDetails,
                                        );
                                      },
                                      pnr: widget.pnr,
                                      pnrDetails: widget.pnrDetails,
                                      selectedPassengers:
                                          widget.selectedPassengers,
                                    ),
                              ),
                            );
                            // addSwapRequest(
                            //   context,
                            //   widget.pnr,
                            //   widget.selectedPassengers,
                            //   widget.pnrDetails,
                            // );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xff1B56FD),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      "Proceed to Payment",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xff3D3D3D),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.cancel, color: Colors.white),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      "Cancel Request",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget selectedPassengerTiles(
  int index,
  Map<String, dynamic> choices,
  Map<String, dynamic>? pnrDetails,
) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, color: Color(0xff1B56FD)),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        "Confirmed",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(
                    top: 5,
                    bottom: 5,
                    left: 10,
                    right: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 218, 236, 252),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "10 fee",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff1B56FD),
                    ),
                    // Status
                  ),
                ),
              ],
            ),
            Divider(color: Colors.grey.shade400, height: 20, thickness: 0.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  padding: const EdgeInsets.only(
                    top: 5,
                    bottom: 5,
                    left: 10,
                    right: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "Current",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Berth: ",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff3D3D3D),
                              ),
                            ),
                            Text(
                              pnrDetails!['passengerDetails'][choices['index']]['berth']
                                  .toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: Color(0xff3D3D3D),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Coach: ",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff3D3D3D),
                              ),
                            ),
                            Text(
                              pnrDetails['passengerDetails'][choices['index']]['coach']
                                  .toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: Color(0xff3D3D3D),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Seat: ",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff3D3D3D),
                              ),
                            ),
                            Text(
                              pnrDetails['passengerDetails'][choices['index']]['seat']
                                  .toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: Color(0xff3D3D3D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_circle_right_outlined,
                  color: Color(0xff1B56FD),
                  size: 32,
                ),
                Container(
                  padding: const EdgeInsets.only(
                    top: 5,
                    bottom: 5,
                    left: 10,
                    right: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 218, 236, 252),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "Preferred",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Berth: ",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff3D3D3D),
                              ),
                            ),
                            Text(
                              choices['berth']
                                  .map((x) => x.toString())
                                  .join("|"),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: Color(0xff3D3D3D),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Coach: ",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff3D3D3D),
                              ),
                            ),
                            Text(
                              choices['coach'].toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: Color(0xff3D3D3D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> addSwapRequest(
  BuildContext context,
  String pnr,
  List<Map<String, dynamic>> selectedPassengers,
  Map<String, dynamic>? pnrDetails,
) async {
  final url = Uri(
    scheme: 'https',
    host: 'swapr-saadiq8149-saadiq8149s-projects.vercel.app',

    path: '/addswaprequest',
  );

  final token = await FlutterSessionJwt.retrieveToken();

  for (dynamic passenger in selectedPassengers) {
    final requestDetails = {
      'token': token,
      'pnr': pnr,
      'train_name': pnrDetails!['trainName'],
      'train_number': pnrDetails['trainNo'],
      'date_of_journey': pnrDetails['dateOfJourney'],
      'from_station': pnrDetails['fromStation'],
      'to_station': pnrDetails['toStation'],
      'coach': pnrDetails['passengerDetails'][passenger['index']]['coach'],
      'berth': pnrDetails['passengerDetails'][passenger['index']]['berth'],
      'seat':
          pnrDetails['passengerDetails'][passenger['index']]['seat'].toString(),
      'preferred_coach': passenger['coach'].toString(),
      'preferred_berth': passenger['berth'].toString(),
      'status': 'Pending',
      'reason': passenger['reason'].toString(),
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestDetails),
    );

    if (response.statusCode == 200) {
      Navigator.pushAndRemoveUntil<dynamic>(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => HomePage(),
        ),
        (route) => false, //if you want to disable back feature set to false
      );
    } else if (response.statusCode == 410) {
      showErrorAlert(json.decode(response.body)['detail'], context);
    } else {
      showErrorAlert(response.body, context);
    }
  }
}
