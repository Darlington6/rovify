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
    {
      'icon': Icons.star,
      'label': 'Popular',
      'value': 'popular',
      'color': Colors.purple
    },
    {
      'icon': Icons.nightlife,
      'label': 'Nightlife',
      'value': 'nightlife',
      'color': Colors.red
    },
    {
      'icon': Icons.music_note,
      'label': 'Music',
      'value': 'music',
      'color': Colors.orange
    },
    {
      'icon': Icons.sports_esports,
      'label': 'Gaming',
      'value': 'gaming',
      'color': Colors.blue
    },
    {
      'icon': Icons.sports,
      'label': 'Sports',
      'value': 'sports',
      'color': Colors.green
    },
    {
      'icon': Icons.art_track,
      'label': 'Art',
      'value': 'art',
      'color': Colors.teal
    },
    {
      'icon': Icons.emoji_food_beverage,
      'label': 'Food',
      'value': 'food',
      'color': Colors.brown
    },
  ];

  @override
  void initState() {
    super.initState();
    activeIndex = categories.indexWhere(
      (cat) => cat['value'] == widget.selectedCategory,
    );
    if (activeIndex == -1) activeIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  activeIndex = index;
                });
                widget.onCategorySelected(
                  categories[index]['value'] as String,
                );
              },
              child: CategoryTab(
                icon: categories[index]['icon'] as IconData,
                label: categories[index]['label'] as String,
                iconColor: categories[index]['color'] as Color,
                isActive: index == activeIndex,
              ),
            );
          },
        ),
      ),
    );
  }
}

class CategoryTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final bool isActive;

  const CategoryTab({
    super.key,
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(icon, color: iconColor, size: 38),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Onest',
            ),
          ),
          const SizedBox(height: 6),
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
