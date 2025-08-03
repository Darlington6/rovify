import 'package:flutter/material.dart';
import 'package:rovify/presentation/screens/home/pages/map_page.dart';
import 'package:rovify/presentation/screens/home/widgets/explore/category_tabs.dart';
import 'package:rovify/presentation/screens/home/widgets/explore/event_list.dart';
import 'package:rovify/presentation/screens/home/widgets/explore/filter_chip_row.dart';
import 'package:rovify/presentation/screens/home/widgets/explore/search_bar.dart';

class EventListWithSearch extends StatefulWidget {
  const EventListWithSearch({super.key});

  @override
  State<EventListWithSearch> createState() => _EventListWithSearchState();
}

class _EventListWithSearchState extends State<EventListWithSearch> {
  String _searchQuery = '';
  String _selectedCategory = 'popular';

  void _handleSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
    });
  }

  void _handleCategorySelected(String categoryValue) {
    setState(() {
      _selectedCategory = categoryValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchBarFeature(
                    onSearchChanged: _handleSearchChanged,
                    onClearSearch: _clearSearch,
                    searchQuery: _searchQuery,
                  ),
                  CategoryTabs(
                    selectedCategory: _selectedCategory,
                    onCategorySelected: _handleCategorySelected,
                  ),
                  const FilterChipRow(),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 4.0),
                    child: Text(
                      'Upcoming Events',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Onest',
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: isLandscape ? screenHeight * 0.6 : screenHeight * 0.4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: EventList(
                        searchQuery: _searchQuery,
                        categoryFilter: _selectedCategory,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Floating Nearby Button
            const Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: _FloatingNearbyButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingNearbyButton extends StatelessWidget {
  const _FloatingNearbyButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _showNearbyEvents(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.near_me, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'Nearby',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Onest',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

 void _showNearbyEvents(BuildContext context) {
  try {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPage(),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error opening map: $e')),
    );
  }
}
}