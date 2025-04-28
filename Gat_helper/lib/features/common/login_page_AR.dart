import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gat_helper_app/features/common/Reset_pass_AR.dart';
import 'package:gat_helper_app/features/common/sign_up_page.dart';

import '../../core/services/auth_service.dart';
import '../../model/user_model.dart';
import '../auth/views/Parent_home_pageAR.dart';
import '../auth/views/Sign_up_page_AR.dart';
import 'login_page.dart';

class LoginPageAR extends StatefulWidget {
  final String userRole; // User Role parameter
  const LoginPageAR({super.key,required this.userRole});

  @override
  State<LoginPageAR> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPageAR> {
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

    return Directionality(
      textDirection: TextDirection.rtl, // Ensure RTL alignment
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // Background Decorations
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
            Positioned(
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

            // زر الرجوع
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => SignUpPageAR(userRole: 'parent',)),);
                  },
                ),
              ),
            ),

            // المحتوى الرئيسي
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 30.0),

                      Center(
                        child: Text(
                          "مرحبا بعودتك!",
                          style: TextStyle(
                            fontSize: 35.0,
                            fontWeight: FontWeight.w600,
                            //height: -3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 35.0),

                      // إدخال البريد الإلكتروني
                      // إدخال البريد الإلكتروني
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'البريد الإلكتروني',
                              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(
                              text: ' *', // Red star for mandatory field
                              style: TextStyle(color: Colors.red, fontSize: 18.0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5.0), // Top padding
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: ' أدخل بريدك الإلكتروني',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 10.0),
                        ),
                      ),
                      const SizedBox(height: 4.0), // Bottom padding

                      // إدخال كلمة المرور
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'كلمة المرور',
                              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(
                              text: ' *',
                              style: TextStyle(color: Colors.red, fontSize: 18.0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5.0), // Top padding
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: ' أدخل كلمة المرور',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 10.0),
                        ),
                      ),

                      const SizedBox(height: 4.0), // Bottom padding

                      const SizedBox(height: 15.0),

                      // زر تسجيل الدخول
                      Center(
                        child: SizedBox(
                          height: 48.0,
                          width: double.maxFinite,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (emailController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('يرجى ادخال بريدك الالكتروني'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              if (!emailController.text.contains('@')) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('صيغة البريد الإلكتروني غير صحيحة, تفتقد "@"'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              if (passwordController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('يرجى ادخال كلمة المرور'),
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

                                if (userModel != null) {
                                  // Check if the user is a parent
                                  if (userModel.userRole == 'parent') { // Adjust based on your Firestore field
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (_) => const ParentHomePageAR()),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Access denied! Only parents can log in here.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('User not found!'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } catch (e) {
                                print("FirebaseAuthException: $e");

                                String errorMessage = 'An unexpected error occurred. Please try again.';

                                if (e is FirebaseAuthException) {
                                  switch (e.code) {
                                    case 'user-not-found':
                                      errorMessage = 'No user found with this email.';
                                      break;
                                    case 'wrong-password':
                                      errorMessage = 'Incorrect password. Please try again.';
                                      break;
                                    case 'invalid-credential':
                                      errorMessage = 'خطأ, تأكد من البريد الالكتروني/كلمة المرور';
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
                                      errorMessage = 'ادخل البريد الالكتروني بشكل صحيح';
                                      break;
                                    default:
                                      errorMessage = 'Error: ${e.message}';
                                      break;
                                  }
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(errorMessage),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }

                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            child: const Text(
                              'تسجيل الدخول',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),

                      //رابط
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: "نسيت كلمة المرور؟ ",
                            style: const TextStyle(color: Colors.black87),
                            children: [
                              TextSpan(
                                text: 'تغيير كلمة المرور',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.lightBlue,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const ResetPassAR(),
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
            // Language Toggle Button, show only for Parent Role
            //if (widget.userRole == 'parent')
              Positioned(
                bottom: screenHeight * 0.15, // Adjusted to bring it closer to the bottom
                left: screenWidth * 0.40,    // Centered horizontally
                child: Center(
                  child: IconButton(
                    icon: Image.asset('assets/img_18.png', width: 40, height: 40), // Smaller size
                    iconSize: 40, // Smaller size
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginPage(userRole: 'parent')),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
