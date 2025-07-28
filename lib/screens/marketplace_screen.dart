import 'package:flutter/material.dart';
import 'nft_detail_screen.dart'; 

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Change background to white
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0), // Adjust padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50), // Adjust for status bar height and top padding
            // --- Custom Header (replaces AppBar) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage('assets/images/profile.png'), 
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Location",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Row(
                      children: const [
                        Icon(Icons.location_on, size: 16, color: Colors.black),
                        SizedBox(width: 4),
                        Text(
                          "Nairobi, Kenya",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none, size: 28, color: Colors.black),
                  onPressed: () {
                    // Handle notification bell press
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- Tab Bar ---
            TabBar(
              controller: _tabController,
              labelColor: Colors.black, // Active tab color
              unselectedLabelColor: Colors.grey, // Inactive tab color
              indicatorColor: Colors.black, // Indicator line color
              indicatorSize: TabBarIndicatorSize.label, // Indicator matches label width
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              tabs: const [
                Tab(text: "Trending"),
                Tab(text: "Top"),
                Tab(text: "Watchlist"),
              ],
            ),
            const SizedBox(height: 20), // Spacing after tabs

            // --- Filter Row ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFilterDropdown('24h', ['1h', '6h', '12h', '24h', '7d', '30d']),
                _buildFilterDropdown('All Categories', ['Art', 'Collectibles', 'Music', 'Photography']),
                _buildFilterDropdown('Type', ['Auction', 'Fixed Price']),
              ],
            ),
            const SizedBox(height: 20), // Spacing after filters

            // --- Top Collection Section ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Top Collection",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    // Handle "See all" for Top Collection
                  },
                  child: const Text(
                    "See all",
                    style: TextStyle(color: Colors.orange, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _nftCard(
                    context,
                    title: "Dripped Monalisa",
                    creatorName: "The Pirate King",
                    price: "0.084Eth",
                    image: 'assets/images/dipped_monalisa.png', 
                    profileImage: 'assets/images/pirate king.png',
                    showBidButton: true,
                  ),
                  _nftCard(
                    context,
                    title: "Red Face",
                    creatorName: "Rhodey",
                    price: "0.044Eth",
                    image: 'assets/images/red_face.png',
                    profileImage: 'assets/images/rhodey.png',
                    showBidButton: true,
                  ),
                  _nftCard(
                    context,
                    title: "The Man 2025",
                    creatorName: "Luffy",
                    price: "7.8 ETH",
                    image: 'assets/images/pirate_king.png', 
                    profileImage: 'assets/images/profile.png',
                    showBidButton: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30), // Spacing between sections

            // --- Best Sellers Section ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Best Sellers",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    // Handle "See all" for Best Sellers
                  },
                  child: const Text(
                    "See all",
                    style: TextStyle(color: Colors.orange, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _nftCard(
                    context,
                    title: "Mona Lisa",
                    creatorName: "Leonardo",
                    price: "4.2 ETH",
                    image: 'assets/images/dipped_monalisa.png',
                    profileImage: 'assets/images/pirate king.png',
                    showBidButton: false,
                  ),
                  _nftCard(
                    context,
                    title: "Red Face",
                    creatorName: "AbstractX",
                    price: "2.3 ETH",
                    image: 'assets/images/red_face.png',
                    profileImage: 'assets/images/rhodey.png',
                    showBidButton: false,
                  ),
                  _nftCard(
                    context,
                    title: "The Man 2025",
                    creatorName: "GhostMaker",
                    price: "3.0 ETH",
                    image: 'assets/images/placeholder_nft.png', 
                    profileImage: 'assets/images/profile.png',
                    showBidButton: false,
                  ),
                  // Add more NFT cards as needed for Best Sellers
                ],
              ),
            ),
            const SizedBox(height: 20), // Padding before bottom nav if content is short
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Important for more than 3 items
        selectedItemColor: Colors.orange, // Selected item color
        unselectedItemColor: Colors.grey, // Unselected item color
        currentIndex: 3, // Set to the index of 'Marketplace' if that's the current screen
        onTap: (index) {
          // Handle navigation here based on index
          // For example, using a PageView or Navigator
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore), // Or Image.asset('assets/icons/explore.png')
            label: "Explore",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videocam), // Or Image.asset('assets/icons/stream.png')
            label: "Stream",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 36, color: Colors.orange), // A prominent plus icon
            label: "Create", // Label for the create button
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront), // Or Image.asset('assets/icons/marketplace.png')
            label: "Marketplace",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.speaker), // Or Image.asset('assets/icons/echo.png')
            label: "Echo",
          ),
        ],
      ),
    );
  }

  // Helper method for filter dropdowns
  Widget _buildFilterDropdown(String hint, List<String> options) {
    String? selectedValue; // You would manage the actual selected value with State
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200], // Light grey background for the dropdown
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue, // This will be null initially
          hint: Text(hint, style: const TextStyle(fontSize: 14)),
          icon: const Icon(Icons.keyboard_arrow_down),
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedValue = newValue; // Update state if you want to reflect selection
            });
            // Handle filter change
            print('Selected $hint: $newValue');
          },
          style: const TextStyle(color: Colors.black, fontSize: 14),
          dropdownColor: Colors.white,
        ),
      ),
    );
  }

  // NFT Card Widget (modified)
  Widget _nftCard(
    BuildContext context, {
    required String title,
    required String creatorName,
    required String price,
    required String? image,
    required String profileImage,
    bool showBidButton = false, // Add this new parameter
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NFTDetailScreen(
              title: title,
              creatorName: creatorName,
              price: price,
              image: image ?? '',
              profileImage: profileImage,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        width: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200, // Lighter shadow
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((image ?? '').isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.asset(
                  image!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, color: Colors.grey[600], size: 40),
                            SizedBox(height: 8),
                            Text("Image Error", style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundImage: AssetImage(profileImage),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        creatorName,
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    price,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  if (showBidButton) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: MaterialButton(
                        onPressed: () {
                          print('Place a bid on $title');
                        },
                        color: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const Text(
                          "Place a bid",
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
