import 'package:flutter/material.dart';
import 'vendor_dashboard_screen.dart';

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
class VendorOnboardingScreen extends StatefulWidget {
  const VendorOnboardingScreen({super.key});

  @override
  State<VendorOnboardingScreen> createState() => _VendorOnboardingScreenState();
}

class _VendorOnboardingScreenState extends State<VendorOnboardingScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  // Form data (no validation for dev)
  final _registeredNameController = TextEditingController();
  final _businessPermitController = TextEditingController();
  final _governmentIdController = TextEditingController();
  final _sanitaryController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Registered name fields
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _suffixController = TextEditingController();
  final _middleNameController = TextEditingController();
  
  // ID card fields
  final _idNumberController = TextEditingController();
  String _selectedIdType = 'Unified Multi-Purpose Identification (UMID) Card';
  
  // File upload placeholders (for dev, just text)
  String? _businessPermitFile;
  String? _governmentIdFile;
  String? _sanitaryFile;

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
    _businessPermitController.dispose();
    _governmentIdController.dispose();
    _sanitaryController.dispose();
    _phoneController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _suffixController.dispose();
    _middleNameController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Last step - go to vendor dashboard
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const VendorDashboardScreen(),
        ),
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
                  _buildBusinessInfoStep(),
                  _buildRegisteredNameStep(),
                  _buildIdCardStep(),
                  _buildPhoneStep(),
                ],
              ),
            ),
            
            // Bottom buttons
            _buildBottomButtons(),
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

  Widget _buildBusinessInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Registered Name field (navigates to step 1)
          _buildNavigationField(
            label: 'Registered Name',
            hint: 'Enter your full legal name as written on your government-issued ID',
            value: _registeredNameController.text.isNotEmpty 
                ? _registeredNameController.text 
                : null,
            onTap: () {
              // Navigate to Registered Name step
              setState(() {
                _currentStep = 1;
              });
              _pageController.jumpToPage(1);
            },
          ),
          const SizedBox(height: 20),
          
          // Business Permit with upload
          _buildUploadField(
            label: 'Business Permit *',
            hint: 'DTI Certificate',
            fileName: _businessPermitFile,
            onTap: () {
              // Placeholder for file upload
              setState(() {
                _businessPermitFile = 'business_permit.pdf';
                _businessPermitController.text = 'business_permit.pdf';
              });
            },
          ),
          const SizedBox(height: 20),
          
          // Government ID with upload
          _buildUploadField(
            label: 'Government ID *',
            hint: 'Please select a clear photo of your government-issued ID',
            fileName: _governmentIdFile,
            onTap: () {
              setState(() {
                _governmentIdFile = 'government_id.jpg';
                _governmentIdController.text = 'government_id.jpg';
              });
            },
          ),
          const SizedBox(height: 20),
          
          // Government ID (w/ Photo) [Front]
          _buildUploadField(
            label: 'Government ID (w/ Photo) [Front] *',
            hint: '+ Upload (0/1)',
            fileName: null,
            onTap: () {
              // Upload placeholder
            },
          ),
          const SizedBox(height: 20),
          
          // Sanitary permit
          _buildUploadField(
            label: 'Sanitary',
            hint: '+ Upload (0/1)',
            fileName: _sanitaryFile,
            onTap: () {
              setState(() {
                _sanitaryFile = 'sanitary_permit.pdf';
                _sanitaryController.text = 'sanitary_permit.pdf';
              });
            },
          ),
          const SizedBox(height: 20),
          
          // Phone Number (navigates to step 3)
          _buildNavigationField(
            label: 'Phone Number *',
            hint: '09XX XXX XXXX',
            value: _phoneController.text.isNotEmpty 
                ? _phoneController.text 
                : null,
            onTap: () {
              setState(() {
                _currentStep = 3;
              });
              _pageController.jumpToPage(3);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationField({
    required String label,
    required String hint,
    required String? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? hint,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      color: value != null 
                          ? const Color(0xFF111827)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadField({
    required String label,
    required String hint,
    required String? fileName,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    fileName ?? hint,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      color: fileName != null
                          ? const Color(0xFF0B372B)
                          : const Color(0xFFF59E0B),
                      fontWeight: fileName != null ? FontWeight.w500 : FontWeight.w600,
                    ),
                  ),
                ),
                if (fileName != null)
                  const Icon(
                    Icons.check_circle,
                    size: 20,
                    color: Color(0xFF0B372B),
                  )
                else
                  const Icon(
                    Icons.upload_file,
                    size: 20,
                    color: Color(0xFF9CA3AF),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisteredNameStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: _lastNameController,
            label: 'Last Name *',
            hint: 'Input',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _firstNameController,
            label: 'First Name *',
            hint: 'Input',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _suffixController,
            label: 'Suffix *',
            hint: 'Input',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _middleNameController,
            label: 'Middle Name *',
            hint: 'Input',
          ),
        ],
      ),
    );
  }

  Widget _buildIdCardStep() {
    // Complete list of Philippine government IDs from Figma
    final idTypes = [
      'Unified Multi-Purpose Identification (UMID) Card',
      'Social Security System (SSS) Card',
      'Government Service Insurance System (GSIS) e-Card',
      'Land Transportation Office (LTO) Driver\'s License',
      'Philippine Postal ID',
      'Philippine Passport',
      'PhilHealth ID',
      'PhilID / ePhilID (PhilSys)',
      'Professional Regulation Commission (PRC) ID',
      'Alien Certification of Registration',
      'Foreign Passport',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(idTypes.length, (index) {
            final type = idTypes[index];
            final isSelected = _selectedIdType == type;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIdType = type;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFF0FDF4)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0B372B)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        type,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF0B372B),
                        size: 20,
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPhoneStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number *',
            hint: 'Input',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: TextEditingController(), // OTP field
                  label: 'Phone Number Verification',
                  hint: 'Input',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  // TODO: Send OTP
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('OTP sent to your phone'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Send OTP',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    Widget? prefix,
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
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            color: Color(0xFF111827),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              color: Color(0xFF9CA3AF),
            ),
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF0B372B),
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            prefixIcon: prefix != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: prefix,
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Business Information (Step 0): Back + Save
          if (_currentStep == 0) ...[
            Expanded(
              child: GestureDetector(
                onTap: _previousStep,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF0B372B),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Back',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B372B),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: _nextStep,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B372B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          
          // Steps 1-2: Just Save (full width)
          if (_currentStep == 1 || _currentStep == 2)
            Expanded(
              child: GestureDetector(
                onTap: _nextStep,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B372B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          
          // Phone Number (Step 3): Submit + Verify
          if (_currentStep == 3) ...[
            Expanded(
              child: GestureDetector(
                onTap: _nextStep,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF0B372B),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B372B),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // TODO: Verify OTP and proceed
                  _nextStep();
                },
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B372B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'Verify',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
