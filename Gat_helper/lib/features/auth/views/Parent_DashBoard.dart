import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gat_helper_app/const/data/line_chart_data.dart';
import 'package:gat_helper_app/features/auth/views/BarGraphCard.dart';
import 'package:gat_helper_app/features/auth/views/student.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class ParentDashboard extends StatefulWidget {
  final String childEmail; // بريد الطفل
  final String childName;  // اسم الطفل

  // Constructor لاستقبال القيم
  ParentDashboard({required this.childEmail, required this.childName});

  @override
  _ParentDashboardState createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  final LineData data = LineData(); // LineData instance for accessing months
  int selectedMonthIndex = 0; // Declare and initialize selectedMonthIndex


  /// Method to calculate weekly activity hours
  Future<Map<int, double>> calculateActiveHours() async {
    final Map<int, double> activityData = {
      for (int i = 0; i < 7; i++) i: 0.0, // تهيئة البيانات للأسبوع (الأحد إلى السبت)
    };

    final today = DateTime.now(); // تاريخ اليوم الحالي
    final currentDay = today.weekday % 7; // اليوم الحالي يبدأ من الأحد (0) إلى السبت (6)

    try {
      final selfGamesSnapshot = await FirebaseFirestore.instance
          .collection('SelfGames')
          .where('student_email', isEqualTo: widget.childEmail)
          .get();

      for (var doc in selfGamesSnapshot.docs) {
        final data = doc.data();
        final startTime = (data['start_time'] as Timestamp?)?.toDate();
        final endTime = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

        if (startTime != null && endTime != null) {
          if (endTime.isAfter(startTime)) {
            final durationInHours = endTime.difference(startTime).inSeconds / 3600.0;

            // ✅ التحقق من صحة المدة
            if (durationInHours > 24 || durationInHours < 0) {
              print("⚠️ Skipping invalid duration: $durationInHours hours for day ${startTime.weekday % 7}");
              continue;
            }

            // ✅ تجاهل الأيام المستقبلية
            if (startTime.isAfter(today) || (startTime.weekday % 7) > currentDay) {
              print("⚠️ Skipping future date: ${startTime.toLocal()}");
              continue;
            }

            // حساب اليوم ليبدأ من الأحد
            final day = (startTime.weekday % 7); // الأحد = 0، السبت = 6
            activityData[day] = (activityData[day] ?? 0) + durationInHours;
          }
        }
      }

      final groupGamesSnapshot = await FirebaseFirestore.instance
          .collectionGroup('Players')
          .where('player_email', isEqualTo: widget.childEmail)
          .get();

      for (var doc in groupGamesSnapshot.docs) {
        final parentGameDoc = await doc.reference.parent.parent!.get();
        final parentData = parentGameDoc.data();
        final startTime = (parentData?['start_time'] as Timestamp?)?.toDate();
        final duration = (parentData?['game_duration'] ?? 0) as int;

        if (startTime != null) {
          final durationInHours = duration / 3600.0;

          // ✅ التحقق من صحة المدة
          if (durationInHours > 24 || durationInHours < 0) {
            print("⚠️ Skipping invalid duration: $durationInHours hours for day ${startTime.weekday % 7}");
            continue;
          }

          // ✅ تجاهل الأيام المستقبلية
          if (startTime.isAfter(today) || (startTime.weekday % 7) > currentDay) {
            print("⚠️ Skipping future date: ${startTime.toLocal()}");
            continue;
          }

          // حساب اليوم ليبدأ من الأحد
          final day = (startTime.weekday % 7); // الأحد = 0، السبت = 6
          activityData[day] = (activityData[day] ?? 0) + durationInHours;
        }
      }

      activityData.forEach((day, hours) {
        print("Day $day: $hours hours");
      });

    } catch (e) {
      print("Error calculating active hours: $e");
    }

    return activityData;
  }

  Future<Map<int, Map<String, double>>> calculateMonthlyActiveHours(String studentEmail) async {
    final Map<int, Map<String, double>> monthlyActivityData = {};

    try {
      // 1. SelfGames
      final selfGamesSnapshot = await FirebaseFirestore.instance
          .collection('SelfGames')
          .where('student_email', isEqualTo: studentEmail)
          .get();

      for (var doc in selfGamesSnapshot.docs) {
        final data = doc.data();
        final Timestamp? startTimestamp = data['start_time'] as Timestamp?;
        final int durationSeconds = (data['game_duration'] ?? 0) as int;
        final String type = (data['question_type'] ?? data['type'] ?? 'Quantitative').toString();

        if (startTimestamp != null) {
          final int month = startTimestamp.toDate().month;
          final double durationHours = durationSeconds / 3600.0;

          // تهيئة الشهر إذا مش موجود
          monthlyActivityData[month] ??= {'verbalHours': 0.0, 'quantitativeHours': 0.0};

          if (type == 'Verbal') {
            monthlyActivityData[month]!['verbalHours'] =
                (monthlyActivityData[month]!['verbalHours'] ?? 0) + durationHours;
          } else if (type == 'Quantitative') {
            monthlyActivityData[month]!['quantitativeHours'] =
                (monthlyActivityData[month]!['quantitativeHours'] ?? 0) + durationHours;
          } else if (type == 'Both') {
            // تحسب مدة اللعبة في كلا النوعين
            monthlyActivityData[month]!['verbalHours'] =
                (monthlyActivityData[month]!['verbalHours'] ?? 0) + durationHours;
            monthlyActivityData[month]!['quantitativeHours'] =
                (monthlyActivityData[month]!['quantitativeHours'] ?? 0) + durationHours;
          }
        }
      }

      // 2. GroupGames
      final groupPlayersSnapshot = await FirebaseFirestore.instance
          .collectionGroup('Players')
          .where('player_email', isEqualTo: studentEmail)
          .get();

      for (var doc in groupPlayersSnapshot.docs) {
        // تجيب بيانات اللعبة الأم (GroupGame)
        final parentGameDoc = await doc.reference.parent.parent!.get();
        final parentData = parentGameDoc.data();

        if (parentData != null) {
          final Timestamp? startTimestamp = parentData['start_time'] as Timestamp?;
          final int durationSeconds = (parentData['game_duration'] ?? 0) as int;
          final String type = (parentData['question_type'] ?? parentData['type'] ?? 'Quantitative').toString();

          if (startTimestamp != null) {
            final int month = startTimestamp.toDate().month;
            final double durationHours = durationSeconds / 3600.0;

            // تهيئة الشهر إذا مش موجود
            monthlyActivityData[month] ??= {'verbalHours': 0.0, 'quantitativeHours': 0.0};

            if (type == 'Verbal') {
              monthlyActivityData[month]!['verbalHours'] =
                  (monthlyActivityData[month]!['verbalHours'] ?? 0) + durationHours;
            } else if (type == 'Quantitative') {
              monthlyActivityData[month]!['quantitativeHours'] =
                  (monthlyActivityData[month]!['quantitativeHours'] ?? 0) + durationHours;
            } else if (type == 'Both') {
              monthlyActivityData[month]!['verbalHours'] =
                  (monthlyActivityData[month]!['verbalHours'] ?? 0) + durationHours;
              monthlyActivityData[month]!['quantitativeHours'] =
                  (monthlyActivityData[month]!['quantitativeHours'] ?? 0) + durationHours;
            }
          }
        }
      }
      for (int i = 1; i <= 12; i++) {
        monthlyActivityData[i] ??= {
          'verbalHours': 0.0,
          'quantitativeHours': 0.0
        };
      }

    } catch (e) {
      print("Error calculating activity: $e");
    }

    return monthlyActivityData;
  }

  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      DashboardHeader(),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          SizedBox(width: 20),
                          LastGameWidget(childEmail: widget.childEmail,),
                          SizedBox(width: 15),
                          QuizPassedWidget(childEmail: widget.childEmail,),
                        ],
                      ),
                      BarGraphCard(fetchActivityData: calculateActiveHours),
                      MonthlyActivityChart(
                        fetchMonthlyData: () => calculateMonthlyActiveHours(widget.childEmail),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          DashboardBottom(
            screenWidth: MediaQuery.of(context).size.width,
            screenHeight: MediaQuery.of(context).size.height,
          ),
        ],
      ),
    );
  }
}
class DashboardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          'assets/rectangle1.png',
          width: double.infinity,
          height: 150, // ✅ تقليل الارتفاع
          fit: BoxFit.cover,
        ),
        Positioned(
          top: 33, // ✅ تحريك الأيقونة للأعلى قليلاً
          left: 20,
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        Positioned(
          top: 88, // ✅ تحريك النص للأعلى قليلاً
          left: 28,
          child: Text(
            'DashBoard',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Montserrat',
              fontSize: 25, // ✅ تصغير حجم الخط
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}


/// ✅ **Widget: Quiz Passed Progress Indicator**
/// ✅ **Widget: Quiz Passed Progress Indicator**
class QuizPassedWidget extends StatefulWidget {
  final String childEmail; // البريد الإلكتروني للطفل

  QuizPassedWidget({required this.childEmail});

  @override
  _QuizPassedWidgetState createState() => _QuizPassedWidgetState();
}

class _QuizPassedWidgetState extends State<QuizPassedWidget> {
  int passedQuizzes = 0; // عدد الاختبارات الناجحة
  int totalQuizzes = 0; // إجمالي عدد الاختبارات
  double percentage = 0.0; // النسبة المئوية للاختبارات الناجحة

  @override
  void initState() {
    super.initState();
    fetchQuizData(); // استدعاء الدالة لجلب بيانات الاختبارات
  }

  /// جلب بيانات الاختبارات
  Future<void> fetchQuizData() async {
    if (widget.childEmail.isEmpty) return;

    int passedCount = 0;
    int totalCount = 0;

    try {
      // جلب بيانات الألعاب الفردية
      final selfGamesSnapshot = await FirebaseFirestore.instance
          .collection('SelfGames')
          .where('student_email', isEqualTo: widget.childEmail)
          .get();

      for (var doc in selfGamesSnapshot.docs) {
        totalCount++;
        final data = doc.data();
        final completionPercentage = data['completionPercentage'] ?? 0;

        if (completionPercentage >= 70) {
          passedCount++;
        }
      }

      // جلب بيانات الألعاب الجماعية
      final groupGamesSnapshot = await FirebaseFirestore.instance
          .collectionGroup('Players')
          .where('player_email', isEqualTo: widget.childEmail)
          .get();

      for (var doc in groupGamesSnapshot.docs) {
        totalCount++;
        final data = doc.data();
        final completionPercentage = data['completionPercentage'] ?? 0;

        if (completionPercentage >= 70) {
          passedCount++;
        }
      }

      setState(() {
        passedQuizzes = passedCount;
        totalQuizzes = totalCount;
        percentage = totalCount > 0 ? (passedCount / totalCount) * 100 : 0.0;
      });
    } catch (e) {
      print('خطأ أثناء جلب بيانات الاختبارات: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // النص فوق الدائرة
          Text(
            "Passed quizzes",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 10),
          // دائرة التقدم
          Container(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // الخلفية الرمادية للدائرة
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[300]!),
                  ),
                ),
                // الدائرة الزرقاء للتقدم
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 10,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
                // النسبة المئوية داخل الدائرة
                Text(
                  "${percentage.toStringAsFixed(1)}%",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          // النص تحت الدائرة
          Text(
            "$passedQuizzes / $totalQuizzes Quizzes",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}


/// ✅ **Widget: Performance Graph**
class PerformanceGraphWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      height: 140,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "January",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text("Verbal", style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(width: 5),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text("Quantitativ",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}



/// ✅ **Widget: Last Game Section**

class LastGameWidget extends StatefulWidget {
  final String childEmail; // بريد الطفل

  LastGameWidget({required this.childEmail}); // Constructor لاستقبال البريد الإلكتروني للطفل

  @override
  _LastGameWidgetState createState() => _LastGameWidgetState();
}

class _LastGameWidgetState extends State<LastGameWidget> {
  bool isGroupSelected = false; // Toggle between Self and Group
  Map<String, dynamic>? selfGameData;
  Map<String, dynamic>? groupGameData;

  @override
  void initState() {
    super.initState();
    fetchLastSelfGame(); // استدعاء الدالة لجلب بيانات الألعاب الفردية
    fetchLastGroupGame(); // استدعاء الدالة لجلب بيانات الألعاب الجماعية
  }

  Future<void> fetchLastSelfGame() async {
    if (widget.childEmail.isEmpty) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('SelfGames')
          .where('student_email', isEqualTo: widget.childEmail)
          .orderBy('start_time', descending: true)
          .limit(1)
          .get();

      print("SelfGames: ${querySnapshot.size} records found");

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          selfGameData = querySnapshot.docs.first.data();
        });
      }
    } catch (e) {
      print('Error fetching Self game data: $e');
    }
  }

  Future<void> fetchLastGroupGame() async {
    if (widget.childEmail.isEmpty) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collectionGroup('Players')
          .where('player_email', isEqualTo: widget.childEmail)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final playerDoc = querySnapshot.docs.first;
        final parentGroupGameDoc = await playerDoc.reference.parent.parent!.get();

        if (parentGroupGameDoc.exists) {
          setState(() {
            groupGameData = {
              ...parentGroupGameDoc.data()!,
              'playerDetails': playerDoc.data(),
            };
          });
        }
      }
    } catch (e) {
      print('Error fetching Group game data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Building LastGameWidget with childEmail: ${widget.childEmail}");
    print("SelfGameData: $selfGameData");
    print("GroupGameData: $groupGameData");

    final currentData = isGroupSelected ? groupGameData : selfGameData;

    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Last Game",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isGroupSelected = false;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: !isGroupSelected ? Colors.cyan.shade100 : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.teal, width: 1),
                  ),
                  child: Text(
                    "Self",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isGroupSelected = true;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isGroupSelected ? Colors.orange.shade100 : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange, width: 1),
                  ),
                  child: Text(
                    "Group",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          currentData != null
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Score: ${isGroupSelected ? currentData?['playerDetails']?['score']?.toString() ?? 'N/A' : currentData?['score']?.toString() ?? 'N/A'}",
                style: TextStyle(fontSize: 14),
              ),
              Text(
                "Date: ${isGroupSelected ? (currentData?['playerDetails']?['timestamp'] != null
                    ? DateTime.fromMillisecondsSinceEpoch(
                    (currentData!['playerDetails']['timestamp'] as Timestamp)
                        .millisecondsSinceEpoch)
                    .toLocal()
                    .toString()
                    .split(' ')[0]
                    : 'N/A') : (currentData?['start_time'] != null
                    ? DateTime.fromMillisecondsSinceEpoch(
                    (currentData!['start_time'] as Timestamp)
                        .millisecondsSinceEpoch)
                    .toLocal()
                    .toString()
                    .split(' ')[0]
                    : 'N/A')}",
                style: TextStyle(fontSize: 14),
              ),
            ],
          )
              : Center(
            child: Text(
              "No game yet",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardBottom extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;

  const DashboardBottom({required this.screenWidth, required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: -screenHeight * 0.12,  // رفع الصورة قليلاً عن أسفل الشاشة
          left: -screenWidth * 0.02,  // ضبط المسافة من اليسار
          right: -screenWidth * 0.03,  // تعيين اليمين لتكون الصورة عند اليمين تمامًا
          child: Image.asset(
            'assets/YellowNew.png',
            fit: BoxFit.cover,  // ملاءمة الصورة بشكل مناسب
            width: screenWidth * 1.1,  // جعل العرض يتناسب مع حجم الشاشة
            height: screenHeight * 0.2,  // تعديل الارتفاع ليتناسب مع المساحة
          ),
        ),


        Positioned(
          bottom: -screenHeight * 0.13,  // رفع الصورة قليلاً عن أسفل الشاشة
          left: -screenWidth * 0.05,  // ضبط المسافة من اليسار
          right: -screenWidth * 0.05,  // ضبط المسافة من اليمين
          child: Image.asset(
            'assets/BlueNew.png',
            fit: BoxFit.cover,  // ملاءمة الصورة بشكل مناسب
            width: screenWidth * 1.1,  // جعل العرض يتناسب مع حجم الشاشة
            height: screenHeight * 0.2,  // تعديل الارتفاع ليتناسب مع المساحة
          ),
        ),


        // Math Image

      ],
    );
  }
}

/// ✅ Added: BarGraphCard widget class
class BarGraphCard extends StatefulWidget {
  final Future<Map<int, double>> Function() fetchActivityData;

  BarGraphCard({required this.fetchActivityData});

  @override
  _BarGraphCardState createState() => _BarGraphCardState();
}

class _BarGraphCardState extends State<BarGraphCard> {
  Map<int, double> activityData = {};

  @override
  void initState() {
    super.initState();
    fetchActivityData();
  }

  Future<void> fetchActivityData() async {
    final data = await widget.fetchActivityData();
    setState(() {
      activityData = data;
    });
  }

  Color getBarColor(double hours) {
    if (hours >= 5) {
      return Colors.green;
    } else if (hours >= 2) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ترتيب الأيام ليبدأ من الأحد
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Container(
      height: 180,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Weekly Activity",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxHeight = constraints.maxHeight; // أقصى ارتفاع للمربع
                final barMaxHeight = maxHeight * 0.6; // تحديد 60% كحد أقصى للأعمدة

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(7, (index) {
                    final hours = activityData[index] ?? 0.0;
                    final barHeight = (hours / 10) * barMaxHeight; // ضبط ارتفاع العمود

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        hours > 0
                            ? Container(
                          width: 20,
                          height: barHeight.clamp(4, barMaxHeight), // لا يتجاوز العمود الحد الأقصى
                          decoration: BoxDecoration(
                            color: getBarColor(hours),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        )
                            : SizedBox(height: 0), // إخفاء العمود إذا كان صفر
                        SizedBox(height: 4),
                        Text(
                          days[index],
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


/// ✅ كلاس مخصص لعرض الرسم البياني للنشاط الشهري

class MonthlyActivityChart extends StatefulWidget {
  final Future<Map<int, Map<String, double>>> Function() fetchMonthlyData;

  MonthlyActivityChart({required this.fetchMonthlyData});

  @override
  _MonthlyActivityChartState createState() => _MonthlyActivityChartState();
}

class _MonthlyActivityChartState extends State<MonthlyActivityChart> {
  int currentMonth = DateTime.now().month;
  Map<int, Map<String, double>> monthlyData = {};

  final List<String> monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    fetchMonthlyData();
  }

  Future<void> fetchMonthlyData() async {
    final data = await widget.fetchMonthlyData();
    setState(() {
      monthlyData = data;
    });
  }

  void _goToPreviousMonth() {
    setState(() {
      currentMonth = currentMonth == 1 ? 12 : currentMonth - 1;
    });
  }

  void _goToNextMonth() {
    setState(() {
      currentMonth = currentMonth == 12 ? 1 : currentMonth + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final verbalHours = monthlyData[currentMonth]?['verbalHours'] ?? 0.0;
    final quantitativeHours = monthlyData[currentMonth]?['quantitativeHours'] ?? 0.0;

    return Container(
      height: 180,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _goToPreviousMonth,
                child: Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
              Text(
                monthNames[currentMonth - 1],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: _goToNextMonth,
                child: Icon(Icons.arrow_forward_ios, color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxHeight = constraints.maxHeight; // أقصى ارتفاع للمربع
                final barMaxHeight = maxHeight * 0.6; // تحديد 60% كحد أقصى للأعمدة

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // العمود اللفظي
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        verbalHours > 0
                            ? Container(
                          width: 44,
                          height: (verbalHours / 10 * barMaxHeight)
                              .clamp(4, barMaxHeight), // ضبط الارتفاع
                          decoration: BoxDecoration(
                            color: Color(0xFF29CDFF),
                            borderRadius: BorderRadius.circular(7),
                          ),
                        )
                            : SizedBox(height: 0),
                        SizedBox(height: 8),
                        Text(
                          "Verbal",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    // العمود الكمي
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        quantitativeHours > 0
                            ? Container(
                          width: 44,
                          height: (quantitativeHours / 10 * barMaxHeight)
                              .clamp(4, barMaxHeight), // ضبط الارتفاع
                          decoration: BoxDecoration(
                            color: Color(0xFFFF9800),
                            borderRadius: BorderRadius.circular(7),
                          ),
                        )
                            : SizedBox(height: 0),
                        SizedBox(height: 8),
                        Text(
                          "Quantitative",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}