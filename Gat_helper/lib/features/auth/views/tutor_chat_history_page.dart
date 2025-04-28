import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gat_helper_app/features/auth/views/tutor_home_page.dart';
import 'Student_chat_page.dart';

class ChatHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;


    return Scaffold(
      appBar: AppBar(
        title: Text("Chat History", style: TextStyle(color: Colors.white)),
        flexibleSpace: Image.asset(
          "assets/img_17.png",
          fit: BoxFit.cover,
          width: double.infinity,
          height: 120,
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => TutorHomepage()), // Navigate back to the Tutor Homepage
            );
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('tutorId', isEqualTo: currentUid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {

              final data = chats[index].data() as Map<String, dynamic>;
              final status = data['status'] ?? ''; // الحالة
              final rating = data['rate']?.toDouble() ?? 0.0;

              return Card(
                color: Colors.blue.shade50,
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 25,
                        child: ClipOval(
                          child: Image.asset(
                            data['studentAvatar'] ?? 'assets/default_avatar.jpg',
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['studentName'] ?? 'Unknown',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            if (status == 'ended') // ✅ فقط لما تنتهي الجلسة
                              RatingBarIndicator(
                                rating: rating, // التقييم المسترجع من Firebase
                                itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
                                itemCount: 5,
                                itemSize: 20,
                                direction: Axis.horizontal,
                              ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            data['timestamp']?.toDate().toString().split('.')[0] ?? '',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_forward_ios, color: Colors.black54),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatPage(
                                    chatId: data['chatId'] ?? '',
                                    studentName: data['studentName'] ?? 'Unknown',
                                    currentUserRole: 'tutor',
                                    studentAvatar: data['studentAvatar'] ?? 'assets/default_avatar.jpg',
                                    tutorAvatar: data['tutorAvatar'] ?? 'assets/default_avatar.jpg',
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}