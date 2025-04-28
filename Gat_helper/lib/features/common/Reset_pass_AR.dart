import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gat_helper_app/features/auth/views/Reset_pass_page2.dart';
import '../auth/views/Reset_pass_AR2.dart';

class ResetPassAR extends StatefulWidget {
  const ResetPassAR({super.key});

  @override
  State<ResetPassAR> createState() => _ResetPassARState();
}

class _ResetPassARState extends State<ResetPassAR> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    String email = emailController.text.trim();

    try {
      // Firestore check if email exists
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users') // Your Firestore collection name
          .where('email', isEqualTo: email)
          .get();

      if (userSnapshot.docs.isEmpty) {
        // If email does not exist in Firestore, show error in dialog
        _showEmailNotExistDialog();
        return;
      }

      // If email exists in Firestore, send the reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      _showEmailSentDialog();
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(e.message.toString()),
        ),
      );
    }
  }

  void _showEmailSentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'تم إرسال البريد',
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'ستتلقى بريداً إلكترونياً لإعادة تعيين كلمة المرور.',
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: const Text('موافق'),
            ),
          ),
        ],
      ),
    );
  }

  void _showEmailNotExistDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'البريد الإلكتروني غير مسجل',
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'هذا البريد الإلكتروني غير مسجل. الرجاء التحقق من بريدك الإلكتروني والمحاولة مرة أخرى.',
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('موافق'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl, // Set text direction to RTL for Arabic
        child: Stack(
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
              bottom: screenHeight * 0,
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
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            // Main Content Centered
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const SizedBox(height: 10.0),
                        Center(
                          child: Text(
                            'إعادة تعيين كلمة المرور',
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'أدخل بريدك الإلكتروني:',
                          style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),

                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'البريد الإلكتروني',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            // Check if the email format is valid
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال بريد إلكتروني';
                            }

                            String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zAZ0-9.-]+\.[a-zA-Z]{2,}$';
                            if (!RegExp(pattern).hasMatch(value)) {
                              return 'الرجاء إدخال بريد إلكتروني صالح';
                            }

                            return null; // email format is valid
                          },
                        ),
                        const SizedBox(height: 30.0),
                        // Submit Button
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              _resetPassword();
                            },
                            child: const Text(
                              'إرسال',
                              style: TextStyle(color: Colors.white, fontSize: 16,fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
