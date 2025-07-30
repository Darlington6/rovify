import 'package:flutter_bloc/flutter_bloc.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingState()) {
    on<OnboardingNextStep>((event, emit) {
      if (state.step < 5) {
        emit(state.copyWith(step: state.step + 1));
      } else {
        emit(state.copyWith(completed: true));
      }
    });
    on<OnboardingPreviousStep>((event, emit) {
      if (state.step > 0) {
        emit(state.copyWith(step: state.step - 1));
      }
    });
    on<OnboardingSkip>((event, emit) {
      emit(state.copyWith(step: 5));
    });
    on<OnboardingSelectWallet>((event, emit) {
      emit(state.copyWith(selectedWallet: event.wallet));
    });
    on<OnboardingProfileSubmitted>((event, emit) {
      emit(state.copyWith(
        name: event.name,
        username: event.username,
        location: event.location,
        discoverable: event.discoverable,
      ));
    });
    on<OnboardingSelectInterests>((event, emit) {
      emit(state.copyWith(interests: event.interests));
    });
    on<OnboardingLocationPermission>((event, emit) {
      emit(state.copyWith(locationGranted: event.granted));
    });
    on<OnboardingNotificationPermission>((event, emit) {
      emit(state.copyWith(notificationGranted: event.granted));
    });
  }
} 