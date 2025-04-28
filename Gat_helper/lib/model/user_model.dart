import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? uid;
  final String name;
  final String email;
  final String userRole;
  final String gender;
  final String? gradeLevel;
  final DateTime createdAt;
  final double? rating; // Only for tutors
  late final String? avatar;
  List<String> children;  // For parent role, a list of child emails

  UserModel({
    this.uid,
    required this.name,
    required this.email,
    required this.userRole,
    required this.gender,
    this.gradeLevel,
    required this.createdAt,
    this.rating,
    this.avatar,
    this.children = const [],
  });

  // Convert model to Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "userRole": userRole,
      "gender": gender,
      "gradeLevel": gradeLevel,
      "createdAt": createdAt.toIso8601String(),
      "rating": rating,
      "avatar": avatar,
      "children": children,
    };
  }
  // Convert Firestore JSON to model
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json["uid"],
      name: json["name"],
      email: json["email"],
      userRole: json["userRole"],
      gender: json["gender"],
      gradeLevel: json["gradeLevel"],
      createdAt:json['createdAt'] is Timestamp ? (json['createdAt'] as Timestamp).toDate() : DateTime.parse(json["createdAt"]),
      rating: json["rating"],
      avatar: json['avatar'],
      children: List<String>.from(json['children'] ?? []),
    );
  }

}