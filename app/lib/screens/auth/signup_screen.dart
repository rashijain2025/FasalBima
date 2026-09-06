

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';

// 🔹 NEW: localization imports
import '../../localization/app_localizations.dart';
import '../../localization/locale_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(loc.t('signup_title')), // "Create Account"
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              localeProvider.toggleLocale();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.person_add,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.t('signup_title'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.t('signup_subtitle'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Signup Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: loc.t('signup_full_name'),
                        prefixIcon: const Icon(Icons.person_outlined),
                        hintText: loc.t('signup_full_name_hint'),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return loc.t('val_enter_name');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 🔹 Email field (optional)
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: loc.t('signup_email'),
                        prefixIcon: const Icon(Icons.email_outlined),
                        hintText: loc.t('signup_email_hint'),
                      ),
                      validator: (value) {
                        // empty allowed
                        if (value == null || value.isEmpty) {
                          return null;
                        }
                        // if filled, basic format check
                        if (!value.contains('@')) {
                          return loc.t('val_email_invalid');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: loc.t('signup_phone'),
                        prefixIcon: const Icon(Icons.phone_outlined),
                        hintText: loc.t('signup_phone_hint'),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return loc.t('val_enter_phone');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: loc.t('signup_address'),
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        hintText: loc.t('signup_address_hint'),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return loc.t('val_enter_address');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: loc.t('signup_password'),
                        prefixIcon: const Icon(Icons.lock_outlined),
                        hintText: loc.t('signup_password_hint'),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return loc.t('val_enter_password');
                        }
                        if (value.length < 6) {
                          return loc.t('val_password_length');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: loc.t('signup_confirm_password'),
                        prefixIcon: const Icon(Icons.lock_outlined),
                        hintText: loc.t('signup_confirm_password_hint'),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return loc.t('val_confirm_password');
                        }
                        if (value != _passwordController.text) {
                          return loc.t('val_password_mismatch');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Signup Button
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                authProvider.isLoading ? null : _handleSignup,
                            child: authProvider.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              Colors.white),
                                    ),
                                  )
                                : Text(loc.t('signup_button')),
                          ),
                        );
                      },
                    ),

                    // Error Message
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        if (authProvider.error != null) {
                          return Container(
                            margin: const EdgeInsets.only(top: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.error.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: AppColors.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    authProvider.error!,
                                    style:
                                        TextStyle(color: AppColors.error),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    loc.t('signup_already'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text(
                      loc.t('signup_login'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.signup(
        _nameController.text.trim(),
        _emailController.text.trim(), // can be empty
        _passwordController.text,
        _phoneController.text.trim(),
        _addressController.text.trim(),
      );

      if (success && mounted) {
        context.go('/home');
      }
    }
  }
}


