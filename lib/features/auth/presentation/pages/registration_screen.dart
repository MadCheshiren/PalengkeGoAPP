import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/navigation/app_routes.dart';
import 'package:palengkego/features/auth/application/auth_provider.dart';
import 'package:palengkego/features/profile/application/preferences_provider.dart';
import 'package:palengkego/features/profile/domain/delivery_address.dart';
import 'package:url_launcher/url_launcher.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _termsAccepted = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  DeliveryAddress? _selectedAddress;

  @override
  void dispose() {
    _firstNameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    // Form validators cover all field-level checks.
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms & Privacy Policy.'),
        ),
      );
      return;
    }

    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set your delivery location first.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final firstName = _firstNameController.text.trim();
      final surname = _surnameController.text.trim();
      final email = _emailController.text.trim().toLowerCase();
      final password = _passwordController.text;
      final name = '$firstName $surname';
      await ref.read(authProvider.notifier).register(email, password, name);

      // Save the selected address if any
      if (_selectedAddress != null) {
        ref
            .read(preferencesProvider.notifier)
            .updateAddress(
              primaryAddress: _selectedAddress!.primaryAddress,
              streetAddress: _selectedAddress!.streetAddress,
              notes: _selectedAddress!.notes,
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Registration successful!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }

      if (!mounted) return;

      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.main, (route) => false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
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
      backgroundColor: const Color(0xFFF6F8F7),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF0B372B),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            // Scrollable form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header text
                      Image.asset('assets/images/logonobg.png', height: 80),
                      const SizedBox(height: 16),
                      Text(
                        'Create an Account',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0B372B),
                          height: 1.2,
                          letterSpacing: -0.75,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join PalengkeGo for fresh market delivery.',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF64748B),
                          height: 1.43,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      // Name
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              label: 'First Name',
                              hintText: 'First name',
                              prefixIcon: Icons.person_outline_rounded,
                              controller: _firstNameController,
                              // Allow letters, spaces, hyphens, and periods (for names like "Ma. Elena")
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r"[a-zA-ZÀ-ÿ .\-']"),
                                ),
                              ],
                              textCapitalization: TextCapitalization.words,
                              validator: (v) {
                                final val = (v ?? '').trim();
                                if (val.isEmpty) {
                                  return 'First name is required';
                                }
                                if (val.length < 2) return 'Too short';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildField(
                              label: 'Surname',
                              hintText: 'Surname',
                              prefixIcon: Icons.person_outline_rounded,
                              controller: _surnameController,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r"[a-zA-ZÀ-ÿ .\-']"),
                                ),
                              ],
                              textCapitalization: TextCapitalization.words,
                              validator: (v) {
                                final val = (v ?? '').trim();
                                if (val.isEmpty) return 'Surname is required';
                                if (val.length < 2) return 'Too short';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Email
                      _buildField(
                        label: 'Email Address',
                        hintText: 'Enter your email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        controller: _emailController,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          _LowercaseFormatter(),
                        ],
                        validator: (v) {
                          final val = (v ?? '').trim();
                          if (val.isEmpty) return 'Email is required';
                          final ok = RegExp(
                            r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
                          ).hasMatch(val);
                          return ok ? null : 'Enter a valid email address';
                        },
                      ),
                      const SizedBox(height: 16),
                      // Phone
                      _buildField(
                        label: 'Phone Number',
                        hintText: 'xxx xxx xxxx',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        controller: _phoneController,
                        prefixText: '+63 ',
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                          _PhoneSpaceFormatter(),
                        ],
                        validator: (v) {
                          final val = (v ?? '').replaceAll(RegExp(r'\D'), '');
                          if (val.isEmpty) return 'Phone number is required';
                          if (val.length < 10) {
                            return 'Enter a 10-digit PH number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Password
                      _buildPasswordField(
                        label: 'Password',
                        hintText: 'Create a password',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        validator: (v) {
                          final val = v ?? '';
                          if (val.isEmpty) return 'Password is required';
                          if (val.length < 8) return 'At least 8 characters';
                          if (!RegExp(r'[A-Z]').hasMatch(val)) {
                            return 'Add an uppercase letter';
                          }
                          if (!RegExp(r'[0-9]').hasMatch(val)) {
                            return 'Add a number';
                          }
                          if (!RegExp(r'[!@#&*~^%]').hasMatch(val)) {
                            return 'Add a special character (!@#&*~^%)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Confirm Password
                      _buildPasswordField(
                        label: 'Confirm Password',
                        hintText: 'Confirm your password',
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                        validator: (v) {
                          if ((v ?? '').isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (v != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Set Address Button
                      _addressPlaceholder(),
                      const SizedBox(height: 24),
                      // Terms
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: _termsAccepted,
                            onChanged: (val) {
                              setState(() {
                                _termsAccepted = val ?? false;
                              });
                            },
                            activeColor: const Color(0xFF0B372B),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final url = Uri.parse(
                                  'https://palengkego.com/terms',
                                );
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                } else {
                                  if (!context.mounted) return;
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text(
                                        'Terms & Privacy Policy',
                                      ),
                                      content: const SingleChildScrollView(
                                        child: Text(
                                          'By registering, you agree to our Terms & Privacy Policy.\n\n'
                                          'Please note: Stall holder contact numbers are collected and displayed to allow direct customer communication.\n\n'
                                          'For full terms, please visit https://palengkego.com/terms',
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(),
                                          child: const Text(
                                            'Close',
                                            style: TextStyle(
                                              color: Color(0xFF0B372B),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF64748B),
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: 'By registering, you agree to our ',
                                    ),
                                    TextSpan(
                                      text: 'Terms & Privacy Policy',
                                      style: TextStyle(
                                        color: const Color(0xFF0B372B),
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _bottomActionBar(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextEditingController? controller,
    String? prefixText,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hintText,
            prefixText: prefixText,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            hintStyle: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF94A3B8),
            ),
            prefixIcon: Icon(
              prefixIcon,
              size: 18,
              color: const Color(0xFF94A3B8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF0B372B),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 1.5,
              ),
            ),
            errorStyle: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 11,
              color: Color(0xFFEF4444),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          textInputAction: TextInputAction.next,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            hintStyle: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 12),
              child: Icon(
                Icons.lock_outline,
                size: 16,
                color: Color(0xFF94A3B8),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 0,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: const Color(0xFF64748B),
              ),
              onPressed: onToggleVisibility,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF0B372B),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 1.5,
              ),
            ),
            errorStyle: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 11,
              color: Color(0xFFEF4444),
            ),
          ),
        ),
      ],
    );
  }

  Widget _addressPlaceholder() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(
          context,
        ).pushNamed(AppRoutes.setDeliveryAddress);
        if (result is DeliveryAddress) {
          setState(() {
            _selectedAddress = result;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0B372B).withValues(alpha: 0.05),
          border: Border.all(
            color: const Color(0xFF0B372B),
            width: 1,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF0B372B).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_outlined,
                size: 20,
                color: Color(0xFF0B372B),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedAddress?.primaryAddress ??
                      'Set Your Delivery Address',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0B372B),
                  ),
                ),
                if (_selectedAddress != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _selectedAddress!.streetAddress,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: Color(0xFF0B372B),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        border: const Border(
          top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 12),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0B372B).withValues(alpha: 0.2),
                      offset: const Offset(0, 4),
                      blurRadius: 6,
                      spreadRadius: -4,
                    ),
                    BoxShadow(
                      color: const Color(0xFF0B372B).withValues(alpha: 0.2),
                      offset: const Offset(0, 10),
                      blurRadius: 15,
                      spreadRadius: -3,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B372B),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    disabledBackgroundColor: const Color(
                      0xFF0B372B,
                    ).withValues(alpha: 0.5),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.0,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Register Account',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                },
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(color: Color(0xFF475569)),
                        ),
                        TextSpan(
                          text: 'Log In',
                          style: TextStyle(
                            color: const Color(0xFF0B372B),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Forces all typed characters to lowercase — used on email fields.
class _LowercaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toLowerCase());
}

class _PhoneSpaceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (text.length > 10) text = text.substring(0, 10);
    var formatted = '';
    for (var i = 0; i < text.length; i++) {
      if (i == 3 || i == 6) formatted += ' ';
      formatted += text[i];
    }

    // Attempt to maintain cursor position
    int cursor = newValue.selection.baseOffset;
    if (cursor > formatted.length) {
      cursor = formatted.length;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
