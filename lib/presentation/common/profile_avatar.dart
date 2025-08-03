import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String displayName;
  final String email;

  const ProfileAvatar({
    super.key,
    required this.displayName,
    required this.email,
    this.avatarUrl
  });

  @override
  Widget build(BuildContext context) {
    final avatarColor = _getAvatarColor(displayName);

    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: () => Scaffold.of(context).openEndDrawer(),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: avatarColor,
            backgroundImage: avatarUrl != null
                ? NetworkImage(avatarUrl!)
                : null,
            child: avatarUrl == null
                ? Text(
                    _getInitial(displayName),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
        );
      },
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

  String _getInitial(String name) {
    return name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
  }
}