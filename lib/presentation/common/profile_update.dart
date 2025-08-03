import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

class ProfilePictureService {
  static final Logger _logger = Logger('ProfilePictureService');
  
  static Future<String?> uploadProfilePicture(File imageFile, String userId) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child(userId)
          .child('profile.jpg');
      
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Update user document with new profile picture URL
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'avatarUrl': downloadUrl});
      
      _logger.info('Profile picture uploaded successfully for user: $userId');
      return downloadUrl;
    } catch (e, stackTrace) {
      _logger.severe('Error uploading profile picture for user $userId', e, stackTrace);
      return null;
    }
  }
  
  static Future<bool> deleteProfilePicture(String userId) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child(userId)
          .child('profile.jpg');
      
      await ref.delete();
      
      // Remove profile picture URL from user document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'avatarUrl': FieldValue.delete()});
      
      _logger.info('Profile picture deleted successfully for user: $userId');
      return true;
    } catch (e, stackTrace) {
      _logger.warning('Error deleting profile picture for user $userId', e, stackTrace);
      return false;
    }
  }
}

class ProfileUpdatePage extends StatefulWidget {
  const ProfileUpdatePage({super.key});

  @override
  State<ProfileUpdatePage> createState() => _ProfileUpdatePageState();
}

class _ProfileUpdatePageState extends State<ProfileUpdatePage> {
  final _formKey = GlobalKey<FormState>();

  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  final _walletAddressController = TextEditingController();

  List<String> _interests = [];
  bool _isCreator = false;
  String? _userId;
  bool _isUploading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _avatarUrlController.dispose();
    _walletAddressController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(_userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        if (mounted) {
          setState(() {
            _displayNameController.text = data['displayName'] ?? '';
            _emailController.text = data['email'] ?? '';
            _avatarUrlController.text = data['avatarUrl'] ?? '';
            _interests = List<String>.from(data['interests'] ?? []);
            _walletAddressController.text = data['walletAddress'] ?? '';
            _isCreator = data['isCreator'] ?? false;
          });
        }
      }
    }
  }

  // Image upload using ProfilePictureService
  Future<void> _pickAndUploadImage() async {
    if (_isUploading || _userId == null) return;

    setState(() => _isUploading = true);

    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        final file = File(pickedImage.path);
        
        // ProfilePictureService upload
        final downloadUrl = await ProfilePictureService.uploadProfilePicture(file, _userId!);

        if (mounted && downloadUrl != null) {
          setState(() => _avatarUrlController.text = downloadUrl);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload profile picture'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image upload failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  // Method to delete profile picture
  Future<void> _deleteProfilePicture() async {
    if (_userId == null || _avatarUrlController.text.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile Picture'),
        content: const Text('Are you sure you want to delete your profile picture?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isUploading = true);
      
      final success = await ProfilePictureService.deleteProfilePicture(_userId!);
      
      if (mounted) {
        setState(() {
          _isUploading = false;
          if (success) {
            _avatarUrlController.text = '';
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success 
                ? 'Profile picture deleted successfully' 
                : 'Failed to delete profile picture'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate() || _userId == null || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'displayName': _displayNameController.text.trim(),
        'email': _emailController.text.trim(),
        'avatarUrl': _avatarUrlController.text.trim(),
        'interests': _interests,
        'walletAddress': _walletAddressController.text.trim(),
        'isCreator': _isCreator,
      });

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      context.pop();
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showInterestDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Interest'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter an interest'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newInterest = controller.text.trim();
              if (newInterest.isNotEmpty && !_interests.contains(newInterest)) {
                setState(() => _interests.add(newInterest));
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  String? _validateWalletAddress(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    final trimmed = value.trim();
    
    if (trimmed.startsWith('0x') && trimmed.length == 42) {
      final hexPart = trimmed.substring(2);
      if (RegExp(r'^[a-fA-F0-9]+$').hasMatch(hexPart)) {
        return null;
      }
    }
    
    if ((trimmed.length >= 26 && trimmed.length <= 35) || 
        (trimmed.length >= 42 && trimmed.length <= 62)) {
      if (RegExp(r'^[a-zA-Z0-9]+$').hasMatch(trimmed)) {
        return null;
      }
    }
    
    return 'Please enter a valid wallet address';
  }

  @override
  Widget build(BuildContext context) {
    final avatar = _avatarUrlController.text.isNotEmpty
        ? NetworkImage(_avatarUrlController.text)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Update Profile',
          style: TextStyle(
            fontFamily: 'Onest',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        actions: [
          IconButton(
            icon: _isSaving 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            onPressed: _isSaving ? null : _updateProfile,
            tooltip: 'Save Changes',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with edit and delete options
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: avatar,
                      child: avatar == null
                          ? const Icon(Icons.person, size: 50, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: _isUploading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.edit, color: Colors.white, size: 20),
                          onPressed: _isUploading ? null : _pickAndUploadImage,
                        ),
                      ),
                    ),
                    // Delete button if avatar exists
                    if (_avatarUrlController.text.isNotEmpty)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                            onPressed: _isUploading ? null : _deleteProfilePicture,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter email';
                  if (!value.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              const Text('Interests',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ..._interests.map(
                    (interest) => Chip(
                      label: Text(interest),
                      onDeleted: () =>
                          setState(() => _interests.remove(interest)),
                    ),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.add, color: Colors.blue),
                    label: const Text('Add Interest',
                        style: TextStyle(color: Colors.blue)),
                    onPressed: _showInterestDialog,
                  )
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _walletAddressController,
                decoration: const InputDecoration(
                  labelText: 'Wallet Address',
                  hintText: 'Enter your wallet address (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance_wallet),
                  helperText: 'Supports Ethereum and Bitcoin addresses',
                ),
                validator: _validateWalletAddress,
                maxLines: 1,
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 8),
                    const Text('Creator Account',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Switch(
                      value: _isCreator,
                      onChanged: (value) => setState(() => _isCreator = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000000),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Saving...'),
                          ],
                        )
                      : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}