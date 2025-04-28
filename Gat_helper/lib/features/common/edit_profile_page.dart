import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../model/user_model.dart';
import 'Reset_pass_page.dart';

class EditProfilePage extends StatefulWidget {
  final String role;

  EditProfilePage({required this.role, required Map initialData});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController pwdController;
  String? uid;
  String? selectedGender;
  String? selectedGrade;
  double tutorRating = 0.0;
  bool isLoading = true;

  // List of predefined avatar asset paths
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

  UserModel? user;

  @override
  void initState() {
    super.initState();
    AuthService().getUserDetails().then((val) {
      setState(() {
        user = val;
        nameController = TextEditingController(text: user?.name);
        emailController = TextEditingController(text: user?.email);
        pwdController = TextEditingController(); // update as needed
        selectedGender = user?.gender ?? 'Male';
        selectedGrade = user?.gradeLevel ?? '';
        tutorRating = user?.rating ?? 0.0; // If rating is null, set to 0
        isLoading = false;
      });
    });
  }

  Future<void> updateUserAvatar(String avatarPath) async {
    try {
      String uid = user?.uid ?? '';
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'avatar': avatarPath, // Update Firestore field "avatar"
      });
      // Manually update the local user model
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
          avatar: avatarPath, // Updated avatar field
        );
        setState(() {});
      }
    } catch (e) {
      print('Error updating avatar: $e');
      // Optionally, show an error message using a Snackbar.
    }
  }

  // Opens a bottom sheet with a grid of predefined avatars.
  void showAvatarSelection() {
    String? tempAvatar = user?.avatar; // Store temporary selection

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
                    "Select an Avatar",
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
                              tempAvatar = avatarPath; // Update temporary selection
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
                        await updateAvatarInChatsAndHelpRequests(tempAvatar!);

                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    ),
                    child: Text("Done", style: TextStyle(color: Colors.white, fontSize: 16)),
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
    // Validate the fields
    if (nameController.text.isEmpty || emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Prepare updated data. Make sure to include the avatar if needed.
    final updatedData = UserModel(
      uid: user?.uid ?? '', // Ensure there's a valid UID
      name: nameController.text,
      email: emailController.text,
      gender: selectedGender ?? 'Male', // Default to Male if no gender selected
      gradeLevel: selectedGrade ?? '12', // Default grade if not selected
      rating: tutorRating,
      userRole: widget.role,
      createdAt: user?.createdAt ?? DateTime.now(),
      avatar: user?.avatar ?? '', // Retain the current avatar
    );

    // Call the AuthService to update user details
    await AuthService().updateUserDetails(updatedData);
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile updated successfully!')),
    );
    print('Updated Data: $updatedData');

    await Future.delayed(Duration(seconds: 2));
    // Return the updated user data to the previous screen
    Navigator.pop(context, updatedData);
  }

  Widget buildChildrenList() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
      builder: (context, parentSnapshot) {
        if (!parentSnapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final parentData = parentSnapshot.data!.data() as Map<String, dynamic>;
        // Assuming the "children" field contains a list of child email addresses
        final List<dynamic> childrenEmailsDynamic = parentData['children'] ?? [];
        final List<String> childrenEmails = childrenEmailsDynamic.cast<String>();

        if (childrenEmails.isEmpty) {
          return Center(child: Text('No Children'));
        }

        // Query to fetch children data from the "users" collection using whereIn on the email field
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
              height: 160, // adjust height as needed
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: childrenDocs.length,
                itemBuilder: (context, index) {
                  final childData = childrenDocs[index].data() as Map<String, dynamic>;
                  final String childEmail = childData['email'] ?? '';
                  return Container(
                    width: 120, // adjust width as needed
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: childData['avatar'] != null && childData['avatar'].toString().isNotEmpty
                                  ? AssetImage(childData['avatar'])
                                  : null,
                              child: (childData['avatar'] == null || childData['avatar'].toString().isEmpty)
                                  ? Icon(Icons.person, size: 40)
                                  : null,
                            ),
                            Positioned(
                              left: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () async {
                                  bool? confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Confirm Delete'),
                                        content: Text('Are you sure you want to remove this child?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(true),
                                            child: Text('Delete', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirm == true) {
                                    List<String> updatedChildren = List.from(childrenEmails);
                                    updatedChildren.remove(childEmail);

                                    // 1. Delete the child from the parent list
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(user!.uid)
                                        .update({'children': updatedChildren});

                                    // 2. Delete the connection request
                                    QuerySnapshot connectionSnapshot = await FirebaseFirestore.instance
                                        .collection('connection_requests')
                                        .where('parentEmail', isEqualTo: user!.email)
                                        .where('childEmail', isEqualTo: childEmail)
                                        .get();

                                    for (var doc in connectionSnapshot.docs) {
                                      await doc.reference.delete();
                                    }

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
                          style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
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
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 170,
              width: screenWidth,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/img_25.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 40.0, left: 16),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
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
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: showAvatarSelection,
                    child:
                    Text('Change Picture', style: TextStyle(fontSize: 16)),
                  ),
                  if (widget.role == 'tutor') ...[
                    SizedBox(height: 5),
                    buildStarRating(tutorRating),
                    SizedBox(height: 10),
                  ],
                ],
              ),
            ),
            Transform.translate(
              offset: Offset(0, -60),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      enabled: false, // Prevent editing email
                    ),
                    SizedBox(height: 12),
                    if (widget.role == 'student') ...[
                      SizedBox(height: 12),
                      DropdownButtonFormField(
                        value: ['12', '11', '10'].contains(selectedGrade) ? selectedGrade : null,
                        decoration: InputDecoration(labelText: 'Grade Level'),
                        items: ['12', '11', '10']
                            .map((grade) => DropdownMenuItem(value: grade, child: Text(grade)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedGrade = value as String?;
                          });
                        },
                      ),

                    ],
                    SizedBox(height: 6),
                    DropdownButtonFormField(
                      value: ['Male', 'Female'].contains(selectedGender) ? selectedGender : null,
                      decoration: InputDecoration(labelText: 'Gender'),
                      items: ['Male', 'Female']
                          .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value as String?;
                        });
                      },
                    ),

                    SizedBox(height: 20),

                    if (widget.role == 'parent') ...[
                      // قسم قائمة الأبناء
                      Text(
                        'My Children',
                        style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      buildChildrenList(),
                    ],
                    //SizedBox(height: 20),
                    Center(
                      child: SizedBox(
                        width: screenWidth * 0.8,
                        child: ElevatedButton(
                          onPressed: _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('Save Changes',
                              style:
                              TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Forgot Password Link
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Forgot password?",
                          style: TextStyle(color: Colors.black87),
                          children: [
                            TextSpan(
                              text: ' Change Password',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.lightBlue,
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
    );
  }

  Widget buildStarRating(double rating) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 30,
        );
      }),
    );
  }


  Future<void> updateAvatarInChatsAndHelpRequests(String newAvatar) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    // Update avatar in the 'chats' collection
    var messages = await FirebaseFirestore.instance
        .collection('chats')
        .where('studentId', isEqualTo: uid) // Filter by the user's ID
        .get();

    for (var message in messages.docs) {
      await message.reference.update({
        'studentAvatar': newAvatar, // Update avatar field in the chat message
      });
    }

    // Update avatar in the 'helpRequests' collection
    var helpRequests = await FirebaseFirestore.instance
        .collection('helpRequests')
        .where('studentId', isEqualTo: uid) // Filter by the user's ID
        .get();

    for (var request in helpRequests.docs) {
      await request.reference.update({
        'avatar': newAvatar, // Update avatar field in the help request
      });
    }
  }




}