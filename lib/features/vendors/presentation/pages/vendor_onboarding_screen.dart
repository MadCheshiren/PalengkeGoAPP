import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/features/auth/application/auth_provider.dart';
import 'package:palengkego/features/auth/domain/app_user.dart';
import 'package:palengkego/core/utils/page_transitions.dart';
import 'package:palengkego/features/vendors/presentation/pages/vendor_dashboard_screen.dart';
import 'package:palengkego/features/vendors/presentation/widgets/onboarding_business_info_step.dart';
import 'package:palengkego/features/vendors/presentation/widgets/onboarding_registered_name_step.dart';
import 'package:palengkego/features/vendors/presentation/widgets/onboarding_id_card_step.dart';
import 'package:palengkego/features/vendors/presentation/widgets/onboarding_phone_step.dart';
import 'package:palengkego/features/vendors/presentation/widgets/onboarding_bottom_buttons.dart';

/// Vendor Onboarding Screen
/// Multi-step flow for vendors to register and start selling.
///
/// Steps:
/// 1. Business Information
/// 2. Registered Name
/// 3. ID Card Type
/// 4. Phone Number
///
/// Note: Field validation is disabled for development testing.
class VendorOnboardingScreen extends ConsumerStatefulWidget {
  const VendorOnboardingScreen({super.key});

  @override
  ConsumerState<VendorOnboardingScreen> createState() => _VendorOnboardingScreenState();
}

class _VendorOnboardingScreenState extends ConsumerState<VendorOnboardingScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  // Form data (no validation for dev)
  final _registeredNameController = TextEditingController();
  final _mayorsPermitController = TextEditingController();
  final _sanitaryPermitController = TextEditingController();
  final _fireCertificationController = TextEditingController();
  final _marketClearanceController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  // Registered name fields
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _suffixController = TextEditingController();
  final _middleNameController = TextEditingController();

  // ID card fields
  final _idNumberController = TextEditingController();
  String _selectedIdType = 'Unified Multi-Purpose Identification (UMID) Card';

  // File upload placeholders (for dev, just text)
  String? _mayorsPermitFile;
  String? _sanitaryPermitFile;
  String? _fireCertificationFile;
  String? _marketClearanceFile;

  final List<String> _steps = [
    'Business Information',
    'Registered Name',
    'ID Card Type',
    'Phone Number',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _registeredNameController.dispose();
    _mayorsPermitController.dispose();
    _sanitaryPermitController.dispose();
    _fireCertificationController.dispose();
    _marketClearanceController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _suffixController.dispose();
    _middleNameController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  void _nextStep() async {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Last step - go to vendor dashboard with smooth transition
      await ref.read(authProvider.notifier).loginAs(UserRole.vendor);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        PageTransitions.slideFromRight(const VendorDashboardScreen()),
        (route) => false,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _onUploadMayorsPermit() {
    setState(() {
      _mayorsPermitFile = 'mayors_permit.pdf';
      _mayorsPermitController.text = 'mayors_permit.pdf';
    });
  }

  void _onUploadSanitaryPermit() {
    setState(() {
      _sanitaryPermitFile = 'sanitary_permit.pdf';
      _sanitaryPermitController.text = 'sanitary_permit.pdf';
    });
  }

  void _onUploadFireCertification() {
    setState(() {
      _fireCertificationFile = 'fire_certification.pdf';
      _fireCertificationController.text = 'fire_certification.pdf';
    });
  }

  void _onUploadMarketClearance() {
    setState(() {
      _marketClearanceFile = 'market_clearance.pdf';
      _marketClearanceController.text = 'market_clearance.pdf';
    });
  }

  void _onSendOtp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP sent to your phone'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with progress
            _buildHeader(),

            // Progress indicator
            _buildProgressIndicator(),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  OnboardingBusinessInfoStep(
                    registeredNameController: _registeredNameController,
                    phoneController: _phoneController,
                    mayorsPermitFile: _mayorsPermitFile,
                    sanitaryPermitFile: _sanitaryPermitFile,
                    fireCertificationFile: _fireCertificationFile,
                    marketClearanceFile: _marketClearanceFile,
                    onUploadMayorsPermit: _onUploadMayorsPermit,
                    onUploadSanitaryPermit: _onUploadSanitaryPermit,
                    onUploadFireCertification: _onUploadFireCertification,
                    onUploadMarketClearance: _onUploadMarketClearance,
                    onTapRegisteredName: () {
                      setState(() => _currentStep = 1);
                      _pageController.jumpToPage(1);
                    },
                    onTapPhone: () {
                      setState(() => _currentStep = 3);
                      _pageController.jumpToPage(3);
                    },
                  ),
                  OnboardingRegisteredNameStep(
                    lastNameController: _lastNameController,
                    firstNameController: _firstNameController,
                    suffixController: _suffixController,
                    middleNameController: _middleNameController,
                  ),
                  OnboardingIdCardStep(
                    selectedIdType: _selectedIdType,
                    onIdTypeChanged: (type) =>
                        setState(() => _selectedIdType = type),
                  ),
                  OnboardingPhoneStep(
                    phoneController: _phoneController,
                    otpController: _otpController,
                    onSendOtp: _onSendOtp,
                  ),
                ],
              ),
            ),

            // Bottom buttons
            OnboardingBottomButtons(
              currentStep: _currentStep,
              onNext: _nextStep,
              onPrevious: _previousStep,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: _previousStep,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFF6F8F7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: Color(0xFF0B372B),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _steps[_currentStep],
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: List.generate(_steps.length, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < _steps.length - 1 ? 8 : 0),
              decoration: BoxDecoration(
                color: index <= _currentStep
                    ? const Color(0xFF0B372B)
                    : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
