import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

import '../models/product.dart';
import '../services/firestore_service.dart';
import '../widgets/address_selector.dart';
import 'success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double total;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.tax,
    required this.deliveryFee,
    required this.total,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedPayment = 0; // 0 = credit, 1 = debit
  bool _saveCard = true;
  Map<String, dynamic>? _selectedAddress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.black87,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order summary',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _SummaryCard(
              rows: [
                _SummaryRowData(
                    'Order', 'LKR${widget.subtotal.toStringAsFixed(0)}'),
                _SummaryRowData('Taxes', 'LKR${widget.tax.toStringAsFixed(0)}'),
                _SummaryRowData('Delivery fees',
                    'LKR${widget.deliveryFee.toStringAsFixed(0)}'),
              ],
              total: 'LKR${widget.total.toStringAsFixed(0)}',
              deliveryTime: '3–5 days',
            ),
            const SizedBox(height: 28),
            // ── Delivery Address Section ──
            AddressSelector(
              onAddressSelected: (address) {
                setState(() => _selectedAddress = address);
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Payment methods',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Credit card
            _PaymentCard(
              isSelected: _selectedPayment == 0,
              onTap: () => setState(() => _selectedPayment = 0),
              logo: Icons.credit_card,
              logoColor: Colors.orange,
              title: 'Credit card',
              subtitle: '5132 **** **** 4565',
              isDark: _selectedPayment == 0,
            ),
            const SizedBox(height: 12),
            // Debit card
            _PaymentCard(
              isSelected: _selectedPayment == 1,
              onTap: () => setState(() => _selectedPayment = 1),
              logo: Icons.credit_card,
              logoColor: Colors.blue.shade800,
              title: 'Debit card',
              subtitle: '9632 **** **** 2461',
              isDark: _selectedPayment == 1,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _saveCard = !_saveCard),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _saveCard ? AppTheme.primaryRed : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _saveCard
                            ? AppTheme.primaryRed
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: _saveCard
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Save card details for future payments',
                  style: GoogleFonts.lato(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total price',
                  style: GoogleFonts.lato(
                      color: Colors.grey.shade500, fontSize: 12),
                ),
                Text(
                  'LKR${widget.total.toStringAsFixed(0)}',
                  style: GoogleFonts.lato(
                    color: AppTheme.primaryRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  // Check address is selected
                  if (_selectedAddress == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Please select a delivery address first.',
                          style: GoogleFonts.lato(),
                        ),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                    return;
                  }

                  try {
                    // Save order WITH address to Firestore
                    await FirestoreService().createOrderWithAddress(
                      total: widget.total,
                      items: widget.cartItems,
                      address: _selectedAddress!,
                    );

                    // Clear cart
                    await FirestoreService().clearCart();

                    // Go to success screen
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SuccessScreen()),
                        (route) => route.isFirst,
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to place order. Try again.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.darkBrown,
                  minimumSize: const Size(0, 54),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  'Pay Now',
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRowData {
  final String label;
  final String value;
  _SummaryRowData(this.label, this.value);
}

class _SummaryCard extends StatelessWidget {
  final List<_SummaryRowData> rows;
  final String total;
  final String deliveryTime;

  const _SummaryCard({
    required this.rows,
    required this.total,
    required this.deliveryTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          ...rows.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(r.label,
                      style: GoogleFonts.lato(
                          color: Colors.grey.shade500, fontSize: 14)),
                  Text(r.value,
                      style: GoogleFonts.lato(
                          color: Colors.grey.shade500, fontSize: 14)),
                ],
              ),
            ),
          ),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style:
                    GoogleFonts.lato(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              Text(
                total,
                style:
                    GoogleFonts.lato(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimated delivery time',
                style:
                    GoogleFonts.lato(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              Text(
                deliveryTime,
                style:
                    GoogleFonts.lato(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final IconData logo;
  final Color logoColor;
  final String title;
  final String subtitle;
  final bool isDark;

  const _PaymentCard({
    required this.isSelected,
    required this.onTap,
    required this.logo,
    required this.logoColor,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkBrown : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(logo,
                  color: isDark ? Colors.white : logoColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lato(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.lato(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.6)
                          : Colors.grey.shade500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.white : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isDark
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
