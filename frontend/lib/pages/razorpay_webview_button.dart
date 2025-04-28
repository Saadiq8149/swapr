//
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'home.dart';
import 'package:flutter_session_jwt/flutter_session_jwt.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RazorpayPaymentPage extends StatefulWidget {
  final Function onPaymentSuccess;
  final int amount;
  final dynamic pnr;
  final dynamic pnrDetails;
  final dynamic selectedPassengers;

  const RazorpayPaymentPage({
    required this.onPaymentSuccess,
    required this.amount,
    required this.pnr,
    required this.pnrDetails,
    required this.selectedPassengers,
    Key? key,
  }) : super(key: key);

  @override
  _RazorpayPaymentPageState createState() => _RazorpayPaymentPageState();
}

class _RazorpayPaymentPageState extends State<RazorpayPaymentPage> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _openCheckout();
  }

  void _openCheckout() {
    var options = {
      'key': 'rzp_test_0QuTw1JoWDwGlp', // Public key
      'amount': widget.amount * 100, // Amount is in paise
      'name': 'swapR',
      'description': 'SwapR Seat Swap Payment',
      'prefill': {
        'contact': '', // optional: you can prefill user's contact
        'email': '',
      },
      'theme': {'color': '#3b82f6'},
      'capture': true,
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("Payment successful: ${response.paymentId}");
    // await widget.onPaymentSuccess();

    await addPayment(
      widget.pnr,
      widget.pnrDetails,
      widget.selectedPassengers,
      response.paymentId!,
    );
    await capturePayment(response.paymentId!);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomePage()),
      (route) => false,
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("Payment failed: ${response.message}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
    Navigator.of(context).pop(); // Go back if payment failed
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("External Wallet selected: ${response.walletName}");
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Redirecting to Razorpay...")));
  }
}

// --- Keep your addPayment function here ---
Future<void> addPayment(
  dynamic pnr,
  dynamic pnrDetails,
  dynamic selectedPassengers,
  String paymentId,
) async {
  print(paymentId);
  final url = Uri(
    scheme: 'https',
    host:
        'swapr-saadiq8149-saadiq8149s-projects.vercel.app', // Replace with your backend URL
    path: '/addpayment',
  );

  final token = await FlutterSessionJwt.retrieveToken();

  final paymentDetails = {
    'token': token,
    'pnr': pnr,
    'train_name': pnrDetails!['trainName'],
    'train_number': pnrDetails['trainNo'],
    'date_of_journey': pnrDetails['dateOfJourney'],
    'from_station': pnrDetails['fromStation'],
    'to_station': pnrDetails['toStation'],
    'payment_id': paymentId,
    'coach':
        pnrDetails['passengerDetails'][selectedPassengers[0]['index']]['coach'],
    'berth':
        pnrDetails['passengerDetails'][selectedPassengers[0]['index']]['berth'],
    'seat':
        pnrDetails['passengerDetails'][selectedPassengers[0]['index']]['seat'],
    'preferred_coach': selectedPassengers[0]['coach'].toString(),
    'preferred_berth': selectedPassengers[0]['berth'].toString(),
    'status': 'Pending',
    'reason': selectedPassengers[0]['reason'].toString(),
  };

  final stringifiedPaymentDetails = {
    for (var entry in paymentDetails.entries) entry.key: entry.value.toString(),
  };

  final response = await http.post(
    url,
    body: jsonEncode(stringifiedPaymentDetails),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    print('Payment added successfully');
  } else {
    print('Failed to add payment: ${response.statusCode}');
  }
}

Future<void> capturePayment(String paymentId) async {
  final url = Uri(
    scheme: 'https',
    host:
        'swapr-saadiq8149-saadiq8149s-projects.vercel.app', // Replace with your backend URL
    path: '/capturepayment',
    queryParameters: {'payment_id': paymentId},
  );

  final response = await http.get(
    url,
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    print('Payment captured successfully');
  } else {
    print('Failed to capture payment: ${response.statusCode}');
  }
}
