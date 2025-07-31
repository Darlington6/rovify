import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileDrawer extends StatelessWidget {
  final String displayName;
  final String email;
  final String? avatarUrl;
  final String? walletAddress;
  final bool isCreator;
  final List<String>? interests;
  final String userId;

  const ProfileDrawer({
    super.key,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    this.walletAddress,
    required this.isCreator,
    this.interests,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final avatarColor = _getAvatarColor(displayName);

    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: avatarColor,
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                  child: avatarUrl == null
                      ? Text(
                          displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  displayName,
                  style: const TextStyle(
                    fontFamily: 'Onest',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(fontFamily: 'Onest', fontSize: 14, color: Colors.black54),
                ),
                if (walletAddress != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Wallet: ${walletAddress!.substring(0, 6)}...${walletAddress!.substring(walletAddress!.length - 4)}',
                    style: const TextStyle(
                      fontFamily: 'Onest',
                      fontSize: 12,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Interests Section
          if (interests != null && interests!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                children: interests!
                    .map((tag) => Chip(label: Text(tag), backgroundColor: Colors.grey[200]))
                    .toList(),
              ),
            ),

          // ✨ New Menu Item: Edit Profile
          _buildMenuItem(
            context,
            icon: Icons.edit,
            title: 'Edit Profile',
            onTap: () {
              context.pop(); // Close drawer
              context.pushNamed('updateProfile'); // Navigate to /updateProfile
            },
          ),

          _buildMenuItem(context, icon: Icons.auto_graph, title: 'Vibemeter'),
          _buildMenuItem(context, icon: Icons.account_balance_wallet, title: 'DAO'),
          _buildMenuItem(context, icon: Icons.wallet, title: 'Wallet'),
          _buildMenuItem(context, icon: Icons.settings, title: 'Settings & Privacy'),

          const Divider(height: 1),

          // Creator Section
          if (isCreator) ...[
            _buildMenuItem(
              context,
              icon: Icons.dashboard,
              title: 'Creator Dashboard',
              onTap: () {
                context.pop();
                context.pushNamed('creatorDashboard', extra: userId);
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.add_circle_outline,
              title: 'Create Event',
              onTap: () {
                context.pop();
                context.pushNamed('addEvent');
              },
            ),
            const Divider(height: 1),
          ] else ...[
            _buildMenuItem(
              context,
              icon: Icons.add_circle_outline,
              title: 'Become a Creator',
              onTap: () {
                context.pop();
                context.pushNamed('becomeCreator', extra: userId);
              },
            ),
            const Divider(height: 1),
          ],

          _buildMenuItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            color: Colors.red,
            onTap: () {
              // TODO: Implement logout functionality
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Color? color,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black),
      title: Text(
        title,
        style: TextStyle(fontFamily: 'Onest', fontSize: 16, color: color ?? Colors.black),
      ),
      onTap: onTap ?? () => context.pop(),
    );
  }

  Color _getAvatarColor(String name) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];
    final index = name.isEmpty ? 0 : name.codeUnitAt(0) % colors.length;
    return colors[index];
  }
}
