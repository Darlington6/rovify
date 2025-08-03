import 'package:equatable/equatable.dart';

class OnboardingState extends Equatable {
  final int step;
  final String? selectedWallet;
  final String? name;
  final String? username;
  final String? location;
  final bool discoverable;
  final List<String> interests;
  final bool locationGranted;
  final bool notificationGranted;
  final bool completed;

  const OnboardingState({
    this.step = 0,
    this.selectedWallet,
    this.name,
    this.username,
    this.location,
    this.discoverable = false,
    this.interests = const [],
    this.locationGranted = false,
    this.notificationGranted = false,
    this.completed = false,
  });

  OnboardingState copyWith({
    int? step,
    String? selectedWallet,
    String? name,
    String? username,
    String? location,
    bool? discoverable,
    List<String>? interests,
    bool? locationGranted,
    bool? notificationGranted,
    bool? completed,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      selectedWallet: selectedWallet ?? this.selectedWallet,
      name: name ?? this.name,
      username: username ?? this.username,
      location: location ?? this.location,
      discoverable: discoverable ?? this.discoverable,
      interests: interests ?? this.interests,
      locationGranted: locationGranted ?? this.locationGranted,
      notificationGranted: notificationGranted ?? this.notificationGranted,
      completed: completed ?? this.completed,
    );
  }

  @override
  List<Object?> get props => [
    step,
    selectedWallet,
    name,
    username,
    location,
    discoverable,
    interests,
    locationGranted,
    notificationGranted,
    completed,
  ];
}