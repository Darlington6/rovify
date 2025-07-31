import 'package:flutter/material.dart';
import 'package:rovify/presentation/pages/explore/widgets/category_tabs.dart';
import 'package:rovify/presentation/pages/explore/widgets/filter_chip_row.dart';
import 'package:rovify/presentation/pages/explore/widgets/search_bar.dart';
import 'package:rovify/presentation/pages/explore/widgets/event_list.dart';

class EventListWithSearch extends StatefulWidget {
  const EventListWithSearch({super.key});

  @override
  State<EventListWithSearch> createState() => _EventListWithSearchState();
}

class _EventListWithSearchState extends State<EventListWithSearch> {
  String _searchQuery = '';
  String _selectedCategory = 'popular'; // <- Match category value, not label

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
    return Stack(
      children: [
        Column(
          children: [
            // Search Bar
            SearchBarFeature(
              onSearchChanged: _handleSearchChanged,
              onClearSearch: _clearSearch,
              searchQuery: _searchQuery,
            ),

            // Category Tabs
            CategoryTabs(
              selectedCategory: _selectedCategory,
              onCategorySelected: _handleCategorySelected,
            ),

            // Filter Chips
            const FilterChipRow(),

            // "Upcoming Events" title
            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 4.0),
              child: Align(
                alignment: Alignment.centerLeft,
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
            ),

            // Event List with all filters
            Expanded(
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

        // Floating Nearby Button
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Center(
            child: _FloatingNearbyButton(),
          ),
        ),
      ],
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
                color: Colors.black.withOpacity(0.1),
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
    // TODO: Implement nearby events functionality
  }
}
