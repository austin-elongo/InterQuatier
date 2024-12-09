import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interquatier/providers/auth_provider.dart';
import 'package:interquatier/models/event.dart';
import 'package:interquatier/services/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:interquatier/services/image_service.dart';
import 'package:interquatier/widgets/image_picker_dialog.dart';
import 'package:interquatier/widgets/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'package:interquatier/providers/premium_provider.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  List<File> _imageFiles = [];
  bool _isProcessingImage = false;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedSport = 'Football';
  String _selectedSkillLevel = 'Beginner';
  int _participantLimit = 10;
  DateTime _selectedStartDate = DateTime.now();
  TimeOfDay _selectedStartTime = TimeOfDay.now();
  DateTime _selectedEndDate = DateTime.now();
  TimeOfDay _selectedEndTime = TimeOfDay.now();
  double _entryFee = 0;
  bool _isUploading = false;
  double _uploadProgress = 0;
  EventVisibility _visibility = EventVisibility.public;

  @override
  void initState() {
    super.initState();
    // Set default end time to 2 hours after start time
    _selectedEndTime = TimeOfDay(
      hour: _selectedStartTime.hour + 2,
      minute: _selectedStartTime.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Create Event'),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Image Picker
                _buildImagePicker(),
                const SizedBox(height: 16),

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Event Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Sport Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedSport,
                  decoration: const InputDecoration(
                    labelText: 'Sport',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    'Football',
                    'Basketball',
                    'Tennis',
                    'Volleyball',
                    'Rugby',
                    'Other',
                  ].map((sport) {
                    return DropdownMenuItem(
                      value: sport,
                      child: Text(sport),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSport = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Location
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date & Time
                ListTile(
                  title: const Text('Start Time'),
                  subtitle: Text(
                    '${DateFormat('MMM d, y').format(_selectedStartDate)} at '
                    '${_selectedStartTime.format(context)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _selectStartDateTime,
                ),
                ListTile(
                  title: const Text('End Time'),
                  subtitle: Text(
                    '${DateFormat('MMM d, y').format(_selectedEndDate)} at '
                    '${_selectedEndTime.format(context)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _selectEndDateTime,
                ),
                const SizedBox(height: 16),

                // Skill Level
                DropdownButtonFormField<String>(
                  value: _selectedSkillLevel,
                  decoration: const InputDecoration(
                    labelText: 'Skill Level',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    'Beginner',
                    'Intermediate',
                    'Advanced',
                    'Professional',
                  ].map((level) {
                    return DropdownMenuItem(
                      value: level,
                      child: Text(level),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSkillLevel = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Participant Limit
                Row(
                  children: [
                    const Text('Participant Limit:'),
                    Expanded(
                      child: Slider(
                        value: _participantLimit.toDouble(),
                        min: 2,
                        max: 50,
                        divisions: 48,
                        label: _participantLimit.toString(),
                        onChanged: (value) {
                          setState(() {
                            _participantLimit = value.round();
                          });
                        },
                      ),
                    ),
                    Text(_participantLimit.toString()),
                  ],
                ),

                // Entry Fee
                TextFormField(
                  initialValue: _entryFee.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Entry Fee (€)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _entryFee = double.tryParse(value) ?? 0;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Visibility
                DropdownButtonFormField<EventVisibility>(
                  value: _visibility,
                  decoration: const InputDecoration(
                    labelText: 'Visibility',
                    border: OutlineInputBorder(),
                  ),
                  items: EventVisibility.values.map((visibility) {
                    return DropdownMenuItem(
                      value: visibility,
                      child: Text(
                        visibility == EventVisibility.public
                            ? 'Public'
                            : 'Relationships Only (Premium)',
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _visibility = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Create Button
                FilledButton(
                  onPressed: _handleCreateEvent,
                  child: const Text('Create Event'),
                ),
              ],
            ),
          ),
        ),
        if (_isUploading)
          LoadingIndicator(
            message: 'Uploading images...',
            progress: _uploadProgress,
          ),
      ],
    );
  }

  Future<void> _pickImage() async {
    showDialog(
      context: context,
      builder: (context) => ImagePickerDialog(
        onSourceSelected: (source) async {
          final picker = ImagePicker();
          final pickedFile = await picker.pickImage(source: source);
          
          if (pickedFile != null) {
            setState(() {
              _isProcessingImage = true;
            });

            try {
              final processedImage = await ImageService.pickAndProcessImage(
                imageFile: File(pickedFile.path),
              );

              if (processedImage != null) {
                setState(() {
                  _imageFiles.add(processedImage);
                });
              }
            } finally {
              setState(() {
                _isProcessingImage = false;
              });
            }
          }
        },
      ),
    );
  }

  Future<void> _selectStartDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime,
    );
    if (time == null) return;

    setState(() {
      _selectedStartDate = date;
      _selectedStartTime = time;
      
      // Update end time to be at least 30 minutes after start time
      final startDateTime = DateTime(
        date.year, date.month, date.day,
        time.hour, time.minute,
      );
      final defaultEndTime = startDateTime.add(const Duration(hours: 2));
      
      _selectedEndDate = defaultEndTime;
      _selectedEndTime = TimeOfDay.fromDateTime(defaultEndTime);
    });
  }

  Future<void> _selectEndDateTime() async {
    final startDateTime = DateTime(
      _selectedStartDate.year,
      _selectedStartDate.month,
      _selectedStartDate.day,
      _selectedStartTime.hour,
      _selectedStartTime.minute,
    );

    final date = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate,
      firstDate: startDateTime,
      lastDate: startDateTime.add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime,
    );
    if (time == null) return;

    final endDateTime = DateTime(
      date.year, date.month, date.day,
      time.hour, time.minute,
    );

    if (endDateTime.isBefore(startDateTime.add(const Duration(minutes: 30)))) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event must be at least 30 minutes long'),
          ),
        );
      }
      return;
    }

    setState(() {
      _selectedEndDate = date;
      _selectedEndTime = time;
    });
  }

  Future<void> _handleCreateEvent() async {
    if (!_formKey.currentState!.validate()) return;
    
    final user = ref.read(authProvider);
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to create events')),
        );
      }
      return;
    }

    final isPremium = ref.read(premiumProvider).value ?? false;

    if (isPremium && _visibility == EventVisibility.public) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Relationship-only events are a premium feature'),
        ),
      );
      return;
    }

    final startDateTime = DateTime(
      _selectedStartDate.year,
      _selectedStartDate.month,
      _selectedStartDate.day,
      _selectedStartTime.hour,
      _selectedStartTime.minute,
    );

    final endDateTime = DateTime(
      _selectedEndDate.year,
      _selectedEndDate.month,
      _selectedEndDate.day,
      _selectedEndTime.hour,
      _selectedEndTime.minute,
    );

    if (endDateTime.isBefore(startDateTime.add(const Duration(minutes: 30)))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event must be at least 30 minutes long'),
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });

    try {
      // Create event with temporary image URL
      final event = Event(
        id: '',
        creatorId: user.uid,
        title: _titleController.text,
        bannerImageUrl: '',
        sport: _selectedSport,
        location: _locationController.text,
        startTime: startDateTime,
        endTime: endDateTime,
        skillLevel: _selectedSkillLevel,
        participantLimit: _participantLimit,
        currentParticipants: [],
        description: _descriptionController.text,
        status: 'active',
        createdAt: DateTime.now(),
        eventType: 'sports',
        entryFee: _entryFee,
        equipmentProvided: '',
        ageGroup: 'All',
        duration: '2 hours',
        genderRestriction: 'None',
        weatherBackupPlan: '',
        specialRequirements: [],
        venueType: 'Outdoor',
        additionalNotes: '',
        visibility: isPremium ? EventVisibility.relationships : EventVisibility.public,
      );

      // Create event in Firestore first to get ID
      final docRef = await FirebaseFirestore.instance
          .collection('events')
          .add(event.toFirestore());

      // Upload image using the event ID
      final imageUrl = await StorageService().uploadEventImage(
        docRef.id,
        _imageFiles[0],
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
          });
        },
      );

      // Update event with image URL
      await docRef.update({'bannerImageUrl': imageUrl});

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Widget _buildImagePicker() {
    return Stack(
      children: [
        if (_imageFiles.isEmpty)
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isProcessingImage
                  ? const Center(child: CircularProgressIndicator())
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, size: 48),
                        SizedBox(height: 8),
                        Text('Add Event Images'),
                      ],
                    ),
            ),
          )
        else
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _imageFiles.length + 1,
              itemBuilder: (context, index) {
                if (index == _imageFiles.length) {
                  return _buildAddImageButton();
                }
                return _buildImageThumbnail(index);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildImageThumbnail(int index) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              _imageFiles[index],
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 16,
          child: IconButton(
            onPressed: () {
              setState(() {
                _imageFiles.removeAt(index);
              });
            },
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black54,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 200,
        height: 200,
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add_photo_alternate, size: 48),
      ),
    );
  }
} 