import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rovify/presentation/common/common_appbar.dart';
import 'package:rovify/presentation/common/profile_drawer.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

  String selectedCategory = 'Popular';
  bool isSearchFocused = false;

  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> categories = [
    {'name': 'Popular', 'icon': Icons.star, 'color': Colors.orange},
    {'name': 'Nightlife', 'icon': Icons.local_bar, 'color': Colors.purple},
    {'name': 'Music', 'icon': Icons.music_note, 'color': Colors.blue},
    {'name': 'Gaming', 'icon': Icons.sports_esports, 'color': Colors.teal},
    {'name': 'Culture', 'icon': Icons.museum, 'color': Colors.indigo},
  ];

  final List<Map<String, dynamic>> mapMarkers = [
    {
      'id': '1',
      'name': 'John Doe',
      'image':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
      'category': 'Popular',
      'color': Colors.orange,
      'position': {'lat': -1.2921, 'lng': 36.8219},
      'activity': 'Coffee at Java House',
    },
    {
      'id': '2',
      'name': 'Sarah Kim',
      'image':
          'https://images.unsplash.com/photo-1494790108755-2616b9dc00a5?w=100&h=100&fit=crop&crop=face',
      'category': 'Nightlife',
      'color': Colors.purple,
      'position': {'lat': -1.2876, 'lng': 36.8308},
      'activity': 'At Kiza Lounge',
    },
    {
      'id': '3',
      'name': 'Mike Johnson',
      'image':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop&crop=face',
      'category': 'Gaming',
      'color': Colors.teal,
      'position': {'lat': -1.3028, 'lng': 36.7806},
      'activity': 'Gaming at Cyber Cafe',
    },
    {
      'id': '4',
      'name': 'Lisa Wang',
      'image':
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop&crop=face',
      'category': 'Music',
      'color': Colors.blue,
      'position': {'lat': -1.2695, 'lng': 36.8147},
      'activity': 'Live music at Blankets & Wine',
    },
    {
      'id': '5',
      'name': 'Alex Brown',
      'image':
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face',
      'category': 'Culture',
      'color': Colors.indigo,
      'position': {'lat': -1.2741, 'lng': 36.8028},
      'activity': 'National Museum visit',
    },
    {
      'id': '6',
      'name': 'Emma Davis',
      'image':
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100&h=100&fit=crop&crop=face',
      'category': 'Popular',
      'color': Colors.orange,
      'position': {'lat': -1.3163, 'lng': 36.8526},
      'activity': 'Shopping at Sarit Centre',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredMarkers {
    if (selectedCategory == 'Popular') return mapMarkers;
    return mapMarkers
        .where((marker) => marker['category'] == selectedCategory)
        .toList();
  }

  void _showMarkerDetails(Map<String, dynamic> marker) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: marker['color'], width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(marker['image']),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        marker['name'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        marker['activity'],
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: marker['color'].withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          marker['category'],
                          style: TextStyle(
                            color: marker['color'],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showSnackBar(
                        'Starting chat with ${marker['name']}',
                        Colors.blue,
                        Icons.chat,
                      );
                    },
                    icon: Icon(Icons.chat_bubble, color: Colors.white),
                    label: Text(
                      'Message',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showSnackBar(
                        'Getting directions to ${marker['name']}',
                        Colors.green,
                        Icons.directions,
                      );
                    },
                    icon: Icon(Icons.directions, color: Colors.white),
                    label: Text(
                      'Directions',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildHeader() {
    return CommonAppBar();
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onTap: () {
          setState(() => isSearchFocused = true);
          HapticFeedback.selectionClick();
        },
        onSubmitted: (value) {
          setState(() => isSearchFocused = false);
          _showSnackBar('Searching for: $value', Colors.blue, Icons.search);
        },
        decoration: InputDecoration(
          hintText: 'Find your moments',
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return SizedBox(
      height: 80,
      child: isLandscape 
        ? Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: categories.map((category) => Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  child: _buildCategory(category),
                ),
              )).toList(),
            ),
          )
        : ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) => _buildCategory(categories[index]),
          ),
    );
  }

  Widget _buildCategory(Map<String, dynamic> category) {
    final isSelected = selectedCategory == category['name'];
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return GestureDetector(
      onTap: () {
        setState(() => selectedCategory = category['name']);
        HapticFeedback.selectionClick();
        _showSnackBar(
          'Showing ${category['name']} locations',
          category['color'],
          category['icon'],
        );
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: isLandscape ? EdgeInsets.zero : EdgeInsets.only(right: 16),
        padding: EdgeInsets.symmetric(horizontal: isLandscape ? 8 : 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? category['color'] : Colors.white,
          borderRadius: BorderRadius.circular(isLandscape ? 16 : 20),
          border: Border.all(
            color: isSelected ? category['color'] : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: category['color'].withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category['icon'],
              color: isSelected ? Colors.white : category['color'],
              size: 24,
            ),
            SizedBox(height: 4),
            FittedBox(
              child: Text(
                category['name'],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMap() {
    return Flexible(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue[100]!,
                      Colors.blue[50]!,
                      Colors.grey[100]!,
                    ],
                  ),
                ),
                child: CustomPaint(painter: MapPainter()),
              ),
              ...filteredMarkers.map((marker) => _buildMapMarker(marker)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapMarker(Map<String, dynamic> marker) {
    final random = (marker['id'].hashCode % 100) / 100;
    final left = 50.0 + (MediaQuery.of(context).size.width - 150) * random;
    final top = 50.0 + 200 * ((marker['id'].hashCode % 50) / 50);

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _showMarkerDetails(marker);
        },
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: marker['color'].withValues(alpha: 0.4),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: marker['color'], width: 3),
                  color: Colors.white,
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(marker['image']),
                ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: marker['color'],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    categories.firstWhere(
                      (cat) => cat['name'] == marker['category'],
                    )['icon'],
                    size: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoBackButton() {
    return Container(
      margin: EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 8,
        ),
        child: Text(
          'Go Back',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

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
        final walletAddress = userData?['walletAddress'] as String?;
        final interests = (userData?['interests'] as List<dynamic>?)?.cast<String>();

        return Scaffold(
          drawer: ProfileDrawer(
            displayName: userName,
            email: userEmail,
            avatarUrl: profileImageUrl,
            isCreator: userData?['isCreator'] ?? false,
            walletAddress: walletAddress,
            interests: interests,
            userId: FirebaseAuth.instance.currentUser?.uid ?? '',
          ),
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    FadeTransition(opacity: _fadeController, child: _buildSearchBar()),
                    SlideTransition(
                      position: Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
                          .animate(
                            CurvedAnimation(
                              parent: _slideController,
                              curve: Curves.easeOutBack,
                            ),
                          ),
                      child: _buildCategories(),
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: _buildMap(),
                    ),
                    _buildGoBackButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
      }
    );
  }
  }

  class MapPainter extends CustomPainter {
    @override
    void paint(Canvas canvas, Size size) {
      final paint = Paint()
        ..color = Colors.grey[300]!
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      final random = [0.2, 0.4, 0.6, 0.8, 0.3, 0.7, 0.1, 0.9, 0.5];

      for (int i = 0; i < 8; i++) {
        final path = Path();
        final startX = size.width * random[i % random.length];
        final startY = size.height * random[(i + 1) % random.length];

        path.moveTo(startX, startY);

        for (int j = 1; j < 4; j++) {
          final x = size.width * random[(i + j) % random.length];
          final y = size.height * random[(i + j + 2) % random.length];
          path.lineTo(x, y);
        }

        canvas.drawPath(path, paint);
      }

      final textStyle = TextStyle(
        color: Colors.grey[400],
        fontSize: 10,
        fontWeight: FontWeight.w500,
      );

      final locations = ['WESTLANDS', 'KILIMANI', 'KAREN', 'NYARI', 'KILELESHWA'];
      for (int i = 0; i < locations.length; i++) {
        final textSpan = TextSpan(text: locations[i], style: textStyle);
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        final x = size.width * (0.1 + (i * 0.2));
        final y = size.height * (0.2 + (i % 2) * 0.6);
        textPainter.paint(canvas, Offset(x, y));
      }
    }

    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
  }