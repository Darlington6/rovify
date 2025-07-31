import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rovify/presentation/common/profile_drawer.dart';

void main() {
  group('ProfileDrawer Widget', () {
    testWidgets('renders display name, email, and avatar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            drawer: ProfileDrawer(
              displayName: 'Test User',
              email: 'test@example.com',
              avatarUrl: null,
              isCreator: false,
              userId: 'user123',
            ),
          ),
        ),
      );
      // Open the drawer
      Scaffold.of(tester.element(find.byType(ProfileDrawer))).openDrawer();
      await tester.pumpAndSettle();
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('shows wallet address if provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            drawer: ProfileDrawer(
              displayName: 'Test User',
              email: 'test@example.com',
              avatarUrl: null,
              isCreator: false,
              userId: 'user123',
              walletAddress: '0x1234567890abcdef',
            ),
          ),
        ),
      );
      // Open the drawer
      Scaffold.of(tester.element(find.byType(ProfileDrawer))).openDrawer();
      await tester.pumpAndSettle();
      expect(find.textContaining('Wallet:'), findsOneWidget);
    });
  });
}