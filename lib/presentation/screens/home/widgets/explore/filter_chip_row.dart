import 'package:flutter/material.dart';

class FilterChipRow extends StatefulWidget {
  const FilterChipRow({super.key});

  @override
  State<FilterChipRow> createState() => _FilterChipRowState();
}

class _FilterChipRowState extends State<FilterChipRow> {
  final List<Map<String, dynamic>> filters = [
    {'label': 'Nairobi', 'icon': Icons.location_on},
    {'label': 'This Weekend', 'icon': Icons.calendar_today},
    {'label': 'Any Price', 'icon': Icons.attach_money},
    {'label': 'In-Person', 'icon': Icons.people},
    {'label': 'Virtual', 'icon': Icons.videocam},
    {'label': 'Free', 'icon': Icons.money_off},
  ];

  String? selectedFilter;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final bool isSelected = selectedFilter == filter['label'];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: FilterChip(
              avatar: Icon(
                filter['icon'],
                color: isSelected ? Colors.white : Colors.black,
                size: 18,
              ),
              label: Text(
                filter['label'],
                style: TextStyle(
                  fontFamily: 'Onest',
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  selectedFilter = selected ? filter['label'] : null;
                });
              },
              backgroundColor: Colors.grey.shade200,
              selectedColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          );
        },
      ),
    );
  }
}