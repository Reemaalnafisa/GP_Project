import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gat_helper_app/features/auth/views/custom_group_game_page.dart';
import 'package:gat_helper_app/core/services/GroupGameSetting_service.dart';
import 'GG_waiting.dart';

class GroupGamePage2 extends StatefulWidget {
  @override
  _GroupGamePageState createState() => _GroupGamePageState();
}

class _GroupGamePageState extends State<GroupGamePage2> {
  TextEditingController _codeController = TextEditingController();
  String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';

  Future<List<Map<String, dynamic>>> _getWaitingGames() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('GroupGames')
        .where('status', isEqualTo: 'waiting')
        .get();

    List<Map<String, dynamic>> games = [];
    for (var doc in snapshot.docs) {
      games.add(doc.data() as Map<String, dynamic>);
    }

    return games;
  }

  // دالة للانضمام والانتقال للعبة
  Future<void> _joinAndNavigate(String gameId) async {
    await FirebaseService().joinGame(gameId, currentUserEmail);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LeaderWidget(gameId: gameId),
      ),
    );
  }

  // دالة البحث باستخدام الكود
  Future<void> _searchGameByCode() async {
    String enteredCode = _codeController.text.trim();

    if (enteredCode.isEmpty) {
      _showSnackBar("Please enter a game code!");
      return;
    }

    try {
      var gameSnapshot = await FirebaseFirestore.instance
          .collection('GroupGames')
          .doc(enteredCode)
          .get();

      if (gameSnapshot.exists) {
        var gameData = gameSnapshot.data() as Map<String, dynamic>;

        if (gameData['status'] == 'waiting') {
          await _joinAndNavigate(gameSnapshot.id);
        } else {
          _showSnackBar("This game is not in a waiting state.");
        }
      } else {
        _showSnackBar("Game not found.");
      }
    } catch (e) {
      _showSnackBar("Error fetching game: $e");
    }
  }

  // دالة عرض رسائل التنبيه
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // العنوان مع زر الرجوع
          Stack(
            children: [
              Image.asset(
                'assets/img_3.png',
                width: double.infinity,
                height: 170,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 50,
                left: 20,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black, size: 30),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),

          // خانة البحث بالكود
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 16.0, right: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Find Your Group Game!",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _codeController,
                        decoration: InputDecoration(
                          hintText: "Enter a Code...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(color: Colors.black, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.search, color: Colors.black),
                            onPressed: _searchGameByCode,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.add, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CustomizeGamePage()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // عرض قائمة الألعاب
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _getWaitingGames(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                var groupGames = snapshot.data ?? [];
                if (groupGames.isEmpty) {
                  return Center(child: Text('No games in waiting state.'));
                }

                return ListView.builder(
                  itemCount: groupGames.length,
                  itemBuilder: (context, index) {
                    var game = groupGames[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                      child: Card(
                        color: Colors.blue.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          title: Row(
                            children: [
                              Icon(Icons.key, color: Colors.black),
                              SizedBox(width: 8),
                              Text(
                                game["game_id"].toString(),
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(game["question_type"] ?? 'No Type'),
                              Row(
                                children: [
                                  Icon(Icons.people),
                                  SizedBox(width: 5),
                                  Text("${game["players"].length} / ${game["max_participants"]} players"),
                                  SizedBox(width: 7),
                                  Icon(Icons.timer),
                                  SizedBox(width: 5),
                                  Text("${game['game_duration']} min"),
                                ],
                              ),
                            ],
                          ),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () async {
                            await _joinAndNavigate(game["game_id"].toString());
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
