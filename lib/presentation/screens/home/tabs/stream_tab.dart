import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rovify/presentation/blocs/event/event_bloc.dart';
import 'package:rovify/presentation/blocs/event/event_event.dart';
import 'package:rovify/presentation/blocs/event/event_state.dart';
import 'package:rovify/domain/entities/event.dart';
import '../widgets/stream/live_avatar_list.dart';
import '../widgets/stream/category_filter_bar.dart';
import '../widgets/stream/event_card.dart';
import 'dart:developer' as developer;

class StreamTab extends StatefulWidget {
  const StreamTab({super.key});

  @override
  State<StreamTab> createState() => _StreamTabState();
}

class _StreamTabState extends State<StreamTab> {
  final List<String> tabOptions = ['Live Now', 'Upcoming', 'Following'];
  int selectedTabIndex = 0;
  String selectedCategory = 'Popular';

  final ScrollController _scrollController = ScrollController();
  bool _isAtTop = true;

  @override
  void initState() {
    super.initState();
    
    // Add a check to prevent unnecessary setState calls
    _scrollController.addListener(() {
      final isCurrentlyAtTop = _scrollController.offset <= 0;
      
      if (_isAtTop != isCurrentlyAtTop) {
        setState(() {
          _isAtTop = isCurrentlyAtTop;
        });
      }
    });

    // Trigger the event fetching when the widget is initialized
    context.read<EventBloc>().add(FetchEventsRequested());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(left: 12.0, right: 12.0),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(child: _buildTabBar()),
            const SliverToBoxAdapter(child: SizedBox(height: 12.0)),
            SliverToBoxAdapter(child: _buildLiveAvatars()),
            const SliverToBoxAdapter(child: SizedBox(height: 12.0)),
            SliverToBoxAdapter(child: _buildCategoryFilterBar()),
            const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
            _buildTrendingEventsGrid(),
          ],
        ),
      ),
    );
  }

  // Builds the top tab bar for switching between Live, Upcoming, and Following
  Widget _buildTabBar() {
    return Padding(
      padding: EdgeInsets.only(top: _isAtTop ? 24.0 : 0.0),
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 1,
                color: const Color(0xFFF5F5F5),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(tabOptions.length, (index) {
                final isSelected = index == selectedTabIndex;

                return GestureDetector(
                  onTap: () => setState(() => selectedTabIndex = index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tabOptions[index],
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        height: 2.5,
                        width: 60,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.black : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // Shows the live avatars horizontally - only show when "Live Now" tab is selected
  Widget _buildLiveAvatars() {
    // Only show live avatars for "Live Now" tab
    if (selectedTabIndex != 0) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<EventBloc, EventState>(
      buildWhen: (previous, current) => current is EventLoaded,
      builder: (context, state) {
        if (state is EventLoading) {
          return const SizedBox(
              height: 85,
              child: Center(child: CircularProgressIndicator()));
        } else if (state is EventLoaded) {
          final liveEvents = state.events.where((e) => e.isLive).toList();
          
          if (liveEvents.isEmpty) {
            return const SizedBox(
              height: 85,
              child: Center(
                child: Text(
                  "No live events",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }
          
          return LiveAvatarList(liveEvents: liveEvents);
        } else if (state is EventError) {
          return const SizedBox(
              height: 85,
              child: Center(child: Text("Failed to load live events")));
        } else {
          return const SizedBox(height: 85); // Placeholder space
        }
      },
    );
  }

  // Category filter bar with callback to update selected category
  Widget _buildCategoryFilterBar() {
    return CategoryFilterBar(
      selectedCategory: selectedCategory,
      onCategorySelected: (category) {
        setState(() {
          selectedCategory = category;
        });
        developer.log(
          'Category selected: $category',
          name: 'StreamTab.CategoryFilter',
        );
      },
    );
  }

  // Filter events based on selected tab and category
  List<Event> _filterEvents(List<Event> allEvents) {
    List<Event> filteredEvents = [];

    // First filter by tab selection
    switch (selectedTabIndex) {
      case 0: // Live Now
        filteredEvents = allEvents.where((e) => e.isLive).toList();
        break;
      case 1: // Upcoming
        filteredEvents = allEvents.where((e) => !e.isLive).toList();
        break;
      case 2: // Following
        //
        filteredEvents = allEvents;
        break;
      default:
        filteredEvents = allEvents;
    }

    // Then filter by category (if not Popular - show all)
    if (selectedCategory != 'Popular') {
      filteredEvents = filteredEvents.where((event) {
        // Handle null category by treating it as 'Popular'
        final eventCategory = event.category ?? 'Popular';
        return eventCategory.toLowerCase() == selectedCategory.toLowerCase();
      }).toList();
    }

    developer.log(
      'Filtered events: ${filteredEvents.length} events for tab: ${tabOptions[selectedTabIndex]}, category: $selectedCategory',
      name: 'StreamTab.FilterEvents',
    );

    return filteredEvents;
  }

  // Builds the trending events using a flexible layout that allows EventCards to control their own height
  Widget _buildTrendingEventsGrid() {
    return BlocBuilder<EventBloc, EventState>(
      builder: (context, state) {
        if (state is EventLoading) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        } else if (state is EventLoaded) {
          final allEvents = state.events;
          final filteredEvents = _filterEvents(allEvents);

          if (filteredEvents.isEmpty) {
            String emptyMessage = "No events available";
            if (selectedTabIndex == 0) {
              emptyMessage = "No live events at the moment. You will find live events here!";
            } else if (selectedTabIndex == 1) {
              emptyMessage = "No upcoming events";
            } else if (selectedTabIndex == 2) {
              emptyMessage = "No events from people you follow";
            }

            if (selectedCategory != 'Popular') {
              emptyMessage = "No events in $selectedCategory category";
            }

            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        emptyMessage,
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Convert events to the format expected by flexible grid
          final eventMaps = filteredEvents.map((event) => {
            'title': event.title,
            'thumbnailUrl': event.thumbnailUrl,
            'hostName': event.hostName,
            'hostImageUrl': event.hostImageUrl,
            'followers': event.followers,
            'viewers': event.viewers,
            'isLive': event.isLive,
            'hostId': event.hostId ?? '',
          }).toList();

          // SliverToBoxAdapter with flexible EventGrid that respects EventCard heights
          return SliverToBoxAdapter(
            child: _buildFlexibleEventGrid(eventMaps),
          );
        } else if (state is EventError) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text('Error: ${state.message}', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<EventBloc>().add(FetchEventsRequested());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          );
        }
      },
    );
  }

  // Flexible grid layout that ensures all cards have exactly the same width
  Widget _buildFlexibleEventGrid(List<Map<String, dynamic>> events) {
    final orientation = MediaQuery.of(context).orientation;
    final crossAxisCount = orientation == Orientation.portrait ? 2 : 4;

    // Calculate exact card width to ensure consistency and prevent overflow
    final screenWidth = MediaQuery.of(context).size.width;
    final parentPadding = 24.0; // 12 left + 12 right from StreamTab padding
    final gridPadding = 16.0; // 8 left + 8 right from grid padding
    final totalSpacing = (crossAxisCount - 1) * 12.0; // 12px spacing between cards
    final totalReservedSpace = parentPadding + gridPadding + totalSpacing;
    final availableWidth = screenWidth - totalReservedSpace;
    final cardWidth = availableWidth / crossAxisCount;

    List<Widget> rows = [];

    // Build rows with the specified number of items per row
    for (int i = 0; i < events.length; i += crossAxisCount) {
      List<Widget> rowChildren = [];

      // Add EventCards to current row with calculated width
      for (int j = 0; j < crossAxisCount && (i + j) < events.length; j++) {
        final event = events[i + j];
        rowChildren.add(
          SizedBox(
            width: cardWidth, // Precisely calculated width to prevent overflow
            child: EventCard(
              title: event['title'],
              thumbnailUrl: event['thumbnailUrl'],
              hostName: event['hostName'],
              hostImageUrl: event['hostImageUrl'],
              followers: event['followers'],
              viewers: event['viewers'],
              isLive: event['isLive'],
              hostId: event['hostId'],
            ),
          ),
        );

        // Add spacing between cards (except for the last card in the row)
        if (j < crossAxisCount - 1 && (i + j + 1) < events.length) {
          rowChildren.add(const SizedBox(width: 12));
        }
      }

      // Create the row with proper alignment
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Align cards to top of row
          mainAxisAlignment: MainAxisAlignment.start, // Align row content to start
          children: rowChildren,
        ),
      );

      // Add vertical spacing between rows (except for the last row)
      if (i + crossAxisCount < events.length) {
        rows.add(const SizedBox(height: 12));
      }
    }

    // Return grid with consistent padding
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
    );
  }
}