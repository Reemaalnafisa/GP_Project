import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gat_helper_app/features/common/login_page.dart';
import 'package:gat_helper_app/features/common/sign_up_page.dart';
import 'package:gat_helper_app/features/common/start_page.dart';

import '../../../core/services/auth_service.dart';
import '../../../model/user_model.dart';
import 'Parent_home_pageAR.dart';
import '../../common/login_page_AR.dart';

class SignUpPageAR extends StatefulWidget {
  final String userRole;
  const SignUpPageAR({super.key, required this.userRole});

  @override
  State<SignUpPageAR> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPageAR> {
  final AuthService authService = AuthService();
  String? _selectedGender;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final pwdController = TextEditingController();
  final List<String> _items = ['ذكر', 'أنثى'];

  /// Helper function to handle gender localization
  String getLocalizedGender(String? gender, String language) {
    if (gender == null) return '';
    if (language == 'ar') {
      return gender == 'Male' ? 'ذكر' : 'أنثى';
    } else {
      return gender == 'ذكر' ? 'Male' : 'Female';
    }
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
              bottom: -screenHeight * 0.13,
              left: -screenWidth * 0.1,
              right: -screenWidth * 0.1,
              child: Image.asset(
                'assets/img_9.png',
                fit: BoxFit.cover,
                width: screenWidth * 1.2,
                height: screenHeight * 0.3,
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

            // زر الرجوع
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => StartPage()),
                    );
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
                      const SizedBox(height: 160),
                      Center(
                        child: Text(
                          'أهلا وسهلا !',
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.w200,
                            height: -7,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Center(
                        child: Text(
                          "دعنا نبدأ !",
                          style: TextStyle(
                            fontSize: 40.0,
                            fontWeight: FontWeight.bold,
                            height: -3,
                          ),
                        ),
                      ),

                      //const SizedBox(height: 3.0),
                      _buildLabel('الاسم'),
                      _buildTextField(controller: nameController,hintText: ' أدخل اسمك', screenWidth: screenWidth ),

                      _buildLabel('البريد الإلكتروني'),
                      _buildTextField(controller: nameController,hintText: ' أدخل بريدك الإلكتروني', screenWidth: screenWidth ),

                      _buildLabel('كلمة المرور'),
                      _buildTextField(controller: nameController,hintText: ' أدخل كلمة المرور', screenWidth: screenWidth ),

                      // اختيار الجنس
                      SizedBox(
                        width: screenWidth * 0.9,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'الجنس',
                                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                  ),
                                  const TextSpan(
                                    text: ' *', // Red star for mandatory field
                                    style: TextStyle(color: Colors.red, fontSize: 16.0),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5.0),
                            DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: InputDecoration(
                                hintText: 'اختر الجنس',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
                              ),
                              items: _items.map((e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: Text(e, style: const TextStyle(fontSize: 14.0)),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),



                      const SizedBox(height: 10.0),

                      // زر التسجيل
                      Center(
                        child: SizedBox(
                          height: 40.0,
                          width: double.maxFinite,
                          child: ElevatedButton(
                            onPressed: () async {
                              String name = nameController.text.trim();
                              String email = emailController.text.trim();
                              String password = pwdController.text;

                              // Empty fields check
                              if (name.isEmpty && email.isEmpty && password.isEmpty && _selectedGender == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('يرجى ادخال معلوماتك كاملة'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              if (name.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('يرجى إدخال الاسم'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              if (email.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('يرجى إدخال البريد الإلكتروني بالشكل الصحيح'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              if (password.length < 6 || !RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d\S]{6,}$').hasMatch(password)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('كلمة المرور يجب أن تحتوي على 6 أحرف على الأقل وتحتوي على حروف وأرقام'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              if (_selectedGender == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('يرجى اختيار الجنس'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              // Store gender in English
                              String genderToSave = getLocalizedGender(_selectedGender, 'en');

                              UserModel userModel = UserModel(
                                name: name,
                                email: email,
                                userRole: widget.userRole,
                                gender: genderToSave,
                                createdAt: DateTime.now(),
                              );

                              final user = await AuthService().createNewUser(userModel, password);
                              if (user != null) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ParentHomePageAR()),
                                );
                              }
                            },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text('تسجيل', style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      // رابط تسجيل الدخول
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: "لديك حساب بالفعل؟",
                            style: const TextStyle(color: Colors.black87),
                            children: [
                              TextSpan(
                                text: ' تسجيل الدخول',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.lightBlue,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const LoginPageAR(userRole: 'parent',),
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
                        MaterialPageRoute(builder: (_) => const SignUpPage(userRole: 'parent')),
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
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 1.0, bottom: 1.0),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black),
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

}