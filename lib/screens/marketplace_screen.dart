import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Updated color constants to match Figma design
const kBackgroundBlue = Color(0xFF1746A2); // Blue background like Figma
const kCardBackground = Color(0xFFF8F8F8);
const kButtonOrange = Color(0xFFFF6A00);
const kTextDark = Color(0xFF222B45);
const kTextGray = Color(0xFF8F9BB3);
const kTextWhite = Color(0xFFFFFFFF);

class MarketplaceScreen extends StatefulWidget {
  @override
  _MarketplaceScreenState createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int _selectedIndex = 3; // Marketplace tab (index 3 for mobile design)
  String _selectedTime = '24h';
  String _selectedCategory = 'All Categories';
  String _selectedType = 'Type';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Set status bar to transparent
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundBlue, // Blue background like Figma
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Trending Tab
                  SingleChildScrollView(
                    child: Container(
                      margin: EdgeInsets.only(top: 0, bottom: 16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Filter Row
                          Row(
                            children: [
                              _buildDropdown(_selectedTime, ['24h', '7d', '30d'], (val) {
                                setState(() {
                                  _selectedTime = val!;
                                });
                              }),
                              SizedBox(width: 8),
                              _buildDropdown(_selectedCategory, ['All Categories', 'Art', 'Music'], (val) {
                                setState(() {
                                  _selectedCategory = val!;
                                });
                              }),
                              SizedBox(width: 8),
                              _buildDropdown(_selectedType, ['Type', 'Auction', 'Buy Now'], (val) {
                                setState(() {
                                  _selectedType = val!;
                                });
                              }),
                            ],
                          ),
                          SizedBox(height: 24),
                          // Top Collection Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Top Collection', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: kTextDark)),
                              Text('See all', style: TextStyle(color: kButtonOrange, fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                          SizedBox(height: 12),
                          SizedBox(
                            height: 220, // Increased height to show buttons properly
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                NFTCard(
                                  imageUrl: 'assets/images/dipped_monalisa.png',
                                  title: 'Dripped Monalisa',
                                  author: 'The Pirate King',
                                  price: '0.084Eth',
                                  showBidButton: true, // Enable bid button
                                  isLocalAsset: true,
                                ),
                                NFTCard(
                                  imageUrl: 'assets/images/red_face.png',
                                  title: 'Red Face',
                                  author: 'Rhodey',
                                  price: '0.044Eth',
                                  showBidButton: true, // Enable bid button
                                  isLocalAsset: true,
                                ),
                                NFTCard(
                                  imageUrl: 'assets/images/dipped_monalisa.png', // Use existing image for third card
                                  title: 'The Man Exclusive 2025',
                                  author: 'Aura Kimani',
                                  price: '0.084Eth',
                                  showBidButton: true, // Enable bid button
                                  isLocalAsset: true,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 32),
                          // Best Sellers Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Best Sellers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: kTextDark)),
                              Text('See all', style: TextStyle(color: kButtonOrange, fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                          SizedBox(height: 12),
                          SizedBox(
                            height: 220, // Increased height to show buttons properly
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                NFTCard(
                                  imageUrl: 'assets/images/dipped_monalisa.png',
                                  title: 'Digital Masterpiece',
                                  author: 'CryptoArtist',
                                  price: '0.156Eth',
                                  showBidButton: true, // Enable bid button
                                  isLocalAsset: true,
                                ),
                                NFTCard(
                                  imageUrl: 'assets/images/red_face.png',
                                  title: 'Red Face',
                                  author: 'Rhodey',
                                  price: '0.089Eth',
                                  showBidButton: true, // Enable bid button
                                  isLocalAsset: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Top Tab
                  Center(child: Text('Top', style: TextStyle(color: kTextDark))),
                  // Watchlist Tab
                  Center(child: Text('Watchlist', style: TextStyle(color: kTextDark))),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white, // White background for header
      child: Row(
        children: [
          // Profile picture
          CircleAvatar(
            backgroundImage: NetworkImage('https://randomuser.me/api/portraits/women/44.jpg'),
            radius: 22,
          ),
          SizedBox(width: 12),
          // Location info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Location', style: TextStyle(fontSize: 12, color: kTextGray)),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: kTextGray),
                    SizedBox(width: 4),
                    Text('Nairobi, Kenya', style: TextStyle(fontWeight: FontWeight.bold, color: kTextDark, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
          // Notification bell and menu
          Icon(Icons.notifications_none, color: kTextGray, size: 24),
          SizedBox(width: 16),
          Icon(Icons.more_vert, color: kTextGray, size: 24),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white, // White background for tab bar
      child: TabBar(
        controller: _tabController,
        labelColor: kTextDark,
        unselectedLabelColor: kTextGray,
        indicatorColor: kButtonOrange,
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
        tabs: [
          Tab(text: 'Trending'),
          Tab(text: 'Top'),
          Tab(text: 'Watchlist'),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: kButtonOrange,
        unselectedItemColor: kTextGray,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_outline), label: 'Stream'),
          BottomNavigationBarItem(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kButtonOrange,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: Colors.white, size: 20),
            ),
            label: 'Create',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Marketplace'),
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: 'Echo'),
        ],
      ),
    );
  }

  Widget _buildDropdown(String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kCardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE4E9F2)),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: SizedBox(),
        icon: Icon(Icons.keyboard_arrow_down, color: kTextGray, size: 16),
        style: TextStyle(
          color: kTextDark,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: TextStyle(
                color: kTextDark,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class NFTCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String author;
  final String price;
  final bool showBidButton;
  final bool isLocalAsset;

  const NFTCard({
    required this.imageUrl,
    required this.title,
    required this.author,
    required this.price,
    this.showBidButton = false,
    this.isLocalAsset = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: EdgeInsets.only(right: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kCardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image container
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 100, // Fixed height for consistency
              width: double.infinity,
              child: imageUrl.isNotEmpty
                  ? isLocalAsset
                      ? Image.asset(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.broken_image, size: 40, color: Colors.grey[500]),
                          ),
                        )
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.broken_image, size: 40, color: Colors.grey[500]),
                          ),
                        )
                  : Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.image, size: 40, color: Colors.grey[500]),
                    ),
            ),
          ),
          SizedBox(height: 8),
          // Title
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: kTextDark,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          // Author row with proper circular avatar
          Row(
            children: [
              CircleAvatar(
                radius: 8,
                backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/32.jpg'),
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  author,
                  style: TextStyle(fontSize: 12, color: kTextGray),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          // Price
          Text(
            price,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: kTextDark,
              fontSize: 13,
            ),
          ),
          // Bid button - properly sized and positioned
          if (showBidButton) ...[
            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 32,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: kButtonOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(
                  'Place a bid',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}