import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
              // if (await canLaunch(url)) {
              try {
                await launch(Uri.encodeFull(url), forceSafariVC: false);
              } catch (e) {
                Fluttertoast.showToast(msg: e.toString());
              }
              // } else {
              //   Fluttertoast.showToast(msg: "Cannot open Calendar");
              // }
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
