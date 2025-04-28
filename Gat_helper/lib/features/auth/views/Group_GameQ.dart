import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gat_helper_app/features/auth/views/QQ_Rank.dart';
import 'package:gat_helper_app/core/services/GroupGameSetting_service.dart';
import 'custom_group_game_page.dart';

class GroupGamePageWidget extends StatefulWidget {
  final String gameId;
  final List<Map<String, dynamic>> questions;

  GroupGamePageWidget({required this.gameId, required this.questions});

  @override
  _GroupGamePageWidgetState createState() => _GroupGamePageWidgetState();
}

class _GroupGamePageWidgetState extends State<GroupGamePageWidget> {
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  List<String?> userAnswers = [];
  int? minutes;
  int seconds = 0;
  Timer? _timer;
  int gameTimeRemainingInSeconds = 0;
  String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
  int gameDuration1 = 0;




  @override
  void initState() {
    super.initState();
    userAnswers = List<String?>.filled(widget.questions.length, null);
    _getGameDurationFromFirebase();

  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (gameTimeRemainingInSeconds > 0) {
        setState(() {
          gameTimeRemainingInSeconds--;
          minutes = gameTimeRemainingInSeconds ~/ 60;
          seconds = gameTimeRemainingInSeconds % 60;
        });

        await FirebaseFirestore.instance.collection('GroupGames').doc(widget.gameId).update({
          'gameTimeRemaining': gameTimeRemainingInSeconds,
        });
      }

      if (gameTimeRemainingInSeconds == 0) {
        var gameDoc = await FirebaseFirestore.instance.collection('GroupGames').doc(widget.gameId).get();
        var gameStatus = gameDoc['status'];
        if (gameStatus == 'started') {
          _timer?.cancel();
          navigateToResultsPage();
          FirebaseService().updateGameStatus(widget.gameId, 'finished');
        }
      }
    });
  }

  Future<void> _getGameDurationFromFirebase() async {
    var gameData = await FirebaseFirestore.instance.collection('GroupGames').doc(widget.gameId).get();
    int gameTimeRemaining = gameData['gameTimeRemaining']; // احصل على الوقت المتبقي

    setState(() {
      gameTimeRemainingInSeconds = gameTimeRemaining;
      minutes = gameTimeRemainingInSeconds ~/ 60;
      seconds = gameTimeRemainingInSeconds % 60;
    });

    startTimer(); // بدء المؤقت بعد الحصول على الوقت
  }

  void navigateToResultsPage() {
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
    int score = (correctAnswers * 10);

    FirebaseFirestore.instance
        .collection('GroupGames')
        .doc(widget.gameId)
        .collection('Players')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .update({
      'score': score,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
      'skippedAnswers': skippedAnswers,
      'timestamp': Timestamp.now(),
      'verbalCorrect': verbalCorrect,
      'quantitativeCorrect': quantitativeCorrect,
      'completionPercentage': completionPercentage,
      'status': 'completed',
      'end_time': FieldValue.serverTimestamp(),
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RankPage(
          gameId: widget.gameId,
          correctAnswers: correctAnswers,
          incorrectAnswers: incorrectAnswers,
          skippedAnswers: skippedAnswers,
          questions: widget.questions,
          userAnswers: userAnswers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final currentQuestion = widget.questions[currentQuestionIndex];
    Color progressColor = gameTimeRemainingInSeconds > 0.5 * gameDuration1
        ? Colors.green
        : Colors.red;
    List<String> options = List<String>.from(currentQuestion["wrong_answers"]);
    if (!options.contains(currentQuestion["correct_answer"])) {
      options.add(currentQuestion["correct_answer"]);
    }

    return Scaffold(
      body: Stack(
        children: [
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
          Positioned(
            top: screenHeight * 0.05,
            right: screenWidth * 0.05,
            child: Text(
              '$minutes:${seconds.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: progressColor, // لون النص بناءً على الوقت المتبقي
              ),
            ),
          ),

          Positioned(
            top: screenHeight * 0.05,
            left: screenWidth * 0.05,
            child: GestureDetector(
              onTap: () {
                _showExitDialog(context);  // استدعاء المربع حوار
              },
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

  /*void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure?', style: TextStyle(fontSize: 18)),
          actions: [
            // زر No
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('No', style: TextStyle(fontSize: 16, color: Colors.black)),
            ),
            // زر Yes
            TextButton(
              onPressed: () async {
                await FirebaseService().leaveGame(widget.gameId, currentUserEmail);
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => StudentHomePage()),
                );
              },
              child: Text('Yes', style: TextStyle(fontSize: 16, color: Colors.black)),
            ),

          ],
        );
      },
    );
  }*/
  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
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
                            builder: (context) => CustomizeGamePage(),
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
          ),        );
      },
    );
  }




}