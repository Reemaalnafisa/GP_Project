import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gat_helper_app/core/services/auth_service.dart';
import 'package:gat_helper_app/features/auth/views/student.dart';
import 'package:gat_helper_app/features/common/login_page.dart';
import 'package:gat_helper_app/features/common/start_page.dart';

import '../../model/user_model.dart';
import '../auth/views/Sign_up_page_AR.dart';
import '../auth/views/tutor_home_page.dart';

class SignUpPage extends StatefulWidget {
  final String userRole; // User Role parameter

  const SignUpPage({super.key, required this.userRole});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final AuthService authService = AuthService();
  String? _selectedGender;
  String? _selectedGrade;
  final List<String> _genders = ['Male', 'Female'];
  final List<String> _grades = ['10', '11', '12'];
final nameController = TextEditingController();
final emailController = TextEditingController();
final pwdController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background Images in a Column
          Positioned(
            top: -screenHeight * 0.15,
            left: -screenWidth * 0.8,
            right: -screenWidth * 0.8,
            child: Image.asset(
              'assets/img_12.png',
              fit: BoxFit.cover,
              width: screenWidth * 2.4,
              height: screenHeight * 0.40,
            ),
          ),
          // Bottom Backgrounds yellow
          Positioned(
            bottom: screenHeight * -0.03,
            left: -screenWidth * 0.1,
            right: -screenWidth * 0.1,
            child: Image.asset(
              'assets/img_11.png',
              fit: BoxFit.cover,
              width: screenWidth * 1.2,
              height: screenHeight * 0.4,
            ),
          ),
          Positioned(
            bottom: -screenHeight * 0.02,  // Moved this image further up by decreasing the negative value
            left: -screenWidth * 0.1,
            right: -screenWidth * 0.1,
            child: Image.asset(
              'assets/img_10.png',
              fit: BoxFit.cover,
              width: screenWidth * 1.2,
              height: screenHeight * 0.35,
            ),
          ),
          Positioned(
            bottom: -screenHeight * 0.13,  // Moved this image a bit up as well
            left: -screenWidth * 0.1,
            right: -screenWidth * 0.1,
            child: Image.asset(
              'assets/img_9.png',
              fit: BoxFit.cover,
              width: screenWidth * 1.2,
              height: screenHeight * 0.3,
            ),
          ),



          // SafeArea for Back Button to ensure it's always on top
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => StartPage()),);
                },
              ),
            ),
          ),

          // Main Content
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 120),
                    Center(
                      child: Text(
                        'Welcome!',
                        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600, height: -7),
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Center(
                      child: Text(
                        "Let's get started!",
                        style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w600, height: -3),
                      ),
                    ),
                    const SizedBox(height: 3.0),

                    // Name Input
                    _buildLabel('Name'),
                    _buildTextField(controller: nameController,hintText: 'Enter your name', screenWidth: screenWidth),

                    // Email Input
                    _buildLabel('Email'),
                    _buildTextField(controller: emailController,hintText: 'Enter your email', screenWidth: screenWidth),

                    // Password Input
                    _buildLabel('Password'),
                    _buildTextField(controller: pwdController,hintText: 'Enter your password', screenWidth: screenWidth, obscureText: true),

                    // Gender Dropdown
                    _buildLabel('Gender'),
                    _buildDropdown(
                      value: _selectedGender,
                      items: _genders,
                      hint: 'Select gender',
                      onChanged: (value) => setState(() => _selectedGender = value),
                      screenWidth: screenWidth,
                    ),

                    // Grade Level Dropdown (Only for Students)
                    if (widget.userRole == 'student') ...[
                      _buildLabel('Grade Level'),
                      _buildDropdown(
                        value: _selectedGrade,
                        items: _grades,
                        hint: 'Select grade level',
                        onChanged: (value) => setState(() => _selectedGrade = value),
                        screenWidth: screenWidth,
                      ),
                    ],

                    const SizedBox(height: 10.0),

                    // Sign Up Button
                    Center(
                      child: SizedBox(
                        height: 40.0,
                        width: double.maxFinite, // Adjusted width
                        child: ElevatedButton(
                          onPressed: () async {
                            String name = nameController.text.trim();
                            String email = emailController.text.trim();
                            String password = pwdController.text;
                            //String confirmPassword = confirmPwdController.text;

                            if (name.isEmpty & email.isEmpty & password.isEmpty ) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Enter your Informations'),backgroundColor: Colors.red,));
                              return;
                            }

                            // Basic validation logic
                            if (name.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Name is required'),backgroundColor: Colors.red,));
                              return;
                            }

                            if (email.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Enter a valid email'),backgroundColor: Colors.red,));
                              return;
                            }

                            if (password.length < 6 || !RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d\S]{6,}$').hasMatch(password)) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password must be at least 6 characters and include both letters and numbers'),backgroundColor: Colors.red,));
                              return;
                            }

                            if (_selectedGender == null) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gender is required'),backgroundColor: Colors.red,));
                              return;
                            }

                            if (widget.userRole == 'student' && _selectedGrade == null) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Grade is required'),backgroundColor: Colors.red,));
                              return;
                            }

                            // Proceed to create the user
                            if (widget.userRole == 'student') {
                              UserModel userModel = UserModel(
                                name: name,
                                email: email,
                                userRole: widget.userRole,
                                gender: _selectedGender!,
                                gradeLevel: _selectedGrade!,
                                createdAt: DateTime.now(),
                              );
                              final user = await AuthService().createNewUser(userModel, password);
                              if (user != null) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const StudentHomePage()),
                                );
                              }
                            } else if (widget.userRole == 'tutor') {
                              UserModel userModel = UserModel(
                                name: name,
                                email: email,
                                userRole: widget.userRole,
                                gender: _selectedGender!,
                                createdAt: DateTime.now(),
                              );
                              final user = await AuthService().createNewUser(userModel, password);
                              if (user != null) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => TutorHomepage()),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0, // Reduced font size
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Login Link
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Already have an account?",
                          style: const TextStyle(color: Colors.black87),
                          children: [
                            TextSpan(
                              text: ' Login',
                              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.lightBlue),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => Navigator.of(context).push( //here
                                  MaterialPageRoute(builder: (_) => LoginPage(userRole: widget.userRole,)),
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
          ),

          // Language Toggle Button, show only for Parent Role
          if (widget.userRole == 'parent')
            Positioned(
              bottom: screenHeight * 0.12, // Adjusted to bring it closer to the bottom
              left: screenWidth * 0.40,    // Centered horizontally
              child: Center(
                child: IconButton(
                  icon: Image.asset('assets/img_18.png', width: 40, height: 40), // Smaller size
                  iconSize: 40, // Smaller size
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const SignUpPageAR(userRole: 'parent')),
                    );
                  },
                ),
              ),
            ),

        ],
      ),
    );
  }

  // Helper method to build input labels
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 1.0, bottom: 1.0),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, color: Colors.black),
          children: const [
            TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }


  // Helper method to build text fields
  Widget _buildTextField({required String hintText, required double screenWidth, bool obscureText = false,required TextEditingController controller}) {
    return SizedBox(
      width: screenWidth * 0.9, // Adjusted width
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0), // Compressed field height
        ),
        style: TextStyle(fontSize: 14.0),
      ),
    );
  }

  // Helper method to build dropdowns
  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
    required double screenWidth,
  }) {
    return SizedBox(
      width: screenWidth * 0.9, // Adjusted width
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: 14.0)))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
