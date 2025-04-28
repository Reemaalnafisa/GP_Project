import 'package:flutter/material.dart';
import 'package:gat_helper_app/features/auth/views/student.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Studentreq extends StatefulWidget {
  final List<Map<String, dynamic>> questions;

  const Studentreq({super.key, required this.questions});

  @override
  State<Studentreq> createState() => _StudentreqState();
}

class _StudentreqState extends State<Studentreq> {
  List<String> _dropdownOptions = [];
  List<String> _selectedOptions = [];
  String? _radioValue = 'Chat';
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _dropdownOptions = List.generate(widget.questions.length, (index) {
      final questionText = widget.questions[index]['question'];
      final words = questionText.split(' ');
      final preview = words.length > 4
          ? words.sublist(0, 4).join(' ') + '...'
          : questionText;
      return 'Question ${index + 1}: $preview';
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Backgrounds
          Positioned(
            top: -screenHeight * 0.10,
            left: -screenWidth * 0.8,
            right: -screenWidth * 0.8,
            child: Image.asset(
              'assets/img_12.png',
              fit: BoxFit.cover,
              width: screenWidth * 2.4,
              height: screenHeight * 0.40,
            ),
          ),

          // انا ريما شلت الصورة عشان اعدل شوي بالمسافات
          //Positioned(
          //bottom: screenHeight * 0.01,
          //left: screenWidth * 0.15,
          //right: screenWidth * 0.15,
          //child: Image.asset(
          // 'assets/img_13.png',
          // fit: BoxFit.cover,
          // width: screenWidth * 0.7,
          // height: screenHeight * 0.3,
          // ),
          // ),


          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30.0),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          // Main content using ListView
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                children: [
                  const SizedBox(height: 190),
                  const Center(
                    child: Text(
                      'We’re here to support you!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Center(
                    child: Text(
                      'Request Details',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Questions:',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _selectedOptions.isEmpty
                                  ? 'Select questions'
                                  : _selectedOptions.join(', '),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(_isExpanded
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  if (_isExpanded)
                    Container(
                      height: 200,
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        itemCount: _dropdownOptions.length,
                        itemBuilder: (context, index) {
                          final option = _dropdownOptions[index];
                          return CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true, // لتقليل المسافات العمودية
                            visualDensity: VisualDensity(horizontal: -3, vertical: -3), // لتصغير الـ checkbox نفسه
                            title: Text(
                              option,
                              style: TextStyle(fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            value: _selectedOptions.contains(option),
                            onChanged: (bool? selected) {
                              setState(() {
                                if (selected == true) {
                                  _selectedOptions.add(option);
                                } else {
                                  _selectedOptions.remove(option);
                                }
                              });
                            },
                          );

                        },
                      ),
                    ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Preferred method:',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Radio<String>(
                            value: 'Chat',
                            groupValue: _radioValue,
                            onChanged: (String? value) {
                              setState(() {
                                _radioValue = value;
                              });
                            },
                          ),
                          const Text('Chat'),
                        ],
                      ),
                      const SizedBox(width: 60),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'Virtual',
                            groupValue: _radioValue,
                            onChanged: (String? value) {
                              setState(() {
                                _radioValue = value;
                              });
                            },
                          ),
                          const Text('Virtual'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {


                        final currentUser = FirebaseAuth.instance.currentUser;

                        // نجيب بيانات المستخدم من Firestore
                        final userDoc = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(currentUser?.uid)
                            .get();

                        final userData = userDoc.data()!;
                        final studentName = userData['name'] ?? 'Unknown';
                        final avatarUrl = userData['avatar'] ?? '';

                        // نرجع الأسئلة الكاملة من اللي اختارهم الطالب
                        final selectedFullQuestions = _selectedOptions.map((preview) {
                          final index = _dropdownOptions.indexOf(preview);
                          return widget.questions[index];
                        }).toList();

                        int customDocumentId = DateTime.now().millisecondsSinceEpoch;
                        await FirebaseFirestore.instance.collection('helpRequests').doc(customDocumentId.toString()).set({
                          'studentEmail': currentUser?.email,
                          'studentName': studentName,
                          'avatar': avatarUrl,
                          'selectedQuestions': selectedFullQuestions,
                          'method': _radioValue,
                          'timestamp': FieldValue.serverTimestamp(),
                          'status': 'pending',
                          'requestID': customDocumentId,
                        });


                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Request sent successfully!')),
                        );

                        Future.delayed(const Duration(seconds: 2), () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const StudentHomePage()),
                          );
                        });
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD6DE97),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Send',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
