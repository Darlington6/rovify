import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class OnboardingNextStep extends OnboardingEvent {}
class OnboardingPreviousStep extends OnboardingEvent {}
class OnboardingSkip extends OnboardingEvent {}
class OnboardingSelectWallet extends OnboardingEvent {
  final String wallet;
  const OnboardingSelectWallet(this.wallet);
  @override
  List<Object?> get props => [wallet];
}
class OnboardingProfileSubmitted extends OnboardingEvent {
  final String name;
  final String? username;
  final String? location;
  final bool discoverable;
  const OnboardingProfileSubmitted({required this.name, this.username, this.location, required this.discoverable});
  @override
  List<Object?> get props => [name, username, location, discoverable];
}
class OnboardingSelectInterests extends OnboardingEvent {
  final List<String> interests;
  const OnboardingSelectInterests(this.interests);
  @override
  List<Object?> get props => [interests];
}
class OnboardingLocationPermission extends OnboardingEvent {
  final bool granted;
  const OnboardingLocationPermission(this.granted);
  @override
  List<Object?> get props => [granted];
}
class OnboardingNotificationPermission extends OnboardingEvent {
  final bool granted;
  const OnboardingNotificationPermission(this.granted);
  @override
  List<Object?> get props => [granted];
}