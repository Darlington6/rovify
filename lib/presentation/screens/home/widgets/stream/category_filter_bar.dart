import 'package:flutter/material.dart';

class CategoryFilterBar extends StatefulWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryFilterBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  State<CategoryFilterBar> createState() => _CategoryFilterBarState();
}

class _CategoryFilterBarState extends State<CategoryFilterBar> {
  final List<String> categories = [
    'Popular',
    'Gaming',
    'Sports',
    'Music',
    'Culture',
    'Night Life',
    'Comedy',
    'Cinema',
    'Education',
    'Business',
    'Wellness',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          final bool isSelected = category == widget.selectedCategory;
          
          // Edge margin only for first and last items
          final EdgeInsetsGeometry edgeMargin = EdgeInsets.only(
            left: index == 0 ? 16.0 : 0.0,      // First item
            right: index == categories.length - 1 ? 16.0 : 0.0, // Last item
          );
          
          return Padding(
            padding: edgeMargin,
            child: GestureDetector(
              onTap: () {
                widget.onCategorySelected(category);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey.shade400,
                    width: 1,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ] : [],
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}