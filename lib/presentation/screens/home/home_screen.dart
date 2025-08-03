import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rovify/presentation/common/common_appbar.dart';
import 'package:rovify/presentation/common/custom_bottom_navbar.dart';
import 'package:rovify/presentation/common/profile_drawer.dart';
import 'package:rovify/presentation/screens/home/tabs/create_tab.dart';
import 'package:rovify/presentation/screens/home/tabs/echo_tab.dart';
import 'package:rovify/presentation/screens/home/tabs/explore_tab.dart';
import 'package:rovify/presentation/screens/home/tabs/marketplace_tab.dart';
import 'package:rovify/presentation/screens/home/tabs/stream_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onTabSelected(int index) {
    if (index == 2) {
      // Show bottom sheet from CreateTab
      CreateTab.showCreateBottomSheet(context, (){}, null);
      return; // Skip setting index or rebuilding screen
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _screens = [
    const ExploreTab(),   // Default screen
    const StreamTab(),    // Livestreams tab
    const SizedBox(),     // Put here to fill in for the indexing
    const MarketplaceTab(), // Marketplace Tab
    const EchoTab(),        // Echo Tab
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: const CommonAppBar(),
      drawer: user != null
          ? StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show loading drawer while fetching data
                  return const Drawer(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  // Show error drawer
                  return const Drawer(
                    child: Center(
                      child: Text('Error loading profile'),
                    ),
                  );
                }

                // Extract user data with fallbacks
                final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
                
                final displayName = userData['displayName'] as String? ?? 'Unknown User';
                final email = user.email ?? 'No email';
                final avatarUrl = userData['avatarUrl'] as String?;
                final walletAddress = userData['walletAddress'] as String?;
                final isCreator = userData['isCreator'] as bool? ?? false; // Update dynamically!
                final interests = (userData['interests'] as List<dynamic>?)?.cast<String>();

                return ProfileDrawer(
                  userId: user.uid,
                  displayName: displayName,
                  email: email,
                  avatarUrl: avatarUrl,
                  walletAddress: walletAddress,
                  isCreator: isCreator, // Dynamically updates when Firestore data changes
                  interests: interests,
                );
              },
            )
          : const Drawer(
              child: Center(
                child: Text('Please log in to view profile'),
              ),
            ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}