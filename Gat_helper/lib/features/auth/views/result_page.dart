import 'package:flutter/material.dart';
import 'package:gat_helper_app/features/auth/views/student.dart';
import 'package:gat_helper_app/features/auth/views/student_req_page.dart';
import 'self_game_page.dart';
import 'correct_answers_page.dart';

class ResultsWidget extends StatelessWidget {
  final int correctAnswers;
  final int incorrectAnswers;
  final int skippedAnswers;
  final double completionPercentage;
  final String score;
  final List<Map<String, dynamic>> questions;
  final List<String?> userAnswers;
  final String? gameId; // ✅ أضف هذا
  final String selectedOptions;
  final int selectedQuestionCount; // ✅ أضف هذا
  final bool isTimerEnabled; // ✅ أضف هذا


  ResultsWidget({
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.skippedAnswers,
    required this.completionPercentage,
    required this.score,
    required this.questions,
    required this.userAnswers,
    required this.gameId, // ✅
    required this.selectedOptions, // ✅
    required this.selectedQuestionCount, // ✅
    required this.isTimerEnabled, // ✅
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(232, 241, 174, 1),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(100),
                    bottomRight: Radius.circular(100),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              left: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelfGamePageWidget(
                        gameId: gameId, // ✅ نفس معرف اللعبة
                        selectedOptions: selectedOptions, // ✅ نفس نوع الأسئلة
                        selectedQuestionCount: selectedQuestionCount, // ✅ نفس عدد الأسئلة
                        isTimerEnabled: isTimerEnabled, // ✅ نفس حالة التايمر
                        questions: questions, // ✅ نفس قائمة الأسئلة
                      ),
                    ),
                  );
                },
                child: Icon(
                  Icons.refresh,
                  size: 30,
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: 90,
              left: MediaQuery.of(context).size.width / 2 - 40,
              child: Image.asset(
                'assets/confetti.png',
                width: 80,
                height: 80,
              ),
            ),
            Positioned(
              top: 180,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Good Job!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color.fromRGBO(60, 96, 170, 1),
                    fontFamily: 'Irish Grover',
                    fontSize: 32,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 250,
              left: MediaQuery.of(context).size.width / 2 - 81,
              child: Container(
                width: 162,
                height: 162,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(97, 134, 204, 0.6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      score,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'DM Sans',
                        fontSize: 32,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your Score',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'DM Sans',
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 440,
              left: 30,
              right: 30,
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(60, 96, 170, 1),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildResultsRow('CORRECT ANSWERS', correctAnswers.toString()),
                    _buildResultsRow('COMPLETION', '${completionPercentage.toStringAsFixed(1)}%'),
                    _buildResultsRow('INCORRECT ANSWERS', incorrectAnswers.toString()),
                    _buildResultsRow('SKIPPED', skippedAnswers.toString()),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CorrectAnswersPage(
                              questions: questions,
                              userAnswers: userAnswers,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(232, 241, 174, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      ),
                      child: Text(
                        'Check Correct Answers',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Rowdies',
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 30,
              right: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Studentreq(questions: questions),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Icon(Icons.help, size: 24, color: Colors.black),
                        SizedBox(height: 5),
                        Text(
                          'Ask a Tutor',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Inter',
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => StudentHomePage()),
                      );
                    },
                    child: Text('Done'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Color.fromRGBO(179, 179, 179, 1),
              fontFamily: 'Rowdies',
              fontSize: 12,
              height: 1.6,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Passion One',
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
