import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:logging/logging.dart';

// Events
abstract class EventFormEvent {}

class InitializeForm extends EventFormEvent {}

class UpdateEventType extends EventFormEvent {
  final String type;
  UpdateEventType(this.type);
}

class UpdateCategory extends EventFormEvent {
  final String category;
  UpdateCategory(this.category);
}

class UpdateTicketType extends EventFormEvent {
  final String ticketType;
  UpdateTicketType(this.ticketType);
}

class UpdatePrice extends EventFormEvent {
  final double price;
  UpdatePrice(this.price);
}

class UpdateStatus extends EventFormEvent {
  final String status;
  UpdateStatus(this.status);
}

class SelectDate extends EventFormEvent {
  final DateTime date;
  SelectDate(this.date);
}

class SelectTime extends EventFormEvent {
  final TimeOfDay time;
  SelectTime(this.time);
}

class SelectImage extends EventFormEvent {}

class SubmitEventForm extends EventFormEvent {
  final String title;
  final String description;
  final String location;
  
  SubmitEventForm({
    required this.title,
    required this.description,
    required this.location,
  });
}

class ResetForm extends EventFormEvent {}

// States
abstract class EventFormState {}

class EventFormInitial extends EventFormState {}

class EventFormLoading extends EventFormState {}

class EventFormImageUploading extends EventFormState {}

class EventFormSuccess extends EventFormState {
  final String message;
  EventFormSuccess(this.message);
}

class EventFormError extends EventFormState {
  final String error;
  EventFormError(this.error);
}

class EventFormUpdated extends EventFormState {
  final String type;
  final String category;
  final String ticketType;
  final String status;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final File? selectedImage;
  final String? thumbnailUrl;
  final double price;

  EventFormUpdated({
    required this.type,
    required this.category,
    required this.ticketType,
    required this.status,
    this.selectedDate,
    this.selectedTime,
    this.selectedImage,
    this.thumbnailUrl,
    this.price = 0.0,
  });

  // Copy with method for easy state updates
  EventFormUpdated copyWith({
    String? type,
    String? category,
    String? ticketType,
    String? status,
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    File? selectedImage,
    String? thumbnailUrl,
    double? price,
    bool clearImage = false,
  }) {
    return EventFormUpdated(
      type: type ?? this.type,
      category: category ?? this.category,
      ticketType: ticketType ?? this.ticketType,
      status: status ?? this.status,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      selectedImage: clearImage ? null : (selectedImage ?? this.selectedImage),
      price: price ?? this.price, 
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }
}

// BLoC
class EventFormBloc extends Bloc<EventFormEvent, EventFormState> {
  final ImagePicker _imagePicker = ImagePicker();
  final Logger _logger = Logger('EventFormBloc');
  EventFormBloc() : super(EventFormInitial()) {
    // Initialize the form with default values
    on<InitializeForm>((event, emit) {
      emit(EventFormUpdated(
        type: 'in-person',
        category: 'Music',
        ticketType: 'NFT',
        status: 'upcoming',
      ));
    });

    on<UpdateEventType>((event, emit) {
      if (state is EventFormUpdated) {
        emit((state as EventFormUpdated).copyWith(type: event.type));
      }
    });

    on<UpdateCategory>((event, emit) {
      if (state is EventFormUpdated) {
        emit((state as EventFormUpdated).copyWith(category: event.category));
      }
    });

    on<UpdateTicketType>((event, emit) {
      if (state is EventFormUpdated) {
        emit((state as EventFormUpdated).copyWith(ticketType: event.ticketType));
      }
    });

    on<UpdatePrice>((event, emit) {
      if (state is EventFormUpdated) {
        emit((state as EventFormUpdated).copyWith(price: event.price));
      }
    });

    on<UpdateStatus>((event, emit) {
      if (state is EventFormUpdated) {
        emit((state as EventFormUpdated).copyWith(status: event.status));
      }
    });

    on<SelectDate>((event, emit) {
      if (state is EventFormUpdated) {
        emit((state as EventFormUpdated).copyWith(selectedDate: event.date));
      }
    });

    on<SelectTime>((event, emit) {
      if (state is EventFormUpdated) {
        emit((state as EventFormUpdated).copyWith(selectedTime: event.time));
      }
    });

    on<SelectImage>((event, emit) async {
      try {
        emit(EventFormImageUploading());
        
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 85,
        );

        if (image != null) {
          final File imageFile = File(image.path);
          
          if (state is EventFormUpdated) {
            emit((state as EventFormUpdated).copyWith(selectedImage: imageFile));
          } else {
            emit(EventFormUpdated(
              type: 'in-person',
              category: 'Music',
              ticketType: 'NFT',
              status: 'upcoming',
              selectedImage: imageFile,
            ));
          }
        } else {
          // User cancelled image selection
          if (state is EventFormUpdated) {
            emit(state as EventFormUpdated);
          } else {
            emit(EventFormUpdated(
              type: 'in-person',
              category: 'Music', 
              ticketType: 'NFT',
              status: 'upcoming',
            ));
          }
        }
      } catch (e) {
        emit(EventFormError('Failed to select image: $e'));
      }
    });

    on<SubmitEventForm>((event, emit) async {
      if (state is! EventFormUpdated) return;
      
      final currentState = state as EventFormUpdated;
      
      try {
        emit(EventFormLoading());

        // Get the current authenticated user
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(EventFormError('You must be logged in to create an event'));
          return;
        }

        // Validate required fields
        if (currentState.selectedDate == null || currentState.selectedTime == null) {
          emit(EventFormError('Please select both date and time for the event'));
          return;
        }

        // Upload image to Firebase Storage if selected
        String? thumbnailUrl;
        if (currentState.selectedImage != null) {
          thumbnailUrl = await _uploadImage(currentState.selectedImage!);
        }

        // Combine date and time
        final dateTime = DateTime(
          currentState.selectedDate!.year,
          currentState.selectedDate!.month,
          currentState.selectedDate!.day,
          currentState.selectedTime!.hour,
          currentState.selectedTime!.minute,
        );

        // Save event to Firestore
        await FirebaseFirestore.instance.collection('events').add({
          'title': event.title.trim(),
          'hostID': user.uid,
          'type': currentState.type,
          'location': event.location.trim(),
          'category': currentState.category,
          'datetime': Timestamp.fromDate(dateTime),
          'description': event.description.trim(),
          'status': currentState.status,
          'thumbnailUrl': thumbnailUrl ?? '',
          'ticketType': currentState.ticketType,
          'price': currentState.price,
          'createdAt': FieldValue.serverTimestamp(),
        });

        emit(EventFormSuccess('Event created successfully!'));
      } catch (e) {
        emit(EventFormError('Failed to create event: $e'));
      }
    });

    on<ResetForm>((event, emit) {
      emit(EventFormUpdated(
        type: 'in-person',
        category: 'Music',
        ticketType: 'NFT',
        status: 'upcoming',
      ));
    });
  }

  /// Upload image to Firebase Storage and return download URL
  Future<String> _uploadImage(File imageFile) async {
    try {
      // Check if file exists
      if (!await imageFile.exists()) {
        throw Exception('Selected image file does not exist');
      }

      final String fileName = 'event_thumbnails/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      
      // Add metadata
      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
      );
      
      final UploadTask uploadTask = storageRef.putFile(imageFile, metadata);
      final TaskSnapshot snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      _logger.severe('Firebase Storage Error', e);
      throw Exception('Failed to upload image: ${e.message}');
    } catch (e) {
      _logger.severe('General Upload Error', e); 
      throw Exception('Failed to upload image: $e');
    }
  }
}