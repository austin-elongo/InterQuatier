import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interquatier/models/rental_item.dart';
import 'package:interquatier/providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interquatier/services/storage_service.dart';
import 'dart:io';
import 'package:interquatier/providers/rental_service_provider.dart';

class CreateRentalScreen extends ConsumerStatefulWidget {
  const CreateRentalScreen({super.key});

  @override
  ConsumerState<CreateRentalScreen> createState() => _CreateRentalScreenState();
}

class _CreateRentalScreenState extends ConsumerState<CreateRentalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _quantityController = TextEditingController();

  RentalCategory _selectedCategory = RentalCategory.sports;
  String _selectedCondition = 'New';
  List<File> _selectedImages = [];
  bool _isLoading = false;
  double _uploadProgress = 0;

  final List<String> _conditions = ['New', 'Like New', 'Good', 'Fair', 'Poor'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    setState(() {
      _selectedImages.addAll(images.map((xFile) => File(xFile.path)));
    });
  }

  Future<void> _handleCreateRental() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }

    final user = ref.read(authProvider);
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to list items')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload images
      final imageUrls = await StorageService().uploadRentalImages(
        'temp_id',
        _selectedImages,
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
          });
        },
      );

      // Create rental item
      final item = RentalItem(
        id: '',
        ownerId: user.uid,
        title: _titleController.text,
        description: _descriptionController.text,
        images: imageUrls,
        pricePerDay: double.parse(_priceController.text),
        category: _selectedCategory,
        condition: _selectedCondition,
        specifications: {},
        createdAt: DateTime.now(),
        tags: [],
        quantity: int.parse(_quantityController.text),
        location: _locationController.text,
        eventTypes: [],
        suitableForEvents: [],
        bookings: [],
        availability: RentalAvailability(
          startDate: DateTime.now(),
          isAvailable: true,
        ),
      );

      await ref.read(rentalServiceProvider).createRentalItem(item);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Equipment'),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Images Section
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _selectedImages.isEmpty
                        ? InkWell(
                            onTap: _pickImages,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_rounded,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add Images',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedImages.length + 1,
                            itemBuilder: (context, index) {
                              if (index == _selectedImages.length) {
                                return IconButton(
                                  onPressed: _pickImages,
                                  icon: const Icon(Icons.add_photo_alternate),
                                );
                              }
                              return Stack(
                                children: [
                                  Image.file(_selectedImages[index]),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _selectedImages.removeAt(index);
                                        });
                                      },
                                      icon: const Icon(Icons.close),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title Field
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter item name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category Dropdown
                DropdownButtonFormField<RentalCategory>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                  ),
                  items: RentalCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(_getCategoryTitle(category)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Price Field
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price per Day',
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description Field
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe your item',
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Location Field
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'Enter pickup location',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Quantity Field
                TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantity Available',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter quantity';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Condition Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCondition,
                  decoration: const InputDecoration(
                    labelText: 'Condition',
                  ),
                  items: _conditions.map((condition) {
                    return DropdownMenuItem(
                      value: condition,
                      child: Text(condition),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCondition = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Submit Button
                FilledButton(
                  onPressed: _isLoading ? null : _handleCreateRental,
                  child: const Text('List Item'),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(value: _uploadProgress),
                    const SizedBox(height: 16),
                    Text(
                      'Uploading... ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getCategoryTitle(RentalCategory category) {
    switch (category) {
      case RentalCategory.sports:
        return 'Sports Equipment';
      case RentalCategory.party:
        return 'Party Equipment';
      case RentalCategory.camping:
        return 'Camping Gear';
      case RentalCategory.gaming:
        return 'Gaming Equipment';
      case RentalCategory.other:
        return 'Other Equipment';
    }
  }
} 