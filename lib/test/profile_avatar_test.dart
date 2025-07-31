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
      expect(find.text('A'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
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
      // Should not show initial if avatarUrl is provided
      expect(find.text('B'), findsNothing);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('tapping avatar opens end drawer', (WidgetTester tester) async {
      final scaffoldKey = GlobalKey<ScaffoldState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            key: scaffoldKey,
            endDrawer: const Drawer(child: Text('Drawer')), // Dummy drawer
            body: const ProfileAvatar(
              displayName: 'Charlie',
              email: 'charlie@example.com',
            ),
          ),
        ),
      );
      await tester.tap(find.byType(ProfileAvatar));
      await tester.pumpAndSettle();
      expect(find.text('Drawer'), findsOneWidget);
    });
  });
}