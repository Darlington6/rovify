import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rovify/presentation/common/profile_drawer.dart';
import 'package:rovify/presentation/screens/home/widgets/explore/event_list_with_search.dart';

class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});

  Future<Map<String, dynamic>?> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: fetchUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userData = snapshot.data;
        final userName = userData?['displayName'] ?? 'Guest';
        final userEmail = userData?['email'] ?? '';
        final profileImageUrl = userData?['avatarUrl'];

        return Scaffold(
          backgroundColor: Colors.white,
          drawer: ProfileDrawer(
            displayName: userName,
            email: userEmail,
            avatarUrl: profileImageUrl,
            isCreator: userData?['isCreator'] ?? false,
            userId: FirebaseAuth.instance.currentUser?.uid ?? '',
          ),
          body: SafeArea(
            child: CustomScrollView(
              slivers: [                
                // Main content with constraints
                SliverFillRemaining(
                  hasScrollBody: true,
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - 
                                 MediaQuery.of(context).padding.top -
                                 MediaQuery.of(context).padding.bottom,
                    ),
                    child: const EventListWithSearch(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}