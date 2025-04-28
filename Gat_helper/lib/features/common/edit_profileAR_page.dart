import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../model/user_model.dart';
import 'Reset_pass_page.dart';

class EditProfileAR extends StatefulWidget {
  final String role;
  final Map initialData;

  EditProfileAR({required this.role, required this.initialData});

  @override
  _EditProfileARState createState() => _EditProfileARState();
}

class _EditProfileARState extends State<EditProfileAR> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  String? selectedGender;
  String? selectedGrade;
  double tutorRating = 0.0;
  bool isLoading = true;

  UserModel? user;

  // Predefined avatars list
  final List<String> predefinedAvatars = [
    'assets/avatar_1.png',
    'assets/avatar_2.png',
    'assets/avatar_3.png',
    'assets/avatar_4.png',
    'assets/avatar_5.png',
    'assets/avatar_6.png',
    'assets/avatar_7.png',
    'assets/avatar_8.png',
    'assets/avatar_9.png',
    'assets/avatar_10.png',
    'assets/avatar_11.png',
    'assets/avatar_12.png',
  ];

  @override
  void initState() {
    super.initState();
    AuthService().getUserDetails().then((value) {
      setState(() {
        user = value;
        nameController = TextEditingController(text: user?.name);
        emailController = TextEditingController(text: user?.email);
        selectedGender = user?.gender ?? 'ذكر';
        selectedGrade = user?.gradeLevel ?? '';
        tutorRating = user?.rating ?? 0.0;
        isLoading = false;
      });
    });
  }

  Future<void> updateUserAvatar(String avatarPath) async {
    try {
      String uid = user?.uid ?? '';
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'avatar': avatarPath,
      });
      if (user != null) {
        user = UserModel(
          uid: user!.uid,
          name: user!.name,
          email: user!.email,
          gender: user!.gender,
          gradeLevel: user!.gradeLevel,
          rating: user!.rating,
          userRole: user!.userRole,
          createdAt: user!.createdAt,
          avatar: avatarPath,
        );
        setState(() {});
      }
    } catch (e) {
      print('خطأ في تحديث الصورة: $e');
    }
  }

  // Display avatar selection bottom sheet
  void showAvatarSelection() {
    String? tempAvatar = user?.avatar;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.all(16),
              height: 450,
              child: Column(
                children: [
                  Text(
                    "اختر صورة",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1,
                      ),
                      itemCount: predefinedAvatars.length,
                      itemBuilder: (context, index) {
                        String avatarPath = predefinedAvatars[index];
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              tempAvatar = avatarPath;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: (tempAvatar == avatarPath)
                                    ? Colors.blue
                                    : Colors.transparent,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.asset(avatarPath, fit: BoxFit.cover),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (tempAvatar != null) {
                        await updateUserAvatar(tempAvatar!);
                        // Update avatar in chat collection
                        await updateAvatarInChats(tempAvatar!);

                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    ),
                    child: Text("حفظ", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveChanges() async {
    if (nameController.text.isEmpty || emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى ملء جميع الحقول')),
      );
      return;
    }

    final updatedData = UserModel(
      uid: user?.uid ?? '',
      name: nameController.text,
      email: emailController.text,
      gender: selectedGender ?? 'ذكر',
      gradeLevel: selectedGrade ?? '12',
      rating: tutorRating,
      userRole: widget.role,
      createdAt: user?.createdAt ?? DateTime.now(),
      avatar: user?.avatar ?? '',
    );

    await AuthService().updateUserDetails(updatedData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم تحديث الملف الشخصي بنجاح!')),
    );

    await Future.delayed(Duration(seconds: 2));
    Navigator.pop(context, updatedData);
  }

  // Widget to display children list if the user is a parent
  Widget buildChildrenList() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
      builder: (context, parentSnapshot) {
        if (!parentSnapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final parentData = parentSnapshot.data!.data() as Map<String, dynamic>;
        final List<dynamic> childrenEmailsDynamic = parentData['children'] ?? [];
        final List<String> childrenEmails = childrenEmailsDynamic.cast<String>();

        if (childrenEmails.isEmpty) {
          return Center(child: Text('لا يوجد أبناء'));
        }

        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .where('email', whereIn: childrenEmails)
              .get(),
          builder: (context, childSnapshot) {
            if (!childSnapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            final childrenDocs = childSnapshot.data!.docs;
            return SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: childrenDocs.length,
                itemBuilder: (context, index) {
                  final childData = childrenDocs[index].data() as Map<String, dynamic>;
                  final String childEmail = childData['email'] ?? '';
                  return Container(
                    width: 120,
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: childData['avatar'] != null && childData['avatar'].toString().isNotEmpty
                                  ? AssetImage(childData['avatar'])
                                  : AssetImage('assets/default_avatar.png'),
                              child: (childData['avatar'] == null || childData['avatar'].toString().isEmpty)
                                  ? Icon(Icons.person, size: 40)
                                  : null,
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () async {
                                  bool? confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('تأكيد الحذف'),
                                        content: Text('هل أنت متأكد من إزالة هذا الابن؟'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: Text('إلغاء'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(true),
                                            child: Text('حذف', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirm == true) {
                                    List<String> updatedChildren = List.from(childrenEmails);
                                    updatedChildren.remove(childEmail);

                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(user!.uid)
                                        .update({'children': updatedChildren});

                                    setState(() {});
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.red,
                                  child: Icon(Icons.close, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          childData['name'] ?? childEmail,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            children: [
              // Background image with back button
              Container(
                height: 170,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/img_25.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 40.0, right: 16),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ),
              // Profile image and change image button
              Transform.translate(
                offset: Offset(0, -70),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 75,
                      backgroundImage: (user?.avatar != null && user!.avatar!.isNotEmpty)
                          ? AssetImage(user!.avatar!)
                          : AssetImage('assets/default_avatar.jpg'),
                    ),
                    //SizedBox(height: 10),
                    TextButton(
                      onPressed: showAvatarSelection,
                      child: Text('تغيير الصورة', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
              // Form for editing profile data
              Transform.translate(
                offset: Offset(0, -50),
                child:Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(labelText: 'الاسم'),
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(labelText: 'البريد الإلكتروني'),
                        enabled: false,
                      ),
                      SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedGender,
                        decoration: const InputDecoration(labelText: 'الجنس'),
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('ذكر')),
                          DropdownMenuItem(value: 'Female', child: Text('أنثى')),
                        ],
                        onChanged: (String? value) {
                          setState(() {
                            selectedGender = value;
                          });
                        },
                      ),

                      SizedBox(height: 20),
                      if (widget.role == 'parent') ...[
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'أبنائي',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 10),
                        buildChildrenList(),
                      ],
                      ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 75),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('حفظ التغييرات', style: TextStyle(color: Colors.white, fontSize: 18)),
                      ),
                      SizedBox(height: 10),

                      // Forgot Password Link
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: "نسيت كلمة المرور؟ ",
                            style: TextStyle(color: Colors.black87, fontSize: 17),
                            children: [
                              TextSpan(
                                text: ' قم بتغيير كلمة المرور',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.lightBlue,
                                  fontSize: 17,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) {
                                        return ResetPassWidget();
                                      },
                                    ),
                                  ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> updateAvatarInChats(String newAvatar) async {
    // Assuming chat messages are stored in the 'chats' collection
    var messages = await FirebaseFirestore.instance
        .collection('chats')
        .where('studentId', isEqualTo: user!.uid) // Filter by the user's ID
        .get();

    for (var message in messages.docs) {
      // Update the avatar in each message document
      await message.reference.update({
        'studentAvatar': newAvatar, // Update avatar field in the chat message
      });
    }
  }
}