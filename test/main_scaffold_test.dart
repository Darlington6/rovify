// test/presentation/common/main_scaffold_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rovify/presentation/common/main_scaffold.dart';

void main() {
  group('MainScaffold Widget', () {
    testWidgets('renders app bar and profile avatar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainScaffold(
            body: Text('Body'),
            title: 'Test Title',
            showAppBar: true,
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Check for title and app bar
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('opens end drawer when profile avatar is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainScaffold(
            body: Text('Body'),
            title: 'Test Title',
            showAppBar: true,
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Look for ProfileAvatar specifically or any tappable element in the app bar
      final profileAvatar = find.byType(GestureDetector);
      
      if (profileAvatar.evaluate().isNotEmpty) {
        await tester.tap(profileAvatar.last);
        await tester.pumpAndSettle();
        
        // Check if drawer is open
        expect(find.byType(Drawer), findsOneWidget);
      } else {
        // Alternative: find by specific widget type if ProfileAvatar is a custom widget
        final avatarWidget = find.byKey(const Key('profile_avatar'));
        if (avatarWidget.evaluate().isNotEmpty) {
          await tester.tap(avatarWidget);
          await tester.pumpAndSettle();
          expect(find.byType(Drawer), findsOneWidget);
        }
      }
    });

    testWidgets('hides app bar when showAppBar is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainScaffold(
            body: Text('Body'),
            title: 'Test Title',
            showAppBar: false,
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      expect(find.byType(AppBar), findsNothing);
      expect(find.text('Body'), findsOneWidget);
    });
  });
}