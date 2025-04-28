import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gat_helper_app/features/auth/views/student.dart';
import 'package:gat_helper_app/features/auth/views/Parent_home_page.dart';
import 'package:gat_helper_app/features/auth/views/tutor_home_page.dart';
import 'package:gat_helper_app/features/common/Reset_pass_page.dart';
import 'package:gat_helper_app/features/auth/views/Sign_up_page_AR.dart';
import 'package:gat_helper_app/features/common/sign_up_page.dart';

import '../../core/services/auth_service.dart';
import '../../model/user_model.dart';
import 'login_page_AR.dart';

class LoginPage extends StatefulWidget {
  final String userRole;

  const LoginPage({super.key, required this.userRole});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Authentication instance
  bool isLoading = false; // To show loading state
  UserModel? user;

  @override
  void initState() {
    AuthService().getUserDetails().then((val){
      setState(() {
        user = val;
      });
    });
    emailController = TextEditingController();
    passwordController = TextEditingController();
    // TODO: implement initState
    super.initState();
  }



  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Top Background
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

          // Bottom Backgrounds yellow
          Positioned(
            bottom: screenHeight * -0.01,
            left: -screenWidth * 0.1,
            right: -screenWidth * 0.1,
            child: Image.asset(
              'assets/img_11.png',
              fit: BoxFit.cover,
              width: screenWidth * 1.2,
              height: screenHeight * 0.4,
            ),
          ),
          Positioned( // Down blue
            bottom: 0,
            left: -screenWidth * 0.1,
            right: -screenWidth * 0.1,
            child: Image.asset(
              'assets/img_10.png',
              fit: BoxFit.cover,
              width: screenWidth * 1.2,
              height: screenHeight * 0.35,
            ),
          ),

          // Math Image
          Positioned(
            bottom: -screenHeight * 0.12,
            left: -screenWidth * 0.1,
            right: -screenWidth * 0.1,
            child: Image.asset(
              'assets/img_9.png',
              fit: BoxFit.cover,
              width: screenWidth * 1.2,
              height: screenHeight * 0.3,
            ),
          ),

          // Back Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => SignUpPage(userRole: widget.userRole,)),);
                },
              ),
            ),
          ),

          // Main content
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(height: 50.0),
                    Center(
                      child: Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Center(
                      child: Text(
                        "Glad to see you!",
                        style: TextStyle(
                          fontSize: 35.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    RichText(
                      text: TextSpan(
                        text: 'Email ',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                        children: [
                          TextSpan(
                            text: '*',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                        text: 'Password ',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                        children: [
                          TextSpan(
                            text: '*',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20.0),

                    // Login Button
                    Center(
                      child: SizedBox(
                        height: 48.0,
                        width: double.maxFinite,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (emailController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter your email'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (!emailController.text.contains('@')) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Invalid email format. Missing "@".'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (passwordController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter your password'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            try {
                              // Sign in the user
                              UserModel? userModel = await AuthService().signIn(
                                emailController.text,
                                passwordController.text,
                              );

                              // Navigate based on user role
                              if (userModel?.userRole == 'student') {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const StudentHomePage()),
                                );
                              } else if (userModel?.userRole == 'tutor') {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => TutorHomepage()),
                                );
                              } else if (userModel?.userRole == 'parent') {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => ParentHomePage()),
                                );
                              }

                            } catch (e) {
                              print("FirebaseAuthException: $e");

                              if (e is FirebaseAuthException) {
                                String errorMessage;

                                switch (e.code) {
                                  case 'user-not-found':
                                    errorMessage = 'No user found with this email.';
                                    break;
                                  case 'wrong-password':
                                    errorMessage = 'Incorrect password. Please try again.';
                                    break;
                                  case 'invalid-credential':
                                    errorMessage = 'Invalid, Check your password.';
                                    break;
                                  case 'too-many-requests':
                                    errorMessage = 'Too many failed attempts. Try again later.';
                                    break;
                                  case 'user-disabled':
                                    errorMessage = 'This account has been disabled.';
                                    break;
                                  case 'operation-not-allowed':
                                    errorMessage = 'Email/password login is disabled.';
                                    break;
                                  case 'invalid-email':
                                    errorMessage = 'Invalid email format.';
                                    break;
                                  default:
                                    errorMessage = 'Error: ${e.message}';
                                    break;
                                }

                                // Show error message in snackbar
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(errorMessage),
                                    backgroundColor: Colors.red,
                                  ),
                                );

                              } else {
                                //
                                //Unexpected error
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('An unexpected error occurred. Please try again.'),
                                    backgroundColor: Colors.red,
                                  ),
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
                          child: isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            'Log In',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),




                    // Forgot Password Link
                    const SizedBox(height: 10.0),
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
          ),
          if (widget.userRole == 'parent')
            Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.15), // Adjust this padding value to position it down
              child: Align(
                alignment: Alignment.bottomCenter, // Align the button at the bottom center
                child: IconButton(
                  icon: Image.asset(
                      'assets/img_18.png',
                      width: 40,
                      height: 40
                  ), // Smaller size
                  iconSize: 40, // Smaller size
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginPageAR(userRole: 'parent')),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}