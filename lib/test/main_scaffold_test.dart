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
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Text), findsWidgets); // Title and body
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
      // Tap the ProfileAvatar (should be only one in actions)
      await tester.tap(find.byType(GestureDetector).last);
      await tester.pumpAndSettle();
      // The drawer should open (ProfileDrawer is present)
      expect(find.byType(Drawer), findsOneWidget);
    });
  });
}