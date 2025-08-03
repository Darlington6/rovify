import 'package:flutter/material.dart';
import 'package:rovify/presentation/screens/home/pages/nft_detail_page.dart';
import 'package:logging/logging.dart';

class MarketplaceTab extends StatefulWidget {
  const MarketplaceTab({super.key});

  @override
  State<MarketplaceTab> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
   final Logger _logger = Logger('MarketplaceTab'); 

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
      backgroundColor: Colors.white, 
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            TabBar(
              controller: _tabController,
              labelColor: Colors.black, 
              unselectedLabelColor: Colors.grey, 
              indicatorColor: Colors.black, 
              indicatorSize: TabBarIndicatorSize.label, 
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              tabs: const [
                Tab(text: "Trending"),
                Tab(text: "Top"),
                Tab(text: "Watchlist"),
              ],
            ),
            const SizedBox(height: 20), 

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFilterDropdown('24h', ['1h', '6h', '12h', '24h', '7d', '30d']),
                _buildFilterDropdown('All Categories', ['Art', 'Collectibles', 'Music', 'Photography']),
                _buildFilterDropdown('Type', ['Auction', 'Fixed Price']),
              ],
            ),
            const SizedBox(height: 20), 
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Top Collection",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                  },
                  child: const Text(
                    "See all",
                    style: TextStyle(color: Color(0xFFFF5900), fontSize: 14),
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
                    image: 'assets/marketplace-images/dipped_monalisa.png', 
                    profileImage: 'assets/marketplace-images/pirate_king.png',
                    showBidButton: true,
                  ),
                  _nftCard(
                    context,
                    title: "Red Face",
                    creatorName: "Rhodey",
                    price: "0.044Eth",
                    image: 'assets/marketplace-images/red_face.png',
                    profileImage: 'assets/marketplace-images/rhodey.png',
                    showBidButton: true,
                  ),
                  _nftCard(
                    context,
                    title: "The Man 2025",
                    creatorName: "Luffy",
                    price: "7.8 ETH",
                    image: 'assets/marketplace-images/dipped_monalisa.png', 
                    profileImage: 'assets/marketplace-images/profile.png',
                    showBidButton: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Best Sellers",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                  },
                  child: const Text(
                    "See all",
                    style: TextStyle(color: Color(0xFFFF5900), fontSize: 14),
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
                    image: 'assets/marketplace-images/dipped_monalisa.png',
                    profileImage: 'assets/marketplace-images/pirate_king.png',
                    showBidButton: false,
                  ),
                  _nftCard(
                    context,
                    title: "Red Face",
                    creatorName: "AbstractX",
                    price: "2.3 ETH",
                    image: 'assets/marketplace-images/red_face.png',
                    profileImage: 'assets/marketplace-images/rhodey.png',
                    showBidButton: false,
                  ),
                  _nftCard(
                    context,
                    title: "The Man 2025",
                    creatorName: "GhostMaker",
                    price: "3.0 ETH",
                    image: 'assets/marketplace-images/dipped_monalisa.png', 
                    profileImage: 'assets/marketplace-images/profile.png',
                    showBidButton: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(String hint, List<String> options) {
    String? selectedValue; 
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue, 
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
              selectedValue = newValue; 
            });
             _logger.info('Selected $hint: $newValue');
          },
          style: const TextStyle(color: Colors.black, fontSize: 14),
          dropdownColor: Colors.white,
        ),
      ),
    );
  }

  Widget _nftCard(
    BuildContext context, {
    required String title,
    required String creatorName,
    required String price,
    required String? image,
    required String profileImage,
    bool showBidButton = false, 
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
              color: Colors.grey.shade200, 
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
                           _logger.info('Place a bid on $title');
                        },
                        color: Color(0xFFFF5900),
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