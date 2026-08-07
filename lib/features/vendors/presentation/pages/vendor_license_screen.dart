import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/features/auth/domain/app_user.dart';
import 'package:palengkego/features/auth/presentation/pages/auth_guard.dart';
import 'package:intl/intl.dart';
import 'package:palengkego/core/utils/image_picker_helper.dart';
import 'package:palengkego/features/vendors/application/license_renewal_provider.dart';
import 'package:palengkego/features/vendors/application/vendor_stall_provider.dart';
import 'package:palengkego/features/vendors/domain/license_renewal.dart';
import 'package:palengkego/features/vendors/domain/vendor_stall.dart';
import 'package:palengkego/features/vendors/presentation/widgets/vendor_screen_header.dart';

class VendorLicenseScreen extends ConsumerStatefulWidget {
  const VendorLicenseScreen({super.key});

  @override
  ConsumerState<VendorLicenseScreen> createState() =>
      _VendorLicenseScreenState();
}

class _VendorLicenseScreenState extends ConsumerState<VendorLicenseScreen> {
  final formatCurrency = NumberFormat.currency(locale: 'en_PH', symbol: '₱');
  String _selectedPaymentMethod = 'paymongo_gcash';
  bool _hasUploadedDoc = false;
  bool _documentsToFollowUp = false;

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(computedLicenseStatusProvider);
    final activeRenewalAsync = ref.watch(activeRenewalProvider);
    final historyAsync = ref.watch(renewalHistoryProvider);
    final stall = ref.watch(vendorStallProvider);

    return AuthGuard(
      allowedRoles: {UserRole.vendor},
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              const VendorScreenHeader(title: 'Stall License'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      activeRenewalAsync.when(
                        data: (activeRenewal) =>
                            _buildStatusCard(status, activeRenewal, stall),
                        loading: () => const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF0B372B),
                          ),
                        ),
                        error: (err, _) => Text('Error: $err'),
                      ),
                      const SizedBox(height: 32),

                      const Text(
                        'Renewal History',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      historyAsync.when(
                        data: (history) => _buildHistoryList(history),
                        loading: () => const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF0B372B),
                          ),
                        ),
                        error: (err, _) => Text('Error: $err'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar:
            (status == LicenseStatus.expiringSoon ||
                status == LicenseStatus.expired ||
                status == LicenseStatus.suspended)
            ? _buildRenewBottomBar(stall)
            : null,
      ),
    );
  }

  Widget _buildStatusCard(
    LicenseStatus status,
    LicenseRenewal? activeRenewal,
    VendorStall stall,
  ) {
    Color cardColor;
    Color iconColor;
    IconData icon;
    String statusText;

    switch (status) {
      case LicenseStatus.active:
        cardColor = const Color(0xFFF0FDF4);
        iconColor = const Color(0xFF22C55E);
        icon = Icons.check_circle_rounded;
        statusText = 'Active';
        break;
      case LicenseStatus.expiringSoon:
        cardColor = const Color(0xFFFFFBEB);
        iconColor = const Color(0xFFF59E0B);
        icon = Icons.warning_rounded;
        statusText = 'Expiring Soon';
        break;
      case LicenseStatus.expired:
        cardColor = const Color(0xFFFEF2F2);
        iconColor = const Color(0xFFEF4444);
        icon = Icons.error_rounded;
        statusText = 'Expired';
        break;
      case LicenseStatus.suspended:
        cardColor = const Color(0xFF7F1D1D); // Dark Red
        iconColor = const Color(0xFFFECACA); // Light Red
        icon = Icons.block_rounded;
        statusText = 'Suspended';
        break;
      case LicenseStatus.pending:
        cardColor = const Color(0xFFFFFBEB);
        iconColor = const Color(0xFFF59E0B);
        icon = Icons.hourglass_empty_rounded;
        statusText = 'Pending Approval';
        break;
    }

    final now = DateTime.now();
    int daysLeft = 0;
    String expiryText = 'No active license';
    if (activeRenewal != null) {
      daysLeft = activeRenewal.periodEnd.difference(now).inDays;
      expiryText = DateFormat('MMMM d, yyyy').format(activeRenewal.periodEnd);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: status == LicenseStatus.suspended ? cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: status == LicenseStatus.suspended
              ? cardColor
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: status == LicenseStatus.suspended
                      ? const Color(0xFF991B1B)
                      : cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: status == LicenseStatus.suspended
                          ? Colors.white
                          : const Color(0xFF0F172A),
                    ),
                  ),
                  if (activeRenewal != null &&
                      status == LicenseStatus.expiringSoon)
                    Text(
                      'Expires in $daysLeft days',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoRow(
            'Stall Name',
            stall.name,
            isDark: status == LicenseStatus.suspended,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Expiry Date',
            expiryText,
            isDark: status == LicenseStatus.suspended,
          ),

          if (activeRenewal != null && activeRenewal.isPending)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.hourglass_empty_rounded,
                      color: Color(0xFFF59E0B),
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Renewal request submitted. Awaiting MEPO approval.',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isDark = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList(List<LicenseRenewal> history) {
    if (history.isEmpty) {
      return const Center(
        child: Text(
          'No renewal history found.',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            color: Color(0xFF64748B),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final r = history[index];
        final start = DateFormat('MMM yyyy').format(r.periodStart);
        final end = DateFormat('MMM yyyy').format(r.periodEnd);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$start - $end',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatCurrency.format(r.amountPaid),
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              _buildStatusChip(r.status),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(LicenseRenewalStatus status) {
    Color bg;
    Color fg;
    String text;

    switch (status) {
      case LicenseRenewalStatus.pending:
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF3B82F6);
        text = 'Pending';
        break;
      case LicenseRenewalStatus.paid:
        bg = const Color(0xFFFFFBEB);
        fg = const Color(0xFFF59E0B);
        text = 'Paid';
        break;
      case LicenseRenewalStatus.approved:
        bg = const Color(0xFFF0FDF4);
        fg = const Color(0xFF22C55E);
        text = 'Approved';
        break;
      case LicenseRenewalStatus.rejected:
        bg = const Color(0xFFFEF2F2);
        fg = const Color(0xFFEF4444);
        text = 'Rejected';
        break;
      case LicenseRenewalStatus.expired:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
        text = 'Expired';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildRenewBottomBar(VendorStall stall) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () => _showPaymentSheet(stall),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0B372B),
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'Renew License',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showPaymentSheet(VendorStall stall) {
    setState(() {
      _hasUploadedDoc = false;
      _documentsToFollowUp = false;
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Renew License',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your renewal will be valid for 1 year.',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Fee summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Annual Fee',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          formatCurrency.format(5000), // Configurable in future
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0B372B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Payment Method',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Payment options
                  _buildPaymentOption(
                    id: 'paymongo_gcash',
                    title: 'GCash (via PayMongo)',
                    icon: Icons.account_balance_wallet_rounded,
                    isSelected: _selectedPaymentMethod == 'paymongo_gcash',
                    onTap: () {
                      setSheetState(
                        () => _selectedPaymentMethod = 'paymongo_gcash',
                      );
                      setState(() => _selectedPaymentMethod = 'paymongo_gcash');
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildPaymentOption(
                    id: 'pay_in_person',
                    title: 'Pay Personally / Pay in Person',
                    icon: Icons.payments_rounded,
                    isSelected: _selectedPaymentMethod == 'pay_in_person',
                    onTap: () {
                      setSheetState(
                        () => _selectedPaymentMethod = 'pay_in_person',
                      );
                      setState(() => _selectedPaymentMethod = 'pay_in_person');
                    },
                  ),
                  const SizedBox(height: 20),

                  // Documents Upload / Follow-up section
                  const Text(
                    'Renewal Documents',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final file = await ImagePickerHelper.pickImage(context);
                      if (file != null) {
                        setSheetState(() => _hasUploadedDoc = true);
                        setState(() => _hasUploadedDoc = true);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _hasUploadedDoc
                                ? Icons.check_circle_rounded
                                : Icons.cloud_upload_outlined,
                            color: _hasUploadedDoc
                                ? const Color(0xFF0B372B)
                                : const Color(0xFF64748B),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _hasUploadedDoc
                                  ? 'Document attached'
                                  : 'Attach available documents',
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: _documentsToFollowUp,
                        onChanged: (val) {
                          setSheetState(
                            () => _documentsToFollowUp = val ?? false,
                          );
                          setState(() => _documentsToFollowUp = val ?? false);
                        },
                        activeColor: const Color(0xFF0B372B),
                      ),
                      const Expanded(
                        child: Text(
                          'I don\'t have all documents yet (to follow up)',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Action button
                  ElevatedButton(
                    onPressed: () {
                      if (!_hasUploadedDoc && !_documentsToFollowUp) {
                        showDialog(
                          context: ctx, // Use the bottom sheet's context
                          builder: (dialogCtx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Text(
                              'Renewal Documents Required',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0B372B),
                              ),
                            ),
                            content: const Text(
                              'Please attach at least one document or check "I don\'t have all documents yet" before proceeding.',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14,
                                color: Color(0xFF475569),
                              ),
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () => Navigator.pop(dialogCtx),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0B372B),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'OK',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'PlusJakartaSans',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                        return;
                      }
                      Navigator.pop(ctx);
                      _processRenewal(stall);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B372B),
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _selectedPaymentMethod == 'pay_in_person'
                          ? 'Request Renewal & Pay in Person'
                          : 'Pay & Renew',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF22C55E)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF166534)
                  : const Color(0xFF64748B),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF166534)
                    : const Color(0xFF0F172A),
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E)),
          ],
        ),
      ),
    );
  }

  void _processRenewal(VendorStall stall) {
    final now = DateTime.now();
    final renewal = LicenseRenewal(
      renewalId: '', // Set by repo
      stallId: stall.stallId,
      vendorUid: stall.ownerUid,
      vendorName: stall.name,
      periodStart: now,
      periodEnd: now.add(const Duration(days: 365)),
      amountPaid: 5000.0,
      paymentMethod: _selectedPaymentMethod,
      submittedAt: now,
      status: LicenseRenewalStatus.pending,
    );

    ref.read(licenseRenewalProcessorProvider.notifier).submitAndPay(renewal);

    if (mounted) {
      if (_selectedPaymentMethod == 'pay_in_person') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment Successful! Awaiting MEPO Approval.'),
            backgroundColor: Color(0xFF0B372B),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Renewal request submitted successfully.'),
            backgroundColor: Color(0xFF0B372B),
          ),
        );
      }
    }
  }
}
