import 'package:flutter/material.dart';
import 'dart:async';

class GroupGameques extends StatefulWidget {
  @override
  _GroupGamePageState createState() => _GroupGamePageState();
}

class _GroupGamePageState extends State<GroupGameques> {
  int currentQuestionIndex = 1;
  String? selectedAnswer;
  int remainingTime = 60;
  Timer? timer;

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'The Pin number of a phone is formed from four numbers from (0 to 9). How many ways can it be formed?',
      'options': ['10000', '6500', '5040', '4000'],
      'correctAnswer': '10000',
    },
    {
      'question': 'What is the value of π (pi) approximately?',
      'options': ['3.14', '2.71', '1.62', '3.00'],
      'correctAnswer': '3.14',
    },
  ];

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        setState(() {
          remainingTime--;
        });
      } else {
        timer.cancel();
        // Handle time-up scenario
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final currentQuestion = questions[currentQuestionIndex - 1];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.06),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back, color: Colors.red, size: 30),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        value: remainingTime / 60,
                        strokeWidth: 5,
                        backgroundColor: Colors.orangeAccent,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                      ),
                    ),
                    Text(
                      '$remainingTime s',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    child: Text(
                      '$currentQuestionIndex',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      currentQuestion['question'],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Column(
              children: List.generate(currentQuestion['options'].length, (index) {
                final option = currentQuestion['options'][index];
                final optionLetter = String.fromCharCode(97 + index);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedAnswer = option;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: selectedAnswer == option ? Colors.blue : Colors.blue.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.amber,
                              radius: 15,
                              child: Text(
                                optionLetter,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              option,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Radio(
                          value: option,
                          groupValue: selectedAnswer,
                          onChanged: (value) {
                            setState(() {
                              selectedAnswer = value as String?;
                            });
                          },
                          activeColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: currentQuestionIndex > 1
                        ? () {
                      setState(() {
                        currentQuestionIndex--;
                        selectedAnswer = null;
                      });
                    }
                        : null,
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back, color: currentQuestionIndex > 1 ? Colors.black : Colors.grey),
                        Text(
                          'Previous',
                          style: TextStyle(
                            fontSize: 16,
                            color: currentQuestionIndex > 1 ? Colors.black : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: currentQuestionIndex < questions.length
                        ? () {
                      setState(() {
                        currentQuestionIndex++;
                        selectedAnswer = null;
                      });
                    }
                        : () {
                      // Navigate to results page
                    },
                    child: Row(
                      children: [
                        Text(
                          currentQuestionIndex < questions.length ? 'Next' : 'Finish',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        Icon(Icons.arrow_forward, color: Colors.black),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
