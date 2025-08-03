import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rovify/presentation/common/my_tickets_screen.dart';

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
          // Use Container for better control
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Important: minimize height
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
                const SizedBox(height: 12),
                // Wrap text in Flexible to prevent overflow
                Flexible(
                  child: Text(
                    displayName,
                    style: const TextStyle(
                      fontFamily: 'Onest',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    email,
                    style: const TextStyle(fontFamily: 'Onest', fontSize: 14, color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (walletAddress != null) ...[
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      _formatWalletAddress(walletAddress!),
                      style: const TextStyle(
                        fontFamily: 'Onest',
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
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
      
          // New Menu Item: Edit Profile
          _buildMenuItem(
            context,
            icon: Icons.edit,
            title: 'Edit Profile',
            onTap: () {
              context.pop(); // Close drawer
              context.pushNamed('updateProfile'); // Navigate to /updateProfile
            },
          ),

          // New Menu Item: My Tickets
          _buildMenuItem(
            context,
            icon: Icons.confirmation_number,
            title: 'My Tickets',
            onTap: () {
              context.pop(); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyTicketsScreen(),
                ),
              );
            },
          ),
      
          _buildMenuItem(context, icon: Icons.auto_graph, title: 'Vibemeter'),
          _buildMenuItem(context, icon: Icons.account_balance_wallet, title: 'DAO'),
          _buildMenuItem(context, icon: Icons.wallet, title: 'Wallet'),

          _buildMenuItem(
            context,
            icon: Icons.settings,
            title: 'Settings & Privacy',
            onTap: () {
              context.pop(); // Close drawer
              context.pushNamed('settingsPrivacy');
            },
          ),
      
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
                context.pushNamed('addEvent', extra: userId);},
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
            onTap: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Confirm Logout'),
                  content: Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
      
              if (shouldLogout != true) return;
              if (!context.mounted) return;
              context.pop(); // Close drawer
      
              try {
                await FirebaseAuth.instance.signOut();
                if (!context.mounted) return;
                context.goNamed('splash');
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logout failed: $e')),
                );
              }
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

  String _formatWalletAddress(String address) {
    // Handle empty or very short addresses
    if (address.isEmpty) {
      return 'Wallet: Not set';
    }
    
    // If address is too short to truncate meaningfully, show it as is
    if (address.length <= 10) {
      return 'Wallet: $address';
    }
    
    // Standard truncation for longer addresses
    return 'Wallet: ${address.substring(0, 6)}...${address.substring(address.length - 4)}';
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