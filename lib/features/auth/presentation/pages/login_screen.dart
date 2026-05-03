import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:palengkego/features/main/presentation/pages/main_screen.dart';
import 'package:palengkego/features/auth/presentation/pages/registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      const SizedBox(height: 40),
                      Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0B372B),
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Skip the roam, order from home.',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF64748B),
                          height: 1.43,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      // Email field
                      _buildField(
                        label: 'Email',
                        hintText: 'Enter your email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      // Password field
                      _buildPasswordField(),
                      const SizedBox(height: 12),
                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Login button
                      _loginButton(),
                      const SizedBox(height: 24),
                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: const Color(0xFFE2E8F0),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or continue with',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: const Color(0xFFE2E8F0),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Social Login Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _socialLoginButton(
                              icon: 'assets/icons/google_icon.svg',
                              label: 'Google',
                              onTap: () {
                                // TODO: Implement Google Sign In
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _socialLoginButton(
                              icon: 'assets/icons/facebook_icon.svg',
                              label: 'Facebook',
                              onTap: () {
                                // TODO: Implement Facebook Sign In
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Register link
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegistrationScreen(),
                            ),
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
                                  text: "Don't have an account? ",
                                  style: TextStyle(color: Color(0xFF475569)),
                                ),
                                TextSpan(
                                  text: 'Register',
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
                      const SizedBox(height: 32),
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

  Widget _backButton() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.arrow_back_ios_new_rounded,
        size: 16,
        color: Color(0xFF0B372B),
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
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
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
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
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _socialLoginButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icon,
              width: 20,
              height: 20,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.login,
                size: 20,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
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
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: 'Enter your password',
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
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                  color: const Color(0xFF64748B),
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
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

  Widget _loginButton() {
    return Container(
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
              'Log In',
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
    );
  }

  Widget _iconPlaceholder(double size) {
    return Container(width: size, height: size, color: const Color(0xFF94A3B8));
  }
}
