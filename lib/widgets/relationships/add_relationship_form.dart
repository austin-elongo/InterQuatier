import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interquatier/providers/relationship_provider.dart';
import 'package:interquatier/providers/auth_provider.dart';

class AddRelationshipForm extends ConsumerStatefulWidget {
  const AddRelationshipForm({super.key});

  @override
  ConsumerState<AddRelationshipForm> createState() => _AddRelationshipFormState();
}

class _AddRelationshipFormState extends ConsumerState<AddRelationshipForm> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String _selectedType = 'friend';
  bool _isSubmitting = false;

  final _relationshipTypes = [
    'friend',
    'family',
    'mentor',
    'colleague',
    'coach',
    'teammate',
    'student',
    'other',
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authProvider);
    if (user == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref.read(relationshipProvider.notifier).createBadge(
            fromUserId: user.uid,
            toUserId: '', // Will be set by the backend
            badgeType: _selectedType,
            toPhoneNumber: _phoneController.text,
          );

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
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add Relationship',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Relationship Type',
                border: OutlineInputBorder(),
              ),
              items: _relationshipTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixText: '+',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : const Text('Send Invitation'),
            ),
          ],
        ),
      ),
    );
  }
} 