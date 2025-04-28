import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';


class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late StreamController<int> _timerStreamController;
  String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';

  FirebaseService() {
    _timerStreamController = StreamController<int>();
  }

  Stream<int> get timerStream => _timerStreamController.stream;

  Future<String> createGame({
    required String adminEmail,
    required String questionType,
    required int numberOfQuestions,
    required int gameDuration, // مدة اللعبة بالدقائق
    required int maxParticipants,
  }) async {
    try {
      int gameId = Random().nextInt(1000000000);
      String gameIdString = gameId.toString();

      DocumentReference gameRef = _firestore.collection('GroupGames').doc(gameIdString);
      await gameRef.set({
        'admin_email': adminEmail,
        'question_type': questionType,
        'number_of_questions': numberOfQuestions,
        'game_duration': gameDuration,
        'status': 'waiting',
        'start_time': Timestamp.now(),
        'players': [adminEmail],
        'max_participants': maxParticipants,
        'current_participants': 1,
        'game_id': gameIdString,
        'remaining_time': 10 * 60,
        'gameTimeRemaining': gameDuration * 60,
      });

      DocumentReference playerRef = gameRef.collection('Players').doc(adminEmail);
      String userName = (await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: adminEmail)
          .get())
          .docs
          .first
          .data()["name"] ;
      await playerRef.set({
        'player_email': adminEmail,
        'score': 0,
        'progress': 0,
        'rank': 0,
        'name': userName,
        'status': 'waiting'
      });

      // بدء مؤقت الانتظار
      startWaitingTimer(gameIdString);

      return gameIdString; // إرجاع الـ Game ID
    } catch (e) {
      return "Error creating game";
    }
  }



  void dispose() {
    _timerStreamController.close();
  }

  Future<void> joinGame(String gameId, String playerEmail) async {
    try {
      DocumentReference gameRef = _firestore.collection('GroupGames').doc(gameId);
      DocumentSnapshot gameSnapshot = await gameRef.get();
      var gameData = gameSnapshot.data() as Map<String, dynamic>;

      int maxParticipants = gameData['max_participants'];
      List<dynamic> players = gameData['players'] ?? [];
      int currentPlayersCount = players.length;

      if (currentPlayersCount < maxParticipants) {
        await gameRef.update({
          'players': FieldValue.arrayUnion([playerEmail]),
          'current_participants': FieldValue.increment(1),
        });
        DocumentReference playerRef = gameRef.collection('Players').doc(currentUserEmail);
        String userName = (await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUserEmail) // البحث عن البريد الإلكتروني
            .get())
            .docs
            .first
            .data()?["name"] ?? '';
        await playerRef.set({
          'player_email': currentUserEmail,
          'score': 0,
          'progress': 0,
          'rank': 0,
          'name': userName,
          'status': 'waiting',
        });
        print('Player added successfully.');
      } else {
        print('Cannot add more players, the game is full.');
      }
    } catch (e) {
      print('Error adding player: $e');
      rethrow;
    }
  }

  Future<void> startGame(String gameId) async {
    try {
      DocumentReference gameRef = _firestore.collection('GroupGames').doc(gameId);
      DocumentSnapshot gameSnapshot = await gameRef.get();
      var gameData = gameSnapshot.data() as Map<String, dynamic>;
      int gameDurationInSeconds = gameData['game_duration'] * 60;

      if (gameSnapshot.exists) {
        await gameRef.update({
          'status': 'started',  // تغيير حالة اللعبة إلى started
          'gameTimeRemaining': gameDurationInSeconds,  // تحديد وقت اللعبة المتبقي
        });

        // بدء مؤقت اللعبة
        startGameTimer(gameId, gameDurationInSeconds);
      }
    } catch (e) {
      print('Error starting game: $e');
    }
  }
  void startWaitingTimer(String gameId) {
    int remainingTime = 10 * 60; // 10 دقائق للانتظار
    Timer.periodic(Duration(seconds: 1), (timer) async {
      if (remainingTime > 0) {
        remainingTime--;
        await FirebaseFirestore.instance.collection('GroupGames').doc(gameId).update({
          'remaining_time': remainingTime, // تحديث الوقت المتبقي للانتظار
        });
      }
    });
  }

  Future<void> stopRemainingTime(String gameId) async {
    try {
      DocumentReference gameRef = _firestore.collection('GroupGames').doc(gameId);
      await gameRef.update({'remaining_time': 0});
      print('Remaining time has been stopped.');
    } catch (e) {
      print('Error stopping remaining time: $e');
    }
  }


  Future<void> updateGameStatus(String gameId, String status) async {
    try {
      DocumentReference gameRef = _firestore.collection('GroupGames').doc(gameId);
      await gameRef.update({'status': status});
    } catch (e) {
      print('Error updating game status: $e');
      rethrow;
    }
  }

  Future<void> leaveGame(String gameId, String playerEmail) async {
    try {
      DocumentReference gameRef = _firestore.collection('GroupGames').doc(gameId);
      DocumentSnapshot gameSnapshot = await gameRef.get();

      if (gameSnapshot.exists) {
        var gameData = gameSnapshot.data() as Map<String, dynamic>;
        List<dynamic> players = gameData['players'] ?? [];
        int currentParticipants = gameData['current_participants'];
        String leaderEmail = gameData['admin_email'];

        if (gameData['current_participants'] == 1 && players.contains(playerEmail)) {
          await gameRef.update({'status': 'cancelled'});
          stopRemainingTime(gameId);
          print('Game cancelled as the last player left.');
        } else if (playerEmail == leaderEmail && currentParticipants >= 1) {
          // إذا كان اللاعب هو القائد وكان هناك لاعبين آخرين
          String newLeaderEmail = players.firstWhere((email) => email != leaderEmail);
          await gameRef.update({'admin_email': newLeaderEmail});
          await gameRef.update({'players': FieldValue.arrayRemove([leaderEmail])});
          await gameRef.update({'current_participants': FieldValue.increment(-1)});
          await FirebaseFirestore.instance
              .collection('GroupGames')
              .doc(gameData['game_id'])
              .collection('Players')
              .doc(leaderEmail)  // Assuming leaderEmail is the document ID
              .delete();
          print('New leader assigned: $newLeaderEmail');
        } else {
          await FirebaseFirestore.instance
              .collection('GroupGames')
              .doc(gameData['game_id'])
              .collection('Players')
              .doc(playerEmail)
              .delete();
          await gameRef.update({
            'players': FieldValue.arrayRemove([playerEmail]),
            'current_participants': FieldValue.increment(-1),
          });

          FirebaseFirestore.instance
              .collection('GroupGames') // أو اسم المجموعة المناسبة
              .doc(gameId) // مستند اللعبة
              .collection('Players') // إذا كنت تخزن اللاعبين في مجموعة فرعية
              .doc(playerEmail) // مستند اللاعب
              .delete();
          print('$playerEmail has left the game.');
        }
      }
    } catch (e) {
      print('Error leaving game: $e');
      rethrow;
    }
  }






  static Future<String> RestartGame(String playerEmail, String oldGameId) async {

    final firestore = FirebaseFirestore.instance;
    final gameRef = firestore.collection('GroupGames').doc(oldGameId);
    final oldGameSnapshot = await gameRef.get();
    final oldGame = oldGameSnapshot.data() as Map<String, dynamic>;

    if (oldGame.containsKey('restarted_game_id')) {
      String newGameId = oldGame['restarted_game_id'];

      await firestore.collection('GroupGames').doc(newGameId).update({
        'players': FieldValue.arrayUnion([playerEmail]),
        'current_participants': FieldValue.increment(1),
      });

      DocumentReference playerRef = firestore
          .collection('GroupGames')
          .doc(newGameId)
          .collection('Players')
          .doc(playerEmail);

      String userName = (await firestore
          .collection('users')
          .where('email', isEqualTo: playerEmail)
          .get())
          .docs
          .first
          .data()["name"] ;

      await playerRef.set({
        'player_email': playerEmail,
        'score': 0,
        'progress': 0,
        'rank': 0,
        'name': userName,
      });



      return newGameId;    }


    final gameService = FirebaseService();

    String newGameId = await gameService.createGame(
      adminEmail: playerEmail,
      questionType: oldGame['question_type'],
      numberOfQuestions: oldGame['number_of_questions'],
      gameDuration: oldGame['game_duration'],
      maxParticipants: oldGame['max_participants'],
    );

    await gameRef.update({
      'restarted_game_id': newGameId,
    });


    print('New game created by $playerEmail');
    return newGameId;
  }

  void startGameTimer(String gameId, int gameDurationInSeconds) {
    int remainingTime = gameDurationInSeconds;
    Timer.periodic(Duration(seconds: 1), (timer) async {
      if (remainingTime > 0) {
        remainingTime--;
        await FirebaseFirestore.instance.collection('GroupGames').doc(gameId).update({
          'gameTimeRemaining': remainingTime, // تحديث وقت اللعبة المتبقي
        });
      } else {
        timer.cancel();
        // عندما ينتهي وقت اللعبة، يتم إنهاء اللعبة
        await updateGameStatus(gameId, 'finished');
      }
    });
  }

  static  Future<void> playerFinishedGame(String gameId) async {
    try {

      int finishedPlayers = 0;
      var gameData = await FirebaseFirestore.instance
          .collection('GroupGames')
          .doc(gameId)
          .get();

      if (gameData.exists) {
        var players = gameData.data()?['players'] ?? [];

        for (var playerEmail in players) {
          var playerData = await FirebaseFirestore.instance
              .collection('GroupGames')
              .doc(gameId)
              .collection('Players')
              .doc(playerEmail)
              .get();

          if (playerData.exists) {
            var playerStatus = playerData.data()?['status'];
            if (playerStatus == 'completed') {
              finishedPlayers++;
            }
          }
        }

        if (finishedPlayers == gameData.data()?['current_participants'] ) {
          await FirebaseFirestore.instance
              .collection('GroupGames')
              .doc(gameId)
              .update({'status': 'finished'});

          var playerRanks = <String, int>{};

          // استرجاع بيانات اللاعبين وحساب الرانك
          for (var playerEmail in players) {
            var playerData = await FirebaseFirestore.instance
                .collection('GroupGames')
                .doc(gameId)
                .collection('Players')
                .doc(playerEmail)
                .get();

            if (playerData.exists) {
              int score = playerData.data()?['score'] ?? 0;  // تأكد من أن السكور هو int
              playerRanks[playerEmail] = score;
            }
          }

          // ترتيب اللاعبين حسب السكور (من الأعلى إلى الأدنى)
          var sortedPlayers = playerRanks.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          // تحديث الرانك في الـ Firestore
          for (int i = 0; i < sortedPlayers.length; i++) {
            await FirebaseFirestore.instance
                .collection('GroupGames')
                .doc(gameId)
                .collection('Players')
                .doc(sortedPlayers[i].key)
                .update({'rank': i + 1});  // تحديث الرانك
          }
        }
      }
    } catch (e) {
      print('Error in player finish and game check: $e');
    }
  }



}