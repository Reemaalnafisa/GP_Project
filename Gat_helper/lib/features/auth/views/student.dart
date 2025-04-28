import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gat_helper_app/core/services/auth_service.dart';
import 'package:gat_helper_app/features/auth/views/AR_dashboard.dart';
import 'package:gat_helper_app/features/auth/views/All_req_page.dart';
import 'package:gat_helper_app/features/auth/views/GG_waiting.dart';
import 'package:gat_helper_app/features/auth/views/find_game_page.dart';
import 'package:gat_helper_app/features/auth/views/self_game_config.dart';
import 'package:gat_helper_app/features/common/start_page.dart';
import 'package:gat_helper_app/features/auth/views/DashBoard.dart'; // استيراد Dashboard لاستخدام الكلاس
import '../../../core/services/Parent_Service.dart';
import '../../../model/user_model.dart';
import '../../common/edit_profile_page.dart';

import 'package:gat_helper_app/features/auth/views/DashBoard.dart';

import '../../common/login_page.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => StudentHome();
}


class StudentHome extends State<StudentHomePage> {
  double totalUsageTime = 0.0; // متغير لتخزين عدد الساعات
  String? userEmail; // البريد الإلكتروني للمستخدم
  bool isLoading = true; // حالة التحميل
  UserModel? user;
  int totalCorrectAnswers = 0; // تعريف المتغير
  bool isLoadingAnswers = true; // حالة التحميل
  int totalQues=0;

  @override
  void initState() {
    AuthService().getUserDetails().then((val){
      setState(() {
        user = val;
      });
    });
    // TODO: implement initState
    super.initState();
    _loadUsageTime(); // تحميل عدد الساعات
    _loadCorrectAnswers(); // استدعاء حساب الإجابات الصحيحة عند تحميل الشاشة


  }

  /// دالة لجلب عدد الساعات
  Future<void> _loadUsageTime() async {
    try {
      final userEmail = await StudentStatisticsService.getCurrentUserEmail();
      if (userEmail != null) {
        final statisticsService = StudentStatisticsService(userEmail);
        final hours = await statisticsService.calculateTotalUsageTime();
        setState(() {
          totalUsageTime = hours >= 0 ? hours : 0.0;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        totalUsageTime = 0.0;
        isLoading = false;
      });
    }
  }
  Future<void> _loadCorrectAnswers() async {
    try {
      final userEmail = await StudentStatisticsService.getCurrentUserEmail();
      if (userEmail != null) {
        final answerStatisticsService = StudentAnswerStatisticsService(userEmail);
        final correctAnswers = await answerStatisticsService.calculateTotalCorrectAnswers();
        final numberofQuestions = await answerStatisticsService.calculateTotalQuestions();
        setState(() {
          totalCorrectAnswers = correctAnswers;
          totalQues= numberofQuestions;
          isLoadingAnswers = false;
        });
      }
    } catch (e) {
      setState(() {
        totalCorrectAnswers = 0;
        totalQues= 0;
        isLoadingAnswers = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 200,
              width: 500,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFF284379),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundImage: user != null && user!.avatar != null
                          ? AssetImage(user!.avatar!) // If user and avatar are not null
                          : AssetImage('assets/default_avatar.jpg'), // Provide a default image if null
                      // Dynamic Avatar
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user?.name ?? '',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.black),
              title: const Text('Edit your profile'),
              onTap: () async {
                // When navigating to the EditProfilePage
                final updatedUser = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) =>
                      EditProfilePage(role: 'student', initialData: {},)),
                );

                if (updatedUser != null) {
                  setState(() {
                    // Update the local user instance so the UI refreshes
                    user = updatedUser;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.messenger_outline, color: Colors.black),
              title: const Text('Requests'),
              onTap: () {
                Navigator.push(
                  context,
                 MaterialPageRoute(
                    builder: (context) => const RequestsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_mail, color: Colors.black),
              title: const Text('Contact Us'),
              onTap: () {
                _showContactUsDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Log Out'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(userRole: 'student',),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/blue_background.png",
              fit: BoxFit.cover,
              height: 380,
              width: screenWidth,
            ),
          ),
          Positioned(
            top: 20,
            left: 10,
            child: Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black, size: 30),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
          ),
          Positioned(
            top: 30,
            right: 12,
            child: CircleAvatar(
              radius: 25,
              backgroundImage: user != null && user!.avatar != null
                  ? AssetImage(user!.avatar!) // If user and avatar are not null
                  : AssetImage('assets/default_avatar.jpg'), // Provide a default image if null
              // Dynamic Avatar
            ),
          ),

          Column(
              children: [
                _buildProfileHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),
                          const Text(
                            "Select Your Game",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8), // Spacing between text and images
                          // Row with two images next to each other
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => GroupGamePage2()),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(90),
                                  child: Ink.image(
                                    image: AssetImage('assets/img_27.png'),
                                    height: 230,
                                    width: 170,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => SelfgameconfigWidget()),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(90), // تغيير الرقم لضبط مقدار الانحناء
                                  child: Ink.image(
                                    image: AssetImage('assets/img_26.png'),
                                    height: 230,
                                    width: 170,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "My Parents",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildParentConnectionRequests(),

                        ],
                      ),
                    ),
                  ),
                ),

              ]
          ),
        ],
      ),
    );

  }

  // الدالة الخاصة بعرض طلبات الاتصال للطالب من Firestore
  Widget _buildParentConnectionRequests() {
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return StreamBuilder<QuerySnapshot>(
      stream: ParentConnectionService().connectionRequestsStreamForChild(childEmail: user!.email),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var requests = snapshot.data!.docs;
        if (requests.isEmpty) {
          return const Center(
            child: Text(
              "No connection requests",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          );
        }
        // Display requests in a horizontal list
        return SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var request = requests[index];
              String parentId = request['parentId'] ?? ''; // Ensure parentId is present

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(parentId).get(),
                builder: (context, parentSnapshot) {
                  if (parentSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator()); // Show loading indicator
                  }
                  if (!parentSnapshot.hasData || parentSnapshot.data == null || !parentSnapshot.data!.exists) {
                    return _buildParentCard(
                      request['parentName'] ?? 'Unknown',
                      request['parentEmail'] ?? 'Unknown',
                      request['status'] ?? 'Pending',
                      'assets/default_avatar.png', // Default avatar if no data
                          (newStatus) async {
                        await ParentConnectionService()
                            .updateConnectionRequestStatus(
                          requestId: request.id,
                          newStatus: newStatus.toLowerCase() == 'approved'
                              ? 'approved'
                              : 'declined',
                        );
                      },
                    );
                  }

                  var parentData = parentSnapshot.data!;
                  String avatarUrl = parentData['avatar'] ?? 'assets/default_avatar.png'; // Get the avatar URL or default

                  return _buildParentCard(
                    request['parentName'] ?? 'Unknown',
                    request['parentEmail'] ?? 'Unknown',
                    request['status'] ?? 'Pending',
                    avatarUrl, // Use the avatar URL from parent document
                        (newStatus) async {
                      await ParentConnectionService()
                          .updateConnectionRequestStatus(
                        requestId: request.id,
                        newStatus: newStatus.toLowerCase() == 'approved'
                            ? 'approved'
                            : 'declined',
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showContactUsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Get in touch with us", textAlign: TextAlign.center),
          content: RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: "If you have any questions, feel free to contact us at:\n\n",
                  style: TextStyle(color: Colors.black),
                ),
                TextSpan(
                  text: "GAThelper@gmail.com\n\n",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const TextSpan(
                  text: "We're here to assist you!",
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileHeader() {

    return Container(
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [



          Column(
            children: [
              const SizedBox(height: 80),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Your Progress",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.keyboard_arrow_right,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Dashboard()), // استبدل NewPage بصفحتك
                      );
                    },
                  ),
                ],
              ),
              Align(
                alignment: Alignment.center,
                child:_profileDashboard(),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _profileDashboard() {
    return Center(
      child: Container(
        width: 350,  // زيادة العرض
        height: 170, // زيادة الارتفاع لاستيعاب التاريخ
        decoration: BoxDecoration(
          color: Colors.orange.shade200.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // موضع الظل
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 10,
              left: 10,
              child: Text(
                "January - December 2025",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Positioned(
              top: 40,
              left: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Usage Time
                  Row(
                    children: [
                      Icon(Icons.access_time_outlined, color: Colors.white, size: 40),
                      SizedBox(width: 10),
                      RichText(
                        text: TextSpan(
                          text: isLoading
                              ? 'Loading...\n' // عرض رسالة "Loading" أثناء التحميل
                              : totalUsageTime > 0
                              ? '${totalUsageTime.toStringAsFixed(2)} hours\n' // عرض عدد الساعات المحملة
                              : 'No data available\n', // في حالة عدم وجود بيانات
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Usage time',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Correct Answers
                  Row(
                    children: [
                      Icon(Icons.check_box_rounded, color: Colors.white, size: 40),
                      SizedBox(width: 10),
                      RichText(
                        text: TextSpan(
                          text: isLoadingAnswers
                              ? 'Loading...\n' // عرض رسالة "Loading" أثناء التحميل
                              : '$totalCorrectAnswers \\ $totalQues\n', // عرض عدد الإجابات الصحيحة مع الشرطة
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: ' Correct answers',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      )

                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 30,
              right: 20,
              child: QuizPassedWidget_profile(), // استدعاء المكون الجديد هنا
            ),
          ],
        ),
      ),
    );
  }
  /*Widget build1(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity, // ✅ جعل العرض غير محدد
          child: SingleChildScrollView( // ✅ في حال كانت العناصر كثيرة
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: parents
                  .map((parent) => _buildParentCard(
                parent["name"]!,
                parent["email"]!,
                parent["status"]!,
                parent["gender"]!,
                    (newStatus) {
                  setState(() {
                    if (newStatus == "Rejected") {
                      parents.removeWhere((p) => p["name"] == parent["name"]);
                    } else {
                      parent["status"] = newStatus;
                    }
                  });
                },
              ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }*/

  Widget _buildParentCard(
      String name,
      String email,
      String status,
      String avatar,
      Function(String) onStatusChanged,
      ) {
    bool isApproved = status.toLowerCase() == 'approved';

    return Container(
      margin: const EdgeInsets.only(top: 6, left: 15),
      width: 170,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Avatar Image
          Positioned(
            top: 10,
            left: isApproved ? 53 : 8,  // Adjust position based on approval status
            child: CircleAvatar(
              radius: isApproved ? 30 : 20,
              backgroundColor: Colors.white70,
              backgroundImage: AssetImage(avatar),
            ),
          ),
          if (status.isNotEmpty)
            Positioned(
              top: 8,
              right: 8,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 30),
                opacity: 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: status.toLowerCase() == 'approved'
                        ? Colors.green
                        : status.toLowerCase() == 'declined'
                        ? Colors.red
                        : Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          // Name, Email, and Avatar Adjustment when approved
          Positioned.fill(
            child: Column(
              mainAxisAlignment: isApproved
                  ? MainAxisAlignment.center  // Center the content when approved
                  : MainAxisAlignment.start,  // Align to top when not approved
              crossAxisAlignment: isApproved? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                if (isApproved) const SizedBox(height: 50), // Keep space when not approved
                if (!isApproved) const SizedBox(height: 50), // Keep space when not approved

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    name,
                    textAlign: isApproved? TextAlign.center: TextAlign.left,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    email,
                    textAlign: isApproved? TextAlign.center: TextAlign.left,
                    style:  TextStyle(
                      fontSize: 12,
                      fontWeight: isApproved ? FontWeight.bold: FontWeight.normal,
                      color: Colors.black45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Display buttons if the status is "pending"
          if (status.toLowerCase() == 'pending')
            Positioned(
              bottom: -10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.check_outlined, color: Colors.green),
                    onPressed: () {
                      onStatusChanged('Approved');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_outlined, color: Colors.red),
                    onPressed: () {
                      onStatusChanged('Rejected');
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }


}