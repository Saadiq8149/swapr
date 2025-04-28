import 'package:flutter/material.dart';
import 'dart:async'; // Add this import
import 'razorpay_webview_button.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import '../util/util.dart';
import 'home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_session_jwt/flutter_session_jwt.dart';

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
                    "15 fee",
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
  int trialUsesLeft = 0;
  bool isLoading = false;
  String loadingMessage = "Please wait...";

  @override
  void initState() {
    super.initState();
    // Start loading data after widget is built
    Future.microtask(() => fetchTrialUsesLeft());
  }

  // Show loading overlay
  void showLoading([String? message]) {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      if (message != null) {
        loadingMessage = message;
      }
    });
  }

  // Hide loading overlay
  void hideLoading() {
    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchTrialUsesLeft() async {
    showLoading("Fetching trial uses...");

    try {
      final token = await FlutterSessionJwt.retrieveToken();
      final url = Uri(
        scheme: 'https',
        host: 'swapr-saadiq8149-saadiq8149s-projects.vercel.app',
        path: '/gettrialuses',
        queryParameters: {'token': token},
      );

      final response = await http
          .get(url)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Connection timed out'),
          );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        setState(() {
          trialUsesLeft = result['trial_uses'] ?? 0;
        });
      } else {
        setState(() {
          trialUsesLeft = 0;
        });
        showErrorAlert("Failed to fetch trial uses", context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          trialUsesLeft = 0;
        });
        showErrorAlert("Error: ${e.toString()}", context);
      }
    } finally {
      hideLoading();
    }
  }

  Future<void> decreaseTrialUses() async {
    showLoading("Using free trial...");

    try {
      // First, decrease the trial count
      final token = await FlutterSessionJwt.retrieveToken();
      final decreaseUrl = Uri(
        scheme: 'https',
        host: 'swapr-saadiq8149-saadiq8149s-projects.vercel.app',
        path: '/decreasetrialuses',
        queryParameters: {'token': token},
      );

      final decreaseResponse = await http
          .get(decreaseUrl)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Connection timed out'),
          );

      if (!mounted) return;

      if (decreaseResponse.statusCode == 200) {
        // Trial uses decreased successfully, now try to add the swap request
        try {
          await addSwapRequest(
            widget.pnr,
            widget.selectedPassengers,
            widget.pnrDetails,
            1, // Mark as free/trial
          );
          // No need to do anything here as addSwapRequest will handle navigation on success
        } catch (e) {
          // If swap request failed, restore the trial use

          try {
            print("Restoring trial use...");
            final restoreUrl = Uri(
              scheme: 'https',
              host: 'swapr-saadiq8149-saadiq8149s-projects.vercel.app',
              path: '/restoretrialuses',
              queryParameters: {'token': token},
            );

            await http
                .get(restoreUrl)
                .timeout(
                  const Duration(seconds: 10),
                  onTimeout:
                      () => throw TimeoutException('Connection timed out'),
                );
          } catch (restoreError) {
            print("Failed to restore trial use: ${restoreError.toString()}");
            // Continue to show the original error even if restore fails
          }

          // Show the original error from addSwapRequest
          hideLoading();
          showErrorAlert("Swap Request Already Exists", context);
        }
      } else {
        // Failed to decrease trial uses
        final errorJson = json.decode(decreaseResponse.body);
        String errorMessage = "Failed to use trial";

        if (errorJson != null && errorJson.containsKey('detail')) {
          errorMessage = errorJson['detail'];
        }

        hideLoading();
        showErrorAlert(errorMessage, context);
      }
    } catch (e) {
      // Error in the overall process
      if (mounted) {
        hideLoading();
        showErrorAlert("An error occurred: ${e.toString()}", context);
      }
    }
  }

  Future<void> addSwapRequest(
    String pnr,
    List<Map<String, dynamic>> selectedPassengers,
    Map<String, dynamic>? pnrDetails,
    int trial,
  ) async {
    showLoading("Adding swap request...");

    try {
      final url = Uri(
        scheme: 'https',
        host: 'swapr-saadiq8149-saadiq8149s-projects.vercel.app',
        path: '/addswaprequest',
      );

      final token = await FlutterSessionJwt.retrieveToken();
      String errorMessage = "";

      for (int i = 0; i < selectedPassengers.length; i++) {
        if (!mounted) return;

        final passenger = selectedPassengers[i];
        setState(() {
          loadingMessage =
              "Processing request ${i + 1}/${selectedPassengers.length}...";
        });

        Map<String, dynamic> requestDetails = {
          'token': token,
          'pnr': pnr,
          'train_name': pnrDetails!['trainName'],
          'train_number': pnrDetails['trainNo'],
          'date_of_journey': pnrDetails['dateOfJourney'],
          'from_station': pnrDetails['fromStation'],
          'to_station': pnrDetails['toStation'],
          'berth': pnrDetails['passengerDetails'][passenger['index']]['berth'],
          'seat':
              pnrDetails['passengerDetails'][passenger['index']]['seat']
                  .toString(),
          'coach':
              pnrDetails['passengerDetails'][passenger['index']]['coach']
                  .toString(),
          'preferred_coach': passenger['coach'].toString(),
          'preferred_berth': passenger['berth'].toString(),
          'status': 'Pending',
          'reason': passenger['reason'].toString(),
          'payment_status': trial > 0 ? 'Free' : 'Paid',
        };

        final response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: json.encode(requestDetails),
            )
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () => throw TimeoutException('Connection timed out'),
            );

        if (response.statusCode != 200) {
          try {
            final responseJson = json.decode(response.body);
            if (responseJson != null && responseJson.containsKey('detail')) {
              errorMessage = responseJson['detail'];
            } else {
              errorMessage =
                  "Request failed with status: ${response.statusCode}";
            }
          } catch (e) {
            errorMessage = "Request failed with status: ${response.statusCode}";
          }

          // Important: Throw exception to be caught by decreaseTrialUses
          throw Exception(errorMessage);
        }
      }

      if (!mounted) return;

      hideLoading(); // Hide loader before navigation

      // If we got here, all requests were successful
      Navigator.pushAndRemoveUntil<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => HomePage(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        // Don't hide loading or show error here - let the caller handle it
        // This ensures the restore trial uses mechanism will work
        rethrow; // Re-throw to be caught by decreaseTrialUses
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> steps = ["PNR", "Select", "Confirm"];

    return Stack(
      children: [
        // Main Scaffold
        Scaffold(
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
                            color: Colors.grey.withOpacity(0.2),
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
                                  Icon(
                                    Icons.calendar_month,
                                    color: Colors.grey,
                                  ),
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
                                  Icon(
                                    Icons.pin_drop_sharp,
                                    color: Colors.grey,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        widget.pnrDetails!["fromStation"] +
                                            " to " +
                                            widget.pnrDetails!["toStation"],
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.visible,
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
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
                            color: Colors.grey.withOpacity(0.2),
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
                                trialUsesLeft > 0
                                    ? Text(
                                      "Free (${trialUsesLeft} trials left)",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    )
                                    : Text(
                                      "₹${widget.selectedPassengers.length * 15}",
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
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: GestureDetector(
                            onTap:
                                isLoading
                                    ? null
                                    : () {
                                      if (trialUsesLeft > 0) {
                                        // Use trial instead of payment
                                        decreaseTrialUses();
                                      } else {
                                        // Proceed to payment
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (
                                                  context,
                                                ) => RazorpayPaymentPage(
                                                  amount:
                                                      widget
                                                          .selectedPassengers
                                                          .length *
                                                      15,
                                                  onPaymentSuccess: () {
                                                    addSwapRequest(
                                                      widget.pnr,
                                                      widget.selectedPassengers,
                                                      widget.pnrDetails,
                                                      0,
                                                    );
                                                  },
                                                  pnr: widget.pnr,
                                                  pnrDetails: widget.pnrDetails,
                                                  selectedPassengers:
                                                      widget.selectedPassengers,
                                                ),
                                          ),
                                        );
                                      }
                                    },
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    isLoading
                                        ? Colors
                                            .grey // Disabled color when loading
                                        : (trialUsesLeft > 0
                                            ? Colors.green
                                            : Color(0xff1B56FD)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  0,
                                  12,
                                  0,
                                  12,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isLoading
                                          ? Icons.hourglass_empty
                                          : (trialUsesLeft > 0
                                              ? Icons.emoji_events
                                              : Icons.check_circle),
                                      color: Colors.white,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text(
                                        isLoading
                                            ? "Loading..."
                                            : (trialUsesLeft > 0
                                                ? "Use Free Trial"
                                                : "Proceed to Payment"),
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
                            onTap:
                                isLoading
                                    ? null
                                    : () {
                                      Navigator.pop(context);
                                    },
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    isLoading
                                        ? Colors.grey[400]
                                        : Color(0xff3D3D3D),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  0,
                                  12,
                                  0,
                                  12,
                                ),
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
                ],
              ),
            ),
          ),
        ),

        // Custom Loading Overlay
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xff1B56FD),
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        loadingMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
