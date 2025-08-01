import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _markerController;

  String selectedCategory = 'Popular';
  bool isSearchFocused = false;

  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Popular',
      'icon': Icons.local_fire_department,
      'color': Color(0xFFFF6B6B),
      'gradient': [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    },
    {
      'name': 'Nightlife',
      'icon': Icons.nightlife,
      'color': Color(0xFF9C27B0),
      'gradient': [Color(0xFF9C27B0), Color(0xFFE91E63)],
    },
    {
      'name': 'Music',
      'icon': Icons.music_note,
      'color': Color(0xFF2196F3),
      'gradient': [Color(0xFF2196F3), Color(0xFF21CBF3)],
    },
    {
      'name': 'Gaming',
      'icon': Icons.sports_esports,
      'color': Color(0xFF4CAF50),
      'gradient': [Color(0xFF4CAF50), Color(0xFF8BC34A)],
    },
    {
      'name': 'Culture',
      'icon': Icons.palette,
      'color': Color(0xFF673AB7),
      'gradient': [Color(0xFF673AB7), Color(0xFF9C27B0)],
    },
  ];

  final List<Map<String, dynamic>> mapMarkers = [
    {
      'id': '1',
      'name': 'John Doe',
      'image':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
      'category': 'Popular',
      'color': Color(0xFFFF6B6B),
      'position': {'lat': -1.2921, 'lng': 36.8219},
      'activity': '☕ Coffee at Java House',
      'distance': '0.5 km away',
      'status': 'online',
    },
    {
      'id': '2',
      'name': 'Sarah Kim',
      'image':
          'https://images.unsplash.com/photo-1494790108755-2616b9dc00a5?w=100&h=100&fit=crop&crop=face',
      'category': 'Nightlife',
      'color': Color(0xFF9C27B0),
      'position': {'lat': -1.2876, 'lng': 36.8308},
      'activity': '🍸 Vibing at Kiza Lounge',
      'distance': '1.2 km away',
      'status': 'online',
    },
    {
      'id': '3',
      'name': 'Mike Johnson',
      'image':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop&crop=face',
      'category': 'Gaming',
      'color': Color(0xFF4CAF50),
      'position': {'lat': -1.3028, 'lng': 36.7806},
      'activity': '🎮 Gaming tournament',
      'distance': '2.1 km away',
      'status': 'busy',
    },
    {
      'id': '4',
      'name': 'Lisa Wang',
      'image':
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop&crop=face',
      'category': 'Music',
      'color': Color(0xFF2196F3),
      'position': {'lat': -1.2695, 'lng': 36.8147},
      'activity': '🎵 Live at Blankets & Wine',
      'distance': '0.8 km away',
      'status': 'online',
    },
    {
      'id': '5',
      'name': 'Alex Brown',
      'image':
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face',
      'category': 'Culture',
      'color': Color(0xFF673AB7),
      'position': {'lat': -1.2741, 'lng': 36.8028},
      'activity': '🏛️ Museum exploration',
      'distance': '1.5 km away',
      'status': 'away',
    },
    {
      'id': '6',
      'name': 'Emma Davis',
      'image':
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100&h=100&fit=crop&crop=face',
      'category': 'Popular',
      'color': Color(0xFFFF6B6B),
      'position': {'lat': -1.3163, 'lng': 36.8526},
      'activity': '🛍️ Shopping spree',
      'distance': '3.2 km away',
      'status': 'online',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );
    _markerController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );

    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat();
    _markerController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _markerController.dispose();
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
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.45,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey[50]!],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            SizedBox(height: 25),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Hero(
                    tag: 'marker-${marker['id']}',
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: categories.firstWhere(
                            (cat) => cat['name'] == marker['category'],
                          )['gradient'],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: marker['color'].withValues(alpha: 0.4),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(4),
                      child: CircleAvatar(
                        radius: 35,
                        backgroundImage: NetworkImage(marker['image']),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          marker['name'],
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          marker['activity'],
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: categories.firstWhere(
                                    (cat) => cat['name'] == marker['category'],
                                  )['gradient'],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                marker['category'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  marker['status'],
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: _getStatusColor(
                                    marker['status'],
                                  ).withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(marker['status']),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    marker['status'],
                                    style: TextStyle(
                                      color: _getStatusColor(marker['status']),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.grey[600], size: 20),
                  SizedBox(width: 8),
                  Text(
                    marker['distance'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF667eea).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showSnackBar(
                            'Starting chat with ${marker['name']}',
                            Color(0xFF667eea),
                            Icons.chat_bubble,
                          );
                        },
                        icon: Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: Text(
                          'Message',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF11998e).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showSnackBar(
                            'Getting directions to ${marker['name']}',
                            Color(0xFF11998e),
                            Icons.directions,
                          );
                        },
                        icon: Icon(
                          Icons.navigation,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: Text(
                          'Directions',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'online':
        return Colors.green;
      case 'busy':
        return Colors.orange;
      case 'away':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.white.withValues(alpha: 0.9)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFFF6B6B).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.all(3),
            child: CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1494790108755-2616b9dc00a5?w=100&h=100&fit=crop&crop=face',
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.location_on, color: Colors.grey[700], size: 18),
                    SizedBox(width: 4),
                    Text(
                      'Nairobi, Kenya',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey[100]!, Colors.grey[50]!],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => _showSnackBar(
                'Notifications',
                Color(0xFF667eea),
                Icons.notifications,
              ),
              icon: Icon(
                Icons.notifications_outlined,
                color: Colors.grey[700],
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, Colors.grey[50]!]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
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
          _showSnackBar(
            'Searching for: $value',
            Color(0xFF667eea),
            Icons.search,
          );
        },
        decoration: InputDecoration(
          hintText: 'Find your moments',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.search, color: Colors.grey[600], size: 22),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) =>
            _buildCategory(categories[index], index),
      ),
    );
  }

  Widget _buildCategory(Map<String, dynamic> category, int index) {
    final isSelected = selectedCategory == category['name'];

    return SlideTransition(
      position: Tween<Offset>(begin: Offset(0, 0.5), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _slideController,
          curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutBack),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          setState(() => selectedCategory = category['name']);
          HapticFeedback.mediumImpact();
          _showSnackBar(
            'Showing ${category['name']} locations',
            category['color'],
            category['icon'],
          );
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.only(right: 16),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: category['gradient'],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey[200]!,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? category['color'].withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: isSelected ? 15 : 8,
                offset: Offset(0, isSelected ? 6 : 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : category['color'].withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category['icon'],
                  color: isSelected ? Colors.white : category['color'],
                  size: 26,
                ),
              ),
              SizedBox(height: 8),
              Text(
                category['name'],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMap() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 25,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
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
                      Color(0xFFE3F2FD),
                      Color(0xFFBBDEFB),
                      Color(0xFF90CAF9),
                      Color(0xFFE1F5FE),
                    ],
                    stops: [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
                child: CustomPaint(painter: EnhancedMapPainter()),
              ),
              ...filteredMarkers.asMap().entries.map((entry) {
                final index = entry.key;
                final marker = entry.value;
                return _buildMapMarker(marker, index);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapMarker(Map<String, dynamic> marker, int index) {
    final random = (marker['id'].hashCode % 100) / 100;
    final left = 40.0 + (MediaQuery.of(context).size.width - 160) * random;
    final top = 40.0 + 250 * ((marker['id'].hashCode % 50) / 50);

    return Positioned(
      left: left,
      top: top,
      child: SlideTransition(
        position: Tween<Offset>(begin: Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _markerController,
            curve: Interval(index * 0.1, 1.0, curve: Curves.elasticOut),
          ),
        ),
        child: GestureDetector(
          onTap: () => _showMarkerDetails(marker),
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final pulseValue =
                  (1.0 +
                  0.1 *
                      (1.0 +
                          Curves.easeInOut.transform(_pulseController.value)));
              return Transform.scale(
                scale: marker['status'] == 'online' ? pulseValue : 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        marker['color'].withValues(alpha: 0.3),
                        marker['color'].withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                      stops: [0.3, 0.7, 1.0],
                    ),
                  ),
                  padding: EdgeInsets.all(8),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: categories.firstWhere(
                          (cat) => cat['name'] == marker['category'],
                        )['gradient'],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: marker['color'].withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(4),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Hero(
                          tag: 'marker-${marker['id']}',
                          child: CircleAvatar(
                            radius: 26,
                            backgroundImage: NetworkImage(marker['image']),
                          ),
                        ),
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.white, Colors.grey[100]!],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              categories.firstWhere(
                                (cat) => cat['name'] == marker['category'],
                              )['icon'],
                              size: 12,
                              color: marker['color'],
                            ),
                          ),
                        ),
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getStatusColor(marker['status']),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGoBackButton() {
    return Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF434343), Color(0xFF000000)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'Go Back',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      body: Column(
        children: [
          _buildHeader(),
          FadeTransition(opacity: _fadeController, child: _buildSearchBar()),
          SlideTransition(
            position: Tween<Offset>(begin: Offset(0, 0.5), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: _slideController,
                    curve: Curves.easeOutBack,
                  ),
                ),
            child: _buildCategories(),
          ),
          _buildMap(),
          _buildGoBackButton(),
        ],
      ),
    );
  }
}

class EnhancedMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final majorRoadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paths = [
      {
        'start': Offset(0, size.height * 0.3),
        'end': Offset(size.width, size.height * 0.3),
        'major': true,
      },
      {
        'start': Offset(size.width * 0.2, 0),
        'end': Offset(size.width * 0.2, size.height),
        'major': false,
      },
      {
        'start': Offset(size.width * 0.7, 0),
        'end': Offset(size.width * 0.7, size.height),
        'major': false,
      },
      {
        'start': Offset(0, size.height * 0.7),
        'end': Offset(size.width, size.height * 0.7),
        'major': true,
      },
      {
        'start': Offset(size.width * 0.5, 0),
        'end': Offset(size.width * 0.5, size.height),
        'major': true,
      },
    ];

    for (final pathData in paths) {
      canvas.drawLine(
        pathData['start'] as Offset,
        pathData['end'] as Offset,
        pathData['major'] as bool ? majorRoadPaint : roadPaint,
      );
    }

    final labelPaint = TextPainter(textDirection: TextDirection.ltr);
    final locations = [
      {
        'name': 'WESTLANDS',
        'pos': Offset(size.width * 0.15, size.height * 0.15),
      },
      {
        'name': 'KILIMANI',
        'pos': Offset(size.width * 0.75, size.height * 0.25),
      },
      {'name': 'KAREN', 'pos': Offset(size.width * 0.25, size.height * 0.8)},
      {'name': 'NYARI', 'pos': Offset(size.width * 0.6, size.height * 0.1)},
      {
        'name': 'KILELESHWA',
        'pos': Offset(size.width * 0.8, size.height * 0.85),
      },
    ];

    for (final location in locations) {
      labelPaint.text = TextSpan(
        text: location['name'] as String,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      );
      labelPaint.layout();
      labelPaint.paint(canvas, location['pos'] as Offset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
