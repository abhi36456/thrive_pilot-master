import 'package:flutter/material.dart';
import 'package:thrive_pilot/screens/home/pages/timer/focus.dart';
import 'package:thrive_pilot/utils/app_colors.dart';
// import 'mindfullness.dart';

class Dashboard extends StatefulWidget {
  String selected;

  Dashboard({this.selected});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String selected;

  void select(String i) {
    setState(() {
      if (selected == i)
        selected = null;
      else
        selected = i;
    });
  }

  @override
  void initState() {
    selected = widget.selected;
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
            height: 15,
          ),
          //buttons
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
