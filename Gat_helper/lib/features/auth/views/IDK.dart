import 'package:flutter/material.dart';
import 'dart:math';

class RankClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double cornerSize = size.width * 0.2; // حجم الزاوية المائلة
    path.moveTo(0, size.height);
    path.lineTo(0, cornerSize);
    path.lineTo(cornerSize, 0);
    path.lineTo(size.width - cornerSize, 0);
    path.lineTo(size.width, cornerSize);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// قسم قائمة اللاعبين
Widget _buildPlayerListSection() {
  return Expanded(
    child: Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: ListView(
        children: [
          _buildPlayerTile("Nora", "590 points", "4", "assets/avatar4.png"),
          _buildPlayerTile("Ahmed", "448 points", "5", "assets/avatar5.png"),
          _buildPlayerTile("Hind", "448 points", "6", "assets/avatar6.png"),
        ],
      ),
    ),
  );
}

/// عنصر ترتيب اللاعبين في القائمة
Widget _buildPlayerTile(String name, String points, String rank, String avatar) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 8),
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        CircleAvatar(radius: 24, backgroundImage: AssetImage(avatar)),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(points, style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        CircleAvatar(
          radius: 12,
          backgroundColor: Colors.grey[300],
          child: Text(rank, style: TextStyle(color: Colors.black, fontSize: 12)),
        ),
      ],
    ),
  );
}
