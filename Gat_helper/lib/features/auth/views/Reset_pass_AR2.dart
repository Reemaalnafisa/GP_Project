import 'package:flutter/material.dart';
import 'package:gat_helper_app/features/auth/views/Reset_pass_page2.dart';
import 'package:gat_helper_app/features/common/login_page_AR.dart';
import '../../common/login_page.dart';

class ResetPassAR2 extends StatelessWidget {
  const ResetPassAR2({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final TextEditingController emailController = TextEditingController();

    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,  // Set text direction to RTL for Arabic
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

                      // New Password Input
                      const Text(
                        'أدخل كلمة المرور الجديدة:',
                        style: TextStyle(fontSize: 16),
                      ),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'كلمة المرور',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const Text( // Confirm Password
                        'تأكيد كلمة المرور الجديدة:',
                        style: TextStyle(fontSize: 16),
                      ),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'كلمة المرور',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 30.0),
                      Center(
                        child: SizedBox(
                          height: 48.0,
                          width: double.maxFinite,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPageAR(userRole: 'parent',),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text(
                              'حفظ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
