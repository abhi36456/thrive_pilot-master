import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrive_pilot/utils/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class CalendarEvents extends StatefulWidget {
  @override
  _CalendarEventsState createState() => _CalendarEventsState();
}

class _CalendarEventsState extends State<CalendarEvents> {
  List<Event> filtered;
  void getCalendarEvents() async {
    var _scopes = const [
      CalendarApi.CalendarEventsScope,
      CalendarApi.CalendarReadonlyScope
    ];
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
      prefs.setString("type", authClient.credentials.accessToken.type);
      prefs.setString("data", authClient.credentials.accessToken.data);
      prefs.setString(
          "expiry", authClient.credentials.accessToken.expiry.toString());
      prefs.setString("refreshToken", authClient.credentials.refreshToken);
    } else {
      var date = DateFormat.jm()
          .format(DateTime.tryParse(prefs.get("expiry")).toLocal());
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
    CalendarApi calendarApi = CalendarApi(authClient);
    var cale = await calendarApi.calendarList.list();
    List<Events> events = [];
    for (var i = 0; i < cale.items.length; i++) {
      var a = await calendarApi.events.list(
        cale.items[i].id,
      );
      events.add(a);
    }
    setState(() {
      filtered = [];
      events.forEach((element) {
        filtered.addAll(element.items.where((e) {
          return e.start.dateTime == null
              ? false
              : e.start.dateTime.difference(DateTime.now()).inDays == 0;
        }));
      });

      // filtered = calEvents.items.where((element) {
      //   return element.start.dateTime == null
      //       ? false
      //       : element.start.dateTime.difference(DateTime.now()).inDays == 0;
      // }).toList();
    });
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

  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Morning';
    }
    if (hour < 17) {
      return 'Afternoon';
    }
    return 'Evening';
  }

  @override
  void initState() {
    getCalendarEvents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        iconTheme: IconThemeData(color: AppColors.primaryColor),
        elevation: 0,
        title: Text("Schedule", style: TextStyle(color: Color(0xFF000000))),
        actions: [
          // FlatButton(
          //   child: Text("ADD TO CALENDAR"),
          //   onPressed: () async {
          //     if (await canLaunch("https://calendar.google.com/")) {
          //       await launch("https://calendar.google.com/");
          //     } else {
          //       Fluttertoast.showToast(msg: "Cannot open Calendar");
          //     }
          //   },
          // ),
        ],
      ),
      body: filtered == null
          ? Center(child: CircularProgressIndicator())
          : filtered.isEmpty
              ? Center(
                  child: Text("No Events to show"),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "Your Meetings",
                          style: TextStyle(
                              color: AppColors.primaryColor, fontSize: 32),
                        ),
                      ),
                      Center(
                        child: Text(
                          DateFormat("dd MMM, yyyy").format(DateTime.now()),
                          style: TextStyle(
                              color: AppColors.primaryColor, fontSize: 32),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Divider(
                        color: Color(0xFF808080),
                      ),
                      Text(
                        "Good ${greeting()}",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "You've got ${filtered.length} appointment(s) scheduled today: ",
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemBuilder: (ctx, index) {
                            var date = DateFormat.jm().format(
                                filtered[index].start.dateTime.toLocal());
                            var end = "";
                            if (filtered[index].end.dateTime != null) {
                              end = DateFormat.jm().format(
                                  filtered[index].end.dateTime.toLocal());
                            }
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "$date - $end",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    filtered[index].summary,
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  Divider(
                                    color: Color(0xFF808080),
                                  ),
                                ],
                              ),
                            );
                          },
                          itemCount: filtered.length,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
