import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gat_helper_app/features/auth/views/tutor_home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SessionLinkPage extends StatefulWidget {
  final String requestId; // Add requestId to pass it later
  const SessionLinkPage({Key? key, required this.requestId}) : super(key: key);

  @override
  _SessionLinkPageState createState() => _SessionLinkPageState();
}

class _SessionLinkPageState extends State<SessionLinkPage> {
  TextEditingController _linkController = TextEditingController();
  TextEditingController _durationController = TextEditingController();
  String _requestStatus = "Pending";
  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Custom Rounded Header
          Stack(
            children: [
              Image.asset(
                "assets/img_17.png",
                fit: BoxFit.cover,
                width: double.infinity,
                height: 120,
              ),
              Positioned(
                top: 45,
                left: 125,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage("assets/img_1.png"), // Profile Image
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Sara Omar", // Tutor Name
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 40,
                left: 16,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 80),

          // Input fields for session link and duration
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _linkController,
                    decoration: InputDecoration(
                      hintText: "Enter session link...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Enter duration in minutes...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 40),

          // Send button
          ElevatedButton(
            onPressed: () async {
              final sessionLink = _linkController.text.trim();
              final sessionDuration = int.tryParse(_durationController.text) ?? 0;

              if (sessionLink.isEmpty || sessionDuration <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter valid link and duration')),
                );
                return;
              }

              // تحديث البيانات في Firestore
              final requestRef = FirebaseFirestore.instance.collection('helpRequests').doc(widget.requestId);
              final expirationTime = DateTime.now().add(Duration(minutes: sessionDuration));

              await requestRef.update({
                'sessionLink': sessionLink,
                'linkValidUntil': Timestamp.fromDate(expirationTime),
                'status': 'accepted', // تحديث الحالة
              });

              // الرجوع إلى صفحة التوتور هوم بيج
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => TutorHomepage()),
                    (route) => false,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Session link submitted successfully!')),
              );
            },
    child: Text(
    "Submit",
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue), // نص الزر

          ),
          ),
        ],
      ),
    );
  }
}