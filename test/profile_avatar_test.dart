// test/presentation/common/profile_avatar_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rovify/presentation/common/profile_avatar.dart';

void main() {
  group('ProfileAvatar Widget', () {
    testWidgets('renders initial when avatarUrl is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileAvatar(
              displayName: 'Alice',
              email: 'alice@example.com',
              avatarUrl: null,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      expect(find.text('A'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('renders empty initial when displayName is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileAvatar(
              displayName: '',
              email: 'alice@example.com',
              avatarUrl: null,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      expect(find.byType(CircleAvatar), findsOneWidget);
      // Should show some default when displayName is null
    });

    testWidgets('uses avatarUrl when provided', (WidgetTester tester) async {
      const testUrl = 'https://example.com/avatar.png';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileAvatar(
              displayName: 'Bob',
              email: 'bob@example.com',
              avatarUrl: testUrl,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Should not show initial if avatarUrl is provided
      expect(find.text('B'), findsNothing);
      expect(find.byType(CircleAvatar), findsOneWidget);
      
      // Check if NetworkImage is being used
      final circleAvatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(circleAvatar.backgroundImage, isA<NetworkImage>());
    });

    testWidgets('tapping avatar opens end drawer', (WidgetTester tester) async {
      final scaffoldKey = GlobalKey<ScaffoldState>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            key: scaffoldKey,
            endDrawer: const Drawer(child: Text('Drawer')),
            body: const ProfileAvatar(
              displayName: 'Charlie',
              email: 'charlie@example.com',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Tap the ProfileAvatar
      await tester.tap(find.byType(ProfileAvatar));
      await tester.pumpAndSettle();
      
      // Check if drawer is open
      expect(find.text('Drawer'), findsOneWidget);
    });
  });
}