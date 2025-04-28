import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gat_helper_app/features/auth/views/request_link_page.dart';
import 'package:gat_helper_app/features/auth/views/tutor_request_details_page.dart';
import 'package:gat_helper_app/features/common/edit_profile_page.dart';
import 'package:gat_helper_app/features/auth/views/tutor_chat_history_page.dart';
import 'package:gat_helper_app/features/common/start_page.dart';

class TutorHomepage extends StatefulWidget {
  @override
  _TutorHomepageState createState() => _TutorHomepageState();
}

class _TutorHomepageState extends State<TutorHomepage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String tutorName = '';
  String? tutorAvatar;

  @override
  void initState() {
    super.initState();
    fetchTutorName();
    fetchTutorAvatar();
  }

  Future<void> fetchTutorName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setState(() {
        tutorName = doc.data()?['name'] ?? '';
      });
    }
  }

  Future<void> fetchTutorAvatar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setState(() {
        tutorAvatar = doc.data()?['avatar'];
      });
    }
  }
  Future<void> fetchStudentAvatar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setState(() {
        tutorAvatar = doc.data()?['avatar'];
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(context),
      body: Stack(
        children: [
          _buildHeader(screenWidth),
          Positioned.fill(
            top: 405,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('helpRequests')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No help requests yet.'));
                  }

                  final currentUid = FirebaseAuth.instance.currentUser?.uid;
                  final requests = snapshot.data!.docs;

                  // Extract the statuses using the helper function
                  bool hasPendingRequest = false;

                  for (var request in snapshot.data!.docs) {
                    final requestData = request.data() as Map<String, dynamic>;
                    if (requestData['status'] == 'pending' ) {
                      hasPendingRequest = true;
                      break; // Stop as soon as we find a pending request
                    }
                  }

                  // Show the "No help requests" message if no pending requests are found
                  if (!hasPendingRequest) {
                    return Center(
                      child: Text(
                        'No help requests for now...',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      final requestData = request.data() as Map<String, dynamic>;

                      if (requestData['acceptedTutor'] != null) {
                        // إذا مقبول من توتور ثاني -> لا تعرضه
                        if (requestData['acceptedTutor'] != currentUid) return SizedBox.shrink();

                        // إذا مقبول من نفس التوتور وكان النوع "Chat" -> برضو لا تعرضه
                        if (requestData['method'] == 'Chat') return SizedBox.shrink();
                        if (requestData['method'] == 'Virtual') return SizedBox.shrink();
                        // if (requestData['status'] == 'accepted') return SizedBox.shrink();

                      }


                      final rejectedTutors = List<String>.from(requestData['rejectedTutors'] ?? []);
                      if (rejectedTutors.contains(currentUid)) {
                        return SizedBox.shrink();
                      }

                      final email = requestData['studentEmail'] ?? 'Unknown';
                      final method = requestData['method'] ?? 'Chat';
                      final studentName = requestData['studentName'] ?? email.split('@')[0];
                      final avatarUrl = requestData['avatar'];
                      final questionsRaw = requestData['selectedQuestions'] as List<dynamic>? ?? [];

                      final color = method == 'Chat' ? Colors.yellow.shade100 : Colors.blue.shade100;

                      final formattedQuestions = questionsRaw.map<Map<String, dynamic>>((q) {
                        if (q is Map<String, dynamic>) {
                          final correct = q['correct_answer'] ?? '';
                          final wrongs = List<String>.from(q['wrong_answers'] ?? []);
                          final allOptions = [...wrongs];
                          if (!allOptions.contains(correct)) {
                            allOptions.add(correct);
                          }
                          return {
                            'question': q['question'],
                            'options': allOptions,
                            'correct_answer': correct,
                            'image': q['image'],
                            'passage': q['passage'],
                          };
                        } else {
                          return {
                            'question': 'Unknown question',
                            'options': [],
                            'correct_answer': '',
                            'image': null,
                            'passage': null,
                          };
                        }
                      }).toList();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.white,
                              backgroundImage: avatarUrl != null && avatarUrl.toString().isNotEmpty
                                  ? AssetImage(avatarUrl)
                                  : AssetImage('assets/default_avatar.jpg'),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.04),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      studentName,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.insert_drive_file, size: 16),
                                        SizedBox(width: 4),
                                        Text('${formattedQuestions.length}'),
                                        SizedBox(width: 16),
                                        Icon(Icons.chat, size: 16),
                                        SizedBox(width: 4),
                                        Text(method),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RequestDetailsPage5(
                                      studentName: studentName,
                                      preferredMethod: method,
                                      questions: formattedQuestions,
                                      requestId: request.id,
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(Icons.arrow_forward, size: 30, color: Colors.black87),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Image.asset(
            "assets/img_23.png",
            fit: BoxFit.cover,
            height: 380,
            width: screenWidth,
          ),
        ),
        Positioned(
          top: 20,
          left: 10,
          child: IconButton(
            icon: Icon(Icons.menu, color: Colors.black, size: 30),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ),
        Positioned(
          top: 100,
          left: 0,
          right: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                backgroundImage: tutorAvatar != null && tutorAvatar!.isNotEmpty
                    ? AssetImage(tutorAvatar!)
                    : AssetImage('assets/default_avatar.png'),
              ),
              SizedBox(height: 10),
              Text(
                'Welcome,',
                style: TextStyle(color: Colors.white70, fontSize: 20),
              ),
              Text(
                tutorName.isNotEmpty ? tutorName : 'Loading...',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 90),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,  // Align to the left
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),  // Adjust this value to move it to the right
                    child: Text(
                      'Student Requests',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200,
            width: 500,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF284379),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: tutorAvatar != null && tutorAvatar!.isNotEmpty
                        ? AssetImage(tutorAvatar!)// If user and avatar are not null
                        : AssetImage('assets/default_avatar.jpg'), // Provide a default image if null
                    // Dynamic Avatar
                  ),
                  const SizedBox(height: 10),
                  Text(
                    tutorName.isNotEmpty ? tutorName : 'Loading...',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),

                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.edit, color: Colors.black),
            title: Text('Edit your profile'),
            onTap: () async {
              final updatedUser = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(role: 'tutor', initialData: {}),
                ),
              );

              if (updatedUser != null) {
                fetchTutorName();
                fetchTutorAvatar();
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.chat),
            title: Text('Chat History'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ChatHistoryPage()));
            },
          ),
          ListTile(
            leading: Icon(Icons.contact_mail, color: Colors.black),
            title: Text('Contact Us'),
            onTap: () => _showContactUsDialog(context),
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Log Out'),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => StartPage()));
            },
          ),
        ],
      ),
    );
  }

  void _showContactUsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Get in touch with us", textAlign: TextAlign.center),
        content: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(color: Colors.black),
            children: [
              TextSpan(text: "If you have any questions, feel free to contact us at:\n\n"),
              TextSpan(
                text: "GAThelper@gmail.com\n\n",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              TextSpan(text: "We're here to assist you!"),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text("Close"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  List<String> extractStatuses(List<QueryDocumentSnapshot> requests) {
    List<String> statuses = [];

    for (var request in requests) {
      final requestData = request.data() as Map<String, dynamic>;
      // Check if the 'status' field exists and is not null
      if (requestData.containsKey('status')) {
        statuses.add(requestData['status']);
      }
    }

    return statuses;
  }

}