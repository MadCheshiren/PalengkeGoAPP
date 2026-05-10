import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:palengkego/features/main/presentation/pages/main_screen.dart';
import 'package:palengkego/features/auth/presentation/pages/login_screen.dart';
import 'package:palengkego/features/profile/presentation/pages/set_delivery_address_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: SafeArea(
        child: Column(
          children: [
            // Simple header with title only (no logo, no back button - entry point)
            const SizedBox(height: 24),
            // Scrollable form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header text
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
                      // Full Name
                      _buildField(
                        label: 'Full Name',
                        hintText: 'Enter your full name',
                        prefixIcon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 16),
                      // Email
                      _buildField(
                        label: 'Email Address',
                        hintText: 'Enter your email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      // Phone
                      _buildField(
                        label: 'Phone Number',
                        hintText: '+63 900 000 0000',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      // Password
                      _buildPasswordField(
                        label: 'Password',
                        hintText: 'Create a password',
                        obscureText: _obscurePassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Confirm Password
                      _buildPasswordField(
                        label: 'Confirm Password',
                        hintText: 'Confirm your password',
                        obscureText: _obscureConfirmPassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Set Address Button
                      _addressPlaceholder(),
                      const SizedBox(height: 24),
                      // Terms
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: RichText(
                          textAlign: TextAlign.center,
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
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom action bar
            _bottomActionBar(),
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
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextFormField(
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            decoration: InputDecoration(
              hintText: hintText,
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
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
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
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            obscureText: obscureText,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: hintText,
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
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _addressPlaceholder() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const SetDeliveryAddressScreen(),
          ),
        );
        // Handle the returned address data if needed
        if (result != null && result is Map<String, dynamic>) {
          // Update the address display or store the data
          setState(() {
            // Update with selected address
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
                  'Set Your Delivery Address',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0B372B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Naga City, Camarines Sur',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                  ),
                ),
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
            children: [
              Container(
                height: 56,
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
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const MainScreen()),
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B372B),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: Row(
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
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
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
