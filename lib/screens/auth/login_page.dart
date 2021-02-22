import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:thrive_pilot/screens/auth/signup.dart';
import 'package:thrive_pilot/utils/animation.dart';
import 'package:thrive_pilot/utils/app_colors.dart';

import '../home/home.dart';
import 'forgetPassword.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginData {
  String email = '';
  String password = '';
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  _LoginData _data = new _LoginData();

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    print("build");
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            backgroundImageWidget(),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  FadeAnimation(
                      1.5,
                      Text(
                        "Login",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 30),
                      )),
                  SizedBox(
                    height: 30,
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
                  loginFormWidget(),
                  SizedBox(
                    height: 20,
                  ),
                  FadeAnimation(
                      1.9,
                      const Text(
                        "or connect with",
                        style: TextStyle(fontSize: 14),
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  socialLoginWidget(),
                  const SizedBox(
                    height: 15,
                  ),
                  signupButtonWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Displaying background image and logo
  Widget backgroundImageWidget() {
    return Positioned(
        top: -40,
        height: 400,
        width: MediaQuery.of(context).size.width,
        child: Container(
          decoration: BoxDecoration(color: AppColors.primaryColor),
        ));
  }

  /// login form
  Widget loginFormWidget() {
    return FadeAnimation(
        1.7,
        Container(
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
            padding: const EdgeInsets.all(15.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  FadeAnimation(
                      1.8,
                      Container(
                        width: MediaQuery.of(context).size.width - 100,
                        child: Text(
                          "Login",
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 24),
                        ),
                      )),
                  SizedBox(
                    height: 20,
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
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Email address required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
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
                          border: InputBorder.none),
                      onSaved: (String value) {
                        this._data.password = value;
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Password required';
                        }
                        return null;
                      },
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      final showSnackBar = await Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => ForgetPassword()));
                      if (showSnackBar != null && showSnackBar == true) {
                        _scaffoldKey.currentState.showSnackBar(SnackBar(
                          content: Text(
                              'Follow the link sent to your email address to reset the password.'),
                          duration: Duration(seconds: 8),
                        ));
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Center(
                          child: Text(
                        "Forgot your password?",
                        style: TextStyle(
                          color: AppColors.primaryColor,
                        ),
                      )),
                    ),
                  ),
                  FadeAnimation(
                      1.8,
                      FloatingActionButton(
                        backgroundColor: AppColors.primaryColor,
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            await _handleSignIn(_data);
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
        ));
  }

  ///Login Button Navigate to Home screen
  Widget loginButtonWidget() {
    return Positioned(
      height: 200,
      width: MediaQuery.of(context).size.width + 20,
      child: FadeAnimation(
        1.9,
        Container(
          child: InkWell(
            onTap: () {
              Navigator.push(
                  context, CupertinoPageRoute(builder: (context) => Home()));
            },
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: AppColors.primaryColor,
              ),
              child: Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  /// Social login button like Facebook, Twitter, Google
  Widget socialLoginWidget() {
    return FadeAnimation(
      1.9,
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            InkWell(
              child: Material(
                child: SvgPicture.asset(
                  'assets/images/google.svg',
                  semanticsLabel: 'Acme Logo',
                  height: 35,
                  width: 35,
                ),
              ),
              onTap: () async {
                print("pressed");
                final User currentUser = await _handleGoogleSignIn();
                print(currentUser);
                if (currentUser != null) {
                  await _setDataUser(currentUser);
                  await Navigator.pushReplacement(context,
                      CupertinoPageRoute(builder: (context) => Home()));
                }
              },
            ),
            SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  Widget signupButtonWidget() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("You do not have an account?"),
          InkWell(
            onTap: () {
              Navigator.push(
                  context, CupertinoPageRoute(builder: (context) => Signup()));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Text(
                " Register Now!",
                style: TextStyle(color: AppColors.primaryColor),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<User> _handleGoogleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final User user = (await _auth.signInWithCredential(credential)).user;
    return user;
  }

  Future<User> _handleSignIn(_data) async {
    UserCredential firebaseAuth;
    try {
      firebaseAuth = await _auth.signInWithEmailAndPassword(
          email: _data.email, password: _data.password);
    } catch (err) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(err.message),
        duration: Duration(seconds: 5),
      ));
      throw (err);
    }
    _setDataUser(firebaseAuth.user);
    return firebaseAuth.user;
  }
}

Future _setDataUser(User currentUser) async {
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
    if (currentUser.uid != null) {
      FirebaseFirestore.instance
          .collection('fl_content')
          .where('_fl_meta_.fl_id', isEqualTo: currentUser.uid)
          .get()
          .then((QuerySnapshot snapshot) async {
        // check if user exists.
        if (snapshot.docs.length <= 0) {
          await FirebaseFirestore.instance
              .collection("fl_content")
              .doc(currentUser.uid)
              .set({
            "_fl_meta_": metaData,
            "email": currentUser.email,
            "name": currentUser.displayName,
            "photoUrl": currentUser.photoURL,
            "joiningDate": DateTime.now().toString()
          }, SetOptions(merge: true));
        }
      });
    }
  } catch (err) {
    print("Error: $err");
  }
}
