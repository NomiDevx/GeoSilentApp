import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../theme.dart';

class CustomCurvedNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomCurvedNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      backgroundColor: Colors.transparent,
      color: AppTheme.primaryColor,
      buttonBackgroundColor: AppTheme.primaryColor,
      height: 60,
      animationDuration: const Duration(milliseconds: 300),
      animationCurve: Curves.easeInOut,
      index: currentIndex,
      items: const [
        Icon(Icons.home, size: 30, color: Colors.white),
        Icon(Icons.location_on, size: 30, color: Colors.white),
        Icon(Icons.layers, size: 30, color: Colors.white),
        Icon(Icons.person, size: 30, color: Colors.white),
      ],
      onTap: onTap,
    );
  }
}
