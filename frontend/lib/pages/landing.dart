import 'package:flutter/material.dart';
import 'login.dart';
import 'package:flutter_session_jwt/flutter_session_jwt.dart';
import 'home.dart';

Future<void> checkAuthentication(BuildContext context) async {
  final jwt = await FlutterSessionJwt.retrieveToken();
  if (jwt != null && !(await FlutterSessionJwt.isTokenExpired())) {
    Navigator.pushAndRemoveUntil<dynamic>(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute<dynamic>(builder: (BuildContext context) => HomePage()),
      (route) => false, //if you want to disable back feature set to false
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    checkAuthentication(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Color(0xffd7e7fd)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/backgrounds/swapr_infographic.png'),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 40,
                left: 32,
                right: 32,
                bottom: 20,
              ),
              child: GestureDetector(
                onTap:
                    () => {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      ),
                    },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xff1B56FD),
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.7),
                        blurRadius: 6,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
