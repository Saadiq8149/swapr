import 'package:flutter/material.dart';
import 'swap_confirm.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:expandable/expandable.dart';
import '../widgets/color_changing_button.dart';
import '../util/util.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'willing_to_swap_confirm.dart';

bool passengersAvailable(List<dynamic> passengers) {
  for (dynamic passenger in passengers) {
    if (passenger['confirmed']) {
      return true;
    }
  }
  return false;
}

class WillingToSwapPage extends StatefulWidget {
  const WillingToSwapPage({super.key});

  @override
  State<WillingToSwapPage> createState() => _WillingToSwapPage();
}

class _WillingToSwapPage extends State<WillingToSwapPage> {
  String pnr = '';
  int _currentStep = 1;
  Map<String, dynamic>? pnrDetails;
  List<dynamic> fetchedPassengers = [];
  bool isLoading = false;
  List<Map<String, dynamic>> choicesList = [];

  Future<void> fetchPNRDetails(BuildContext context, String pnr) async {
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
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          fetchedPassengers = responseBody['passengerDetails'];
          pnrDetails = responseBody;
          _currentStep = 2;
          isLoading = false;
        });
      } else {
        // ignore: use_build_context_synchronously
        showErrorAlert("Invalid PNR Number", context);
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
  }

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
      body: SingleChildScrollView(
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
                                  (event) => FocusScope.of(context).unfocus(),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                pnr = value;
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
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
                                      borderRadius: BorderRadius.circular(6.0),
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
                                      padding: const EdgeInsets.only(left: 8.0),
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
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      'Select Passengers for Seat Swap',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  )
                                  : Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
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
                                            if (i['index'] == choice['index']) {
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
                                  borderRadius: BorderRadius.circular(6.0),
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
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    backgroundColor: Color(0xff1B56FD),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6.0),
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
    // 'coach': "",
    'berth': [],
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
          expanded: Column(
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
              Divider(color: Colors.grey, thickness: 1),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Berth Limitations",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Wrap(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          BERTHS.map((item) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ColorChangingButton(
                                "Not " + item,
                                Color.fromARGB(255, 221, 80, 80),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void submitSwapRequest(
  BuildContext context,
  Map<String, dynamic>? pnrDetails,
  String pnr,
  List<Map<String, dynamic>> choices,
) {
  List<Map<String, dynamic>> selectedPassengers = [];
  for (Map<String, dynamic> choice in choices) {
    if (choice['selected'] == true) {
      selectedPassengers.add(choice);
    }
  }

  if (selectedPassengers.isEmpty) {
    showErrorAlert("Please select at least one passenger", context);
    return;
  }

  Navigator.of(context).push(
    MaterialPageRoute(
      builder:
          (context) => WillingToSwapConfirm(
            pnrDetails: pnrDetails,
            pnr: pnr,
            selectedPassengers: selectedPassengers,
          ),
    ),
  );
}
