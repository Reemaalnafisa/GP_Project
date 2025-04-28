import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gat_helper_app/features/auth/views/student.dart';
import 'self_game_config.dart';
import 'result_page.dart';
import 'dart:async';

class SelfGamePageWidget extends StatefulWidget {
  final String selectedOptions;
  final int? selectedQuestionCount;
  final String? gameId;
  final List<Map<String, dynamic>> questions;
  bool isTimerEnabled;

  SelfGamePageWidget({
    required this.gameId,
    required this.selectedOptions,
    required this.selectedQuestionCount, // ✅ أضف هذا
    required this.questions,
    this.isTimerEnabled = false,
  });

  @override
  _SelfGamePageWidgetState createState() => _SelfGamePageWidgetState();
}

class _SelfGamePageWidgetState extends State<SelfGamePageWidget> {

  Timer? _timer;

  String? selectedAnswer;
  int currentQuestionIndex = 0;
  List<String?> userAnswers = [];
  int? minutes;
  int seconds = 0;

  @override
  void initState() {
    super.initState();
    userAnswers = List<String?>.filled(widget.questions.length, null);
    if (widget.selectedQuestionCount != null && widget.selectedQuestionCount! > 0) {
      minutes = widget.selectedQuestionCount;
      startTimer();
    }
  }

  void showExitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          content: Container(
            height: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Confirm Quit?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Stop the timer
                        _timer?.cancel();

                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelfgameconfigWidget(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(232, 241, 174, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Confirm',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Close the dialog
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // لون مميز لزر الإلغاء
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted && minutes != null) {
        setState(() {
          if (seconds > 0) {
            seconds--;
          } else if (minutes! > 0) {
            minutes = minutes! - 1;
            seconds = 59;
          }

          if (minutes == 0 && seconds == 0) {
            timer.cancel();
            navigateToResultsPage();
          }
        });
      }
    });
  }

  void navigateToResultsPage() {

    _timer?.cancel(); // Cancel the timer

    int correctAnswers = 0;
    int skippedAnswers = 0;
    int verbalCorrect = 0;
    int quantitativeCorrect = 0;


    for (int i = 0; i < widget.questions.length; i++) {
      if (userAnswers[i] == null) {
        skippedAnswers++;
      } else if (userAnswers[i] == widget.questions[i]['correct_answer']) {
        correctAnswers++;
        if (widget.questions[i]['type'] == 'Verbal') {
          verbalCorrect++;
        } else if (widget.questions[i]['type'] == 'Quantitative') {
          quantitativeCorrect++;
        }
      }
    }
    int incorrectAnswers = widget.questions.length - correctAnswers - skippedAnswers;
    double completionPercentage = ((widget.questions.length - skippedAnswers) / widget.questions.length) * 100;
    String score = (correctAnswers * 10).toString();

    FirebaseFirestore.instance.collection('SelfGames')
        .doc(widget.gameId)
        .update({
      'score': score,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
      'skippedAnswers': skippedAnswers,
      'timestamp': Timestamp.now(),
      'verbalCorrect': verbalCorrect,
      'quantitativeCorrect': quantitativeCorrect,
      'completionPercentage': completionPercentage,
      'numberOfQuestions': widget.questions.length,
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsWidget(
          correctAnswers: correctAnswers,
          incorrectAnswers: incorrectAnswers,
          skippedAnswers: skippedAnswers,
          completionPercentage: completionPercentage,
          score: score,
          questions: widget.questions,
          userAnswers: userAnswers,
          gameId: widget.gameId, // ✅ تمرير معرف اللعبة
          selectedOptions: widget.selectedOptions, // ✅ تمرير نوع الأسئلة
          selectedQuestionCount: widget.selectedQuestionCount ?? 0, // ✅ تمرير عدد الأسئلة
          isTimerEnabled: widget.isTimerEnabled, // ✅ تمرير حالة التايمر
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    // حساب النسبة المئوية للوقت المتبقي
    final totalSeconds = (widget.selectedQuestionCount ?? 0) * 60; // الوقت الإجمالي بالثواني
    final remainingSeconds = (minutes ?? 0) * 60 + seconds; // الوقت المتبقي بالثواني
    final progress = remainingSeconds / totalSeconds; // النسبة المئوية للوقت المتبقي
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final currentQuestion = widget.questions[currentQuestionIndex];
    // تحديد لون شريط التقدم بناءً على الوقت المتبقي
    Color progressColor = progress > 0.5 ? Colors.green : Colors.red;
    List<String> options = List<String>.from(currentQuestion["wrong_answers"]);
    if (!options.contains(currentQuestion["correct_answer"])) {
      options.add(currentQuestion["correct_answer"]);
    }

    return Scaffold(
      body: Stack(
        children: [
          // خلفيات
          Positioned(
            bottom: screenHeight * 0.01,
            left: -screenWidth * 0.1,
            right: -screenWidth * 0.1,
            child: Image.asset(
              'assets/yellow_background.png',
              fit: BoxFit.cover,
              width: screenWidth * 1.2,
              height: screenHeight * 0.4,
            ),
          ),

          // شريط التقدم (الخط العلوي)
          if (widget.isTimerEnabled == true )
          // التايمر كنص في أعلى الشاشة
            Positioned(
              top: MediaQuery.of(context).size.height * 0.05,
              right: MediaQuery.of(context).size.width * 0.05,
              child: Text(
                "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: progressColor, // لون النص بناءً على الوقت المتبقي
                ),
              ),
            ),


          Positioned(
            bottom: 0,
            left: -screenWidth * 0.1,
            right: -screenWidth * 0.1,
            child: Image.asset(
              'assets/downblue_background.png',
              fit: BoxFit.cover,
              width: screenWidth * 1.2,
              height: screenHeight * 0.35,
            ),
          ),
          Positioned(
            bottom: -screenHeight * 0.12,
            left: -screenWidth * 0.1,
            right: -screenWidth * 0.1,
            child: Image.asset(
              'assets/Math.png',
              fit: BoxFit.cover,
              width: screenWidth * 1.2,
              height: screenHeight * 0.3,
            ),
          ),

          // زر الخروج
          Positioned(
            top: screenHeight * 0.05,
            left: screenWidth * 0.05,
            child: GestureDetector(
              onTap: showExitConfirmationDialog,
              child: Image.asset(
                'assets/exit_logo.png',
                width: screenWidth * 0.1,
                height: screenWidth * 0.1,
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.1),

                // السؤال داخل بطاقة
                Stack(
                  clipBehavior: Clip.none,
                  children: [

                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: screenHeight * 0.05, // قللنا المسافة عشان ما يصير فراغ كبير
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFF0EFFF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // ✨ هذا السطر هو المفتاح
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (currentQuestion.containsKey('image') && currentQuestion['image'] != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: screenWidth * 0.5,
                                  maxHeight: 200,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Image.network(
                                    currentQuestion['image'],
                                    errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                                  ),
                                ),
                              ),
                            ),
                          Text(
                            currentQuestion['question'],
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (currentQuestion['subtype'] == 'passage' && currentQuestion.containsKey('passage'))
                            TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    content: SingleChildScrollView(
                                      child: Text(
                                        currentQuestion['passage'] ?? '',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Close'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Text('View Passage'),
                            ),


                        ],
                      ),
                    ),
                    Positioned(
                      top: -screenWidth * 0.075,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: screenWidth * 0.15,
                          height: screenWidth * 0.15,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blueAccent, width: 4),
                          ),
                          child: Center(
                            child: Text(
                              '${currentQuestionIndex + 1}',
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.05,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),


                SizedBox(height: screenHeight * 0.03),

                // خيارات الإجابة
                ...List.generate(options.length, (index) {
                  final option = options[index];
                  final optionLetter = String.fromCharCode(97 + index);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        userAnswers[currentQuestionIndex] = option;
                        selectedAnswer = option;
                      });
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05,
                            vertical: screenHeight * 0.015,
                          ),
                          decoration: BoxDecoration(
                            color: selectedAnswer == option ? Colors.blue[400] : Colors.blue[100],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                color: selectedAnswer == option ? Colors.white : Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Positioned(
                          top: -screenWidth * 0.03,
                          left: -screenWidth * 0.03,
                          child: Container(
                            width: screenWidth * 0.1,
                            height: screenWidth * 0.1,
                            decoration: BoxDecoration(
                              color: Colors.yellow[600],
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                optionLetter,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth * 0.045,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                SizedBox(height: screenHeight * 0.03),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: screenHeight * 0.1,
                    left: screenWidth * 0.05,
                    right: screenWidth * 0.05,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: currentQuestionIndex > 0
                            ? () {
                          setState(() {
                            currentQuestionIndex--;
                            selectedAnswer = userAnswers[currentQuestionIndex];
                          });
                        }
                            : null,
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_back,
                              color: currentQuestionIndex > 0 ? Colors.black : Colors.grey,
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Text(
                              'Previous',
                              style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.bold,
                                color: currentQuestionIndex > 0 ? Colors.black : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: currentQuestionIndex < widget.questions.length - 1
                            ? () {
                          setState(() {
                            currentQuestionIndex++;
                            selectedAnswer = userAnswers[currentQuestionIndex];
                          });
                        }
                            : () {
                          navigateToResultsPage();
                        },
                        child: Row(
                          children: [
                            Text(
                              currentQuestionIndex < widget.questions.length - 1 ? 'Next' : 'Finish',
                              style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}