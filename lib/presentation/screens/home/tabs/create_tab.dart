import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rovify/domain/repositories/nft_repository.dart';
import 'package:rovify/domain/usecases/fetch_nfts.dart';
import 'package:rovify/presentation/blocs/event/event_bloc.dart';
import 'package:rovify/presentation/blocs/event/event_event.dart';
import 'package:rovify/presentation/blocs/event/event_state.dart';
import 'package:rovify/presentation/blocs/nft/nft_bloc.dart';
import 'package:rovify/presentation/blocs/nft/nft_event.dart';
import 'package:rovify/presentation/blocs/nft/nft_state.dart';
import 'package:rovify/presentation/screens/home/pages/live_events_page.dart';
import 'package:rovify/presentation/screens/home/pages/trending_nfts_page.dart';
import 'package:rovify/presentation/screens/home/widgets/stream/event_card.dart';

/// Main CreateTab widget
class CreateTab extends StatelessWidget {
  const CreateTab(showCreateBottomSheet,
      {super.key, required this.onProfileTap, this.userProfileUrl});
  final String? userProfileUrl;
  final VoidCallback onProfileTap;

  /// Static method to open bottom sheet
  static void showCreateBottomSheet(
      BuildContext context, VoidCallback onProfileTap,
      [String? userProfileUrl]) {
    final draggableController = DraggableScrollableController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return BlocProvider(
          create: (_) => TabSelectionCubit(),
          child: DraggableScrollableSheet(
            controller: draggableController,
            expand: false,
            initialChildSize: 0.9,
            minChildSize: 0.85,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              // Animate to max height after the sheet is fully built and attached
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                context.read<EventBloc>().add(FetchEventsRequested());
                context.read<TrendingNftBloc>().add(FetchTrendingNftsRequested());
                
                // Wait a bit more to ensure the controller is properly attached
                await Future.delayed(const Duration(milliseconds: 300));
                
                // Check if controller is attached before calling animateTo
                if (draggableController.isAttached && 
                    draggableController.size < 0.9) {
                  try {
                    await draggableController.animateTo(
                      0.9,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOutCubic,
                    );
                  } catch (e) {
                    // Silently handle any animation errors
                    debugPrint('Animation error: $e');
                  }
                }
              });

              return SingleChildScrollView(
                controller: scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top grab bar
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Profile input field with avatar
                    Row(
                      children: [
                        GestureDetector(
                          onTap: onProfileTap,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.black,
                            backgroundImage: userProfileUrl != null
                                ? NetworkImage(userProfileUrl)
                                : null,
                            child: userProfileUrl == null
                                ? const Icon(Icons.person,
                                    color: Colors.grey, size: 18)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "What's happening at your event?",
                              hintStyle: const TextStyle(fontSize: 16),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFE9E9E9),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Media option buttons with onTap logic placeholders
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _MediaOption(
                          icon: Icons.photo,
                          label: "Photo",
                          color: Colors.orange,
                          onTap: () {
                            //
                          },
                        ),
                        _MediaOption(
                          icon: Icons.videocam,
                          label: "Video",
                          color: Colors.purple,
                          onTap: () {
                            //
                          },
                        ),
                        _MediaOption(
                          icon: Icons.music_note,
                          label: "Music",
                          color: Colors.blue,
                          onTap: () {
                            //
                          },
                        ),
                        _MediaOption(
                          icon: Icons.event,
                          label: "Event",
                          color: Colors.green,
                          onTap: () {
                            context.pushNamed('addEvent');
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Divider(
                      thickness: 1, 
                      color: Color(0xFFE0E0E0)
                    ),
                    
                    const SizedBox(height: 20),

                    // Dynamic category tabs
                    BlocBuilder<TabSelectionCubit, String>(
                      builder: (context, selectedTab) {
                        final tabs = [
                          "For You",
                          "Memories",
                          "Events",
                          "NFTs"
                        ];
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: tabs.map((label) {
                            return Flexible(
                              child: GestureDetector(
                                onTap: () => context
                                    .read<TabSelectionCubit>()
                                    .selectTab(label),
                                child: _TabChip(
                                  label: label,
                                  isSelected: selectedTab == label,
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Live section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Live Now",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const EventsPage()),
                            );
                          },
                          child: const Text(
                            "See All",
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Color(0xFFFF5900)
                              ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      height: 200,
                      child: BlocBuilder<EventBloc, EventState>(
                        builder: (context, state) {
                          if (state is EventLoading) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (state is EventLoaded) {
                            final liveEvents =
                                state.events.where((e) => e.isLive).toList();

                            if (liveEvents.isEmpty) {
                              return const Center(child: Text("No live events right now"));
                            }

                            return ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              itemCount: liveEvents.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final event = liveEvents[index];
                                return EventCard(
                                  title: event.title,
                                  thumbnailUrl: event.thumbnailUrl,
                                  hostName: event.hostName,
                                  followers: event.followers,
                                  viewers: event.viewers,
                                  isLive: event.isLive, 
                                  hostImageUrl: '', 
                                  hostId: '',
                                );
                              },
                            );
                          } else if (state is EventError) {
                            return Center(child: Text(state.message));
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Trending NFTs section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Trending NFTs",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                // Navigate to full NFT screen
                                builder: (_) => TrendingNftsPage(
                                  fetchTrendingNfts: FetchTrendingNfts(NftRepository()),
                                ),
                              ),
                            );
                          },
                    
                          child: const Text(
                            "See All",
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Color(0xFFFF5900),
                              ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: BlocBuilder<TrendingNftBloc, TrendingNftState>(
                        builder: (context, state) {
                          if (state is TrendingNftLoading) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (state is TrendingNftLoaded) {
                            if (state.nfts.isEmpty) {
                              return const Center(child: Text("No trending NFTs currently"));
                            }
                            return ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: state.nfts.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final nft = state.nfts[index];
                                return Container(
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: NetworkImage(nft.imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      color: Colors.black54,
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(4),
                                      child: Text(
                                        nft.title,
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          } else if (state is TrendingNftError) {
                            return Center(child: Text(state.message));
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                    ),

                    const SizedBox(height: 8),
                    
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // CreateTab is only used as a trigger
    return const SizedBox();
  }
}

/// Reusable Media Option Button
class _MediaOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MediaOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withAlpha((0.1 * 255).round()),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

/// Category tab chip for switching between views
class _TabChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _TabChip({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: isSelected ? Colors.black : Colors.white,
      side: BorderSide(
        color: isSelected ? Colors.black : Colors.grey.shade400,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

/// Simple Bloc for managing selected category tab
class TabSelectionCubit extends Cubit<String> {
  TabSelectionCubit() : super("For You");

  void selectTab(String label) => emit(label);
}