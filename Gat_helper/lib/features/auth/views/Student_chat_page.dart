import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gat_helper_app/features/auth/views/ViewQ.dart';
import 'package:gat_helper_app/features/auth/views/tutor_chat_history_page.dart';

import 'All_req_page.dart';


class ChatPage extends StatefulWidget {
  final String studentName;
  final String currentUserRole; // 'tutor' or 'student'
  final String chatId;
  final String studentAvatar;
  final String tutorAvatar;

  const ChatPage({
    required this.studentName,
    required this.currentUserRole,
    required this.chatId,
    required this.studentAvatar,
    required this.tutorAvatar,
    Key? key,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  bool isSessionEnded = false;
  late Stream<DocumentSnapshot> chatStream;

  @override
  void initState() {
    super.initState();
    chatStream = FirebaseFirestore.instance.collection('chats').doc(widget.chatId).snapshots();
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty || isSessionEnded) return;

    final messageText = _controller.text.trim();
    _controller.clear();
print(widget.chatId);
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'text': messageText,
      'sender': widget.currentUserRole,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _showEndSessionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("End Session"),
          content: const Text("Are you sure you want to end this session?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                elevation: 3,
              ),
              onPressed: () async {
                try {
                  Navigator.of(context).pop(); // قفلي التنبيه أول شيء

                  // 1. تحديث حالة الشات
                  await FirebaseFirestore.instance
                      .collection('chats')
                      .doc(widget.chatId)
                      .update({'status': 'ended'});
                  print(widget.chatId);

                  // 2. جلب الريكويست المرتبط بنفس chatId
                  final helpRequestSnapshot = await FirebaseFirestore.instance
                      .collection('helpRequests')
                      .where('chatId', isEqualTo: widget.chatId)
                      .limit(1)
                      .get();

                  // 3. إذا لقينا الريكويست نحدث حالته
                  if (helpRequestSnapshot.docs.isNotEmpty) {
                    final helpRequestDoc = helpRequestSnapshot.docs.first;
                    await FirebaseFirestore.instance
                        .collection('helpRequests')
                        .doc(helpRequestDoc.id)
                        .update({'status': 'ended'});
                  }

                  // 4. بعد ما نخلص، نحدث الشاشة
                  setState(() {
                    isSessionEnded = true;
                  });
                } catch (e) {
                  print('Error ending session: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('❌ Failed to end session.')),
                  );
                }
              },

              child: const Text(
                "Confirm",
                style: TextStyle(
                  color: Colors.white, // Setting the text color to white
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  ImageProvider getImageProvider(String path) {
    return path.startsWith('http')
        ? NetworkImage(path)
        : AssetImage(path) as ImageProvider;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: chatStream,
      builder: (context, chatSnapshot) {
        if (chatSnapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Something went wrong')),
          );
        }

        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final chatData = chatSnapshot.data?.data() as Map<String, dynamic>?;
        isSessionEnded = (chatData?['status'] == 'ended');

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(90),
            child:AppBar(
              flexibleSpace: Image.asset(
                "assets/img_17.png", // صورة الخلفية
                fit: BoxFit.cover,
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () async{
                    if (widget.currentUserRole == 'tutor') {
                    Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => ChatHistoryPage()),  // Navigate to Tutor's homepage
                    );
                    } else if (widget.currentUserRole == 'student') {
                    Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => RequestsPage()),  // Navigate to Student's homepage
                    );
                    };
                },
              ),
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: getImageProvider(
                      widget.currentUserRole == 'tutor' ? widget.studentAvatar : widget.tutorAvatar,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    widget.studentName,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.transparent,
              toolbarHeight: 90,
              actions: [
                // إضافة رمز الملف
                IconButton(
                  icon: const Icon(Icons.file_copy, color: Colors.white),
                  onPressed: _goToQuestionsPage,  // الانتقال إلى صفحة الأسئلة
                ),
                if (widget.currentUserRole == 'tutor' && !isSessionEnded)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _showEndSessionDialog,
                  ),
              ],
            ),

          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .doc(widget.chatId)
                      .collection('messages')
                      .orderBy('timestamp')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final messages = snapshot.data!.docs;

                    return ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final text = message['text'];
                        final sender = message['sender'];
                        final isUser = sender == widget.currentUserRole;

                        final avatarPath = sender == 'student'
                            ? widget.studentAvatar
                            : widget.tutorAvatar;

                        return Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Row(
                            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                            children: [
                              if (!isUser)
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: getImageProvider(avatarPath),
                                ),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isUser ? Colors.blue[300] : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  text,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              if (isUser)
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: getImageProvider(avatarPath),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              if (!isSessionEnded)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: "Type a message...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        color: Colors.blue,
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "This session has ended.",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
  void _goToQuestionsPage() async {
    try {
      // 1. احصل على مستند الشات باستخدام chatId
      final chatDoc = await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)  // استخدم الـ chatId هنا
          .get();

      if (!chatDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat not found.')),
        );
        return;
      }

      // 2. استخرج الأسئلة من مستند الشات
      final raw = chatDoc.data()?['questions'];  // افترض أن الأسئلة مخزنة في الحقل 'questions'
      final questions = List<Map<String, dynamic>>.from(raw ?? []);

      if (questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No questions found in this chat.')),
        );
        return;
      }

      // 3. انتقل لصفحة عرض الأسئلة
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionsViewPage(
            questions: questions,
            studentName: widget.studentName,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error fetching questions: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Failed to fetch questions.')),
      );
    }
  }


}