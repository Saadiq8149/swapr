import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter_session_jwt/flutter_session_jwt.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'landing.dart';
import 'swap_request.dart';
import 'willing_swap.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../util/util.dart';
import 'package:link_text/link_text.dart';
// import 'package:frontend/pages/landing.dart';

Future<void> logout(BuildContext context) async {
  await FlutterSessionJwt.deleteToken();
  Navigator.pushAndRemoveUntil<dynamic>(
    context,
    MaterialPageRoute<dynamic>(
      builder: (BuildContext context) => LandingPage(),
    ),
    (route) => false, //if you want to disable back feature set to false
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  dynamic swapRequests = [];
  dynamic swapSubmissions = [];
  dynamic userDetails;
  bool isLoading = false;
  String loadingMessage = "Loading...";
  final serverAddress = "swapr-saadiq8149-saadiq8149s-projects.vercel.app";

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

  Future<void> fetchSwapRequests() async {
    showLoading("Fetching data...."); // Show loader
    try {
      final token = await FlutterSessionJwt.retrieveToken();
      final url = Uri(
        scheme: 'https',
        host: serverAddress,
        path: '/getswaprequests',
        queryParameters: {'token': token},
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Assuming the response body is a JSON array
        final result = json.decode(response.body)['swap_requests'];
        for (dynamic x in result) {
          if (x['status'] == "Expired") {
            deleteRequest(x['id'].toString());
            return;
          }
        }
        setState(() {
          swapRequests = result;
        });
      } else {
        showErrorAlert("Network Error", context);
      }
    } catch (e) {
      showErrorAlert("An error occurred", context);
    } finally {
      hideLoading(); // Hide loader
    }
  }

  Future<void> fetchSwapSubmissions() async {
    showLoading("Fetching submissions..."); // Show loader
    try {
      final token = await FlutterSessionJwt.retrieveToken();
      final url = Uri(
        scheme: 'https',
        host: serverAddress,

        path: '/getswapsubmissions',
        queryParameters: {'token': token},
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final result = json.decode(response.body)['swap_requests'];
        setState(() {
          swapSubmissions = result;
        });
      } else {
        showErrorAlert("Network Error", context);
      }
    } catch (e) {
      showErrorAlert("An error occurred", context);
    } finally {
      hideLoading(); // Hide loader
    }
  }

  Future<void> deleteRequest(String id) async {
    showLoading("Deleting request..."); // Show loader
    try {
      final token = await FlutterSessionJwt.retrieveToken();
      final url = Uri(
        scheme: 'https',
        host: serverAddress,

        path: '/deleteswaprequest',
        queryParameters: {'token': token, 'id': id},
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        fetchSwapRequests();
        fetchSwapSubmissions();
      } else {
        showErrorAlert(response.body, context);
      }
    } catch (e) {
      showErrorAlert("An error occurred", context);
    } finally {
      hideLoading(); // Hide loader
    }
  }

  Future<void> deleteSubmission(String id) async {
    showLoading("Deleting submission..."); // Show loader
    try {
      final token = await FlutterSessionJwt.retrieveToken();
      final url = Uri(
        scheme: 'https',
        host: serverAddress,

        path: '/deleteswapsubmission',
        queryParameters: {'token': token, 'id': id},
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final result = json.decode(response.body)['swap_requests'];
        setState(() {
          swapSubmissions = result;
        });
      } else {
        showErrorAlert("Network Error", context);
      }
    } catch (e) {
      showErrorAlert("An error occurred", context);
    } finally {
      hideLoading(); // Hide loader
    }
  }

  Future<void> declineSwap(String id) async {
    showLoading("Declining swap..."); // Show loader
    try {
      final token = await FlutterSessionJwt.retrieveToken();
      final url = Uri(
        scheme: 'https',
        host: serverAddress,

        path: '/declineswap',
        queryParameters: {'token': token, 'id': id},
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        fetchSwapRequests();
        fetchSwapSubmissions();
      } else {
        showErrorAlert("Network Error", context);
      }
    } catch (e) {
      showErrorAlert("An error occurred", context);
    } finally {
      hideLoading(); // Hide loader
    }
  }

  Future<void> acceptSwap(String id) async {
    showLoading("Fetching rewards :)..."); // Show loader
    try {
      final token = await FlutterSessionJwt.retrieveToken();
      final url = Uri(
        scheme: 'https',
        host: serverAddress,

        path: '/acceptswap',
        queryParameters: {'token': token, 'id': id},
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        fetchSwapRequests();
        fetchSwapSubmissions();
      } else {
        showErrorAlert("Network Error", context);
      }
    } catch (e) {
      showErrorAlert("An error occurred", context);
    } finally {
      hideLoading(); // Hide loader
    }
  }

  Future<void> fetchUserDetails(BuildContext context) async {
    try {
      dynamic token = await FlutterSessionJwt.retrieveToken();
      if (token == null) {
        showErrorAlert("Session expired", context);
        return;
      } else {
        final url = Uri(
          scheme: 'https',
          host: serverAddress,

          path: '/getuser',
          queryParameters: {'token': token},
        );

        final response = await http.get(url);

        if (response.statusCode == 200) {
          final result = json.decode(response.body)['user'];
          setState(() {
            userDetails = result;
          });
        } else {
          showErrorAlert("Network Error", context);
        }
      }
    } catch (e) {
      showErrorAlert("An error occurred", context);
    }
  }

  @override
  void initState() {
    super.initState();
    // Delay to allow the widget to be fully built before showing loader
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await Future.wait([
          fetchSwapRequests(),
          fetchSwapSubmissions(),
          fetchUserDetails(context),
        ]);
      } catch (error) {
        if (mounted) {
          showErrorAlert("Error loading data", context);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.grey[50],
            leading: null,
            toolbarHeight: 50,
            title: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: const Text(
                      "swapR",
                      style: TextStyle(
                        color: Color(0xff1B56FD),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          fetchSwapRequests();
                          fetchSwapSubmissions();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.person),
                        onPressed:
                            () => showDialog(
                              context: context,
                              builder:
                                  (BuildContext context) => AlertDialog(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    title: const Text("User Profile"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 10,
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.person,
                                                color: Color(0xff1B56FD),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 8.0,
                                                ),
                                                child: Text(
                                                  "Name: ",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                child: Text(
                                                  userDetails != null
                                                      ? userDetails["name"]
                                                      : "",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.email,
                                              color: Color(0xff1B56FD),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 8.0,
                                              ),
                                              child: Text(
                                                "Email: ",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            Flexible(
                                              child: Text(
                                                userDetails != null
                                                    ? userDetails["email"]
                                                    : "",
                                                style: TextStyle(fontSize: 16),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text("Cancel"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text("Logout"),
                                        onPressed: () {
                                          logout(context);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  ),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // actions: [
            //   IconButton(
            //     onPressed: () {
            //       // logout();
            //     },
            //     icon: const Icon(Icons.person),
            //   ),
            // ],
            // centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 30.0,
                right: 20,
                bottom: 20,
                left: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 0.0),
                          child: Text(
                            "Your Swap Submissions",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => WillingToSwapPage(),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.add,
                              color: Colors.white,
                            ), // "+" icon
                            label: Text(
                              "New Swap",
                              style: TextStyle(color: Colors.white),
                            ), // Button text
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(
                                0xff1B56FD,
                              ), // Button color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return swapSubmissionCard(
                        index,
                        swapSubmissions,
                        deleteSubmission,
                        declineSwap,
                        acceptSwap,
                      );
                    },
                    itemCount: swapSubmissions.length,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 0.0),
                          child: Text(
                            "Your Swap Requests",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => SwapRequestPage(),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.add,
                              color: Colors.white,
                            ), // "+" icon
                            label: Text(
                              "New Request",
                              style: TextStyle(color: Colors.white),
                            ), // Button text
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(
                                0xff1B56FD,
                              ), // Button color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return swapRequestCard(
                        index,
                        swapRequests,
                        deleteRequest,
                        context,
                      );
                    },
                    itemCount: swapRequests.length,
                  ),
                ],
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

Widget swapRequestCard(
  int index,
  List<dynamic> swapRequests,
  dynamic deleteRequest,
  BuildContext context,
) {
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
        theme: ExpandableThemeData(
          headerAlignment: ExpandablePanelHeaderAlignment.center,
          iconColor: Color(0xff1B56FD),
          iconPadding: EdgeInsets.only(right: 10),
          tapBodyToExpand: true,
          tapBodyToCollapse: true,
        ),
        header: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(Icons.directions_subway_sharp, color: Color(0xff1B56FD)),
                Text(
                  swapRequests[index]["train_name"],
                  style: TextStyle(fontWeight: FontWeight.bold),
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
                color:
                    swapRequests[index]['status'] == "Pending"
                        ? Colors.amber[200]
                        : Colors.green[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                swapRequests[index]["status"],
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                // Status
              ),
            ), // ID
          ],
        ),
        collapsed: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month, color: Colors.grey),
                Text(
                  swapRequests[index]["date_of_journey"],
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        expanded: Column(
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month, color: Colors.grey),
                Text(
                  swapRequests[index]["date_of_journey"],
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text("From: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    swapRequests[index]!["from_station"],
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
                Text("To: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    swapRequests[index]!["to_station"],
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            swapRequests[index]['status'] != "Confirmed"
                ? Column(
                  children: [
                    Row(
                      children: [
                        Text.rich(
                          TextSpan(
                            text: "Current Seat: ",
                            children: [
                              TextSpan(
                                text: swapRequests[index]["seat"],
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                            ],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text.rich(
                          TextSpan(
                            text: "Current Berth: ",
                            children: [
                              TextSpan(
                                text: swapRequests[index]["berth"],
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                            ],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text.rich(
                          TextSpan(
                            text: "Requested Berth: ",
                            children: [
                              TextSpan(
                                text: swapRequests[index]["preferred_berth"]
                                    .replaceAll("[", "")
                                    .replaceAll("]", ""),
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                            ],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text.rich(
                            overflow: TextOverflow.ellipsis,
                            TextSpan(
                              text: "Reason: ",
                              children: [
                                TextSpan(
                                  text: swapRequests[index]["reason"]
                                      .replaceAll("[", "")
                                      .replaceAll("]", ""),
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
                : Row(),

            swapRequests[index]['status'] != "Confirmed"
                ? Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            title: Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Confirm Cancellation",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.amber,
                                  size: 40,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Are you sure you want to cancel this request?",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Upon cancelling, you will be refunded ₹10 of your money.",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            actionsAlignment: MainAxisAlignment.spaceEvenly,
                            actions: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[300],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  "No",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xff1B56FD),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  "Yes",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () {
                                  deleteRequest(
                                    swapRequests[index]["id"].toString(),
                                  );
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
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
                )
                : Row(),
            swapRequests[index]["status"] == "Confirmed"
                ? Column(
                  children: [swapRequestTile(index, swapRequests[index])],
                )
                : Row(),
          ],
        ),
      ),
    ),
  );
}

Widget swapSubmissionCard(
  int index,
  List<dynamic> swapSubmissions,
  dynamic deleteRequest,
  dynamic declineSwap,
  dynamic acceptSwap,
) {
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
        theme: ExpandableThemeData(
          headerAlignment: ExpandablePanelHeaderAlignment.center,
          iconColor: Color(0xff1B56FD),
          iconPadding: EdgeInsets.only(right: 10),
          tapBodyToExpand: true,
          tapBodyToCollapse: true,
        ),
        header: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(Icons.directions_subway_sharp, color: Color(0xff1B56FD)),
                Text(
                  swapSubmissions[index]["train_name"],
                  style: TextStyle(fontWeight: FontWeight.bold),
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
                color:
                    swapSubmissions[index]['status'] == "Pending"
                        ? Colors.amber[200]
                        : Colors.green[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                swapSubmissions[index]["status"],
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                // Status
              ),
            ), // ID
          ],
        ),
        collapsed: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month, color: Colors.grey),
                Text(
                  swapSubmissions[index]["date_of_journey"],
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Divider(color: Colors.grey.shade400, height: 20, thickness: 0.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wallet_giftcard_rounded, color: Color(0xff1B56FD)),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    "Tap the link to collect your reward:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: GestureDetector(
                onTap: () {
                  // Handle link tap
                },
                child: LinkText(
                  swapSubmissions[index]['cashgram_link'] ??
                      "Reward available after confirmation",
                  linkStyle: TextStyle(
                    fontSize: 14,
                    color: Color(0xff1B56FD),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        expanded: Column(
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month, color: Colors.grey),
                Text(
                  swapSubmissions[index]["date_of_journey"],
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text("From: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    swapSubmissions[index]!["from_station"],
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
                Text("To: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    swapSubmissions[index]!["to_station"],
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            swapSubmissions[index]['status'] == "Pending"
                ? Column(
                  children: [
                    Row(
                      children: [
                        Text.rich(
                          TextSpan(
                            text: "Your Berth: ",
                            children: [
                              TextSpan(
                                text: swapSubmissions[index]["berth"],
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                            ],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text.rich(
                          TextSpan(
                            text: "Berth Restrictions: ",
                            children: [
                              TextSpan(
                                text: swapSubmissions[index]["preferred_berth"]
                                    .replaceAll("[", "")
                                    .replaceAll("]", ""),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
                : Row(),
            swapSubmissions[index]["status"] != "Pending"
                ? Column(
                  children: [swapSubmissionTile(index, swapSubmissions[index])],
                )
                : Row(),
            swapSubmissions[index]["status"] == "Awaiting Confirmation"
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xff1B56FD),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                          child: GestureDetector(
                            onTap: () {
                              acceptSwap(
                                swapSubmissions[index]['id'].toString(),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, color: Colors.white),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    "Accept Swap",
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
                          declineSwap(swapSubmissions[index]['id'].toString());
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xff3D3D3D),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cancel, color: Colors.white),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    "Decline Swap",
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
                )
                : Row(),

            swapSubmissions[index]["status"] == "Pending"
                ? Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      deleteRequest(swapSubmissions[index]["id"].toString());
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
                )
                : Row(),
          ],
        ),
      ),
    ),
  );
}

Widget swapSubmissionTile(int index, Map<String, dynamic> passengerDetails) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
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
                  left: 20,
                  right: 20,
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
                            passengerDetails['berth'].toString(),
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
                            passengerDetails['coach'].toString(),
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
                            passengerDetails['seat'].toString(),
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
                  left: 20,
                  right: 20,
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
                        "New",
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
                            passengerDetails['swap_request_berth'].toString(),
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
                            passengerDetails['swap_request_coach'].toString(),
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
                            passengerDetails['swap_request_seat'].toString(),
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
          // Divider(color: Colors.grey.shade400, height: 20, thickness: 0.5),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     Icon(Icons.wallet_giftcard_rounded, color: Color(0xff1B56FD)),
          //     Padding(
          //       padding: const EdgeInsets.only(left: 8.0),
          //       child: Text(
          //         "Tap the link to collect your reward:",
          //         style: TextStyle(
          //           fontWeight: FontWeight.bold,
          //           fontSize: 14,
          //           color: Colors.grey[600],
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          // Padding(
          //   padding: const EdgeInsets.only(top: 8.0),
          //   child: GestureDetector(
          //     onTap: () {
          //       // Handle link tap
          //     },
          //     child: LinkText(
          //       passengerDetails['cashgram_link'] ?? "No link available",
          //       linkStyle: TextStyle(
          //         fontSize: 14,
          //         color: Color(0xff1B56FD),
          //         fontWeight: FontWeight.bold,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    ),
  );
}

Widget swapRequestTile(int index, Map<String, dynamic> passengerDetails) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
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
                  left: 20,
                  right: 20,
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
                            passengerDetails['berth'].toString(),
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
                            passengerDetails['coach'].toString(),
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
                            passengerDetails['seat'].toString(),
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
                  left: 20,
                  right: 20,
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
                        "New",
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
                            passengerDetails['willing_swap_berth'].toString(),
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
                            passengerDetails['willing_swap_coach'].toString(),
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
                            passengerDetails['willing_swap_seat'].toString(),
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
  );
}
