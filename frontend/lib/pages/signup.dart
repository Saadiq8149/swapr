import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_session_jwt/flutter_session_jwt.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'home.dart';
import 'login.dart';
import 'package:http/http.dart' as http;
import '../util/util.dart';

Future<void> register(
  BuildContext context,
  // String username,
  String password,
  String email,
  String name,
  String confirmPassword,
  String phoneNumber,
) async {
  String errorMessage = "None";
  String token = "";
  context.loaderOverlay.show();

  if (password == confirmPassword &&
      password.isNotEmpty &&
      email.isNotEmpty &&
      name.isNotEmpty) {
    try {
      final url = Uri(
        scheme: 'https',
        host: 'swapr-saadiq8149-saadiq8149s-projects.vercel.app',

        path: '/register',
      );
      final userDetails = jsonEncode({
        'password': password,
        'email': email,
        'name': name,
        'phone_number': phoneNumber,
      });
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: userDetails,
      );
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        token = responseBody['access_token'];
        errorMessage = "";
      } else if (response.statusCode == 400) {
        errorMessage = responseBody['detail'];
      } else {
        errorMessage = "Something went wrong";
      }
    } catch (e) {
      errorMessage = "Network error";
    }
  } else {
    errorMessage = "Passwords don't match";
  }

  if (errorMessage != "None" && errorMessage != "") {
    // ignore: use_build_context_synchronously
    context.loaderOverlay.hide();
    showErrorAlert(errorMessage, context);
  } else {
    // ignore: use_build_context_synchronously
    await FlutterSessionJwt.saveToken(token);
    Navigator.pushAndRemoveUntil<dynamic>(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute<dynamic>(builder: (BuildContext context) => HomePage()),
      (route) => false, //if you want to disable back feature set to false
    );
  }
}

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    String password = '';
    String email = '';
    String name = '';
    String confirmPassword = '';
    String phoneNumber = '';

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
                    padding: const EdgeInsets.only(bottom: 32.0),
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
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'Sign up',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(bottom: 16.0),
                  //   child: TextField(
                  //     onChanged: (value) => {username = value},
                  //     decoration: InputDecoration(
                  //       border: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(12.0),
                  //       ),
                  //       hintText: 'Username',
                  //       hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  //       contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  //     ),
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextField(
                      onChanged: (value) => {name = value},
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        hintText: 'Name',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextField(
                      keyboardType: TextInputType.phone,
                      onChanged: (value) => {phoneNumber = value},
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        hintText: 'Phone number',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextField(
                      onChanged: (value) => {password = value},
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
                    padding: const EdgeInsets.only(bottom: 24),
                    child: TextField(
                      onChanged: (value) => {confirmPassword = value},
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        hintText: 'Confirm Password',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () {
                        register(
                          context,
                          password,
                          email,
                          name,
                          confirmPassword,
                          phoneNumber,
                        );
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
                            'Sign up',
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
                                builder: (context) => LoginPage(),
                              ),
                            ),
                          },
                      child: Text.rich(
                        TextSpan(
                          text: 'Already a member? ',
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Login now',
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
