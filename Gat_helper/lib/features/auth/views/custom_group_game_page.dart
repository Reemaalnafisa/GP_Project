import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gat_helper_app/features/auth/views/find_game_page.dart';
import 'package:gat_helper_app/features/auth/views/student.dart';
import '../../../core/services/GroupGameSetting_service.dart';
import '../../../services/questions.dart';
import 'package:gat_helper_app/features/auth/views/GG_waiting.dart';

class CustomizeGamePage extends StatefulWidget {
  @override
  _CustomizeGamePageState createState() => _CustomizeGamePageState();
}

class _CustomizeGamePageState extends State<CustomizeGamePage> {
  String? selectedQuestionType;
  int? selectedQuestionNumber;
  int? selectedTimer;
  int maxParticipants = 2;
  int currentParticipants = 1;
  bool isVerbalSelected = false;
  bool isQuantitativeSelected = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -10,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/img_3.png',
              width: double.infinity,
              height: 190,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black, size: 30),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupGamePage2(), // Navigate to ConfigPage
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 160,
            left: 20,
            child: Text(
              "Customize Your GROUP GAME!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Positioned.fill(
            top: 210,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildQuestionTypeCard(),
                      _buildOptionCard(
                        "Number of questions?",
                        [5, 10, 15, 20]
                            .map((num) => _buildRadioOption(num, selectedQuestionNumber, (value) {
                          setState(() {
                            selectedQuestionNumber = value;
                          });
                        })).toList(),
                      ),
                      _buildOptionCard(
                        "Timer of Game?",
                        [10, 15, 20, 30]
                            .map((num) => _buildRadioOption(num, selectedTimer, (value) {
                          setState(() {
                            selectedTimer = value;
                          });
                        })).toList(),
                      ),
                      _buildParticipantsDropdown(),
                      SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFE8F1AE),
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          _createGame();
                        },
                        child: Text(
                          "CREATE",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createGame() async {
    if (!isVerbalSelected && !isQuantitativeSelected) {
      _showSnackBar("Please select a question type!");
      return;
    }
    if (selectedQuestionNumber == null) {
      _showSnackBar("Please select the number of questions!");
      return;
    }
    if (selectedTimer == null) {
      _showSnackBar("Please select a timer!");
      return;
    }

    String questionType = isVerbalSelected && isQuantitativeSelected
        ? 'Both'
        : isVerbalSelected
        ? 'Verbal'
        : 'Quantitative';

    try {
      // تحقق من تسجيل الدخول
      if (FirebaseAuth.instance.currentUser == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      String gameId = await FirebaseService().createGame(
        adminEmail: FirebaseAuth.instance.currentUser!.email!,
        questionType: questionType!,
        numberOfQuestions: selectedQuestionNumber!,
        gameDuration: selectedTimer!,
        maxParticipants: maxParticipants,

      );

      if (gameId.isNotEmpty) {
        FirebaseService().startWaitingTimer(gameId);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LeaderWidget(
              gameId: gameId,
            ),
          ),
        );
      } else {
        _showSnackBar("Failed to create game, please try again.");
      }
    } catch (e) {
      _showSnackBar("Error creating game: ${e.toString()}");
    }
  }



  /// ✅ **Reusable method to show error messages**
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// ✅ **Dropdown for selecting participants**
  Widget _buildParticipantsDropdown() {
    return Card(
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select number of participants:", style: TextStyle(fontSize: 14, color: Colors.black)),
            SizedBox(height: 10),
            DropdownButtonFormField<int>(
              value: maxParticipants,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
              items: List.generate(
                9,
                    (index) => DropdownMenuItem<int>(
                  value: index + 2,
                  child: Text((index + 2).toString()),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  maxParticipants = value ?? 2;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ **Widget to build option selection cards**
  Widget _buildOptionCard(String title, List<Widget> options) {
    return Card(
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 14, color: Colors.black)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: options,
            ),
          ],
        ),
      ),
    );
  }


  /// ✅ **Fix Missing Method**
  Widget _buildRadioOption(int value, int? groupValue, Function(int?) onChanged) {
    return Row(
      children: [
        Radio<int>(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
        ),
        Text(value.toString(), style: TextStyle(color: Colors.black)),
      ],
    );
  }

  /// ✅ **Fix Missing `_buildQuestionTypeCard` Method**
  Widget _buildQuestionTypeCard() {
    return Card(
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select Question Type?", style: TextStyle(fontSize: 14, color: Colors.black)),
            SizedBox(height: 10),
            CheckboxListTile(
              title: Text("Verbal"),
              value: isVerbalSelected,
              onChanged: (value) => setState(() => isVerbalSelected = value!),
            ),
            CheckboxListTile(
              title: Text("Quantitative"),
              value: isQuantitativeSelected,
              onChanged: (value) => setState(() => isQuantitativeSelected = value!),
            ),
          ],
        ),
      ),
    );
  }
}
