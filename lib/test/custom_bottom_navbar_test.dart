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
      final bottomNavBar = find.byType(BottomNavigationBar);
      expect(bottomNavBar, findsOneWidget);
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
      // Tap the second item (Stream)
      await tester.tap(find.text('Stream'));
      await tester.pumpAndSettle();
      expect(tappedIndex, 1);
    });
  });
}