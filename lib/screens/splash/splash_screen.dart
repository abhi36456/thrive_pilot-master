import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thrive_pilot/screens/home/home.dart';

import '../auth/login_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void startTimer() {
    Timer(Duration(seconds: 3), navigate);
  }

  void navigate() async {
    if (FirebaseAuth.instance.currentUser == null)
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
    else {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => Home()));
    }
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/icon.png"),
            Text(
              "thrivepilot",
              style: TextStyle(
                  color: Color.fromRGBO(66, 66, 66, 1),
                  letterSpacing: 2,
                  fontSize: 40),
            ),
          ],
        ),
      ),
    );
  }
}
