import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'swap_confirm.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:expandable/expandable.dart';
import '../widgets/color_changing_button.dart';
import '../util/util.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_session_jwt/flutter_session_jwt.dart';

bool passengersAvailable(List<dynamic> passengers) {
  for (dynamic passenger in passengers) {
    if (passenger['confirmed']) {
      return true;
    }
  }
  return false;
}

class SwapRequestPage extends StatefulWidget {
  const SwapRequestPage({super.key});

  @override
  State<SwapRequestPage> createState() => _SwapRequestPageState();
}

class _SwapRequestPageState extends State<SwapRequestPage> {
  String pnr = '';
  int _currentStep = 1;
  Map<String, dynamic>? pnrDetails;
  List<dynamic> fetchedPassengers = [];
  bool isLoading = false;
  List<Map<String, dynamic>> choicesList = [];
  String loadingMessage = "Please wait...";

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

  Future<void> fetchPNRDetails(BuildContext context, String pnr) async {
    showLoading("Fetching PNR Details...");
    try {
      if (pnr.isEmpty) {
        // ignore: use_build_context_synchronously
        showErrorAlert("Please fill in all fields", context);
        setState(() {
          isLoading = false;
        });
      } else if (pnr.length == 10) {
        final url = Uri(
          scheme: 'https',
          host: 'swapr-saadiq8149-saadiq8149s-projects.vercel.app',

          path: '/pnr',
          queryParameters: {'pnr': pnr},
        );
        // final token = await FlutterSessionJwt.retrieveToken();
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          // final responseBody = jsonDecode(response.body);
          setState(() {
            fetchedPassengers = responseBody['passengerDetails'];
            pnrDetails = responseBody;
            _currentStep = 2;
            isLoading = false;
          });
        } else if (response.statusCode == 404) {
          final responseBody = jsonDecode(response.body);
          // ignore: use_build_context_synchronously
          showErrorAlert(responseBody["detail"], context);
          setState(() {
            isLoading = false;
          });
        }
      } else {
        // ignore: use_build_context_synchronously
        showErrorAlert("Invalid PNR Number", context);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      showErrorAlert("An error occurred", context);
      setState(() {
        isLoading = false;
      });
    } finally {
      hideLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = ["PNR", "Select", "Confirm"];
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.grey[50],
            leading: null,
            title: Center(
              child: StepProgressIndicator(
                totalSteps: 3,
                currentStep: _currentStep,
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
          body: LoaderOverlay(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
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
                                      "Enter PNR Number",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    onTapOutside:
                                        (event) =>
                                            FocusScope.of(context).unfocus(),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      pnr = value;
                                    },
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      hintText: 'Enter PNR',
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                      contentPadding: EdgeInsets.fromLTRB(
                                        10,
                                        0,
                                        10,
                                        0,
                                      ),
                                    ),
                                  ),
                                ),
                                isLoading
                                    ? Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: CircularProgressIndicator(
                                        color: Color(0xff1B56FD),
                                        strokeWidth: 5,
                                        backgroundColor: Colors.white,
                                      ),
                                    )
                                    : Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          fetchPNRDetails(context, pnr);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          backgroundColor: Color(0xff1B56FD),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              6.0,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          "Fetch",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    (pnrDetails != null && _currentStep >= 2)
                        ? Column(
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
                                            padding: const EdgeInsets.only(
                                              left: 8.0,
                                            ),
                                            child: Text(
                                              pnrDetails!['trainName'],
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
                                              padding: const EdgeInsets.only(
                                                left: 8.0,
                                              ),
                                              child: Text(
                                                pnrDetails!["dateOfJourney"],
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
                                            Text(
                                              "From: ",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 8.0,
                                              ),
                                              child: Text(
                                                pnrDetails!["fromStation"],
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
                                            Text(
                                              "To:      ",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 8.0,
                                              ),
                                              child: Text(
                                                pnrDetails!["toStation"],
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
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    passengersAvailable(fetchedPassengers)
                                        ? Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: Text(
                                            'Select Passenger for Seat Swap',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        )
                                        : Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: Text(
                                            'No Confirmed Seats for this PNR',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return fetchedPassengers[index]['confirmed']
                                            ? PassengerSelect(
                                              index,
                                              fetchedPassengers,
                                              pnrDetails!['coaches'],
                                              fetchedPassengers[index]['coach'],
                                              (Map<String, dynamic> choice) {
                                                for (dynamic i in choicesList) {
                                                  if (i['index'] ==
                                                      choice['index']) {
                                                    choicesList.remove(i);
                                                    choicesList.add(choice);
                                                    return;
                                                  }
                                                }
                                                choicesList.add(choice);
                                              },
                                            )
                                            : Row();
                                      },
                                      itemCount: fetchedPassengers.length,
                                      physics: NeverScrollableScrollPhysics(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    passengersAvailable(fetchedPassengers)
                                        ? MainAxisAlignment.spaceAround
                                        : MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      backgroundColor: Color(0xff3D3D3D),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          6.0,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      " Cancel ",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  passengersAvailable(fetchedPassengers)
                                      ? ElevatedButton(
                                        onPressed: () {
                                          // Handle confirm action
                                          // You can add your logic here
                                          submitSwapRequest(
                                            context,
                                            pnrDetails,
                                            pnr,
                                            choicesList,
                                            showLoading,
                                            hideLoading,
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          backgroundColor: Color(0xff1B56FD),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              6.0,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          "Confirm",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      )
                                      : Row(),
                                ],
                              ),
                            ),
                          ],
                        )
                        : Row(),
                  ],
                ),
              ),
            ),
          ),
        ),
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

class PassengerSelect extends StatefulWidget {
  final int index;
  final List<dynamic> passengerList;
  final List<dynamic> coachSelection;
  final String selectedValue;
  final Function(Map<String, dynamic>) onSelectionChange;
  // ignore: use_key_in_widget_constructors
  const PassengerSelect(
    this.index,
    this.passengerList,
    this.coachSelection,
    this.selectedValue,
    this.onSelectionChange,
  );

  @override
  State<PassengerSelect> createState() => _PassengerSelectState();
}

class _PassengerSelectState extends State<PassengerSelect> {
  late String _dropdownSelectedValue = "";
  final ExpandableController _expandableController = ExpandableController(
    initialExpanded: false,
  );
  Map<String, dynamic> choices = {
    'index': 0,
    'selected': false,
    'coach': "",
    'berth': [],
    'reason': [],
  };

  List<String> BERTHS = [];

  @override
  void initState() {
    super.initState();
    _dropdownSelectedValue = widget.selectedValue;
    choices['coach'] = _dropdownSelectedValue;
    choices['index'] = widget.index;

    _expandableController.addListener(() {
      setState(() {
        if (_expandableController.expanded) {
          choices['selected'] = true;
        } else {
          choices['selected'] = false;
        }
      });
    });
    widget.onSelectionChange(choices);

    if (widget.passengerList[widget.index]['coach'][0] == "B") {
      BERTHS = ["SL", "SU", "UB", "MB", "LB"];
    } else if (widget.passengerList[widget.index]['coach'][0] == "A") {
      BERTHS = ["SL", "SU", "UB", "LB"];
    } else {
      BERTHS = ["SL", "SU", "UB", "MB", "LB"];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        padding: const EdgeInsets.all(10),
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
        child: ExpandablePanel(
          controller: _expandableController,
          theme: ExpandableThemeData(
            headerAlignment: ExpandablePanelHeaderAlignment.center,
            iconColor: Color(0xff1B56FD),
            iconPadding: EdgeInsets.only(right: 10),
            tapBodyToExpand: true,
            tapBodyToCollapse: true,
            expandIcon: Icons.check_box_outline_blank,
            collapseIcon: Icons.check_box,
          ),
          header: Text(
            widget.passengerList[widget.index]['confirmed']
                ? "Confirmed"
                : "Not Confirmed",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color:
                  widget.passengerList[widget.index]['confirmed']
                      ? const Color.fromARGB(255, 22, 186, 28)
                      : Colors.red,
            ),
          ),
          collapsed: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  text: "Current Berth: ",
                  children: [
                    TextSpan(
                      text: widget.passengerList[widget.index]['berth'],
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text.rich(
                TextSpan(
                  text: "Current Coach: ",
                  children: [
                    TextSpan(
                      text: widget.passengerList[widget.index]['coach'],
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          expanded:
              widget.passengerList[widget.index]['confirmed']
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text.rich(
                            TextSpan(
                              text: "Current Berth: ",
                              children: [
                                TextSpan(
                                  text:
                                      widget.passengerList[widget
                                          .index]['berth'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              text: "Current Coach: ",
                              children: [
                                TextSpan(
                                  text:
                                      widget.passengerList[widget
                                          .index]['coach'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Colors.grey, thickness: 1),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Berth preference",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:
                                  BERTHS.map((item) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ColorChangingButton(
                                        item,
                                        Color(0xff1B56FD),
                                        Colors.white,
                                        () {
                                          if (choices['berth'].contains(item)) {
                                            choices['berth'].remove(item);
                                          } else {
                                            choices['berth'].add(item);
                                          }
                                          widget.onSelectionChange(choices);
                                        },
                                      ),
                                    );
                                  }).toList(),
                            ),
                            Text(
                              "Reason for swap",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Wrap(
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                                  [
                                    "Elderly Passenger",
                                    "Luggage",
                                    "Group Booking",
                                    "Other",
                                  ].map((item) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ColorChangingButton(
                                        item,
                                        Color(0xff1B56FD),
                                        Colors.white,
                                        () {
                                          if (choices['reason'].contains(
                                            item,
                                          )) {
                                            choices['reason'].remove(item);
                                          } else {
                                            choices['reason'].add(item);
                                          }
                                          widget.onSelectionChange(choices);
                                        },
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                  : Row(),
        ),
      ),
    );
  }
}

Future<void> submitSwapRequest(
  BuildContext context,
  Map<String, dynamic>? pnrDetails,
  String pnr,
  List<Map<String, dynamic>> choices,
  dynamic showLoading,
  dynamic hideLoading,
) async {
  showLoading("Submitting Swap Request...");
  try {
    List<Map<String, dynamic>> selectedPassengers = [];
    for (Map<String, dynamic> choice in choices) {
      if (choice['selected'] == true) {
        selectedPassengers.add(choice);
      }
    }

    if (selectedPassengers.isEmpty) {
      showErrorAlert("Please select at least one passenger", context);
      return;
    } else if (selectedPassengers.length > 1) {
      showErrorAlert("You can only swap one passenger at a time", context);
      return;
    }

    for (Map<String, dynamic> passenger in selectedPassengers) {
      if (passenger['berth'].isEmpty) {
        showErrorAlert("Please select a berth preference", context);
        return;
      }
      if (passenger['reason'].isEmpty) {
        showErrorAlert("Please select a reason for swapping", context);
        return;
      }
    }

    final token = await FlutterSessionJwt.retrieveToken();
    final url = Uri(
      scheme: 'https',
      host: 'swapr-saadiq8149-saadiq8149s-projects.vercel.app',

      path: '/addswaprequest',
    );

    for (Map<String, dynamic> passenger in selectedPassengers) {
      Map<String, dynamic> requestDetails = {
        'token': token,
        'pnr': pnr,
        'train_name': pnrDetails!['trainName'],
        'date_of_journey': pnrDetails['dateOfJourney'],
        'from_station': pnrDetails['fromStation'],
        'to_station': pnrDetails['toStation'],
        'passenger_name':
            pnrDetails['passengerDetails'][passenger['index']]['name'],
        'berth': pnrDetails['passengerDetails'][passenger['index']]['berth'],
        'seat':
            pnrDetails['passengerDetails'][passenger['index']]['seat']
                .toString(),
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
        showErrorAlert("Swap request already exists", context);
        return;
      }
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => SwapConfirmPage(
              pnrDetails: pnrDetails,
              pnr: pnr,
              selectedPassengers: selectedPassengers,
            ),
      ),
    );
  } catch (e) {
    showErrorAlert("An error occurred", context);
  } finally {
    hideLoading();
  }
}
