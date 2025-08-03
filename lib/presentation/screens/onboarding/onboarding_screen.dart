import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/onboarding/onboarding_bloc.dart';
import '../../blocs/onboarding/onboarding_event.dart';
import '../../blocs/onboarding/onboarding_state.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingBloc(),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatelessWidget {
  const _OnboardingView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  _OnboardingHeader(step: state.step),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _OnboardingStepContent(state: state),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OnboardingHeader extends StatelessWidget {
  final int step;
  const _OnboardingHeader({required this.step});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/icons/app_icon.png',
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            ),
            // Only show Skip button if not on last step (6 steps in total)
            if (step < 5)
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                  backgroundColor: Colors.white,
                ),
                onPressed: () {
                  // Skip to the next step
                  context.read<OnboardingBloc>().add(OnboardingNextStep());
                },
                child: const Text('Skip', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            children: List.generate(6, (i) => Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                height: 4,
                decoration: BoxDecoration(
                  color: i == step ? Colors.black : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            )).take(6).toList(),
          ),
        ),
      ],
    );
  }
}

class _OnboardingStepContent extends StatelessWidget {
  final OnboardingState state;
  const _OnboardingStepContent({required this.state});

  @override
  Widget build(BuildContext context) {
    switch (state.step) {
      case 0:
        return _WalletStep(selectedWallet: state.selectedWallet);
      case 1:
        return _ProfileStep(state: state);
      case 2:
        return _InterestsStep(selected: state.interests);
      case 3:
        return _LocationStep(granted: state.locationGranted);
      case 4:
        return _NotificationStep(granted: state.notificationGranted);
      case 5:
        return _WelcomeStep();
      default:
        return const SizedBox();
    }
  }
}

class _WalletStep extends StatelessWidget {
  final String? selectedWallet;
  const _WalletStep({this.selectedWallet});

  @override
  Widget build(BuildContext context) {
    final wallets = [
      {'name': 'Coinbase', 'icon': 'assets/onboarding-images/coinbase.png'},
      {'name': 'MetaMask', 'icon': 'assets/onboarding-images/metamask.png'},
      {'name': 'Rainbow', 'icon': 'assets/onboarding-images/rainbow.png'},
      {'name': 'Wallet Connect', 'icon': 'assets/onboarding-images/walletconnect.png'},
      {'name': 'Phantom', 'icon': 'assets/onboarding-images/phantom.png'},
      {'name': 'Other Wallets', 'icon': 'assets/onboarding-images/menu-dots.png'},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Set up your wallet', 
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
        const SizedBox(height: 8),
        const Text(
          'Create your account to start discovering amazing events and collecting unforgettable memories',
          style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.4),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: ListView(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            children: wallets.map((w) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                elevation: 0.5,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    context.read<OnboardingBloc>().add(OnboardingSelectWallet(w['name'] as String));
                    context.read<OnboardingBloc>().add(OnboardingNextStep());
                  },
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selectedWallet == w['name'] ? Colors.blue : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            w['icon'] as String,
                            width: 28,
                            height: 28,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Text(
                            w['name'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                ),
              ),
            )).toList(),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.bottomLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, size: 28),
            onPressed: () {
              context.pushNamed('splash');
            },
          ),
        ),
      ],
    );
  }
}

class _ProfileStep extends StatefulWidget {
  final OnboardingState state;
  const _ProfileStep({required this.state});
  @override
  State<_ProfileStep> createState() => _ProfileStepState();
}

class _ProfileStepState extends State<_ProfileStep> {
  late TextEditingController nameController;
  late TextEditingController usernameController;
  String? location;
  bool discoverable = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.state.name ?? '');
    usernameController = TextEditingController(text: widget.state.username ?? '');
    location = widget.state.location;
    discoverable = widget.state.discoverable;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Create your profile', 
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
        const SizedBox(height: 8),
        const Text(
          'Tell us a bit about yourself so we can personalize your event recommendations',
          style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.4),
        ),
        const SizedBox(height: 24),
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(Icons.camera_alt_outlined, color: Colors.black26, size: 36),
            ),
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: 'Alex Smith',
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.2),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.2),
            ),
          ),
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: usernameController,
          decoration: InputDecoration(
            hintText: 'Username (Optional)',
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.2),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.2),
            ),
          ),
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: location,
          items: ['Lagos', 'Abuja', 'Nairobi', 'Accra', 'Other']
              .map((loc) => DropdownMenuItem(value: loc, child: Text(loc)))
              .toList(),
          onChanged: (val) => setState(() => location = val),
          decoration: InputDecoration(
            hintText: 'Location',
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.2),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.2),
            ),
          ),
          style: const TextStyle(fontSize: 16, color: Colors.black),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Checkbox(
              value: discoverable,
              onChanged: (val) => setState(() => discoverable = val ?? false),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              side: const BorderSide(width: 1, color: Colors.black38),
            ),
            const SizedBox(width: 4),
            const Flexible(
              child: Text('Make my profile discoverable by friends', 
                style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () {
              context.read<OnboardingBloc>().add(OnboardingProfileSubmitted(
                name: nameController.text,
                username: usernameController.text.isEmpty ? null : usernameController.text,
                location: location,
                discoverable: discoverable,
              ));
              context.read<OnboardingBloc>().add(OnboardingNextStep());
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Continue', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: Colors.white),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.read<OnboardingBloc>().add(OnboardingPreviousStep()),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _InterestsStep extends StatefulWidget {
  final List<String> selected;
  const _InterestsStep({required this.selected});
  @override
  State<_InterestsStep> createState() => _InterestsStepState();
}

class _InterestsStepState extends State<_InterestsStep> {
  late List<String> selected;

  final interests = [
    {'name': 'Night Life', 'icon': 'assets/onboarding-images/night-life.png'},
    {'name': 'Music', 'icon': 'assets/onboarding-images/music.png'},
    {'name': 'Gaming', 'icon': 'assets/onboarding-images/gaming.png'},
    {'name': 'Comedy', 'icon': 'assets/onboarding-images/comedy.png'},
    {'name': 'Cinema', 'icon': 'assets/onboarding-images/cenema.png'},
    {'name': 'Education', 'icon': 'assets/onboarding-images/education.png'},
    {'name': 'Sports', 'icon': 'assets/onboarding-images/sports.png'},
    {'name': 'Business', 'icon': 'assets/onboarding-images/business.png'},
    {'name': 'Wellness', 'icon': 'assets/onboarding-images/wellness.png'},
  ];

  @override
  void initState() {
    super.initState();
    selected = List.from(widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('What interests you?', 
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
        const SizedBox(height: 8),
        const Text(
          'Select your favorite event types so we can show you the best recommendations',
          style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.4),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: GridView.count(
            crossAxisCount: 3,
            childAspectRatio: 0.9,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            padding: EdgeInsets.zero,
            children: interests.map((interest) {
              final isSelected = selected.contains(interest['name']);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selected.remove(interest['name']);
                    } else {
                      selected.add(interest['name']!);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xB5000000) : Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        interest['icon']!,
                        width: 38,
                        height: 38,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        interest['name']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: selected.isNotEmpty ? () {
              context.read<OnboardingBloc>().add(OnboardingSelectInterests(selected));
              context.read<OnboardingBloc>().add(OnboardingNextStep());
            } : null,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Continue', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.read<OnboardingBloc>().add(OnboardingPreviousStep()),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _LocationStep extends StatelessWidget {
  final bool granted;
  const _LocationStep({required this.granted});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Discover nearby events',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Allow location access to find amazing events happening around you',
          style: TextStyle(
            fontSize: 15,
            color: Colors.black54,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1.2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_pin, size: 80, color: Color(0xFFFF3EBF)),
              const SizedBox(height: 16),
              const Text(
                'Location Access',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "We'll show you events in your area and help friends find you at venues.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              elevation: 0,
            ),
            onPressed: () {
              context.read<OnboardingBloc>().add(const OnboardingLocationPermission(true));
              context.read<OnboardingBloc>().add(OnboardingNextStep());
            },
            child: const Text(
              'Allow Location',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.grey, width: 1.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              backgroundColor: Colors.white,
            ),
            onPressed: () {
              context.read<OnboardingBloc>().add(const OnboardingLocationPermission(false));
              context.read<OnboardingBloc>().add(OnboardingNextStep());
            },
            child: const Text(
              'Maybe Later',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.read<OnboardingBloc>().add(OnboardingPreviousStep()),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _NotificationStep extends StatelessWidget {
  final bool granted;
  const _NotificationStep({required this.granted});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Stay in the loop',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Get notified about events starting, friends arriving, and exclusive drops',
          style: TextStyle(
            fontSize: 15,
            color: Colors.black54,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1.2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.notifications, size: 80, color: Color(0xFFFFB300)),
              const SizedBox(height: 16),
              const Text(
                'Push Notifications',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Event reminders, friend activity, exclusive drops, & memory reel notifications.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () {
              context.read<OnboardingBloc>().add(const OnboardingNotificationPermission(true));
              context.read<OnboardingBloc>().add(OnboardingNextStep());
            },
            child: const Text(
              'Enable Notifications',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.grey, width: 1.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              backgroundColor: Colors.white,
            ),
            onPressed: () {
              context.read<OnboardingBloc>().add(const OnboardingNotificationPermission(false));
              context.read<OnboardingBloc>().add(OnboardingNextStep());
            },
            child: const Text(
              'Skip for now',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.read<OnboardingBloc>().add(OnboardingPreviousStep()),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final events = [
      {
        'title': 'The Man Exclusive 2025 | Nairobi',
        'date': 'Sat, Jan 1',
        'venue': 'Jonah Jang Crescent',
        'price': 'Free',
        'image': 'assets/onboarding-images/image1.png',
        'dateColor': Color(0xFFFF5900),
      },
      {
        'title': 'Panydoesart x DNJ Studios Sip & Paint',
        'date': 'Thu, Feb 7',
        'venue': 'Don & Divas Lounge',
        'price': 'Starts from \$25',
        'image': 'assets/onboarding-images/image2.png',
        'dateColor': Color(0xFFFF5900),
      },
      {
        'title': 'Tidal Rave - the 8th wonder | Mombasa',
        'date': 'Fri, Feb 8',
        'venue': 'Diani',
        'price': 'Free',
        'image': 'assets/onboarding-images/image3.png',
        'dateColor': Color(0xFFFF5900),
      },
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Welcome to Rovify!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: Colors.black),
        ),
        const SizedBox(height: 8),
        const Text(
          "You're all set! Here are some events happening near you this week",
          style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.4),
        ),
        const SizedBox(height: 24),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final e = events[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0), width: 0.50),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      e['image'] as String,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e['title'] as String,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                e['date'] as String,
                                style: TextStyle(fontSize: 13, color: e['dateColor'] as Color, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  e['venue'] as String,
                                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            e['price'] as String,
                            style: const TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.favorite_border, size: 20, color: Colors.black38),
                          onPressed: () {},
                        ),
                        Switch(value: false, onChanged: (_) {}, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              context.go('/home'); // Then go to home screen
            },
            child: const Text('Explore Events', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 16),

        Align(
          alignment: Alignment.bottomLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, size: 28),
            onPressed: () {
              context.read<OnboardingBloc>().add(OnboardingPreviousStep());
            },
          ),
        ),
      ],
    );
  }
}