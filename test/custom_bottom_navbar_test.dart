// test/presentation/common/custom_bottom_navbar_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rovify/presentation/common/custom_bottom_navbar.dart';

void main() {
  group('CustomBottomNavBar Widget', () {
    testWidgets('renders and highlights selected index', (WidgetTester tester) async {
      int selectedIndex = 2;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBar(
              selectedIndex: selectedIndex,
              onTap: (_) {},
            ),
          ),
        ),
      );

      // Wait for the widget to be built
      await tester.pumpAndSettle();
      
      // Find the BottomNavigationBar
      final bottomNavBar = find.byType(BottomNavigationBar);
      expect(bottomNavBar, findsOneWidget);
      
      // Check the selected index
      final navBarWidget = tester.widget<BottomNavigationBar>(bottomNavBar);
      expect(navBarWidget.currentIndex, selectedIndex);
    });

    testWidgets('calls onTap when item is tapped', (WidgetTester tester) async {
      int tappedIndex = -1;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBar(
              selectedIndex: 0,
              onTap: (index) {
                tappedIndex = index;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Find all BottomNavigationBarItem widgets
      final bottomNavItems = find.byType(BottomNavigationBar);
      expect(bottomNavItems, findsOneWidget);
      
      // Tap the second item by finding the specific area
      final navBar = tester.widget<BottomNavigationBar>(bottomNavItems);
      
      // Tap at the second item's position (approximate)
      if (navBar.items.length > 1) {
        final center = tester.getCenter(bottomNavItems);
        final itemWidth = tester.getSize(bottomNavItems).width / navBar.items.length;
        await tester.tapAt(Offset(center.dx - itemWidth/2 + itemWidth, center.dy));
        await tester.pumpAndSettle();
        
        expect(tappedIndex, 1);
      }
    });
  });
}