import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rovify/presentation/pages/explore/explore_page.dart';
import 'package:rovify/presentation/pages/event_form_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 2) { // Create button
      final user = _auth.currentUser;
      if (user != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventFormScreen(userId: user.uid),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to create events')),
        );
      }
      return;
    }

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ExplorePage()),
        );
        break;
      case 1:
        // Handle Stream navigation
        break;
      case 3:
        // Handle Marketplace navigation
        break;
      case 4:
        // Handle Echo navigation
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedLabelStyle: const TextStyle(
        fontFamily: 'Onest',
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'Onest',
        fontWeight: FontWeight.w500,
      ),
      currentIndex: _selectedIndex,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      onTap: _onItemTapped,
      items: [
        BottomNavigationBarItem(
          icon: _selectedIndex == 0
              ? const Icon(Icons.search)
              : const Icon(Icons.search_outlined),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: _selectedIndex == 1
              ? const Icon(Icons.stream)
              : const Icon(Icons.stream_outlined),
          label: 'Stream',
        ),
        BottomNavigationBarItem(
          icon: const Icon(
            Icons.add_circle,
            color: Colors.orange,
            size: 32,
          ),
          label: 'Create',
        ),
        BottomNavigationBarItem(
          icon: _selectedIndex == 3
              ? const Icon(Icons.shopping_bag)
              : const Icon(Icons.shopping_bag_outlined),
          label: 'Marketplace',
        ),
        BottomNavigationBarItem(
          icon: _selectedIndex == 4
              ? const Icon(Icons.chat_bubble)
              : const Icon(Icons.chat_bubble_outline),
          label: 'Echo',
        ),
      ],
    );
  }
}