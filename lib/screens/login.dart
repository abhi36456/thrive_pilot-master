import 'dart:convert';
import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrive_pilot/utils/api.dart';
import 'package:thrive_pilot/utils/app_colors.dart';

import 'home/pages/timer/timer.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User _user;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(top: kToolbarHeight),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/icon.png",
                    height: 150,
                    width: 150,
                  ),
                ],
              ),
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  signIn(context);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: AppColors.primaryColor)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/google.png",
                        height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.1,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: Text(
                          "Sign in with Google",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void signIn(context) async {
    GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (googleSignInAccount != null) {
      Map<String, dynamic> authHeaders = await googleSignInAccount.authHeaders;
      prefs.setString("auth_headers", jsonEncode(authHeaders));
      GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      _user = result.user;
      assert(!_user.isAnonymous);
      assert(await _user.getIdToken() != null);
      User currentUser = _auth.currentUser;
      assert(_user.uid == currentUser.uid);
      try {
        Dio dio = Dio();
        Response response = await dio.post(baseUrl + "social_login.php",
            data: FormData.fromMap({
              "full_name": currentUser.displayName,
              "email": currentUser.email,
              "social_key": currentUser.uid,
              "login_type": "google",
              "profile_pic": currentUser.photoURL,
              "device_type": Platform.isAndroid ? "A" : "I",
              "device_token": "",
            }));
        var data = jsonDecode(response.data);
        print(data);
        if (data["status"]) {
          prefs.setString("key", data["data"]["auth_key"]);
          Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (_) => Dashboard()));
        } else {
          Fluttertoast.showToast(msg: data["message"]);
          await FirebaseAuth.instance.signOut();
          await _googleSignIn.signOut();
        }
      } catch (e) {
        await FirebaseAuth.instance.signOut();
        await _googleSignIn.signOut();
        Fluttertoast.showToast(msg: "Something went wrong!");
      }
    }
  }
}
