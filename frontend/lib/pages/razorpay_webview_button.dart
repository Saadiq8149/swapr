import 'dart:convert';
import 'package:flutter/material.dart';
import 'home.dart';
// import 'package:frontend/pages/swap_confirm.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_session_jwt/flutter_session_jwt.dart';
import 'package:http/http.dart' as http;

class RazorpayWebview extends StatefulWidget {
  final Function onPaymentSuccess;
  final int amount;
  final pnr;
  final pnrDetails;
  final selectedPassengers;

  const RazorpayWebview({
    required this.onPaymentSuccess,
    required this.amount,
    required this.pnr,
    required this.pnrDetails,
    required this.selectedPassengers,
    Key? key,
  }) : super(key: key);

  @override
  State<RazorpayWebview> createState() => _RazorpayWebviewState();
}

class _RazorpayWebviewState extends State<RazorpayWebview> {
  final String razorpayHtml = '''
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <title>Pay with Swapr</title>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
      <style>
        :root {
          --bg: #f8fafc;
          --card-bg: #ffffff;
          --primary: #3b82f6;
          --primary-dark: #2563eb;
          --text: #1e293b;
          --text-light: #64748b;
          --border: #e2e8f0;
          --shadow-sm: 0 1px 3px rgba(0, 0, 0, 0.05);
          --shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
        }

        * {
          box-sizing: border-box;
          margin: 0;
          padding: 0;
        }

        body {
          background-color: var(--bg);
          font-family: 'Inter', sans-serif;
          color: var(--text);
          display: flex;
          align-items: center;
          justify-content: center;
          min-height: 100vh;
          padding: 20px;
        }

        .container {
          max-width: 400px;
          width: 100%;
        }

        .card {
          background-color: var(--card-bg);
          border-radius: 16px;
          box-shadow: var(--shadow);
          overflow: hidden;
          animation: fadeIn 0.6s ease-out;
        }

        .card-header {
          padding: 24px 32px;
          border-bottom: 1px solid var(--border);
          display: flex;
          align-items: center;
          justify-content: center;
          flex-direction: column;
        }

        .logo {
          display: flex;
          align-items: center;
          justify-content: center;
          margin-bottom: 16px;
        }

        .logo-icon {
          width: 36px;
          height: 36px;
          background-color: var(--primary);
          border-radius: 8px;
          display: flex;
          align-items: center;
          justify-content: center;
          margin-right: 12px;
          color: white;
          font-weight: 700;
          font-size: 18px;
        }

        .logo-text {
          font-size: 24px;
          font-weight: 700;
          color: var(--text);
          letter-spacing: -0.5px;
        }

        .card-body {
          padding: 32px;
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
        }

        h2 {
          font-weight: 600;
          font-size: 18px;
          margin-bottom: 8px;
          color: var(--text);
        }

        .description {
          color: var(--text-light);
          font-size: 14px;
          margin-bottom: 24px;
        }

        .secure-badge {
          display: flex;
          align-items: center;
          justify-content: center;
          margin-top: 24px;
          color: var(--text-light);
          font-size: 13px;
        }

        .secure-badge svg {
          margin-right: 6px;
          width: 14px;
          height: 14px;
        }

        .card-footer {
          padding: 16px 32px;
          background-color: #f8fafc;
          border-top: 1px solid var(--border);
          text-align: center;
          font-size: 13px;
          color: var(--text-light);
        }

        @keyframes fadeIn {
          from { opacity: 0; transform: translateY(20px); }
          to { opacity: 1; transform: translateY(0); }
        }

        @media (max-width: 480px) {
          .card-header, .card-body {
            padding: 24px;
          }
        }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="card">
          <div class="card-header">
            <div class="logo">
              <div class="logo-icon">S</div>
              <div class="logo-text">swapR</div>
            </div>
          </div>
          <div class="card-body">
            <h2>Complete Your Payment</h2>
            <p class="description">Secure payment processing by Razorpay</p>

            <form>
              <script src="https://checkout.razorpay.com/v1/payment-button.js" data-payment_button_id="pl_QHUA3lod86rMGJ" async></script>
            </form>

            <div class="secure-badge">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
              </svg>
              Secure 256-bit encrypted payment
            </div>
          </div>
          <div class="card-footer">
            © 2025 Swapr. All rights reserved.
          </div>
        </div>
      </div>
    </body>
    </html>
    ''';
  late final WebViewController controller;
  @override
  void initState() {
    super.initState();
    controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              // onProgress: (int progress) {},
              // onPageStarted: (String url) {},
              // onPageFinished: (String url) {},
              // onHttpError: (HttpResponseError error) {},
              // onWebResourceError: (WebResourceError error) {},
              onNavigationRequest: (NavigationRequest request) {
                if (request.url.startsWith('https://swapr.com/api/success/')) {
                  final uri = Uri.parse(request.url);
                  String? paymentId = uri.queryParameters['payment_id'];
                  if (paymentId != null) {
                    // Handle the payment success here
                    widget.onPaymentSuccess();
                    addPayment(
                      widget.pnr,
                      widget.pnrDetails,
                      widget.selectedPassengers,
                      paymentId,
                    );
                  }
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => HomePage()));
                  return NavigationDecision.prevent;
                } else if (request.url.startsWith('/')) {
                  Navigator.of(context).pop();
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadHtmlString(razorpayHtml);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: WebViewWidget(controller: controller));
  }
}

Future<void> addPayment(
  dynamic pnr,
  dynamic pnrDetails,
  dynamic selectedPassengers,
  String paymentId,
) async {
  final url = Uri(
    scheme: 'https',
    host: 'swapr-saadiq8149-saadiq8149s-projects.vercel.app',

    path: '/addpayment',
  );

  final token = await FlutterSessionJwt.retrieveToken();

  final paymentDetails = {
    'token': token,
    'payment_id': paymentId,
    'coach':
        pnrDetails['passengerDetails'][selectedPassengers[0]['index']]['coach'],
    'berth':
        pnrDetails['passengerDetails'][selectedPassengers[0]['index']]['berth'],
    'seat':
        pnrDetails['passengerDetails'][selectedPassengers[0]['index']]['seat'],
    'train_number': pnrDetails['trainNo'],
    'train_name': pnrDetails['trainName'],
    'date_of_journey': pnrDetails['dateOfJourney'],
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
    // Payment added successfully
    print('Payment added successfully');
  } else {
    // Handle error
    print('Failed to add payment: ${response.statusCode}');
  }
}
