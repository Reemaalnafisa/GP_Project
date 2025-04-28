

import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gat_helper_app/const/data/line_chart_data.dart';
import 'package:gat_helper_app/features/auth/views/BarGraphCard.dart';
import 'package:gat_helper_app/features/auth/views/student.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


import 'package:gat_helper_app/model/BarGraphModel.dart';

class BarGraphData {
  final data = [
    const BarGraphModel(
        label: "Active Hours",
        color: Color(0xFF5A88FE),
        graph: [
          GraphModel(x: 0, y: 2),  // Monday
          GraphModel(x: 1, y: 4),  // Tuesday
          GraphModel(x: 2, y: 6),  // Wednesday
          GraphModel(x: 3, y: 10), // Thursday
          GraphModel(x: 4, y: 12), // Friday
          GraphModel(x: 5, y: 8),  // Saturday
          GraphModel(x: 6, y: 14), // Sunday
        ]),
  ];

  final label = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
}

class BarGraphCard extends StatefulWidget {
  final Future<Map<int, double>> Function() fetchActivityData;

  BarGraphCard({required this.fetchActivityData});

  @override
  _BarGraphCardState createState() => _BarGraphCardState();
}

class _BarGraphCardState extends State<BarGraphCard> {
  Map<int, double> activityData = {}; // Holds activity hours for the week

  @override
  void initState() {
    super.initState();
    fetchActivityData();
  }

  Future<void> fetchActivityData() async {
    final data = await widget.fetchActivityData();
    setState(() {
      activityData = data;
    });
  }

  Color getBarColor(double hours) {
    if (hours >= 5) {
      return Colors.green; // Highly active
    } else if (hours >= 2) {
      return Colors.orange; // Moderately active
    } else {
      return Colors.red; // Less active
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Weekly Activity",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final hours = activityData[index] ?? 0.0;
              return Column(
                children: [
                  Text(
                    "${hours.toStringAsFixed(1)}h",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  SizedBox(height: 6),
                  Container(
                    width: 20,
                    height: hours * 10, // Scale height based on hours
                    decoration: BoxDecoration(
                      color: getBarColor(hours),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    days[index],
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

