import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrive_pilot/screens/home/pages/timer/focus.dart';
import 'package:thrive_pilot/utils/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class Dashboard extends StatefulWidget {
  String selected;

  Dashboard({this.selected});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String selected = "meditate";

  void select(String i) {
    setState(() {
      selected = i;
    });
  }

  @override
  void initState() {
    selected = widget.selected ?? "meditate";
    super.initState();
  }

  void prompt(String url) async {
    print("Please go to the following URL and grant access:");
    print("  => $url");
    print("");
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void getCalendarEvents() async {
    var _scopes = const [cal.CalendarApi.CalendarEventsScope];
    var _credentials;
    if (Platform.isAndroid) {
      _credentials = new ClientId(
          "729228812626-ggbfbro4c6e7neoo9hsh4t2bkdl3akde.apps.googleusercontent.com",
          "");
    } else if (Platform.isIOS) {
      _credentials = new ClientId(
          "729228812626-pk06sc5nc4l59ah94ih9i4k582lqhn3b.apps.googleusercontent.com",
          "");
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var authClient;
    if (!prefs.containsKey("expiry")) {
      authClient = await clientViaUserConsent(_credentials, _scopes, prompt);
      print(authClient.credentials.accessToken.expiry);
      prefs.setString("type", authClient.credentials.accessToken.type);
      prefs.setString("data", authClient.credentials.accessToken.data);
      prefs.setString(
          "expiry", authClient.credentials.accessToken.expiry.toString());
      prefs.setString("refreshToken", authClient.credentials.refreshToken);
    } else {
      var date = DateFormat.jm()
          .format(DateTime.tryParse(prefs.get("expiry")).toLocal());
      print(date);
      print(prefs.get("expiry"));
      if (DateTime.tryParse(prefs.get("expiry"))
          .toLocal()
          .isBefore(DateTime.now())) {
        Dio dio = Dio();
        Response response =
            await dio.post("https://oauth2.googleapis.com/token", data: {
          "client_id": Platform.isAndroid
              ? "729228812626-ggbfbro4c6e7neoo9hsh4t2bkdl3akde.apps.googleusercontent.com"
              : "729228812626-pk06sc5nc4l59ah94ih9i4k582lqhn3b.apps.googleusercontent.com",
          "client_secret": "",
          "refresh_token": prefs.get("refreshToken"),
          "grant_type": "refresh_token"
        });
        print(response.data);
        // authClient = await clientViaUserConsent(_credentials, _scopes, prompt);
        // print(authClient.credentials.accessToken.expiry);
        prefs.setString("type", response.data["token_type"]);
        prefs.setString("data", response.data["access_token"]);
        prefs.setString(
            "expiry",
            DateTime.parse(prefs.get("expiry"))
                .add(Duration(seconds: response.data["expires_in"]))
                .toString());
        prefs.setString("refreshToken", prefs.get("refreshToken"));
        authClient = authenticatedClient(
          http.Client(),
          AccessCredentials(
              AccessToken(prefs.get("type"), prefs.get("data"),
                  DateTime.tryParse(prefs.get("expiry"))),
              prefs.get("refreshToken"),
              _scopes),
        );
      } else {
        authClient = authenticatedClient(
          http.Client(),
          AccessCredentials(
              AccessToken(prefs.get("type"), prefs.get("data"),
                  DateTime.tryParse(prefs.get("expiry"))),
              prefs.get("refreshToken"),
              _scopes),
        );
      }
    }
    cal.CalendarApi calendarApi = cal.CalendarApi(authClient);
    cal.Event event = cal.Event(); // Create object of event
    event.summary = selected[0].toUpperCase() +
        selected.substring(1) +
        " Session: ThrivePilot";
    calendarApi.events.insert(
      event,
      "primary",
    );
    // var calEvents = await calendarApi.events.list(
    //   "primary",
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () async {
              String url =
                  "https://www.google.com/calendar/render?action=TEMPLATE&text=" +
                      selected[0].toUpperCase() +
                      selected.substring(1) +
                      " Session: ThrivePilot&dates=${DateTime.now().toString().replaceAll('-', '').replaceAll(':', '').replaceAll(' ', 'T')}/${DateTime.now().add(Duration(hours: 1)).toString().replaceAll('-', '').replaceAll(':', '').replaceAll(' ', 'T')}&ctz=${DateTime.now().timeZoneName}";
              print(url);
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                Fluttertoast.showToast(msg: "Cannot open Calendar");
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 15),
              width: MediaQuery.of(context).size.width * 0.6,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  gradient: AppColors.gradient),
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Text(
                "ADD TO CALENDAR",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Container(
            margin: const EdgeInsets.only(top: 20, bottom: 30),
            child: Row(
              children: [
                Expanded(
                  child: RaisedButton(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    onPressed: () {
                      select("meditate");
                    },
                    child: Text(
                      "Meditate",
                      style: TextStyle(
                          color: selected == "meditate"
                              ? Colors.white
                              : AppColors.primaryColor,
                          fontSize: 20),
                    ),
                    color: selected == "meditate"
                        ? AppColors.primaryColor
                        : Colors.white,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: RaisedButton(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    onPressed: () {
                      select("focus");
                    },
                    child: Text(
                      "Focus",
                      style: TextStyle(
                          color: selected == "focus"
                              ? Colors.white
                              : AppColors.primaryColor,
                          fontSize: 20),
                    ),
                    color: selected == "focus"
                        ? AppColors.primaryColor
                        : Colors.white,
                  ),
                ),
              ],
            ),
          ),
          FocusPage(
            type: selected,
          )
        ],
      ),
    );
  }
}
