import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:thrive_pilot/screens/auth/login_page.dart';

import 'edit-profile.dart';
import 'invite-firends.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Settings",
              style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 24)),
          elevation: 0.0),
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: <Widget>[
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => EditProfile()),
                );
              },
              child: Container(
                decoration: BoxDecoration(border: Border(bottom: BorderSide())),
                padding: const EdgeInsets.only(left: 25, bottom: 20, top: 20),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.account_box, color: Color(0xFF727C8E)),
                    const SizedBox(width: 16),
                    Text(
                      'Account',
                      style: TextStyle(fontSize: 14, color: Color(0xFF212121)),
                    )
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => Invite()),
                );
              },
              child: Container(
                decoration: BoxDecoration(border: Border(bottom: BorderSide())),
                padding: const EdgeInsets.only(left: 25, bottom: 20, top: 20),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.share, color: Color(0xFF727C8E)),
                    const SizedBox(width: 16),
                    Text(
                      'Share ThrivePilot',
                      style: TextStyle(fontSize: 14, color: Color(0xFF212121)),
                    )
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                await _googleSignIn.signOut();
                await _auth.signOut();
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => LoginPage()));
              },
              child: Container(
                decoration: BoxDecoration(border: Border(bottom: BorderSide())),
                padding: const EdgeInsets.only(left: 25, bottom: 20, top: 20),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.power_settings_new, color: Color(0xFF727C8E)),
                    const SizedBox(width: 16),
                    Text(
                      'Log Out',
                      style: TextStyle(fontSize: 14, color: Color(0xFF212121)),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
