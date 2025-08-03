import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class EventFormScreen extends StatefulWidget {
  final String userId;
  const EventFormScreen({super.key, required this.userId});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _thumbnailUrlController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String _type = 'in-person';
  String _category = 'Music';
  String _ticketType = 'NFT';
  String _status = 'upcoming';

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.indigo,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a date'), backgroundColor: Colors.red),
          );
        }
        return;
      }
      if (_selectedTime == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a time'), backgroundColor: Colors.red),
          );
        }
        return;
      }

      try {
        final dateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );

        final price = _priceController.text.isNotEmpty 
            ? double.tryParse(_priceController.text) ?? 0.0
            : 0.0;

        await FirebaseFirestore.instance.collection('events').add({
          'title': _titleController.text.trim(),
          'hostID': widget.userId, 
          'type': _type,
          'location': _locationController.text.trim(),
          'category': _category,
          'datetime': Timestamp.fromDate(dateTime),
          'description': _descriptionController.text.trim(),
          'status': _status,
          'thumbnailUrl': _thumbnailUrlController.text.trim(),
          'ticketType': _ticketType,
          'price': price,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating event: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVirtual = _type == 'virtual';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Create New Event',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Event Details'),
              const SizedBox(height: 12),
              _buildTextFormField(
                controller: _titleController,
                label: 'Event Title',
                hint: 'Enter your event title',
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              _buildDropdownField<String>(
                value: _type,
                label: 'Event Type',
                items: const ['in-person', 'virtual', 'hybrid'],
                onChanged: (value) => setState(() => _type = value!),
              ),
              const SizedBox(height: 16),

              _buildTextFormField(
                controller: _locationController,
                label: isVirtual ? 'Event Link' : 'Location',
                hint: isVirtual 
                    ? 'e.g., https://meet.google.com/xyz' 
                    : 'e.g., Accra Sports Stadium, Ghana',
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              _buildDropdownField<String>(
                value: _category,
                label: 'Category',
                items: const ['Music', 'Nightlife', 'Gaming', 'Sports', 'Health', 'Comedy', 'Cinema', 'Education', 'Business', 'Wellness'],
                onChanged: (value) => setState(() => _category = value!),
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Date & Time'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: _dateController,
                      label: 'Date',
                      hint: 'Select date',
                      readOnly: true,
                      suffixIcon: Icons.calendar_today,
                      onTap: _selectDate,
                      validator: (value) => value?.isEmpty == true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextFormField(
                      controller: _timeController,
                      label: 'Time',
                      hint: 'Select time',
                      readOnly: true,
                      suffixIcon: Icons.access_time,
                      onTap: _selectTime,
                      validator: (value) => value?.isEmpty == true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Description'),
              const SizedBox(height: 12),
              _buildTextFormField(
                controller: _descriptionController,
                label: 'Event Description',
                hint: 'Describe your event in detail...',
                maxLines: 4,
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Event Settings'),
              const SizedBox(height: 12),
              
              _buildDropdownField<String>(
                value: _status,
                label: 'Status',
                items: const ['upcoming', 'live', 'ended'],
                onChanged: (value) => setState(() => _status = value!),
              ),
              const SizedBox(height: 16),

              _buildDropdownField<String>(
                value: _ticketType,
                label: 'Ticket Type',
                items: const ['NFT', 'General', 'VIP'],
                onChanged: (value) => setState(() => _ticketType = value!),
              ),
              const SizedBox(height: 24),

              _buildTextFormField(
                controller: _priceController,
                label: 'Price (Kes)',
                hint: 'Enter price or leave blank for free',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final price = double.tryParse(value);
                    if (price == null || price < 0) {
                      return 'Enter a valid price';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Event Thumbnail'),
              const SizedBox(height: 12),
              _buildTextFormField(
                controller: _thumbnailUrlController,
                label: 'Thumbnail URL',
                hint: 'Enter URL for event thumbnail image',
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              if (_thumbnailUrlController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _thumbnailUrlController.text,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 150,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        ),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / 
                                    loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000000),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Create Event',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    bool readOnly = false,
    int maxLines = 1,
    IconData? suffixIcon,
    VoidCallback? onTap,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      readOnly: readOnly,
      maxLines: maxLines,
      onTap: onTap,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon != null 
            ? Icon(suffixIcon, color: Colors.grey[600])
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: TextStyle(color: Colors.grey[700]),
        hintStyle: TextStyle(color: Colors.grey[500]),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required T value,
    required String label,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField2<T>(
      value: value,
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Center(
          child: Text(
            item.toString().replaceAll('-', ' '),
            textAlign: TextAlign.center,
          ),
        ),
      )).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: TextStyle(color: Colors.grey[700]),
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 200,
        width: MediaQuery.of(context).size.width * 0.6,
        offset: const Offset(0, -5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      menuItemStyleData: const MenuItemStyleData(
        height: 60,
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _thumbnailUrlController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}