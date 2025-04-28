import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gat_helper_app/features/auth/views/student.dart';
import 'package:intl/intl.dart';
import 'Student_chat_page.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  _RequestsPageState createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  Map<int, bool> showDetails = {};
  Map<int, int> ratings = {};
  late Future<List<Request>> requestsFuture;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
    });
  }

  Stream<List<Request>> fetchRequestsStream() async* {
    final user = FirebaseAuth.instance.currentUser;



    if (user == null) {
      yield [];
      return;
    }

    final snapshots = FirebaseFirestore.instance
        .collection('helpRequests')
        .where('studentEmail', isEqualTo: user.email)
        .orderBy('timestamp', descending: true)
        .snapshots();

    await for (final snapshot in snapshots) {
      List<Request> requests = await Future.wait(snapshot.docs.map((doc) async {
        final data = doc.data();
        final status = (data['status'] ?? 'pending').toString().toLowerCase();
        final method = data['method'] ?? 'Unknown';
        final selectedQuestions = data['selectedQuestions'] ?? [];
        final acceptedTutor = data['acceptedTutor'];  // tutor doc ID not email
        final sessionLink = data['sessionLink'];
        final linkValidUntil = (data['linkValidUntil'] as Timestamp?)?.toDate();
        final statusReason = data['statusReason'] ?? '';
        final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
        final studentId = data['studentId'];
        final chatId = data['chatId'];

        String? remainingTime;
        if (linkValidUntil != null) {
          final now = DateTime.now();
          final difference = linkValidUntil.difference(now);
          if (difference.isNegative) {
            remainingTime = "Expired";
          } else {
            final minutes = difference.inMinutes;
            final seconds = difference.inSeconds % 60;
            remainingTime = "$minutes minutes, $seconds seconds remaining";
          }
        }

        String? studentAvatar;
        if (studentId != null) {
          final studentDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(studentId)
              .get();
          studentAvatar = studentDoc.data()?['avatar'];
        }

        String? tutorName;
        String? tutorAvatar;
        String? tutorUID;

        if (acceptedTutor != null) {
          final tutorDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(acceptedTutor)
              .get();
          final tutorData = tutorDoc.data();
          tutorUID = acceptedTutor; // 🔥 خذ الـ UID الحقيقي
          tutorName = tutorData?['name'] ?? 'Unknown'; // فقط الاسم للعرض
          tutorAvatar = tutorData?['avatar'];
        }


        if (acceptedTutor != null) {
          final tutorDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(acceptedTutor)
              .get();
          final tutorData = tutorDoc.data();
          tutorUID = acceptedTutor; // 🔥 خذ الـ UID الحقيقي
          tutorName = tutorData?['name'] ?? 'Unknown'; // فقط الاسم للعرض
          tutorAvatar = tutorData?['avatar'];
        }


        if (status == 'accepted' &&
            method == 'Chat' &&
            acceptedTutor != null &&
            studentId != null) {
          final chatSnap = await FirebaseFirestore.instance
              .collection('chats')
              .where('studentId', isEqualTo: studentId)
              .where('tutorId', isEqualTo: acceptedTutor)
              .limit(1)
              .get();

          if (chatSnap.docs.isNotEmpty) {
            final chatDoc = chatSnap.docs.first;
            if ((chatDoc.data()['status'] ?? '') == 'ended' && status != 'ended') {
              await FirebaseFirestore.instance
                  .collection('helpRequests')
                  .doc(doc.id)
                  .update({'status': 'ended'});
            }
          }
        }

        String timeFormatted = timestamp != null
            ? DateFormat('EEEE | hh:mm a').format(timestamp)
            : '';

        String details = '';
        bool showRating = false;

        if (status == 'pending') {
          details = 'Method: $method\nQuestions: ${selectedQuestions.length}';
        } else if (status == 'accepted') {
          if (method == 'Chat') {
            details = 'Approved by: $tutorName';
          } else if (method == 'Virtual') {
            details = 'Approved by: $tutorName\n🔗 $sessionLink\nExpires in: $remainingTime';
            if (remainingTime == "Expired") {
              // إذا انتهت صلاحية الرابط، قم بعرض رسالة انتهاء الصلاحية فقط
              details = 'Approved by: $tutorName\nLink has expired.';
            } else {
              // إذا كان الرابط لا يزال صالحًا، قم بعرض الرابط ووقت الانتهاء
              details = 'Approved by: $tutorName\n🔗 $sessionLink\nExpires in: $remainingTime';
            }
          }
        } else if (status == 'rejected') {
          details = 'Sorry, Hope to see you next time!';
        } else if (status == 'ended') {
          details = 'ended by: $tutorName\n';
          showRating = true;
        } else if( status.toLowerCase()=='confirmed'){
          details = 'Approved by: $tutorName\n🔗 $sessionLink\nExpires in: $remainingTime';
        }

        final statusColor = status == 'pending'
            ? Colors.yellow
            : status == 'accepted'
            ? Colors.green
            : status == 'rejected'
            ? Colors.red
            : status == 'confirmed'
            ? Colors.green
            : Colors.grey;

        return Request(
          doc.id.hashCode,
          status[0].toUpperCase() + status.substring(1),
          timeFormatted,
          statusColor,
          details,
          showRating,
          status == 'rejected' ? statusReason : null,
          method,
          chatId,
          tutorName,
          tutorUID,
          tutorAvatar,
          studentAvatar,
          remainingTime,

        );
      }).toList());

      yield requests;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Stack(
            children: [
              Image.asset(
                "assets/img_17.png",
                fit: BoxFit.cover,
                width: double.infinity,
                height: 120,
              ),
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => StudentHomePage()), // Navigate to the Student Homepage
                    );
                  },
                ),
                title: const Text(
                  "Requests",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                centerTitle: true,
              ),
            ],
          ),
        ),
        body: StreamBuilder<List<Request>>(
          stream: fetchRequestsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else {
              final requests = snapshot.data ?? [];
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    return requestCard(requests[index]);
                  },
                ),
              );
            }
          },
        )

    );
  }
  Widget requestCard(Request request) {
    // بعد رسم الكارد، نتحقق إذا في rate محفوظ مسبقاً في فايرستور
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (request.showRating &&
          request.chatId != null &&
          !ratings.containsKey(request.id)) {
        final chatSnap = await FirebaseFirestore.instance
            .collection('chats')
            .doc(request.chatId)
            .get();
        final existingRate = chatSnap.data()?['rate'] as int?;
        if (existingRate != null) {
          setState(() {
            ratings[request.id] = existingRate;
          });
        }
      }
    });

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صف الحالة والوقت
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: request.statusColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    request.status,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
                Row(
                  children: [
                    Text(request.time,
                        style: TextStyle(color: Colors.grey[600])),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        setState(() {
                          showDetails[request.id] =
                          !(showDetails[request.id] ?? false);
                        });
                      },
                    ),
                  ],
                )
              ],
            ),

            // تفاصيل الطلب
            if (showDetails[request.id] ?? false) ...[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (request.status.toLowerCase() != 'rejected' && request.tutorAvatar != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundImage: AssetImage(request.tutorAvatar!),
                      ),
                    ),
                  Expanded(
                    child: Text(request.details, style: const TextStyle(fontSize: 16)),
                  ),

                ],
              ),

              // زر فتح الشات
              if (request.method == 'Chat' &&
                  request.status.toLowerCase() == 'accepted' &&
                  request.chatId != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.chat, color: Colors.white),
                    label: const Text("Open Chat"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            studentName: request.acceptedTutor ?? 'Tutor',
                            currentUserRole: 'student',                            chatId: request.chatId!,
                            studentAvatar: request.studentAvatar ??
                                'assets/student.png',
                            tutorAvatar:
                            request.tutorAvatar ?? 'assets/tutor.png',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              // تفاصيل الجلسة الافتراضية
              if (request.method == 'Virtual' &&
                  request.status.toLowerCase() == 'accepted') ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.attach_file,
                            size: 20, color: Colors.blue),
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Session Link'),
                                content: Text(
                                  request.details.contains('🔗')
                                      ? request.details.split('🔗 ')[1]
                                      : 'No link provided.',
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text("Close"),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text("View Link",
                              style: TextStyle(color: Colors.blue)),
                        ),
                      ],
                    ),
                    if (request.details.contains('Expires in:')) ...[
                      Text(
                        request.details.split('Expires in: ')[1],
                        style: TextStyle(
                            color: Colors.redAccent, fontSize: 14),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          // First search the document by chatId field
                          final querySnapshot = await FirebaseFirestore.instance
                              .collection('helpRequests')
                              .where('chatId', isEqualTo: request.chatId)
                              .get();

                          if (querySnapshot.docs.isNotEmpty) {
                            // Get the first matching document
                            final docId = querySnapshot.docs.first.id;

                            // Update the status to confirmed
                            await FirebaseFirestore.instance
                                .collection('helpRequests')
                                .doc(docId)
                                .update({'status': 'confirmed'});

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("You have accepted the session!")),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Request not found.")),
                            );
                          }
                        } catch (e) {
                          print('Error confirming the session: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Error accepting the session.")),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text(
                        "Accept",
                        style: TextStyle(
                          color: Colors.white, // Set the text color to white
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          // First search the document by chatId field
                          final querySnapshot = await FirebaseFirestore.instance
                              .collection('helpRequests')
                              .where('chatId', isEqualTo: request.chatId)
                              .get();

                          if (querySnapshot.docs.isNotEmpty) {
                            final docId = querySnapshot.docs.first.id;

                            // Update the status to Rejected
                            await FirebaseFirestore.instance
                                .collection('helpRequests')
                                .doc(docId)
                                .update({'status': 'Rejected'});

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("You have rejected the session!")),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Request not found.")),
                            );
                          }
                        } catch (e) {
                          print('Error rejecting the session: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Error rejecting the session.")),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text(
                        "Reject",
                        style: TextStyle(
                          color: Colors.white, // Set the text color to white
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ],

            // صف التقييم
            if (request.showRating && request.tutorID != null) ...[
              const SizedBox(height: 10),
              Row(
                children: List.generate(5, (starIndex) {
                  return IconButton(
                    icon: Icon(
                      starIndex < (ratings[request.id] ?? 0)
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 30,
                    ),
                    onPressed: ratings.containsKey(request.id)
                        ? null
                        : () async {
                      final selectedRating = starIndex + 1;
                      final chatId = request.chatId!;

                      setState(() {
                        ratings[request.id] = selectedRating;
                      });

                      // المرجع لوثيقة الشات
                      final chatRef = FirebaseFirestore.instance
                          .collection('chats')
                          .doc(chatId);

// 1) جلب بيانات وثيقة الشات
                      final chatSnap = await chatRef.get();
                      if (!chatSnap.exists) return;

// 2) استخراج حقل tutorId
                      final chatData = chatSnap.data()!;
                      final tutorId = chatData['tutorId'] as String?;
                      if (tutorId == null) return;

// الآن عندنا tutorId، نقدر نحدث سجل المدرس
                      final tutorRef = FirebaseFirestore.instance
                          .collection('users')
                          .doc(tutorId);

// 3) جلب بيانات المدرس القديمة
                      final tutorSnap = await tutorRef.get();
                      if (!tutorSnap.exists) return;
                      final data = tutorSnap.data()!;
                      final oldRating = (data['rating'] ?? 0.0) as double;
                      final oldCount  = (data['ratingCount'] ?? 0)   as int;

// 4) حساب المتوسط والعدد الجديد
                      final newCount  = oldCount + 1;
                      final newRating = (oldRating * oldCount + selectedRating) / newCount;

// 5) تحديث سجل المدرس
                      await tutorRef.update({
                        'rating': newRating,
                        'ratingCount': newCount,
                      });

// 6) (اختياري) تسجيل التقييم في وثيقة الشات نفسها
                      await chatRef.update({'rate': selectedRating});

                    },
                  );
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }

}

class Request {
  final int id;
  final String status;
  final String time;
  final Color statusColor;
  final String details;
  final bool showRating;
  final String? rejectionReason;
  final String method;
  final String? chatId;
  final String? acceptedTutor;
  final String? tutorID;
  final String? tutorAvatar;
  final String? studentAvatar;
  final String? remainingTime; // أضف الحقل الجديد هنا

  Request(
      this.id,
      this.status,
      this.time,
      this.statusColor,
      this.details,
      this.showRating,
      this.rejectionReason,
      this.method,
      this.chatId,
      this.acceptedTutor,
      this.tutorID,
      this.tutorAvatar,
      this.studentAvatar,
      this.remainingTime, // تأكد من إضافة الحقل هنا أيضًا
      );
}