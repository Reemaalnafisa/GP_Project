import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaderWidget1 extends StatelessWidget {
  final int gameId; // المتغير لاستقبال gameId

  // المُنشئ لاستقبال gameId
  LeaderWidget1({required this.gameId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leader Widget'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('GroupGames')
            .doc(gameId.toString()) // استخدام gameId للاستعلام
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // الانتظار
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // إذا كان هناك خطأ
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No game found')); // إذا لم توجد البيانات
          } else {
            var gameData = snapshot.data!.data() as Map<String, dynamic>;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Game ID: ${gameData['gameId']}'), // عرض gameId
                  Text('Status: ${gameData['status']}'), // عرض status
                  // إضافة المزيد من البيانات هنا حسب الحاجة
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
