import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';

import '../models/product.dart';
import '../services/firestore_service.dart';
import 'checkout_screen.dart';
import '../widgets/empty_state.dart';

class CartScreen extends StatefulWidget {
  final VoidCallback onBack; // FIX 3

  const CartScreen({super.key, required this.onBack});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: widget.onBack,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
                color: Colors.black87, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
          ),
        ),
        title: Text('MY CART',
            style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: 2)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: StreamBuilder<List<CartItem>>(
        stream: FirestoreService().getCartStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryRed));
          }
          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: 'Your cart is empty',
              subtitle:
                  'Looks like you haven\'t added\nanything to your cart yet.',
              buttonLabel: 'Start Shopping',
              onButtonTap: widget.onBack, // goes back to home
            );
          }

          double subtotal = items.fold(
              0, (sum, item) => sum + item.product.price * item.quantity);
          double deliveryFee = 1000;
          double tax = subtotal * 0.02;
          double total = subtotal + deliveryFee + tax;

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return _CartItemCard(
                      item: item,
                      onRemove: () =>
                          FirestoreService().removeFromCart(item.id!),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, -4)),
                  ],
                ),
                child: Column(
                  children: [
                    _SummaryRow(
                        label: 'Order',
                        value: 'LKR ${subtotal.toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    _SummaryRow(
                        label: 'Delivery fees',
                        value: 'LKR ${deliveryFee.toStringAsFixed(2)}'),
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider()),
                    _SummaryRow(
                        label: 'Total :',
                        value: 'LKR ${total.toStringAsFixed(2)}',
                        isBold: true),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => CheckoutScreen(
                                  cartItems: items,
                                  subtotal: subtotal,
                                  tax: tax,
                                  deliveryFee: deliveryFee,
                                  total: total,
                                )),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRed,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('PROCEED TO CHECKOUT',
                          style: GoogleFonts.lato(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1)),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback onRemove;
  const _CartItemCard({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: (item.product.imagePath.startsWith('http'))
                ? CachedNetworkImage(
                    imageUrl: item.product.imagePath,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppTheme.primaryRed),
                        )),
                    errorWidget: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.broken_image,
                            color: Colors.grey, size: 36)),
                  )
                : Image.asset(
                    item.product.imagePath,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.checkroom,
                            color: Colors.grey, size: 36)),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name,
                    style: GoogleFonts.lato(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                Text('Size - ${item.selectedSize}',
                    style: GoogleFonts.lato(
                        color: Colors.grey.shade500, fontSize: 13)),
                const SizedBox(height: 6),
                Text(
                    'LKR ${(item.product.price * item.quantity).toStringAsFixed(2)}',
                    style: GoogleFonts.lato(
                        color: AppTheme.primaryRed,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, color: AppTheme.primaryRed, size: 22),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final bool isBold;
  const _SummaryRow(
      {required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.lato(
                color: isBold ? Colors.black : Colors.grey.shade600,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.normal,
                fontSize: isBold ? 16 : 14)),
        Text(value,
            style: GoogleFonts.lato(
                color: isBold ? Colors.black : Colors.grey.shade600,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.normal,
                fontSize: isBold ? 16 : 14)),
      ],
    );
  }
}
