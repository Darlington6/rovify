import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LocationBar extends StatelessWidget {
  const LocationBar({super.key});

  Future<Map<String, dynamic>?> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    return doc.exists ? doc.data() : null;
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchUserData(),
      builder: (context, snapshot) {
        final avatarUrl = snapshot.data?['avatarUrl'];

        return Container(
          width: double.infinity,
          height: 76 + topPadding,
          padding: EdgeInsets.only(
            top: topPadding + 10,
            left: 16,
            right: 16,
            bottom: 8,
          ),
          decoration: const BoxDecoration(color: Colors.white),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Builder(
                builder: (context) {
                  return GestureDetector(
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage: avatarUrl != null
                          ? NetworkImage(avatarUrl)
                          : const AssetImage('assets/download.jpg') as ImageProvider,
                    ),
                  );
                },
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Location',
                    style: TextStyle(
                      fontFamily: 'Onest',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    children: const [
                      Icon(Icons.location_on, size: 18, color: Colors.black),
                      SizedBox(width: 4),
                      Text(
                        'Nairobi, Kenya',
                        style: TextStyle(
                          fontFamily: 'Onest',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.black),
                iconSize: 30,
                onPressed: () {
                  // TODO: Implement notifications
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
