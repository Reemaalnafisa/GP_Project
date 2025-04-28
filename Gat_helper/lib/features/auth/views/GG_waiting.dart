import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:gat_helper_app/features/auth/views/Group_GameQ.dart';
import 'package:gat_helper_app/features/auth/views/find_game_page.dart';
import 'package:gat_helper_app/features/auth/views/student.dart';
import '../../../core/services/GroupGameSetting_service.dart';
import '../../../services/questions.dart';

class LeaderWidget extends StatefulWidget {
  final String gameId;
  LeaderWidget({required this.gameId});

  @override
  _LeaderWidgetState createState() => _LeaderWidgetState();
}
class _LeaderWidgetState extends State<LeaderWidget> {
  String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
  Timer? timer;
  late int numberOfQuestions;
  late int gameDuration;
  late int numberOfParticipants;
  late int maxParticipants;
  late String questionType;
  List<Map<String, dynamic>>? cachedQuestions;
  late StreamSubscription<DocumentSnapshot> _gameSubscription;


  @override
  void initState() {
    super.initState();
    _startListening();

  }
  void _startListening() {
    _gameSubscription = FirebaseFirestore.instance
        .collection('GroupGames')
        .doc(widget.gameId)
        .snapshots()
        .listen((snapshot) async {
      if (!snapshot.exists) return;
      var gameData = snapshot.data() as Map<String, dynamic>;
      checkAndStartGame(gameData);
    });
  }





  @override
  void dispose() {
    _gameSubscription.cancel();
    super.dispose();
  }




  /* void showTimeOutPopup() async {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFC5DDF2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
          ),
          content: Container(
            height: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "Time's Up!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (!mounted) return;
                        _gameSubscription.cancel();
                        await FirebaseService().updateGameStatus(widget.gameId, 'Cancel');
                        await FirebaseService().stopRemainingTime(widget.gameId);
                        if (!mounted) return;

                        Navigator.pop(context); // Close dialog

                        // الانتقال إلى الصفحة الرئيسية بعد إتمام العمليات
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudentHomePage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400], // زر أحمر
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Confirm',
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
  }*/



  void showTimeOutPopup() async {
    if (!mounted) return;

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
                  "Time's Up!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (!mounted) return;
                    _gameSubscription.cancel();
                    await FirebaseService().updateGameStatus(widget.gameId, 'Cancel');
                    await FirebaseService().stopRemainingTime(widget.gameId);
                    if (!mounted) return;

                    Navigator.pop(context); // Close dialog

                    // الانتقال إلى الصفحة الرئيسية بعد إتمام العمليات
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentHomePage(),
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
                    'OK',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }







  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(color: Colors.white), // خلفية لحالها


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


          Positioned(
            top: 100,
            left: screenWidth / 2.5,
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('GroupGames')
                  .doc(widget.gameId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                var gameData = snapshot.data!.data() as Map<String, dynamic>;
                int remainingTime = gameData['remaining_time'] ?? 1;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: remainingTime / 600, // التقدم بناءً على الوقت المتبقي
                        strokeWidth: 5,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                      ),
                    ),
                    Text(
                      '${(remainingTime ~/ 60)}:${(remainingTime % 60).toString().padLeft(2, '0')}',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    ),
                  ],
                );
              },
            ),
          ),

          // 📦 صندوق المعلومات الرئيسي
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('GroupGames')
                      .doc(widget.gameId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }

                    var gameData = snapshot.data!.data() as Map<String, dynamic>;
                    int numberOfQuestions = gameData['number_of_questions'] ?? 0;
                    String questionType = gameData['question_type'] ?? 'unknown';
                    int gameDuration = gameData['game_duration'] ?? 0;
                    List<dynamic> players = gameData['players'] ?? [];
                    int numberOfParticipants = gameData['current_participants'] ?? 0;
                    int maxParticipants = gameData['max_participants'] ?? 0;

                    return Container(
                      width: screenWidth * 0.9,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 0.8,
                          colors: [Color(0xC5DDF2FF), Color(0xFF698AC8)],
                          stops: [0.1, 0.7],
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Waiting...',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          SizedBox(height: 10),
                          _buildInfoRow('Type of Questions:', questionType),
                          _buildInfoRow('Number of Questions:', numberOfQuestions.toString()),
                          _buildInfoRow('Timer of Game:', '$gameDuration min'),
                          _buildInfoRow('Number of Participants:', '$numberOfParticipants/$maxParticipants'),
                          SizedBox(height: 10),
                          Text('Join code:', style: TextStyle(fontSize: 18, color: Colors.white)),
                          Text(
                            ' ${widget.gameId}',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.yellow),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // 🌊 الخلفية السفلية
          Positioned(
            bottom: screenHeight * 0,
            left: -screenWidth * 0.1,
            right: -screenWidth * 0.1,
            child: Image.asset(
              fit: BoxFit.cover,
              'assets/downgreen_background.png',
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
          // 🎨 الصورة تحت زر Start Game
          Positioned(
            bottom: -44,
            left: -screenWidth * 0.1,
            right: -screenWidth * 0.1,
            child: Image.asset(
              'assets/Mathremovebgpreview.png',
              fit: BoxFit.cover,
              width: screenWidth * 1.2,
              height: screenHeight * 0.18, // تقدرين تكبرينها أو تصغرينها حسب الشكل
            ),
          ),



          // زر Start Game
          Positioned(
            bottom: screenHeight * 0.20,
            left: screenWidth / 2 - 75,
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('GroupGames')
                  .doc(widget.gameId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // أو أي عنصر انتظار آخر
                }

                if (snapshot.hasError) {
                  _showSnackBar("Error fetching game data.");
                  return SizedBox.shrink(); // Return a widget to avoid null return
                }

                if (snapshot.hasData && snapshot.data!.exists) {
                  var gameData = snapshot.data!.data() as Map<String, dynamic>;
                  String leaderId = gameData['admin_email'];
                  String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
                  if (leaderId == currentUserEmail) {
                    return ElevatedButton(
                      onPressed: () async {
                        if (gameData['current_participants']  < 1) {
                          _showSnackBar("Not enough players to start the game.");
                          return;
                        }
                        else{
                          await FirebaseFirestore.instance
                              .collection('GroupGames')
                              .doc(widget.gameId)
                              .update({
                            'status': 'started',
                          });

                          await checkAndStartGame(gameData);
                        }


                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE8F1AE),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Start Game',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                      ),

                    );

                  } else {
                    return SizedBox.shrink(); // لا يظهر الزر إذا لم يكن المستخدم هو القائد
                  }
                } else {
                  _showSnackBar("Game data not found.");
                  return SizedBox.shrink(); // Ensure something is returned
                }
              },
            ),
          ),


        ],
      ),
    );
  }

  // تصميم صفوف المعلومات
  Widget _buildInfoRow(String title, String value) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
          Text(value, style: TextStyle(fontSize: 16, color: Colors.black)),
        ],
      ),
    );
  }
  void showExitConfirmationDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // تغيير الزوايا
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
                        Navigator.pop(context); // Close dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(232, 241, 174, 1), // اللون الأخضر
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (!mounted) return;

                        await FirebaseService().leaveGame(widget.gameId, currentUserEmail);

                        if (!mounted) return;

                        Navigator.pop(context); // Close dialog
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupGamePage2(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400], // زر أحمر
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Confirm',
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



  Future<void> checkAndStartGame(Map<String, dynamic> gameData) async {
    if (!mounted) return;
    String gameStatus = gameData['status'] ;


    if (gameData['remaining_time'] == 0  && gameStatus == 'waiting' ) {
      if (gameData['current_participants'] < 2 ) {
        showTimeOutPopup();
        _gameSubscription.cancel();
      } else  {
        await FirebaseFirestore.instance
            .collection('GroupGames')
            .doc(widget.gameId)
            .update({
          'status': 'started',
        });
      }
    }


    if (gameData['current_participants'] == gameData['max_participants'] && gameStatus == 'waiting') {
      await FirebaseFirestore.instance.collection('GroupGames').doc(widget.gameId).update({
        'status': 'started',
      });
    }

    if (gameStatus == 'started') {
      if (cachedQuestions == null || cachedQuestions!.isEmpty) {
        List<dynamic> questions = gameData['questions'] ?? [];

        if (questions.isEmpty) {
          String questionType = gameData['question_type'] ;
          int numberOfQuestions = gameData['number_of_questions'] ;

          questions = await QuestionService().fetchQuestions(
            questionType: questionType,
            limit: numberOfQuestions,
          );

          if (questions.isNotEmpty) {
            await FirebaseFirestore.instance.collection('GroupGames').doc(widget.gameId).update({
              'questions': questions,
            });
          } else {
            if (!mounted) return;
            _showSnackBar("No questions available.");
            return;
          }
        }

        cachedQuestions = List<Map<String, dynamic>>.from(questions);
      }
      if (!mounted) return;
      timer?.cancel();
      _gameSubscription.cancel();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GroupGamePageWidget(
            gameId: widget.gameId,
            questions: cachedQuestions!,
          ),
        ),
      );
    }
  }


  _showSnackBar(String message) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}