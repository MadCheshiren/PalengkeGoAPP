import 'package:flutter/material.dart';

class OnboardingBusinessInfoStep extends StatelessWidget {
  final TextEditingController registeredNameController;
  final TextEditingController phoneController;
  final String? mayorsPermitFile;
  final String? sanitaryPermitFile;
  final String? fireCertificationFile;
  final String? marketClearanceFile;
  final VoidCallback onUploadMayorsPermit;
  final VoidCallback onUploadSanitaryPermit;
  final VoidCallback onUploadFireCertification;
  final VoidCallback onUploadMarketClearance;
  final VoidCallback onTapRegisteredName;
  final VoidCallback onTapPhone;

  const OnboardingBusinessInfoStep({
    super.key,
    required this.registeredNameController,
    required this.phoneController,
    required this.mayorsPermitFile,
    required this.sanitaryPermitFile,
    required this.fireCertificationFile,
    required this.marketClearanceFile,
    required this.onUploadMayorsPermit,
    required this.onUploadSanitaryPermit,
    required this.onUploadFireCertification,
    required this.onUploadMarketClearance,
    required this.onTapRegisteredName,
    required this.onTapPhone,
  });

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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Registered Name field (navigates to step 1)
          _buildNavigationField(
            label: 'Registered Name',
            hint: 'Enter your full legal name as written on your government-issued ID',
            value: registeredNameController.text.isNotEmpty 
                ? registeredNameController.text 
                : null,
            onTap: onTapRegisteredName,
          ),
          const SizedBox(height: 20),
          
          // Mayor's Permit with upload
          _buildUploadField(
            label: 'Mayor\'s Permit *',
            hint: '+ Upload (0/1)',
            fileName: mayorsPermitFile,
            onTap: onUploadMayorsPermit,
          ),
          const SizedBox(height: 20),
          
          // Sanitary Permit with upload
          _buildUploadField(
            label: 'Sanitary Permit *',
            hint: '+ Upload (0/1)',
            fileName: sanitaryPermitFile,
            onTap: onUploadSanitaryPermit,
          ),
          const SizedBox(height: 20),
          
          // Fire Certification with upload
          _buildUploadField(
            label: 'Fire Certification *',
            hint: '+ Upload (0/1)',
            fileName: fireCertificationFile,
            onTap: onUploadFireCertification,
          ),
          const SizedBox(height: 20),
          
          // Market Clearance with upload
          _buildUploadField(
            label: 'Market Clearance *',
            hint: '+ Upload (0/1)',
            fileName: marketClearanceFile,
            onTap: onUploadMarketClearance,
          ),
          const SizedBox(height: 20),
          
          // Phone Number (navigates to step 3)
          _buildNavigationField(
            label: 'Phone Number *',
            hint: '09XX XXX XXXX',
            value: phoneController.text.isNotEmpty 
                ? phoneController.text 
                : null,
            onTap: onTapPhone,
          ),
        ],
      ),
    );
  }
}
