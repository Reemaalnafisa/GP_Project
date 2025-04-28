import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gat_helper_app/features/auth/views/Parent_DashBoard.dart';
import 'package:gat_helper_app/features/common/edit_profile_page.dart';
import '../../../core/services/Parent_Service.dart';
import '../../../core/services/auth_service.dart';
import '../../../model/user_model.dart';
import '../../common/edit_profileAR_page.dart';
import 'AR_dashboard.dart';
import 'Parent_home_page.dart';
import 'Parent_home_pageAR.dart';
import '../../common/login_page.dart';

class ParentHomePageAR extends StatefulWidget {
  const ParentHomePageAR({super.key});

  @override
  _ParentHomePageARState createState() => _ParentHomePageARState();
}

class _ParentHomePageARState extends State<ParentHomePageAR> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  bool isNotificationEnabled = false;

  // قائمة الأبناء الموافق عليهم
  List<Map<String, String>> approvedChildren = [];

  // قائمة طلبات الاتصال المعلقة أو المرفوضة
  List<Map<String, String>> pendingChildren = [];

  UserModel? user;

  @override
  void initState() {
    super.initState();
    AuthService().getUserDetails().then((val) {
      setState(() {
        user = val;
      });
    });
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Directionality(
      textDirection: TextDirection.rtl, // عرض من اليمين لليسار
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: Drawer(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 200,
                width: 500,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: const Color(0xFF284379),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundImage: (user != null && user!.avatar != null)
                            ? AssetImage(user!.avatar!)
                            : const AssetImage('assets/default_avatar.jpg'),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user?.name ?? '',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 5),

                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.black),
                title: const Text('تعديل الملف الشخصي'),
                onTap: () async {
                  // عند التنقل إلى صفحة تعديل الملف الشخصي
                  final updatedUser = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EditProfileAR(role: 'parent', initialData: {}),
                    ),
                  );
                  if (updatedUser != null) {
                    setState(() {
                      user = updatedUser;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.contact_mail, color: Colors.black),
                title: const Text('تواصل معنا'),
                onTap: () {
                  _showContactUsDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('تسجيل الخروج'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                        const LoginPage(userRole: 'parent')),
                  );
                },
              ),
              const Spacer(),
              ListTile(
                leading: Padding(
                  padding: const EdgeInsets.only(right: 85.5),
                  child: Image.asset('assets/img_18.png', width: 40, height: 40),
                ),
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const ParentHomePage()),
                  );
                },
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            // الصورة الخلفية
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                "assets/img_23.png",
                fit: BoxFit.cover,
                height: 380,
                width: screenWidth,
              ),
            ),
            // زر القائمة (القائمة الجانبية)
            Positioned(
              top: 20,
              right: 10,
              child: Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black, size: 30),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  );
                },
              ),
            ),
            Column(
              children: [
                _buildProfileHeader(), // رأس الملف الشخصي
                const SizedBox(height: 60),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 1.0, left: 16.0, right: 16.0, bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildChildrenSection(), // عرض الأبناء الموافق عليهم
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "اتصال الأبناء",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline,
                                    color: Colors.blue),
                                onPressed: () {
                                  _showAddChildDialog();
                                },
                              ),
                            ],
                          ),
                          _buildConnectionRequests(), // عرض طلبات الاتصال المعلقة أو المرفوضة
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showContactUsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
          const Text("تواصل معنا", textAlign: TextAlign.center),
          content: RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                    text:
                    "إذا كان لديك أي استفسار، لا تتردد في التواصل معنا على:\n\n",
                    style: TextStyle(color: Colors.black)),
                TextSpan(
                    text: "GAThelper@gmail.com\n\n",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black)),
                const TextSpan(
                    text: "نحن هنا لمساعدتك!",
                    style: TextStyle(color: Colors.black)),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
                child: const Text("إغلاق"),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ],
        );
      },
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      child: Column(
        children: [
          const SizedBox(height: 80),
          CircleAvatar(
            radius: 60,
            backgroundImage: (user != null && user!.avatar != null)
                ? AssetImage(user!.avatar!)
                : const AssetImage('assets/default_avatar.jpg'),
          ),
          const SizedBox(height: 10),
          const Text("مرحبا", style: TextStyle(fontSize: 20, color: Colors.white)),
          Text(
            user?.name ?? '',
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // قسم عرض الأبناء الموافق عليهم (أبنائي)
  Widget _buildChildrenSection() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('المستخدم غير موجود.'));
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, parentSnapshot) {
        if (!parentSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final parentData = parentSnapshot.data!.data() as Map<String, dynamic>;
        final List<dynamic> childrenEmailsDynamic = parentData['children'] ?? [];
        final List<String> childrenEmails = childrenEmailsDynamic.cast<String>();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان دائمًا يظهر
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "أبنائي",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isNotificationEnabled
                          ? Icons.notifications_on
                          : Icons.notifications_off,
                      color: isNotificationEnabled ? Colors.green : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        isNotificationEnabled = !isNotificationEnabled;
                      });
                    },
                  ),
                ],
              ),

              if (childrenEmails.isEmpty)
                const Center(child: Text(
                  "لا يوجد ابناء",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                ),)
              else
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .where('email', whereIn: childrenEmails)
                      .get(),
                  builder: (context, childSnapshot) {
                    if (!childSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final childrenDocs = childSnapshot.data!.docs;

                    return Column(
                      children: childrenDocs.map((doc) {
                        final childData = doc.data() as Map<String, dynamic>;
                        final String childEmail = childData['email'] ?? '';
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 5),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: childData['avatar'] != null &&
                                      childData['avatar']
                                          .toString()
                                          .isNotEmpty
                                      ? AssetImage(childData['avatar'])
                                      : null,
                                  child: (childData['avatar'] == null ||
                                      childData['avatar']
                                          .toString()
                                          .isEmpty)
                                      ? const Icon(Icons.person, size: 30)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        childData['name'] ?? 'غير معروف',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        childEmail,
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.bar_chart, color: Colors.grey),
                                  onPressed: () {
                                    String childName =
                                        childData["name"] ?? "غير معروف";
                                    String childEmail =
                                        childData["email"] ?? "لا يوجد بريد";
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AR_ParentDashboard(
                                          childEmail: childEmail,
                                          childName: childName,
                                        ),
                                        settings: RouteSettings(arguments: {
                                          'name': childName,
                                          'email': childEmail
                                        }),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }



  // قسم طلبات الاتصال (المعلقة أو المرفوضة)
  Widget _buildConnectionRequests() {
    if (user == null) {
      return Container(); // أو مؤشر تحميل
    }
    return StreamBuilder<QuerySnapshot>(
      stream: ParentConnectionService()
          .connectionRequestsStreamForParent(parentId: user!.uid!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var requests = snapshot.data!.docs;

        // تصفية الطلبات المعلقة والمرفوضة فقط
        var pendingOrDeclinedRequests = requests.where((request) {
          final status = request['status'].toString().toLowerCase();
          return status == 'pending' || status == 'declined';
        }).toList();

        if (pendingOrDeclinedRequests.isEmpty) {
          return Center(
            child: Text(
              "لا توجد طلبات اتصال حالياً",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          );
        }

        return Column(
          children: pendingOrDeclinedRequests.map((request) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Card(
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 3,
                child: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .where('email', isEqualTo: request['childEmail'])
                      .limit(1)
                      .get()
                      .then((querySnapshot) =>
                  querySnapshot.docs.isNotEmpty
                      ? querySnapshot.docs.first
                      : throw Exception('Child Not Found')),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListTile(
                        title: Text('جار التحميل...'),
                        subtitle: Text('جاري جلب تفاصيل الابن...'),
                      );
                    }
                    if (snapshot.hasError) {
                      return ListTile(
                        title: Text('خطأ في تحميل تفاصيل الابن'),
                        subtitle: Text(snapshot.error.toString()),
                      );
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return ListTile(
                        title: Text('الابن غير موجود'),
                        subtitle:
                        Text(request['childEmail'] ?? 'لا يوجد بريد إلكتروني'),
                      );
                    }

                    var childData =
                    snapshot.data!.data() as Map<String, dynamic>;
                    String childName =
                        childData['name'] ?? 'No name available';
                    return ListTile(
                      title: Text(childName,
                          style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(request['childEmail'] ?? ''),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: request['status'] == "Pending"
                              ? Colors.yellow
                              : Colors.red,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          request['status'] ?? '',
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // حوار لإضافة ابن جديد بواسطة البريد الإلكتروني
  void _showAddChildDialog() {
    final TextEditingController emailController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    String? errorMessage; // لتخزين رسائل الخطأ

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                "إضافة ابن جديد",
                textAlign: TextAlign.center,
              ),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: "أدخل البريد الإلكتروني للابن",
                        border: OutlineInputBorder(),
                        errorText: errorMessage,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "البريد الإلكتروني مطلوب";
                        }
                        final emailRegex = RegExp(
                            r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
                        if (!emailRegex.hasMatch(value)) {
                          return "أدخل بريد إلكتروني صالح";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding:
                      const EdgeInsets.only(right: 5.0, left: 5),
                      child: TextButton(
                        child: const Text("إلغاء"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    TextButton(
                      child: const Text("إرسال"),
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        String enteredEmail =
                        emailController.text.trim();
                        if (user != null) {
                          // استرجاع مستند الوالد
                          DocumentSnapshot parentDoc =
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user!.uid)
                              .get();
                          final List<dynamic> childrenEmailsDynamic =
                              parentDoc['children'] ?? [];
                          final List<String> childrenEmails =
                          childrenEmailsDynamic.cast<String>();
                          // التحقق مما إذا كان البريد الإلكتروني مضافاً مسبقاً
                          if (childrenEmails.contains(enteredEmail)) {
                            setState(() {
                              errorMessage =
                              "تم إضافة هذا الابن بالفعل!";
                            });
                            return;
                          }
                          // التحقق مما إذا كان الطلب مرفوضاً مسبقاً
                          QuerySnapshot declinedRequests =
                          await FirebaseFirestore.instance
                              .collection('connection_requests')
                              .where('parentId', isEqualTo: user!.uid)
                              .where('childEmail', isEqualTo: enteredEmail)
                              .where('status', isEqualTo: 'declined')
                              .get();
                          // حذف الطلب المرفوض ثم جعله قيد الانتظار
                          for (var doc in declinedRequests.docs) {
                            await doc.reference.delete();
                          }
                          // التحقق مما إذا كان الطلب قيد الانتظار بالفعل
                          QuerySnapshot pendingRequests =
                          await FirebaseFirestore.instance
                              .collection('connection_requests')
                              .where('parentId', isEqualTo: user!.uid)
                              .where('childEmail', isEqualTo: enteredEmail)
                              .where('status', isEqualTo: 'Pending')
                              .get();
                          if (pendingRequests.docs.isNotEmpty) {
                            setState(() {
                              errorMessage =
                              "الطلب قيد الانتظار بالفعل!";
                            });
                            return;
                          }
                          // التحقق مما إذا كان البريد الإلكتروني موجوداً في Firestore ضمن دور 'student'
                          QuerySnapshot studentQuery =
                          await FirebaseFirestore.instance
                              .collection('users')
                              .where('email', isEqualTo: enteredEmail)
                              .where('userRole', isEqualTo: 'student')
                              .get();
                          if (studentQuery.docs.isEmpty) {
                            setState(() {
                              errorMessage =
                              "البريد الإلكتروني المدخل غير موجود!";
                            });
                            return;
                          }
                          // إرسال طلب الاتصال إذا مرت جميع الشيكات
                          await ParentConnectionService()
                              .sendConnectionRequest(
                            parentName: user!.name,
                            parentId: user!.uid!,
                            parentEmail: user!.email,
                            childEmail: enteredEmail,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'تم إرسال طلبك بنجاح!')),
                          );
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
