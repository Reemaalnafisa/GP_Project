import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gat_helper_app/features/auth/views/student.dart';
import 'package:gat_helper_app/features/common/start_page.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // ✅ Upload both JSON files dynamically
  //await uploadJsonToFirestore('assets/verbal_questions.json', 'verbal_questions');
  //await uploadJsonToFirestore('assets/Math_questions.json', 'Math_questions');

  runApp(MyApp());
}

// ✅ Generic function to upload any JSON file to Firestore
Future<void> uploadJsonToFirestore(String jsonFilePath, String collectionName) async {
  try {
    // Load JSON file
    String jsonString = await rootBundle.loadString(jsonFilePath);
    List<dynamic> jsonData = json.decode(jsonString);

    // Reference to Firestore collection
    CollectionReference collectionRef =
    FirebaseFirestore.instance.collection(collectionName);

    // Loop through JSON and add each document to Firestore
    for (var doc in jsonData) {
      await collectionRef.add(doc);
    }

    print("✅ JSON uploaded successfully to Firestore in collection: $collectionName");
  } catch (e) {
    print("❌ Error uploading JSON to $collectionName: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gat Helper',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: StartPage()
    );
  }
}
