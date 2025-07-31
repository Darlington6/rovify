// lib/presentation/widgets/main_scaffold.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rovify/presentation/pages/explore/widgets/profile_avatar.dart';
import 'package:rovify/presentation/pages/explore/widgets/profile_drawer.dart';

class MainScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final bool showAppBar;
  final List<Widget>? actions;

  const MainScaffold({
    super.key,
    required this.body,
    required this.title,
    this.showAppBar = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();
    final userName = user?.displayName ?? 'Guest';
    final userEmail = user?.email ?? '';
    final profileImageUrl = user?.photoURL;
    final userId = user?.uid ?? '';

    // NOTE: FirebaseAuth.User doesn't include isCreator unless you manage it separately
    // This value should come from Firestore or another state provider
    final bool isCreator = false; // Set this from Firestore in real use

    return Scaffold(
      endDrawer: ProfileDrawer(
        displayName: userName,
        email: userEmail,
        avatarUrl: profileImageUrl,
        userId: userId,
        isCreator: isCreator,
      ),
      appBar: showAppBar
          ? AppBar(
              title: Text(title),
              actions: [
                ...?actions,
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: ProfileAvatar(
                    displayName: userName.split(' ').first,
                    email: userEmail,
                    avatarUrl: profileImageUrl,
                  ),
                ),
              ],
            )
          : null,
      body: body,
    );
  }
}
