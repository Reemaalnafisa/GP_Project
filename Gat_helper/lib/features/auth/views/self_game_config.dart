import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gat_helper_app/features/auth/views/student.dart';
import '../../../core/services/SelfGame_Service.dart'; // Ensure service is correctly imported
import '../../../services/questions.dart'; // ✅ Import Question Service
import 'self_game_page.dart'; // ✅ Import Game Page

class SelfgameconfigWidget extends StatefulWidget {
  @override
  _SelfgameconfigWidgetState createState() => _SelfgameconfigWidgetState();
}

class _SelfgameconfigWidgetState extends State<SelfgameconfigWidget> {
  bool isVerbalSelected = false;
  bool isQuantitativeSelected = false;
  String? selectedQuestionType;
  bool isTimerEnabled = false; // ✅ خيار لتفعيل أو تعطيل التايمر
  int? selectedQuestionCount; // عدد الأسئلة

  final SelfGameService _selfGameService = SelfGameService(); // Game creation service

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned(
            top: -screenHeight * 0.10,
            left: -screenWidth * 0.8,
            right: -screenWidth * 0.8,
            child: Image.asset(
              'assets/img_12.png',
              fit: BoxFit.cover,
              width: screenWidth * 2.4,
              height: screenHeight * 0.40,
            ),
          ),

          // Back Button
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
                    builder: (context) => StudentHomePage(), // Navigate to ConfigPage
                  ),
                );
              },
            ),
          ),

          // Page Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Spacer(),
                SizedBox(height: screenHeight * 0.23),
                Center(
                  child: Text(
                    'Customize Your Game!',
                    style: TextStyle(
                      fontSize: screenWidth * 0.07,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),

                // Question Type Selection
                _buildQuestionTypeSelection(),

                // Question Count Selection
                _buildQuestionCountSelection(),

                // Timer Enable Option
                _buildTimerEnableOption(),

                SizedBox(height: screenHeight * 0.025),

                // Start Game Button
                _buildStartGameButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ **Builds Question Type Selection**
  Widget _buildQuestionTypeSelection() {
    return Column(
      children: [
        Center(
          child: Text(
            'Type of questions:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 10),
        CheckboxListTile(
          title: Text('Verbal', style: TextStyle(fontSize: 16, color: Colors.black)),
          value: isVerbalSelected,
          onChanged: (value) => setState(() => isVerbalSelected = value!),
        ),
        CheckboxListTile(
          title: Text('Quantitative', style: TextStyle(fontSize: 16, color: Colors.black)),
          value: isQuantitativeSelected,
          onChanged: (value) => setState(() => isQuantitativeSelected = value!),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  /// ✅ **Builds Question Count Selection**
  Widget _buildQuestionCountSelection() {
    return Column(
      children: [
        Center(
          child: Text(
            'Number of questions:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [10, 20, 30].map((num) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: GestureDetector(
                onTap: () => setState(() => selectedQuestionCount = num),
                child: Container(
                  decoration: BoxDecoration(
                    color: selectedQuestionCount == num ? Colors.blue : Colors.grey[300],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    '$num',
                    style: TextStyle(
                      color: selectedQuestionCount == num ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// ✅ **Builds Timer Enable Option**
  Widget _buildTimerEnableOption() {
    return SwitchListTile(
      title: Text(
        'Enable Timer',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
      ),
      value: isTimerEnabled,
      onChanged: (value) {
        setState(() {
          isTimerEnabled = value;
        });
      },
    );
  }

  /// ✅ **Builds Start Game Button**
  Widget _buildStartGameButton(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: EdgeInsets.only(right: 20, bottom: 50),
        child: ElevatedButton(
          onPressed: () async => await _startGame(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFFF176),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Let\'s Start',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              SizedBox(width: 10),
              Icon(Icons.arrow_forward, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ **Handles Game Start Logic**
  Future<void> _startGame(BuildContext context) async {
    // Validate selections
    if (!isVerbalSelected && !isQuantitativeSelected) {
      _showSnackBar("Please select at least one question type!");
      return;
    }
    if (selectedQuestionCount == null) {
      _showSnackBar("Please select the number of questions!");
      return;
    }

    // Define selected options
    String questionType = isVerbalSelected && isQuantitativeSelected
        ? 'Both'
        : isVerbalSelected
        ? 'Verbal'
        : 'Quantitative';

    // Fetch questions
    List<Map<String, dynamic>> questions = await QuestionService().fetchQuestions(
      questionType: questionType, limit: selectedQuestionCount!,
    );

    // Create game
    String gameId = await _selfGameService.createSelfGame(
      StuEmail: FirebaseAuth.instance.currentUser!.email!,
      questionType: questionType,
      gameDuration: isTimerEnabled ? selectedQuestionCount! : 0,
    );

    // Update Firestore
    await FirebaseFirestore.instance.collection('SelfGames').doc(gameId).update({
      'questions': questions,
      'status': 'started',
    });

    // Navigate to game page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelfGamePageWidget(
          gameId: gameId,
          selectedQuestionCount: selectedQuestionCount, // ✅ تمرير عدد الأسئلة
          questions: questions,
          isTimerEnabled: isTimerEnabled, selectedOptions :questionType,
        ),
      ),
    );
  }

  /// ✅ **Reusable method to show error messages**
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}