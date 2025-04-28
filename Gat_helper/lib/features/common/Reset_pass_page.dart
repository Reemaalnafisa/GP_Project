import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ResetPassWidget extends StatefulWidget {
  const ResetPassWidget({Key? key}) : super(key: key);

  @override
  State<ResetPassWidget> createState() => _ResetPassWidgetState();
}

class _ResetPassWidgetState extends State<ResetPassWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    String email = _emailController.text.trim();

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
        title: const Text('Email Sent',textAlign: TextAlign.center,
        ),
        content: const Text('You will receive an email to reset your password.',
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: const Text('OK'),
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
        title: const Text('Email Not Registered',
          textAlign: TextAlign.center,
        ),
        content: const Text('This email address is not registered. Please check your email and try again.',
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(  // Center the OK button
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('OK'),
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
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
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
          // Submit Button
          Positioned(
            bottom: 280,
            left: 0,
            right: 0,
            child: Center(
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
                  'Submit',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Form( // <-- Wrapped with Form
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const SizedBox(height: 10.0),
                      Center(
                        child: Text(
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Enter your Email:',
                        style: TextStyle(fontSize: 16),
                      ),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          // Check if the email format is valid
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email address';
                          }

                          String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zAZ0-9.-]+\.[a-zA-Z]{2,}$';
                          if (!RegExp(pattern).hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }

                          return null; // email format is valid
                        },
                      ),
                      const SizedBox(height: 30.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
