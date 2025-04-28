import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'home.dart';
import 'signup.dart';
import 'package:http/http.dart' as http;
import '../util/util.dart';
import 'package:flutter_session_jwt/flutter_session_jwt.dart';

Future<void> login(BuildContext context, String email, String password) async {
  if (email.isEmpty || password.isEmpty) {
    // ignore: use_build_context_synchronously
    showErrorAlert("Please fill in all fields", context);
    return;
  }

  context.loaderOverlay.show();

  try {
    final url = Uri(
      scheme: 'https',
      host: 'swapr-saadiq8149-saadiq8149s-projects.vercel.app',
      path: '/login',
    );

    final userDetails = {'password': password, 'email': email};
    final response = await http.post(
      url,
      body: jsonEncode(userDetails),
      headers: {'Content-Type': 'application/json'},
    );
    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final token = responseBody['access_token'];
      await FlutterSessionJwt.saveToken(token);
      Navigator.pushAndRemoveUntil<dynamic>(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => HomePage(),
        ),
        (route) => false, //if you want to disable back feature set to false
      );
    } else if (response.statusCode == 400) {
      // ignore: use_build_context_synchronously
      showErrorAlert(responseBody['detail'], context);
    } else {
      // ignore: use_build_context_synchronously
      showErrorAlert("Something went wrong", context);
    }
  } catch (e) {
    // ignore: use_build_context_synchronously
    showErrorAlert("Network error", context);
  } finally {
    context.loaderOverlay.hide();
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    String email = '';
    String password = '';

    return LoaderOverlay(
      child: Scaffold(
        body: Align(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 45, right: 45),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Image(
                            image: AssetImage(
                              'assets/icons/swapr_logo_transparent.png',
                            ),
                            width: 60,
                          ),
                        ),
                        Text(
                          "swapR",
                          style: TextStyle(
                            color: Color(0xff1B56FD),
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'Welcome!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextField(
                      onChanged: (value) => {email = value},
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        hintText: 'Email',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: TextField(
                      onChanged: (value) => {password = value},
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        hintText: 'Password',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () {
                        login(context, email, password);
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xff1B56FD),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap:
                          () => {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SignupPage(),
                              ),
                            ),
                          },
                      child: Text.rich(
                        TextSpan(
                          text: 'Not a member? ',
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Register now',
                              style: TextStyle(
                                color: Color(0xff1B56FD),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  // Divider(
                  //   color: Colors.grey.shade400,
                  //   height: 30,
                  //   thickness: 0.5,
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.only(bottom: 12),
                  //   child: Align(
                  //     alignment: Alignment.center,
                  //     child: Text(
                  //       'Or',
                  //       style: TextStyle(color: Colors.grey, fontSize: 14),
                  //     ),
                  //   ),
                  // ),
                  // GestureDetector(
                  //   onTap: () => {print("Google")},
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //       color: Colors.redAccent,
                  //       borderRadius: BorderRadius.circular(10),
                  //     ),
                  //     child: Padding(
                  //       padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                  //       child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: [
                  //           Image(
                  //             image: AssetImage(
                  //               'assets/icons/google_white.png',
                  //             ),
                  //             width: 20,
                  //           ),
                  //           Padding(
                  //             padding: const EdgeInsets.only(left: 10),
                  //             child: Text(
                  //               "Continue with Google",
                  //               style: TextStyle(
                  //                 color: Colors.white,
                  //                 fontWeight: FontWeight.bold,
                  //               ),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
