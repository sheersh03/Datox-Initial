import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_errors.dart';
import '../../profile/data/profile_api.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameCtrl = TextEditingController();
  final _birthYearCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  String _gender = 'male';
  String _intent = 'dating';
  bool _saving = false;

  String? _validate({
    required String name,
    required int? birthYear,
    required String city,
    required String bio,
  }) {
    final currentYear = DateTime.now().year;
    if (name.isEmpty || name.length > 80) {
      return 'Name must be between 1 and 80 characters.';
    }
    if (birthYear == null || birthYear < 1900 || birthYear > currentYear) {
      return 'Birth year must be between 1900 and $currentYear.';
    }
    if (city.length > 80) {
      return 'City must be at most 80 characters.';
    }
    if (bio.length > 400) {
      return 'Bio must be at most 400 characters.';
    }
    return null;
  }

  String _errorMessage(Object e) {
    if (e is DioException && e.error is ApiException) {
      return (e.error as ApiException).message;
    }
    return 'Failed to save profile. Please try again.';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _birthYearCtrl.dispose();
    _cityCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final birthYear = int.tryParse(_birthYearCtrl.text.trim());
    final city = _cityCtrl.text.trim();
    final bio = _bioCtrl.text.trim();

    final validationError = _validate(
      name: name,
      birthYear: birthYear,
      city: city,
      bio: bio,
    );
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }
    final safeBirthYear = birthYear!;

    setState(() => _saving = true);
    try {
      await ProfileApi.upsertBasic(
        name: name,
        birthYear: safeBirthYear,
        gender: _gender,
        intent: _intent,
        city: city.isEmpty ? null : city,
        bio: bio.isEmpty ? null : bio,
      );
      if (!mounted) return;
      context.go('/discover');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Finish your profile to unlock discovery.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _birthYearCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Birth year'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _gender,
            decoration: const InputDecoration(labelText: 'Gender'),
            items: const [
              DropdownMenuItem(value: 'male', child: Text('Male')),
              DropdownMenuItem(value: 'female', child: Text('Female')),
              DropdownMenuItem(value: 'non-binary', child: Text('Non-binary')),
            ],
            onChanged: (value) => setState(() => _gender = value ?? 'male'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _intent,
            decoration: const InputDecoration(labelText: 'Intent'),
            items: const [
              DropdownMenuItem(value: 'dating', child: Text('Dating')),
              DropdownMenuItem(value: 'friends', child: Text('Friends')),
              DropdownMenuItem(value: 'marriage', child: Text('Marriage')),
            ],
            onChanged: (value) => setState(() => _intent = value ?? 'dating'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cityCtrl,
            decoration: const InputDecoration(labelText: 'City (optional)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bioCtrl,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Bio (optional)'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saving ? null : _submit,
            child: Text(_saving ? 'Saving...' : 'Continue'),
          ),
        ],
      ),
    );
  }
}
