import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    final street = _streetController.text.trim();
    final city = _cityController.text.trim();
    final country = _countryController.text.trim();

    Map<String, String>? address;
    if (street.isNotEmpty || city.isNotEmpty || country.isNotEmpty) {
      address = {
        'street': street,
        'city': city,
        'country': country,
      };
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      phone: phone,
      address: address,
    );

    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Registration failed'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Create\nAccount',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign up to start shopping',
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 40),
                CustomTextField(
                  hint: 'Full Name',
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  hint: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  hint: 'Phone Number (optional)',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  hint: 'Password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  hint: 'Confirm Password',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Address section (optional, collapsible)
                _buildAddressSection(),

                const SizedBox(height: 32),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) => CustomButton(
                    text: 'Sign Up',
                    onPressed: _register,
                    isLoading: auth.isLoading,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: Row(
          children: [
            Icon(Icons.location_on_outlined, size: 20, color: AppTheme.textSecondary),
            const SizedBox(width: 8),
            Text(
              'Address (optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        children: [
          const SizedBox(height: 8),
          CustomTextField(
            hint: 'Street Address',
            controller: _streetController,
            prefixIcon: const Icon(Icons.home_outlined, size: 20),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  hint: 'City',
                  controller: _cityController,
                  prefixIcon: const Icon(Icons.location_city_outlined, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  hint: 'Country',
                  controller: _countryController,
                  prefixIcon: const Icon(Icons.flag_outlined, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
