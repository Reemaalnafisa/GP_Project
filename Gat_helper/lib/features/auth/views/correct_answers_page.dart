import 'package:flutter/material.dart';

class CorrectAnswersPage extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final List<String?> userAnswers;

  CorrectAnswersPage({required this.questions, required this.userAnswers});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // الخلفية
          Positioned(
            top: -screenHeight * 0.15,
            left: -screenWidth * 0.8,
            right: -screenWidth * 0.8,
            child: Image.asset(
              'assets/img_12.png',
              fit: BoxFit.cover,
              width: screenWidth * 2.4,
              height: screenHeight * 0.40,
            ),
          ),

          // السهم للرجوع
          Positioned(
            top: screenHeight * 0.05, // Adjust top to place the arrow at the top
            left: screenWidth * 0.05, // Adjust left to place the arrow on the left
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black, size: 30),
              onPressed: () {
                Navigator.pop(context); // العودة إلى الصفحة السابقة
              },
            ),
          ),

          // النص العلوي
          Positioned(
            top: screenHeight * 0.10, // Adjust this value to move text lower or higher
            left: screenWidth * 0.1,  // Adjust left alignment
            right: screenWidth * 0.1, // Adjust right alignment if needed
            child: Center(
              child: Text(
                'Check Correct answers',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 1),
                  fontFamily: 'Istok Web',
                  fontSize: 24,
                  letterSpacing: 0,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                ),
              ),
            ),
          ),

          // محتوى الـ ListView
          Positioned(
            top: screenHeight * 0.20, // يبدأ المحتوى بعد الصورة والنص العلوي
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  final userAnswer = userAnswers[index];
                  final correctAnswer = question['correct_answer'];
                  final isCorrect = userAnswer == correctAnswer;

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              color: isCorrect ? Colors.green : Colors.red,
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Expanded(
                              child: Text(
                                question['question'],
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          'Chosen Answer: ${userAnswer ?? "No Answer"}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: isCorrect ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Correct Answer: $correctAnswer',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
