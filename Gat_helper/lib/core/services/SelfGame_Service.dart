import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SelfGameService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // إنشاء اللعبة وحفظ البيانات في Firestore باستخدام gameId
  Future<String> createSelfGame({
    required String StuEmail,
    required String questionType,
    required int gameDuration,
  }) async {
    try {
      int gameId = DateTime.now().millisecondsSinceEpoch; // Or use Random().nextInt(1000000000)

      DocumentReference gameRef = FirebaseFirestore.instance.collection('SelfGames').doc(gameId.toString());

      // Save self game data to Firestore
      await gameRef.set({
        'game_id': gameId.toString(),
        'student_email':  StuEmail,
        'question_type': questionType,
        'game_duration': gameDuration,
        'start_time': Timestamp.now(),


      });

      return gameId.toString(); // Return gameId
    } catch (e) {
      print("Error creating self game: $e");
      rethrow;
    }
  }


}
