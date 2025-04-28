import 'package:flutter/material.dart';
class DashboardBottom extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;

  const DashboardBottom({required this.screenWidth, required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: screenHeight * 0,
          left: -screenWidth * 0.1,
          right: -screenWidth * 0.1,
          child: Image.asset(
            'assets/downgreen_background.png',
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
            'assets/downblue_background.png',
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
            'assets/BB.png',
            fit: BoxFit.cover,
            width: screenWidth * 1.2,
            height: screenHeight * 0.3,
          ),
        ),
      ],
    );
  }
}
