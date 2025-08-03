import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:rovify/core/constants/colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFE8E8E8),
          border: const Border(
            top: BorderSide(
              color: Color(0xFFE8E8E8), // Light grey line
              width: 0.30, // Thin line
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          // backgroundColor: const Color(0xFFE8E8E8),
          backgroundColor:  Colors.white,
          selectedItemColor: AppColors.activeTranslucentBlack,
          unselectedItemColor: AppColors.inactiveTranslucentBlack,
          selectedFontSize: 15,
          unselectedFontSize: 12,
          items: [
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage('assets/tab-images/explore.png'),
                size: 24,
              ),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage('assets/tab-images/stream.png'),
                size: 24,
              ),
              label: 'Stream',
            ),
            BottomNavigationBarItem(
              icon: Image.asset('assets/tab-images/create.png', width: 24, height: 24,),
              label: 'Create',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage('assets/tab-images/marketplace.png'),
                size: 24,
              ),
              label: 'Marketplace',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage('assets/tab-images/echo.png'),
                size: 24,
              ),
              label: 'Echo',
            ),
          ],
        ),
      ),
    );
  }
}