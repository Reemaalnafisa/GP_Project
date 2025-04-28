import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gat_helper_app/features/auth/views/Parent_DashBoard.dart';
import 'package:gat_helper_app/features/common/edit_profile_page.dart';
import '../../../core/services/Parent_Service.dart';
import '../../../core/services/auth_service.dart';
import '../../../model/user_model.dart';
import 'Parent_home_pageAR.dart';
import '../../common/login_page.dart';

class ParentHomePage extends StatefulWidget {
  const ParentHomePage({super.key});

  @override
  _ParentHomePageState createState() => _ParentHomePageState();
}

class _ParentHomePageState extends State<ParentHomePage> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  bool isNotificationEnabled = false;


  // List for children approved
  List<Map<String, String>> approvedChildren = [];

  // List for children pending or declined
  List<Map<String, String>> pendingChildren = [];


  UserModel? user;

  @override
  void initState() {
    AuthService().getUserDetails().then((val) {
      setState(() {
        user = val;
      });
    });
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 200,
              width: 500,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFF284379),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundImage: user != null && user!.avatar != null
                          ? AssetImage(user!.avatar!) // If user and avatar are not null
                          : AssetImage('assets/default_avatar.jpg'), // Provide a default image if null
                      // Dynamic Avatar
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user?.name ?? '', // Dynamic Name
                      style: const TextStyle(fontSize: 20,
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
              title: const Text('Edit Profile'),
              onTap: () async {
                // When navigating to the EditProfilePage
                final updatedUser = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) =>
                      EditProfilePage(role: 'parent', initialData: {},)),
                );

                if (updatedUser != null) {
                  setState(() {
                    // Update the local user instance so the UI refreshes
                    user = updatedUser;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_mail, color: Colors.black),
              title: const Text('Contact Us'),
              onTap: () {
                _showContactUsDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Log Out'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>
                  const LoginPage(
                      userRole: 'parent')),
                );
              },
            ),
            const Spacer(),
            ListTile(
              leading: Padding(
                padding: const EdgeInsets.only(left: 85.5),
                child: Image.asset('assets/img_18.png', width: 40, height: 40),
              ),
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (_) => const ParentHomePageAR()));
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset("assets/img_23.png", fit: BoxFit.cover,
                height: 380,
                width: screenWidth),
          ),
          Positioned(
            top: 20,
            left: 10,
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
              _buildProfileHeader(), // Fixed Header
              const SizedBox(height: 60),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 1.0, left: 16.0, right: 16.0, bottom: 16.0), // Add top padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildChildrenSection(),
                        //const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Children Connection",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
                              onPressed: () {
                                _showAddChildDialog();
                              },
                            ),
                          ],
                        ),
                        _buildConnectionRequests(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )

        ],
      ),
    );
  }


  void _showContactUsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
              "Get in touch with us", textAlign: TextAlign.center),
          content: RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                    text: "If you have any questions, feel free to contact us at:\n\n",
                    style: TextStyle(color: Colors.black)),
                TextSpan(text: "GAThelper@gmail.com\n\n",
                    style: const TextStyle(fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black)),
                const TextSpan(text: "We're here to assist you!",
                    style: TextStyle(color: Colors.black)),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(child: const Text("Close"), onPressed: () {
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
            backgroundImage: user != null && user!.avatar != null
                ? AssetImage(user!.avatar!) // If user and avatar are not null
                : AssetImage('assets/default_avatar.jpg'), // Provide a default image if null
          ),
          const SizedBox(height: 10),
          const Text("Welcome", style: TextStyle(fontSize: 20, color: Colors.white70)),
          Text(user?.name ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  // This widget shows the approved children (name and avatar) in the "My Children" section.
  Widget _buildChildrenSection() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(child: Text('User not authenticated.'));
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, parentSnapshot) {
        if (!parentSnapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final parentData = parentSnapshot.data!.data() as Map<String, dynamic>;
        final List<dynamic> childrenEmailsDynamic = parentData['children'] ?? [];
        final List<String> childrenEmails = childrenEmailsDynamic.cast<String>();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "My Children",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isNotificationEnabled ? Icons.notifications_on : Icons.notifications_off,
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
                Center(
                  child: Text(
                    "No Children.",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),)
              else
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .where('email', whereIn: childrenEmails)
                      .get(),
                  builder: (context, childSnapshot) {
                    if (!childSnapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
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
                          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: childData['avatar'] != null && childData['avatar'].toString().isNotEmpty
                                      ? AssetImage(childData['avatar'])
                                      : null,
                                  child: (childData['avatar'] == null || childData['avatar'].toString().isEmpty)
                                      ? Icon(Icons.person, size: 30)
                                      : null,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        childData['name'] ?? 'Unknown',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        childEmail,
                                        style: TextStyle(fontSize: 14, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.bar_chart, color: Colors.grey),
                                  onPressed: () {
                                    String childEmail = childData['email'] ?? 'No email';
                                    String childName = childData['name'] ?? 'Unknown';

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ParentDashboard(
                                          childEmail: childEmail,
                                          childName: childName,
                                        ),
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


  // This widget displays connection requests.
  // If a request is approved, the child is added to approvedChildren (if not already added)
  // and that approved request is not shown in this list.
  Widget _buildConnectionRequests() {
    if (user == null) {
      return Container(); // or a loading indicator
    }

    return StreamBuilder<QuerySnapshot>(
      stream: ParentConnectionService().connectionRequestsStreamForParent(parentId: user!.uid!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var requests = snapshot.data!.docs;

        // Filter only pending or declined requests
        var nonApprovedRequests = requests.where((doc) {
          var status = doc['status'].toString().toLowerCase();
          return status == 'pending' || status == 'declined';
        }).toList();

        // Show message if no non-approved requests
        if (nonApprovedRequests.isEmpty) {
          return Center(
            child: Text(
              "No requests at the moment.",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          );
        }

        return Column(
          children: nonApprovedRequests.map((request) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
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
                        title: Text('Loading...'),
                        subtitle: Text('Fetching child details...'),
                      );
                    }
                    if (snapshot.hasError) {
                      return ListTile(
                        title: Text('Error loading child details'),
                        subtitle: Text(snapshot.error.toString()),
                      );
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return ListTile(
                        title: Text('Child Not Found'),
                        subtitle: Text(
                            request['childEmail'] ?? 'No email available'),
                      );
                    }
                    var childData = snapshot.data!.data() as Map<String, dynamic>;
                    String childName = childData['name'] ?? 'No name available';
                    return ListTile(
                      title: Text(childName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(request['childEmail'] ?? ''),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                            fontSize: 14,
                          ),
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


  void _showAddChildDialog() {
    final TextEditingController emailController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    String? errorMessage; // Holds error messages

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add New Child",textAlign: TextAlign.center,),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: "Enter child's email",
                        border: OutlineInputBorder(),
                        errorText: errorMessage,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email is required";
                        }
                        final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
                        if (!emailRegex.hasMatch(value)) {
                          return "Enter a valid email address";
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
                  padding: const EdgeInsets.only(right: 5.0,left: 5), // Adds padding between buttons
                  child: TextButton(
                    child: const Text("Cancel"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                TextButton(
                  child: const Text("Submit"),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    String enteredEmail = emailController.text.trim();
                    if (user != null) {
                      // Retrieve parent's document
                      DocumentSnapshot parentDoc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user!.uid)
                          .get();

                      final List<dynamic> childrenEmailsDynamic = parentDoc['children'] ?? [];
                      final List<String> childrenEmails = childrenEmailsDynamic.cast<String>();

                      // Check if email is already added
                      if (childrenEmails.contains(enteredEmail)) {
                        setState(() {
                          errorMessage = "This child is already added!";
                        });
                        return;
                      }
                      //Check if the req declined before
                      QuerySnapshot declinedRequests = await FirebaseFirestore.instance
                          .collection('connection_requests')
                          .where('parentId', isEqualTo: user!.uid)
                          .where('childEmail', isEqualTo: enteredEmail)
                          .where('status', isEqualTo: 'declined')
                          .get();

                      // Delete declined request for the entered email then became pending
                      for (var doc in declinedRequests.docs) {
                        await doc.reference.delete();
                      }

                      // Check if a request is already pending
                      QuerySnapshot pendingRequests = await FirebaseFirestore.instance
                          .collection('connection_requests')
                          .where('parentId', isEqualTo: user!.uid)
                          .where('childEmail', isEqualTo: enteredEmail)
                          .where('status', isEqualTo: 'Pending')
                          .get();

                      if (pendingRequests.docs.isNotEmpty) {
                        setState(() {
                          errorMessage = "The request is already pending!";
                        });
                        return;
                      }

                      // Check if the entered email exists in Firestore under 'Student' role
                      QuerySnapshot studentQuery = await FirebaseFirestore.instance
                          .collection('users')
                          .where('email', isEqualTo: enteredEmail)
                          .where('userRole', isEqualTo: 'student')
                          .get();

                      if (studentQuery.docs.isEmpty) {
                        setState(() {
                          errorMessage = "The entered Email does not exist!";
                        });
                        return;
                      }

                      // Send connection request if all checks pass
                      await ParentConnectionService().sendConnectionRequest(
                        parentName: user!.name,
                        parentId: user!.uid!,
                        parentEmail: user!.email,
                        childEmail: enteredEmail,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Your request was sent successfully!')),
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

}
