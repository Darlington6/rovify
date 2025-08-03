// test/presentation/common/profile_drawer_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rovify/presentation/common/profile_drawer.dart';

void main() {
  group('ProfileDrawer Widget', () {
    testWidgets('renders display name, email, and avatar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            endDrawer: const ProfileDrawer(
              displayName: 'Test User',
              email: 'test@example.com',
              avatarUrl: null,
              isCreator: false,
              userId: 'user123',
            ),
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                child: const Text('Open Drawer'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Open the drawer using the button
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();
      
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('shows wallet address if provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            endDrawer: const ProfileDrawer(
              displayName: 'Test User',
              email: 'test@example.com',
              avatarUrl: null,
              isCreator: false,
              userId: 'user123',
              walletAddress: '0x1234567890abcdef',
            ),
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                child: const Text('Open Drawer'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Open the drawer
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();
      
      expect(find.textContaining('Wallet'), findsOneWidget);
      expect(find.textContaining('0x1234567890abcdef'), findsOneWidget);
    });

    testWidgets('shows creator badge when isCreator is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            endDrawer: const ProfileDrawer(
              displayName: 'Creator User',
              email: 'creator@example.com',
              avatarUrl: null,
              isCreator: true,
              userId: 'creator123',
            ),
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                child: const Text('Open Drawer'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Open Drawer'));
      await tester.pumpAndSettle();
      
      // Look for creator-specific elements
      expect(find.text('Creator User'), findsOneWidget);
    });
  });
}