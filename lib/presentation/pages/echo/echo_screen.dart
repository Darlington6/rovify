import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rovify/presentation/pages/explore/widgets/main_scaffold.dart';
import 'package:rovify/presentation/pages/explore/widgets/bottom_navigation.dart';

class EchoScreen extends StatefulWidget {
  const EchoScreen({super.key});

  @override
  State<EchoScreen> createState() => _EchoScreenState();
}

class _EchoScreenState extends State<EchoScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  String selectedFilter = 'All';
  int selectedFriend = 0;
  bool isRefreshing = false;

  final List<Map<String, dynamic>> friends = [
    {
      'name': 'Doggo',
      'image':
          'https://images.unsplash.com/photo-1552053100-e77b9da5846f?w=100&h=100&fit=crop&crop=face',
      'special': true,
      'online': true,
    },
    {
      'name': 'Frank',
      'image':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
      'special': false,
      'online': true,
    },
    {
      'name': 'Lorna',
      'image':
          'https://images.unsplash.com/photo-1494790108755-2616b9dc00a5?w=100&h=100&fit=crop&crop=face',
      'special': false,
      'online': false,
    },
    {
      'name': 'James',
      'image':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop&crop=face',
      'special': false,
      'online': true,
    },
    {
      'name': 'Max',
      'image':
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face',
      'special': false,
      'online': false,
    },
    {
      'name': 'Sarah',
      'image':
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop&crop=face',
      'special': false,
      'online': true,
    },
  ];

  final Map<String, List<Map<String, dynamic>>> events = {
    'All': [
      {
        'title': 'The Man Exclusive 2025',
        'subtitle': 'So excited to go to this amazing event!',
        'time': '07:07',
        'badge': 1,
        'color': Colors.deepOrange,
        'image':
            'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=50&h=50&fit=crop',
      },
      {
        'title': 'Ultra Music Festival 2025',
        'subtitle': 'Who else is going? Let\'s meet up!',
        'time': '07:05',
        'badge': 3,
        'color': Colors.purple,
        'image':
            'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=50&h=50&fit=crop',
      },
      {
        'title': 'Nairobi Food Festival',
        'subtitle': 'Best food in town! Already got my tickets',
        'time': '06:45',
        'badge': 2,
        'color': Colors.green,
        'image':
            'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=50&h=50&fit=crop',
      },
      {
        'title': 'Tech Conference KE',
        'subtitle': 'Can\'t wait for the keynote speech!',
        'time': '06:30',
        'badge': 0,
        'color': Colors.blue,
        'image':
            'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=50&h=50&fit=crop',
      },
      {
        'title': 'Rooftop Cinema Night',
        'subtitle': 'Movie under the stars',
        'time': '06:15',
        'badge': 1,
        'color': Colors.indigo,
        'image':
            'https://images.unsplash.com/photo-1489599639072-65ba7eada4ec?w=50&h=50&fit=crop',
      },
    ],
    'Before': [
      {
        'title': 'Planning Committee Meeting',
        'subtitle': 'Let\'s discuss the event details',
        'time': '2 days ago',
        'badge': 0,
        'color': Colors.grey,
        'image':
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=50&h=50&fit=crop',
      },
      {
        'title': 'Venue Booking Discussion',
        'subtitle': 'Found the perfect location!',
        'time': '1 week ago',
        'badge': 0,
        'color': Colors.grey,
        'image':
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=50&h=50&fit=crop',
      },
    ],
    'During': [
      {
        'title': 'Live Event Updates',
        'subtitle': 'Everyone having a great time!',
        'time': 'Now',
        'badge': 5,
        'color': Colors.red,
        'image':
            'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=50&h=50&fit=crop',
      },
      {
        'title': 'Photo Sharing',
        'subtitle': 'Check out these amazing shots!',
        'time': '2 min ago',
        'badge': 12,
        'color': Colors.pink,
        'image':
            'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=50&h=50&fit=crop',
      },
    ],
    'After': [
      {
        'title': 'Event Memories',
        'subtitle': 'What an incredible night! Thanks everyone',
        'time': '1 hour ago',
        'badge': 8,
        'color': Colors.amber,
        'image':
            'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=50&h=50&fit=crop',
      },
      {
        'title': 'Feedback & Reviews',
        'subtitle': 'Please share your thoughts!',
        'time': '3 hours ago',
        'badge': 3,
        'color': Colors.teal,
        'image':
            'https://images.unsplash.com/photo-1489599639072-65ba7eada4ec?w=50&h=50&fit=crop',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => isRefreshing = true);
    await Future.delayed(Duration(milliseconds: 1500));
    setState(() => isRefreshing = false);
    _showSnackBar('Messages updated!', Colors.green, Icons.check_circle);
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

  void _showDialog(String title, String description, IconData icon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(icon, color: Colors.deepOrange),
            SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar(
                '$title coming soon!',
                Colors.deepOrange,
                Icons.rocket_launch,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Try It', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCreateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 8),
              child: SizedBox(
                width: 40,
                height: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Create New Message',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.count(
                padding: EdgeInsets.all(20),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildAction(
                    'Start Group Chat',
                    Icons.group_add,
                    Colors.blue,
                  ),
                  _buildAction('Create Event Room', Icons.event, Colors.green),
                  _buildAction('Share Location', Icons.location_on, Colors.red),
                  _buildAction(
                    'Send Photos',
                    Icons.photo_library,
                    Colors.purple,
                  ),
                  _buildAction('Voice Message', Icons.mic, Colors.orange),
                  _buildAction('Video Call', Icons.video_call, Colors.teal),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAction(String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.pop(context);
        _showDialog(title, 'This feature will be available soon!', icon);
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: FloatingActionButton(
            mini: true,
            heroTag: "video",
            backgroundColor: Colors.green,
            onPressed: () {
              HapticFeedback.mediumImpact();
              _showDialog(
                'Video Call',
                'Start a video call with your friends',
                Icons.video_call,
              );
            },
            child: Icon(Icons.video_call, color: Colors.white),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: FloatingActionButton(
            mini: true,
            heroTag: "voice",
            backgroundColor: Colors.blue,
            onPressed: () {
              HapticFeedback.mediumImpact();
              _showDialog(
                'Voice Message',
                'Send a voice message to the group',
                Icons.mic,
              );
            },
            child: Icon(Icons.mic, color: Colors.white),
          ),
        ),
        FloatingActionButton(
          heroTag: "main",
          backgroundColor: Colors.deepOrange,
          onPressed: () {
            HapticFeedback.lightImpact();
            _showCreateSheet();
          },
          child: Icon(Icons.add, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey[50]!],
          ),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Hero(
          tag: 'profile',
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1494790108755-2616b9dc00a5?w=100&h=100&fit=crop&crop=face',
              ),
            ),
          ),
        ),
      ),
      title: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.location_on_outlined, color: Colors.grey[600], size: 16),
            SizedBox(width: 4),
            Text(
              'Nairobi, Kenya',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () => _showSnackBar(
              'Search feature coming soon!',
              Colors.blue,
              Icons.search,
            ),
            icon: Icon(Icons.search, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        TabBar(
          controller: _tabController,
          indicatorColor: Colors.deepOrange,
          indicatorWeight: 3,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey[600],
          labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          unselectedLabelStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          tabs: [
            Tab(text: 'Rooms'),
            Tab(text: 'Groups'),
            Tab(text: 'Friends'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatus() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withValues(alpha: 0.1),
            Colors.blue.withValues(alpha: 0.1),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          Text(
            '4 friends online',
            style: TextStyle(
              color: Colors.green[700],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 8),
          Text('•', style: TextStyle(color: Colors.grey[400])),
          SizedBox(width: 8),
          Text(
            '12 active chats',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildFriends() {
    return FadeTransition(
      opacity: _fadeController,
      child: Container(
        height: 90,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16),
          itemCount: friends.length,
          itemBuilder: (context, index) => _buildAvatar(index),
        ),
      ),
    );
  }

  Widget _buildAvatar(int index) {
    final friend = friends[index];
    final selected = selectedFriend == index;

    return GestureDetector(
      onTap: () {
        setState(() => selectedFriend = index);
        HapticFeedback.selectionClick();
        _showSnackBar(
          'Viewing ${friend['name']}\'s messages',
          Colors.blue,
          Icons.chat,
        );
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: EdgeInsets.only(right: 16),
        transform: Matrix4.identity()..scale(selected ? 1.1 : 1.0),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: friend['special']
                        ? LinearGradient(
                            colors: [Colors.amber, Colors.orange],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [Colors.deepOrange, Colors.orange[300]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (friend['special']
                                    ? Colors.amber
                                    : Colors.deepOrange)
                                .withValues(alpha: 0.3),
                        blurRadius: selected ? 12 : 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(2),
                  child: CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(friend['image']),
                  ),
                ),
                if (friend['online'])
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 6),
            Text(
              friend['name'],
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.deepOrange : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SlideTransition(
      position: Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
      ),
      child: Container(
        height: 50,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16),
          children: [
            'All',
            'Before',
            'During',
            'After',
          ].map((filter) => _buildFilter(filter)).toList(),
        ),
      ),
    );
  }

  Widget _buildFilter(String label) {
    final selected = selectedFilter == label;
    return Container(
      margin: EdgeInsets.only(right: 12),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
        selected: selected,
        onSelected: (value) {
          setState(() => selectedFilter = label);
          HapticFeedback.selectionClick();
        },
        backgroundColor: Colors.white,
        selectedColor: Colors.deepOrange,
        checkmarkColor: Colors.white,
        elevation: selected ? 4 : 2,
        shadowColor: Colors.deepOrange.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
    );
  }

  Widget _buildEvents() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 400),
      child: Container(
        key: ValueKey(selectedFilter),
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: (events[selectedFilter] ?? []).asMap().entries.map((entry) {
            final index = entry.key;
            final event = entry.value;
            return AnimatedContainer(
              duration: Duration(milliseconds: 300 + (index * 100)),
              curve: Curves.easeOutBack,
              child: _buildEvent(event, index),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEvent(Map<String, dynamic> event, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.lightImpact();
            _showSnackBar(
              'Opening chat: ${event['title']}',
              event['color'],
              Icons.chat_bubble,
            );
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Hero(
                  tag: 'event-$index',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: event['color'].withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(event['image']),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['title'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              event['subtitle'],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      event['time'],
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (event['badge'] > 0) ...[
                      SizedBox(height: 6),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              event['color'],
                              event['color'].withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: event['color'].withValues(alpha: 0.4),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          event['badge'] > 99
                              ? '99+'
                              : event['badge'].toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTyping() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=50&h=50&fit=crop',
            ),
          ),
          SizedBox(width: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Frank is typing',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(width: 8),
                _TypingDots(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Echo',
      showAppBar: false,
      body: Scaffold(
        backgroundColor: Colors.grey[50],
        body: RefreshIndicator(
          onRefresh: _refresh,
          color: Colors.deepOrange,
          child: CustomScrollView(
            slivers: [
              _buildHeader(),
              _buildTabBar(),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: 16),
                    _buildStatus(),
                    SizedBox(height: 8),
                    _buildFriends(),
                    SizedBox(height: 24),
                    _buildFilters(),
                    SizedBox(height: 20),
                    _buildEvents(),
                    if (selectedFilter == 'All') _buildTyping(),
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: _buildFab(),
        bottomNavigationBar: BottomNavBar(currentIndex: 4),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height + 10;
  @override
  double get maxExtent => tabBar.preferredSize.height + 10;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) =>
      tabBar != oldDelegate.tabBar;
}

class _TypingDots extends StatefulWidget {
  @override
  _TypingDotsState createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          children: List.generate(3, (index) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 1),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400]?.withValues(
                  alpha: ((_controller.value + index * 0.3) % 1.0),
                ),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}
