// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:go_router/go_router.dart';
// import '../../providers/auth_provider.dart';
// import '../../utils/app_colors.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _phoneController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _obscurePassword = true;

//   @override
//   void dispose() {
//     _phoneController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const SizedBox(height: 60),
//               // Logo and Title
//               Column(
//                 children: [
//                   Container(
//                     width: 120,
//                     height: 120,
//                     decoration: BoxDecoration(
//                       color: AppColors.primary,
//                       borderRadius: BorderRadius.circular(60),
//                     ),
//                     child: const Icon(
//                       Icons.agriculture,
//                       size: 60,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   Text(
//                     'Farmer App',
//                     style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.textPrimary,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Manage your crops and track your farming journey',
//                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                       color: AppColors.textSecondary,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 48),
              
//               // Login Form
//               Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     TextFormField(
//                       controller: _phoneController,
//                       keyboardType: TextInputType.phone,
//                       decoration: const InputDecoration(
//                         labelText: 'Phone Number',
//                         prefixIcon: Icon(Icons.phone_outlined),
//                         hintText: 'Enter your phone number',
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your phone number';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _passwordController,
//                       obscureText: _obscurePassword,
//                       decoration: InputDecoration(
//                         labelText: 'Password',
//                         prefixIcon: const Icon(Icons.lock_outlined),
//                         hintText: 'Enter your password',
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _obscurePassword ? Icons.visibility : Icons.visibility_off,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _obscurePassword = !_obscurePassword;
//                             });
//                           },
//                         ),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your password';
//                         }
//                         if (value.length < 6) {
//                           return 'Password must be at least 6 characters';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 24),
                    
//                     // Login Button
//                     Consumer<AuthProvider>(
//                       builder: (context, authProvider, _) {
//                         return SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             onPressed: authProvider.isLoading ? null : _handleLogin,
//                             child: authProvider.isLoading
//                                 ? const SizedBox(
//                                     height: 20,
//                                     width: 20,
//                                     child: CircularProgressIndicator(
//                                       strokeWidth: 2,
//                                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                                     ),
//                                   )
//                                 : const Text('Login'),
//                           ),
//                         );
//                       },
//                     ),
                    
//                     // Error Message
//                     Consumer<AuthProvider>(
//                       builder: (context, authProvider, _) {
//                         if (authProvider.error != null) {
//                           return Container(
//                             margin: const EdgeInsets.only(top: 16),
//                             padding: const EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: AppColors.error.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(color: AppColors.error.withOpacity(0.3)),
//                             ),
//                             child: Row(
//                               children: [
//                                 Icon(Icons.error_outline, color: AppColors.error, size: 20),
//                                 const SizedBox(width: 8),
//                                 Expanded(
//                                   child: Text(
//                                     authProvider.error!,
//                                     style: TextStyle(color: AppColors.error),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }
//                         return const SizedBox.shrink();
//                       },
//                     ),
//                   ],
//                 ),
//               ),
              
//               const SizedBox(height: 32),
              
//               // Sign Up Link
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "Don't have an account? ",
//                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () => context.go('/signup'),
//                     child: Text(
//                       'Sign Up',
//                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                         color: AppColors.primary,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
              
//               const SizedBox(height: 24),
              
//               // Demo Credentials
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: AppColors.info.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: AppColors.info.withOpacity(0.3)),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.info_outline, color: AppColors.info, size: 20),
//                         const SizedBox(width: 8),
//                         Text(
//                           'Demo Credentials',
//                           style: TextStyle(
//                             color: AppColors.info,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Phone: your registered number\nPassword: your password',
//                       style: TextStyle(color: AppColors.info),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _handleLogin() async {
//     if (_formKey.currentState!.validate()) {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final success = await authProvider.login(
//         _phoneController.text.trim(),
//         _passwordController.text,
//       );
      
//       if (success && mounted) {
//         context.go('/home');
//       }
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';

// 🔹 NEW: localization imports
import '../../localization/app_localizations.dart';
import '../../localization/locale_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🔹 top-right language toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.language),
                    onPressed: () {
                      localeProvider.toggleLocale();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Logo and Title
              Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: const Icon(
                      Icons.agriculture,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    loc.t('app_title'), // e.g. "Farmer App"
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.t('login_subtitle'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // Login Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: loc.t('login_phone_label'),
                        prefixIcon: const Icon(Icons.phone_outlined),
                        hintText: loc.t('login_phone_hint'),
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
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: loc.t('login_password_label'),
                        prefixIcon: const Icon(Icons.lock_outlined),
                        hintText: loc.t('login_password_hint'),
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
                    const SizedBox(height: 24),

                    // Login Button
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                authProvider.isLoading ? null : _handleLogin,
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
                                : Text(loc.t('login_button')),
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

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    loc.t('login_no_account'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/signup'),
                    child: Text(
                      loc.t('login_signup'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Demo Credentials
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.info.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.info,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          loc.t('login_demo_title'),
                          style: TextStyle(
                            color: AppColors.info,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.t('login_demo_body'),
                      style: TextStyle(color: AppColors.info),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _phoneController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        context.go('/home');
      }
    }
  }
}
