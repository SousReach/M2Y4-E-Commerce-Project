import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _streetController = TextEditingController(text: user?.address.street ?? '');
    _cityController = TextEditingController(text: user?.address.city ?? '');
    _countryController = TextEditingController(text: user?.address.country ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    
    final address = {
      'street': _streetController.text.trim(),
      'city': _cityController.text.trim(),
      'country': _countryController.text.trim(),
    };

    final success = await authProvider.updateUserProfile(
      _nameController.text.trim(),
      _phoneController.text.trim(),
      address,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Failed to update profile'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Personal Info',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hint: 'Full Name',
                controller: _nameController,
                prefixIcon: const Icon(Icons.person_outline, size: 20),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                hint: 'Phone Number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined, size: 20),
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Address',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hint: 'Street Address',
                controller: _streetController,
                prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                hint: 'City',
                controller: _cityController,
                prefixIcon: const Icon(Icons.location_city_outlined, size: 20),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                hint: 'Country',
                controller: _countryController,
                prefixIcon: const Icon(Icons.flag_outlined, size: 20),
              ),
              const SizedBox(height: 40),
              
              Consumer<AuthProvider>(
                builder: (context, auth, _) => CustomButton(
                  text: 'Save Changes',
                  onPressed: _saveProfile,
                  isLoading: auth.isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
