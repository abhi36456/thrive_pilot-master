import 'package:flutter/material.dart';
import 'package:thrive_pilot/models/summary.dart';

class DashboardTable extends StatelessWidget {
  final Data data;
  final String title;

  DashboardTable({this.data, this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
          ),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.center,
            child: Text(
              title ?? "",
              style: TextStyle(fontSize: 22, color: Colors.white),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Table(
            border: TableBorder(
              top: BorderSide(color: Colors.white),
              horizontalInside: BorderSide(color: Colors.white),
              verticalInside: BorderSide(color: Colors.white),
            ),
            children: [
              TableRow(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: FittedBox(
                      child: Text(
                        "Today",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: FittedBox(
                      child: Text(
                        "This Week",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: FittedBox(
                      child: Text(
                        "This Month",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: FittedBox(
                      child: Text(
                        "All Time",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: Text(
                      double.parse(data.today).toStringAsFixed(2),
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: Text(
                      double.parse(data.thisWeek).toStringAsFixed(2),
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: Text(
                      double.parse(data.thisMonth).toStringAsFixed(2),
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: Text(
                      double.parse(data.all).toStringAsFixed(2),
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
