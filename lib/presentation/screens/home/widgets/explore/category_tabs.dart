import 'package:flutter/material.dart';

class CategoryTabs extends StatefulWidget {
  final Function(String) onCategorySelected;
  final String selectedCategory;

  const CategoryTabs({
    super.key,
    required this.onCategorySelected,
    required this.selectedCategory,
  });

  @override
  State<CategoryTabs> createState() => _CategoryTabsState();
}

class _CategoryTabsState extends State<CategoryTabs> {
  late int activeIndex;

  final categories = [
    {'icon': Icons.star, 'label': 'Popular', 'value': 'popular', 'color': Colors.purple},
    {'icon': Icons.nightlife, 'label': 'Nightlife', 'value': 'nightlife', 'color': Colors.red},
    {'icon': Icons.music_note, 'label': 'Music', 'value': 'music', 'color': Colors.orange},
    {'icon': Icons.sports_esports, 'label': 'Gaming', 'value': 'gaming', 'color': Colors.blue},
    {'icon': Icons.sports, 'label': 'Sports', 'value': 'sports', 'color': Colors.green},
    {'icon': Icons.art_track, 'label': 'Art', 'value': 'art', 'color': Colors.teal},
    {'icon': Icons.emoji_food_beverage, 'label': 'Food', 'value': 'food', 'color': Colors.brown},
  ];

  @override
  void initState() {
    super.initState();
    activeIndex = categories.indexWhere((cat) => cat['value'] == widget.selectedCategory);
    if (activeIndex == -1) activeIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: isLandscape
          ? _buildWrapLayout(isSmallScreen)
          : _buildHorizontalList(isSmallScreen),
    );
  }

  Widget _buildHorizontalList(bool isCompact) {
    return SizedBox(
      height: isCompact ? 90 : 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 4),
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              setState(() => activeIndex = index);
              widget.onCategorySelected(category['value'] as String);
            },
            child: CategoryTab(
              icon: category['icon'] as IconData,
              label: category['label'] as String,
              iconColor: category['color'] as Color,
              isActive: index == activeIndex,
              isCompact: isCompact,
            ),
          );
        },
      ),
    );
  }

  Widget _buildWrapLayout(bool isCompact) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 16,
        children: List.generate(categories.length, (index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              setState(() => activeIndex = index);
              widget.onCategorySelected(category['value'] as String);
            },
            child: CategoryTab(
              icon: category['icon'] as IconData,
              label: category['label'] as String,
              iconColor: category['color'] as Color,
              isActive: index == activeIndex,
              isCompact: isCompact,
            ),
          );
        }),
      ),
    );
  }
}

class CategoryTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final bool isActive;
  final bool isCompact;

  const CategoryTab({
    super.key,
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.isActive,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: isCompact ? 13 : 16,
      fontWeight: FontWeight.w500,
      fontFamily: 'Onest',
    );

    return SizedBox(
      width: isCompact ? 72 : 84,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: isCompact ? 28 : 36),
          const SizedBox(height: 4),
          Text(label, style: textStyle, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Container(
            width: 40,
            height: isActive ? 3 : 1,
            color: isActive ? Colors.black : Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}