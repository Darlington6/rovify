import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rovify/core/theme/utils/validators.dart';
import 'package:rovify/core/widgets/loading_button.dart';
import 'package:rovify/presentation/pages/explore/explore_page.dart';

class BecomeCreatorScreen extends StatefulWidget {
  final String userId;
  const BecomeCreatorScreen({super.key, required this.userId});

  @override
  State<BecomeCreatorScreen> createState() => _BecomeCreatorScreenState();
}

class _BecomeCreatorScreenState extends State<BecomeCreatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  
  // Form state
  bool _acceptedTerms = false;
  bool _isSubmitting = false;
  String? _creatorCategory;

  // Controllers
  final _bioController = TextEditingController();
  final _portfolioController = TextEditingController();
  final _instagramController = TextEditingController();
  final _twitterController = TextEditingController();

  @override
  void dispose() {
    _bioController.dispose();
    _portfolioController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    super.dispose();
  }

  Future<void> _submitCreatorApplication() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      _showError('Please accept the terms and conditions');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Create a batch to perform multiple writes atomically
      final batch = _firestore.batch();

      // Update user document
      final userRef = _firestore.collection('users').doc(widget.userId);
      batch.update(userRef, {
        'isCreator': true,
        'creatorSince': FieldValue.serverTimestamp(),
        'creatorStatus': 'approved', // Auto-approve in this implementation
      });

      // Create creator document
      final creatorRef = _firestore.collection('creators').doc(widget.userId);
      batch.set(creatorRef, {
        'bio': _bioController.text.trim(),
        'portfolioUrl': _portfolioController.text.trim(),
        'category': _creatorCategory,
        'socials': {
          'instagram': _instagramController.text.trim(),
          'twitter': _twitterController.text.trim(),
        },
        'eventsHosted': [], // Initialize empty array, will be populated by events where host=userID
        'walletConnected': false, // Can be updated later
        'createdAt': FieldValue.serverTimestamp(),
        'userID': widget.userId, // Store the userID directly instead of reference
      });

      // Commit the batch
      await batch.commit();

      if (!mounted) return;
      
      // Show success message
      _showSuccess('You are now a creator! Redirecting to explore page...');
      
      // Redirect to explore page after a short delay
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ExplorePage()),
        (route) => false,
      );
    } catch (e) {
      _showError('Failed to submit application: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Creator'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bio Field
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Creator Bio',
                  hintText: 'Tell us about yourself as a creator',
                ),
                maxLines: 3,
                validator: Validators.requiredField,
              ),
              const SizedBox(height: 20),

              // Portfolio URL
              TextFormField(
                controller: _portfolioController,
                decoration: const InputDecoration(
                  labelText: 'Portfolio URL',
                  hintText: 'Link to your work or social media',
                ),
                keyboardType: TextInputType.url,
                validator: Validators.validateUrl,
              ),
              const SizedBox(height: 20),

              // Social Media Fields
              TextFormField(
                controller: _instagramController,
                decoration: const InputDecoration(
                  labelText: 'Instagram Handle',
                  hintText: '@yourhandle',
                  prefixText: '@',
                ),
              ),
              const SizedBox(height: 15),
              
              TextFormField(
                controller: _twitterController,
                decoration: const InputDecoration(
                  labelText: 'Twitter Handle',
                  hintText: '@yourhandle',
                  prefixText: '@',
                ),
              ),
              const SizedBox(height: 20),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _creatorCategory,
                decoration: const InputDecoration(
                  labelText: 'Primary Category',
                ),
                items: const [
                  DropdownMenuItem(value: 'music', child: Text('Music')),
                  DropdownMenuItem(value: 'art', child: Text('Art')),
                  DropdownMenuItem(value: 'gaming', child: Text('Gaming')),
                  DropdownMenuItem(value: 'education', child: Text('Education')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (value) => setState(() => _creatorCategory = value),
                validator: Validators.requiredField,
              ),
              const SizedBox(height: 30),

              // Terms and Conditions
              const Text(
                'Creator Terms & Conditions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'By becoming a creator, you agree to our community guidelines and terms of service. '
                'You are responsible for the content you create and events you organize.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 15),

              // Terms Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _acceptedTerms,
                    onChanged: (value) => setState(() => _acceptedTerms = value ?? false),
                  ),
                  const Expanded(
                    child: Text(
                      'I accept the terms and conditions',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Submit Button
              LoadingButton(
                isLoading: _isSubmitting,
                onPressed: _submitCreatorApplication,
                text: 'Submit Application',
              ), 
            ],
          ),
        ),
      ),
    );
  }
}