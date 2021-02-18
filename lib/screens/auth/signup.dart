import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrive_pilot/screens/home/home.dart';
import 'package:thrive_pilot/utils/animation.dart';
import 'package:thrive_pilot/utils/app_colors.dart';

import 'login_page.dart';
import 'termsCondition.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _LoginData {
  String displayName = '';
  String email = '';
  String password = '';
}

class _SignupState extends State<Signup> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  _LoginData _data = new _LoginData();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              backgroundImageWidget(),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    FadeAnimation(
                        1.7,
                        Center(
                          child: Image.asset(
                            'assets/images/icon.png',
                            height: 150,
                            color: Colors.white,
                          ),
                        )),
                    signupFormWidget(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///Background image and logo
  Widget backgroundImageWidget() {
    return Positioned(
      top: -40,
      height: 400,
      width: MediaQuery.of(context).size.width,
      child: FadeAnimation(
          1,
          Container(
              decoration: BoxDecoration(
            color: AppColors.primaryColor,
          ))),
    );
  }

//Signup form Widget
  Widget signupFormWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: FadeAnimation(
        1.7,
        Container(
          height: MediaQuery.of(context).size.height * .55,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(196, 135, 198, .3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                )
              ]),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  FadeAnimation(
                      1.8,
                      Container(
                        width: MediaQuery.of(context).size.width - 100,
                        child: Text(
                          "Sign up",
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 24),
                        ),
                      )),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    height: 55.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        border: Border.all(color: Colors.grey)),
                    child: TextFormField(
                      style: TextStyle(fontWeight: FontWeight.w600),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Full Name",
                        hintStyle: TextStyle(
                            fontSize: 15, color: Colors.grey.withOpacity(0.8)),
                        icon: Icon(Icons.person),
                        border: InputBorder.none,
                      ),
                      onSaved: (String value) {
                        this._data.displayName = value;
                      },
                      onChanged: (value) {
                        this._data.displayName = value;
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter your name.';
                        }
                        return null;
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    height: 55.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        border: Border.all(color: Colors.grey)),
                    child: TextFormField(
                      style: TextStyle(fontWeight: FontWeight.w600),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Email",
                        hintStyle: TextStyle(
                            fontSize: 15, color: Colors.grey.withOpacity(0.8)),
                        icon: Icon(Icons.email),
                        border: InputBorder.none,
                      ),
                      onSaved: (String value) {
                        this._data.email = value;
                      },
                      onChanged: (String value) {
                        this._data.email = value;
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter your email address.';
                        }
                        return null;
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    height: 55.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        border: Border.all(color: Colors.grey)),
                    child: TextFormField(
                      obscureText: true,
                      style: TextStyle(fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.withOpacity(0.8),
                        ),
                        icon: Icon(Icons.lock),
                        border: InputBorder.none,
                      ),
                      onSaved: (String value) {
                        this._data.password = value;
                      },
                      onChanged: (String value) {
                        this._data.password = value;
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter password.';
                        }
                        return null;
                      },
                    ),
                  ),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "By pressing 'submit' you agree to our",
                          style: TextStyle(fontSize: 14),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => TermsAndCondition()));
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Text(
                              "terms & conditions",
                              style: TextStyle(
                                  color: Color(0xFFB74951), fontSize: 14),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  FadeAnimation(
                      1.8,
                      FloatingActionButton(
                        backgroundColor: AppColors.primaryColor,
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            final User currentUser = await register(_data);
                            await _setDataUser(currentUser, _data.displayName);
                            // SharedPreferences prefs =
                            //     await SharedPreferences.getInstance();
                            // await prefs.clear();
                            // await _auth.signOut();
                            Navigator.pushReplacement(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => Home()));
                          }
                        },
                        child: Icon(Icons.arrow_forward),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future register(_data) async {
    try {
      final User user = (await _auth.createUserWithEmailAndPassword(
        email: _data.email,
        password: _data.password,
      ))
          .user;
      return user;
    } catch (err) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(err.message),
        duration: Duration(seconds: 4),
      ));
    }
  }

  Future _setDataUser(currentUser, displayName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var expiryDate;
    Map metaData = {
      "createdBy": "0L1uQlYHdrdrG0D5CroAeybZsL33",
      "createdDate": DateTime.now(),
      "docId": currentUser.uid,
      "env": "production",
      "fl_id": currentUser.uid,
      "locale": "en-US",
      "schema": "users",
      "schemaRef": "fl_schemas/RIGJC2G8tsCBml0270IN",
      "schemaType": "collection",
    };
    try {
      FirebaseFirestore.instance
          .collection("fl_content")
          .doc(currentUser.uid)
          .set(
        {
          "_fl_meta_": metaData,
          "email": currentUser.email,
          "name": displayName,
          "joiningDate": DateTime.now().toString()
        },
        SetOptions(merge: true),
      );
      expiryDate = DateTime.now().add(new Duration(days: 7));
      prefs.setString('expiryDate', expiryDate.toString());
      prefs.setBool('isTrial', true);
    } catch (err) {
      print("Error: $err");
      throw (err);
    }
  }
}
