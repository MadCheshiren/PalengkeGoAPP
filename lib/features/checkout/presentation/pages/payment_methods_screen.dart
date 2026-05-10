import 'package:flutter/material.dart';
import 'package:palengkego/core/widgets/app_screen_header.dart';
import 'add_credit_card_screen.dart';

/// Payment Methods Screen
/// Allows user to select or add payment methods.
/// 
/// Supports:
/// - Cash on Delivery (default)
/// - GCash (via Paymongo)
/// - Credit/Debit Card
class PaymentMethodsScreen extends StatefulWidget {
  final String? currentMethod;

  const PaymentMethodsScreen({
    super.key,
    this.currentMethod,
  });

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String? _selectedMethod;

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.currentMethod ?? 'cod';
  }

  void _selectMethod(String method) {
    setState(() {
      _selectedMethod = method;
    });
    // Return selected method to previous screen
    Navigator.pop(context, {'method': method});
  }

  Future<void> _addCard() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCreditCardScreen(),
      ),
    );
    if (result != null && result is Map<String, dynamic>) {
      if (!mounted) return;
      setState(() {
        _selectedMethod = 'card';
      });
      Navigator.pop(context, {
        'method': 'card',
        'cardData': result,
      });
    }
  }

  Future<void> _addGCash() async {
    // TODO: Implement Paymongo GCash integration
    // For now, show placeholder
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('GCash Payment'),
        content: const Text(
          'GCash setup is not connected yet.\n\n'
          'For now, you can continue with Cash on Delivery or add a card.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
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
            AppScreenHeader(
              title: 'Payment Methods',
              size: 32,
              titleSize: 18,
              onBack: () => Navigator.pop(context),
            ),
            
            // Payment options
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Payment Method',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Cash on Delivery
                    _buildPaymentOption(
                      method: 'cod',
                      title: 'Cash on Delivery',
                      subtitle: 'Pay when you receive your order',
                      icon: Icons.payments_outlined,
                      iconBgColor: const Color(0xFFFFF7ED),
                      iconColor: const Color(0xFFF59E0B),
                      isSelected: _selectedMethod == 'cod',
                      onTap: () => _selectMethod('cod'),
                    ),
                    const SizedBox(height: 12),
                    
                    // GCash
                    _buildPaymentOption(
                      method: 'gcash',
                      title: 'GCash',
                      subtitle: 'Pay with GCash via Paymongo',
                      icon: Icons.account_balance_wallet_outlined,
                      iconBgColor: const Color(0xFF0079FF),
                      iconColor: Colors.white,
                      isSelected: _selectedMethod == 'gcash',
                      onTap: _addGCash,
                    ),
                    const SizedBox(height: 12),
                    
                    // Credit/Debit Card
                    _buildPaymentOption(
                      method: 'card',
                      title: 'Credit/Debit Card',
                      subtitle: 'Add a new card',
                      icon: Icons.credit_card_outlined,
                      iconBgColor: const Color(0xFF1A1F71),
                      iconColor: Colors.white,
                      isSelected: _selectedMethod == 'card',
                      onTap: _addCard,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String method,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: const Color(0xFF0B372B), width: 2)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF0B372B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                ),
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
