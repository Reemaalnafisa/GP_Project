import 'package:flutter/material.dart';
import '../auth/views/Sign_up_page_AR.dart';
import 'sign_up_page.dart';

// Define user roles
enum userRole { student, parent, tutor }

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white, // Keeps the background white
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

          // Bottom Background Yellow
          Positioned(
            bottom: -screenHeight * 0.1,
            left: -screenWidth * 0.1,
            right: -screenWidth * 0.1,
            child: Image.asset(
              'assets/img_5.png',
              fit: BoxFit.cover,
              width: screenWidth * 1.2,
              height: screenHeight * 0.4,
            ),
          ),

          // Main Content
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // App Logo & Title
                    Image.asset(
                      'assets/logo2.png',
                      height: 170, // Adjust logo size
                    ),

                    const SizedBox(height: 5),

                    // Role selection buttons
                    _buildRoleButton(context, userRole.student, "Student"),
                    const SizedBox(height: 20),
                    _buildRoleButton(context, userRole.parent, "Parent"),
                    const SizedBox(height: 20),
                    _buildRoleButton(context, userRole.tutor, "Tutor"),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to build a button
  Widget _buildRoleButton(BuildContext context, userRole role, String roleText) {
    return ElevatedButton(
      onPressed: () {
        // Navigate based on the role
        if (role == userRole.parent) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SignUpPageAR(userRole: 'parent',), // Navigate to SignUpPageAR for Parent
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SignUpPage(userRole: role.name.toLowerCase(),), // Pass role to SignUpPage
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightGreen,
        minimumSize: const Size(200, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      child: Text(
        roleText,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}