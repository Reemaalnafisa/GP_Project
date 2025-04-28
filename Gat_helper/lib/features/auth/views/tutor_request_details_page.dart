import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gat_helper_app/features/auth/views/tutor_home_page.dart';
import 'Student_chat_page.dart';
import 'request_link_page.dart';

class RequestDetailsPage5 extends StatefulWidget {
  final String studentName;
  final String preferredMethod;
  final List<Map<String, dynamic>> questions;
  final String requestId;

  const RequestDetailsPage5({
    Key? key,
    required this.studentName,
    required this.preferredMethod,
    required this.questions,
    required this.requestId,
  }) : super(key: key);

  @override
  _RequestDetailsPageState createState() => _RequestDetailsPageState();
}

class _RequestDetailsPageState extends State<RequestDetailsPage5> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: AppBar(
          centerTitle: true,
          title: Padding(
            padding: const EdgeInsets.only(bottom: 10), // Move title down
            child: const Text(
              "Request Details",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          flexibleSpace: Image.asset(
            "assets/img_17.png", // your background image
            fit: BoxFit.cover,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: widget.questions.length,
                itemBuilder: (context, index) {
                  final questionData = widget.questions[index];
                  final question = questionData['question'] ?? '';
                  final options = List<String>.from(questionData['options'] ?? []);
                  final correctAnswer = questionData['correct_answer'] ?? '';
                  final passage = questionData['passage'];
                  final imageUrl = questionData['image'];
                  return _questionCard(question, options, correctAnswer, passage, imageUrl);
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton("Reject", Colors.red, () async {
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid == null) return;

                  await FirebaseFirestore.instance
                      .collection('helpRequests')
                      .doc(widget.requestId)
                      .update({
                    'rejectedTutors': FieldValue.arrayUnion([uid]),
                  });

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => TutorHomepage()),
                        (route) => false, // إزالة جميع الصفحات السابقة من المكدس
                  );
                }),
                _actionButton("Accept", Colors.green, () async {
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid == null) return;

                  final requestRef = FirebaseFirestore.instance.collection('helpRequests').doc(widget.requestId);
                  final requestSnap = await requestRef.get();
                  String? studentId = requestSnap.data()?['studentId'];
                  String? studentAvatar;
                  String? tutorAvatar;

                  // Get student avatar
                  if (studentId == null || studentId.isEmpty) {
                    final studentEmail = requestSnap.data()?['studentEmail'];
                    final studentSnapshot = await FirebaseFirestore.instance
                        .collection('users')
                        .where('email', isEqualTo: studentEmail)
                        .limit(1)
                        .get();
                    if (studentSnapshot.docs.isNotEmpty) {
                      final studentDoc = studentSnapshot.docs.first;
                      studentId = studentDoc.id;
                      studentAvatar = studentDoc.data()['avatar'];
                      await requestRef.update({'studentId': studentId});
                    }
                  } else {
                    final studentDoc = await FirebaseFirestore.instance.collection('users').doc(studentId).get();
                    studentAvatar = studentDoc.data()?['avatar'];
                  }

                  // Get tutor avatar
                  final tutorDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
                  tutorAvatar = tutorDoc.data()?['avatar'];


                  await requestRef.update({
                    'acceptedTutor': uid,
                    'rejectedTutors': FieldValue.delete(),
                    'status': 'accepted',
                    'chatId': widget.requestId,
                  });


                  if (widget.preferredMethod == 'Chat') {
                    await FirebaseFirestore.instance
                        .collection('chats')
                        .doc(widget.requestId) // هنا وضعنا الـ document id بنفس الـ chatId
                        .set({
                      'studentId': studentId,
                      'tutorId': uid,
                      'chatId': widget.requestId,
                      'studentName': widget.studentName,
                      'studentAvatar': studentAvatar ?? 'assets/student.png',
                      'tutorAvatar': tutorAvatar ?? 'assets/tutor.png',
                      'timestamp': FieldValue.serverTimestamp(),
                      'status': 'active',
                      'questions': widget.questions, // إضافة الأسئلة مع الإجابات والخيارات إلى الشات
                    });

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          studentName: widget.studentName,
                          currentUserRole: 'tutor',
                          chatId: widget.requestId,
                          studentAvatar: studentAvatar ?? '',
                          tutorAvatar: tutorAvatar ?? '',
                        ),
                      ),
                    );
                  } else if (widget.preferredMethod == 'Virtual') {
                    await showDialog(
                      context: context,
                      barrierDismissible: false, // منع إغلاق النافذة بالنقر خارجها
                      builder: (BuildContext dialogContext) {
                        final TextEditingController linkController = TextEditingController();
                        final TextEditingController durationController = TextEditingController();

                        return AlertDialog(
                          title: Text("Enter Session Details"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: linkController,
                                decoration: InputDecoration(
                                  labelText: "Session Link",
                                  hintText: "Enter session link...",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(height: 16),
                              TextField(
                                controller: durationController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Duration (minutes)",
                                  hintText: "Enter duration in minutes...",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () async {
                                final sessionLink = linkController.text.trim();
                                final sessionDuration = int.tryParse(durationController.text.trim()) ?? 0;

                                // التحقق من صحة الإدخالات
                                if (sessionLink.isEmpty || sessionDuration <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Please enter a valid link and duration.')),
                                  );
                                  return; // منع الخروج إذا كانت الإدخالات غير صحيحة
                                }

                                // تحديث مستند الطلب في Firestore
                                final expirationTime = DateTime.now().add(Duration(minutes: sessionDuration));

                                await FirebaseFirestore.instance
                                    .collection('helpRequests')
                                    .doc(widget.requestId)
                                    .update({
                                  'acceptedTutor': FirebaseAuth.instance.currentUser!.uid,
                                  'status': 'accepted',
                                  'sessionLink': sessionLink,
                                  'linkValidUntil': Timestamp.fromDate(expirationTime),
                                });

                                // نقل المستخدم إلى الصفحة الرئيسية للتوتور
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (_) => TutorHomepage()),
                                      (route) => false,
                                );
                              },
                              child: Text("Submit"),
                            ),
                          ],
                        );
                      },
                    );
                  } } ),

              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _questionCard(
      String question,
      List<String> options,
      String correctAnswer,
      dynamic passage,
      dynamic imageUrl,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.help_outline, color: Colors.black54, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
                ),
              ),
              if (passage != null || imageUrl != null)
                IconButton(
                  icon: const Icon(Icons.attach_file, size: 20),
                  tooltip: 'View extra content',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Extra Content'),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (passage != null) ...[
                                Text(
                                  passage,
                                  style: const TextStyle(fontSize: 14.5, fontStyle: FontStyle.italic),
                                ),
                                const SizedBox(height: 16),
                              ],
                              if (imageUrl != null)
                                Image.network(imageUrl),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: const Text("Close"),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...options.map((option) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 6, color: Colors.black54),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 14,
                      color: option == correctAnswer ? Colors.green : Colors.black54,
                      fontWeight: option == correctAnswer ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _actionButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}