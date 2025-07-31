import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:rovify/presentation/pages/explore/widgets/location_bar.dart';
import 'package:rovify/presentation/pages/explore/widgets/event_list_with_search.dart';
import 'package:rovify/presentation/pages/explore/widgets/bottom_navigation.dart';
import 'package:rovify/presentation/pages/explore/widgets/profile_drawer.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  Future<Map<String, dynamic>?> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    return doc.data();
  }



  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: fetchUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userData = snapshot.data;
        final userName = userData?['displayName'] ?? 'Guest';
        final userEmail = userData?['email'] ?? '';
        final profileImageUrl = userData?['avatarUrl'];

        return Scaffold(
          drawer: ProfileDrawer(
            displayName: userName,
            email: userEmail,
            avatarUrl: profileImageUrl,
            isCreator: userData?['isCreator'] ?? false,
            userId: FirebaseAuth.instance.currentUser?.uid ?? '',
          ),
          body: SafeArea(
            child: Column(
              children: const [
                LocationBar(),
                Expanded(child: EventListWithSearch()),
              ],
            ),
          ),
          bottomNavigationBar: const BottomNavBar(),
        );
      },
    );
  }
}
