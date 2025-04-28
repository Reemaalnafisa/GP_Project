import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../../../core/services/GroupGameSetting_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../model/user_model.dart';
import 'GG_waiting.dart';
import 'correct_answers_page.dart';
import 'student.dart';
import 'student_req_page.dart';

class RankPage extends StatefulWidget {
  final String gameId;
  final int correctAnswers;
  final int incorrectAnswers;
  final int skippedAnswers;
  final List<Map<String, dynamic>> questions;
  final List<String?> userAnswers;

  RankPage({
    required this.gameId,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.skippedAnswers,
    required this.questions,
    required this.userAnswers,
  });

  @override
  _RankPageState createState() => _RankPageState();
}

class _RankPageState extends State<RankPage> {
  late ConfettiController _confettiController;
  UserModel? user;
  List<Map<String, dynamic>> contestants = [];
  bool isGameFinished = false;
  int totalPlayers = 0;
  String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 3))..play();
    _fetchUserData();
    FirebaseService.playerFinishedGame(widget.gameId);
    _listenToGameUpdates();
  }

  void _fetchUserData() async {
    var val = await AuthService().getUserDetails();
    setState(() => user = val);
  }
  void _listenToGameUpdates() {
    FirebaseFirestore.instance
        .collection('GroupGames')
        .doc(widget.gameId)
        .snapshots()
        .listen((snapshot) async {
      if (!snapshot.exists) return;
      var gameData = snapshot.data() as Map<String, dynamic>;

      bool finished = (gameData['status'] == 'finished');

      if (!mounted) return; // ✨ اضف هذي قبل أي setState

      setState(() {
        isGameFinished = finished;
        totalPlayers = gameData['current_participants'] ?? 0;
      });

      if (finished) {
        List<Map<String, dynamic>> rankings = await _loadRankings();
        if (!mounted) return; // ✨ وكمان هنا قبل ثاني setState
        setState(() {
          contestants = rankings;
        });
      }
    });
  }

  Future<List<Map<String, dynamic>>> _loadRankings() async {
    try {
      var gameDoc = await FirebaseFirestore.instance.collection('GroupGames').doc(widget.gameId).get();
      var players = gameDoc.data()?['players'] ?? [];
      List<Map<String, dynamic>> list = [];

      for (var email in players) {
        var playerDoc = await FirebaseFirestore.instance
            .collection('GroupGames')
            .doc(widget.gameId)
            .collection('Players')
            .doc(email)
            .get();

        var userDoc = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).get();
        if (playerDoc.exists) {
          list.add({
            'email': email,
            'rank': playerDoc.data()?['rank'] ?? 0,
            'score': playerDoc.data()?['score'] ?? 0,
            'name': playerDoc.data()?['name'] ?? 'No name',
            'avatar': userDoc.docs.first.data()?['avatar'] ?? 'assets/avatar_1.png',
          });
        }
      }
      return list;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF3C60AA),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          if (isGameFinished)
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi,
              emissionFrequency: 0.4,
              numberOfParticles: 30,
              blastDirectionality: BlastDirectionality.explosive,
              gravity: 0.1,
              colors: [
                Colors.blueAccent, Colors.pinkAccent, Colors.orangeAccent, Colors.purpleAccent
              ],
            ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              _buildCongratsAndScore(),
              Positioned(
                  top: 350,
                  left: 0,
                  right: 0,
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // podium المركز الثاني
                      Column(
                        children: [
                          if (isGameFinished && contestants.length >= 2)
                            _buildRankInfo(
                              contestants[1]['name'],
                              contestants[1]['score'],
                              contestants[1]['avatar'],
                              2,
                            ),
                          _buildRankColumn(2, 'assets/rank2.png'),
                        ],
                      ),


                      // podium المركز الأول
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isGameFinished && contestants.isNotEmpty)
                            _buildRankInfo(
                              contestants[0]['name'],
                              contestants[0]['score'],
                              contestants[0]['avatar'],
                              1,
                            ),
                          SizedBox(height: 8),
                          _buildRankColumn(1, 'assets/rank1.png'),
                        ],
                      ),


                      // podium المركز الثالث
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isGameFinished && contestants.length >= 3)
                            _buildRankInfo(
                              contestants[2]['name'],
                              contestants[2]['score'],
                              contestants[2]['avatar'],
                              3,
                            ),
                          SizedBox(height: 8),
                          _buildRankColumn(3, 'assets/rank3.png'),
                        ],
                      ),
                    ],
                  )



              ),


              // 🟣 الصندوق البنفسجي فوق العواميد
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 210,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[100],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),


          if (isGameFinished)
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 610),
                child: Column(
                  children: [
                    if (contestants.where((c) => c['rank'] > 3).isNotEmpty)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ListView.builder(
                            itemCount: contestants.where((c) => c['rank'] > 3).length,
                            itemBuilder: (context, index) {
                              var additionalPlayers = contestants.where((c) => c['rank'] > 3).toList();
                              var player = additionalPlayers[index];
                              return _buildAdditionalRank(
                                player['name'],
                                player['score'],
                                player['avatar'],
                                player['rank'],
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }






  Widget _buildRankInfo(String name, int points, String avatarImage, int rank) {
    double topPadding = 0.0;
    double avatarSize = 40; // ممكن تعدله عشان اللاعب الأول يكون أوضح مثلا

    if (rank == 1) {
      topPadding = 0;  // المركز الأول فوق podium الكبير
      avatarSize = 45; // صورة أكبر للأول
    } else if (rank == 2) {
      topPadding = 20; // المركز الثاني ينزل شوي
      avatarSize = 38;
    } else if (rank == 3) {
      topPadding = 40; // المركز الثالث ينزل أكثر
      avatarSize = 36;
    }

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Column(
        children: [
          CircleAvatar(
            radius: avatarSize / 2, // حجم الصورة حسب المركز
            backgroundImage: AssetImage(avatarImage),
          ),
          SizedBox(height: 5),
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 5),
          Text(
            points.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFFB3B3B3)),
          ),
        ],
      ),
    );
  }



  Widget _buildRankColumn(int rank, String podiumImage) {
    double height;

    if (rank == 1) {
      height = 250; // المركز الأول أطول
    } else if (rank == 2) {
      height = 200; // المركز الثاني متوسط
    } else {
      height = 180; // المركز الثالث أقصر
    }

    return Container(
      width: 110,
      height: height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(podiumImage),
          fit: BoxFit.cover,
        ),
      ),
    );
  }


  Widget _buildAdditionalRank(String name, int points, String avatarImage,
      int rank) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          child: Row(
            children: [
              Container(
                alignment: Alignment.center,
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                ),
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(width: 16),
              CircleAvatar(
                radius: 15,
                backgroundImage: AssetImage(avatarImage),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                ),
              ),
              SizedBox(width: 9),
              Text(
                points.toString(),
                style: TextStyle(color: Color(0xFFB3B3B3)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCongratsAndScore() {
    return Stack(
      children: [
        // ✅ زر "Done" يسار و زر "إعادة" يمين على نفس السطر في الأعلى
        Positioned(
          top: 40, // تنزل الزرين شوي
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StudentHomePage()),
                    );
                  },
                  child: Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    String newgameId = await FirebaseService.RestartGame(
                        currentUserEmail, widget.gameId);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LeaderWidget(gameId: newgameId),
                      ),
                    );
                  },
                  icon: Icon(Icons.replay),
                  color: Colors.blue,
                  iconSize: 28,
                  tooltip: 'إعادة اللعبة',
                ),
              ],
            ),
          ),
        ),

        // ✨ باقي المحتوى داخل Column
        Padding(
          padding: const EdgeInsets.only(top: 70), // عشان ما يغطي الزرّين
          child: Column(
            children: [
              SizedBox(height: 20),
              Center(
                child: Text(
                  'Congratulations!',
                  style: TextStyle(fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  '${widget.correctAnswers} / ${widget.questions.length}',
                  style: TextStyle(fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text('Incorrect Answers', style: TextStyle(
                          color: Color(0xFFB3B3B3), fontSize: 14)),
                      SizedBox(height: 4),
                      Text('${widget.incorrectAnswers}',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                  SizedBox(width: 20),
                  Column(
                    children: [
                      Text('Skipped Answers', style: TextStyle(
                          color: Color(0xFFB3B3B3), fontSize: 14)),
                      SizedBox(height: 4),
                      Text('${widget.skippedAnswers}',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CorrectAnswersPage(
                                questions: widget.questions,
                                userAnswers: widget.userAnswers,
                              ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                    ),
                    child: Text('Check Correct Answers',
                        style: TextStyle(fontSize: 12)),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Studentreq(questions:widget.questions, ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Icon(Icons.help_outline, color: Colors.white),
                        SizedBox(width: 5),
                        Text('Ask Tutor', style: TextStyle(
                            color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }





}