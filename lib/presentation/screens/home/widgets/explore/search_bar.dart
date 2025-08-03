import 'package:flutter/material.dart';

class SearchBarFeature extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final String searchQuery;

  const SearchBarFeature({
    super.key,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.searchQuery,
  });

  @override
  State<SearchBarFeature> createState() => _SearchBarFeatureState();
}

class _SearchBarFeatureState extends State<SearchBarFeature> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant SearchBarFeature oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != _controller.text) {
      _controller.text = widget.searchQuery;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: _controller,
          onChanged: widget.onSearchChanged,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 20),
            hintStyle: const TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
            hintText: null,
            hint: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.search, color: Colors.black),
                SizedBox(width: 8),
                Text(
                  'Find your moments',
                  style: TextStyle(
                    fontFamily: 'Onest',
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFF9C27B0),
                width: 2,
              ),
            ),
            suffixIcon: widget.searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: widget.onClearSearch,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}