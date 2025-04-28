import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../model/user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';



class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;


  // Create new user (Sign Up)
  Future<User?> createNewUser(UserModel userModel, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: userModel.email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Store user data in Firestore
        userModel.uid = user.uid;
        await _firestore.collection("users").doc(user.uid).set(userModel.toJson());
      }

      return user;
    } catch (e) {
      throw FirebaseAuthException(
        code: "sign_up_error",
        message: e.toString(),
      );
    }
  }

  // Login user (Sign In)
  Future<UserModel?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Call the function after login
      //await saveParentFCMToken();

      User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        // Fetch user data from Firestore
        final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (userDoc.exists) {
          return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
        } else {
          throw FirebaseAuthException(
            code: 'user_not_found',
            message: 'User not found in Firestore.',
          );
        }
      } else {
        return null;
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw FirebaseAuthException(
          code: e.code,
          message: e.message ?? 'An error occurred during sign-in.',
        );
      } else {
        throw FirebaseAuthException(
          code: 'sign_in_error',
          message: e.toString(),
        );
      }
    }
  }

  // Logout user (Sign Out)
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw FirebaseAuthException(
        code: "sign_out_error",
        message: e.toString(),
      );
    }
  }


  // Get current logged-in user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<UserModel?> getUserDetails() async {
    try {
      final doc = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print(e);
      return null;
    }
  }
  // Method to upload profile picture to Firebase Storage
  Future<String> uploadProfilePicture(File image) async {
    try {
      // Create a unique filename for the image
      String fileName = 'profile_pictures/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload the image to Firebase Storage
      TaskSnapshot snapshot = await FirebaseStorage.instance
          .ref(fileName)
          .putFile(image);

      // Get the URL of the uploaded image
      String imageUrl = await snapshot.ref.getDownloadURL();

      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }



  // Reset password (Send password reset email)
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw FirebaseAuthException(
        code: "reset_password_error",
        message: e.toString(),
      );
    }
  }

  // Update user password
  Future<void> updatePassword(String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      }
    } catch (e) {
      throw FirebaseAuthException(
        code: "update_password_error",
        message: e.toString(),
      );
    }
  }



  // Delete user account (with re-authentication)
  Future<void> deleteUser(String password) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
        await _firestore.collection('users').doc(user.uid).delete();
        await user.delete();
      }
    } catch (e) {
      throw FirebaseAuthException(
        code: "delete_user_error",
        message: e.toString(),
      );
    }
  }



  // Update user details method (You have it, make sure it's working)
  Future<void> updateUserDetails(UserModel user) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': user.name,
        'email': user.email,
        'gender': user.gender,
        'gradeLevel': user.gradeLevel,
        'rating': user.rating,
        'avatar': user.avatar, // This should be the URL now
      });
    } catch (e) {
      print('Error updating user details: $e');
    }
  }



}