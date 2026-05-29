import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../utils/order_status.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;
  final double total;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    required this.total,
  });

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
        title: Text(
          'TRACK ORDER',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirestoreService().getOrderStream(orderId),
        builder: (context, snapshot) {

          // ── Loading ──
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryRed),
            );
          }

          // ── Error ──
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text(
                'Could not load order.',
                style: GoogleFonts.lato(color: Colors.grey),
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final status = data['status'] ?? 'Processing';
          final items  = List<Map<String, dynamic>>.from(data['items'] ?? []);
          final currentStep = OrderStatus.stepIndex(status);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Order ID & Total ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order ID',
                            style: GoogleFonts.lato(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                            ),
                          ),
                          // ── Status Badge ──
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: OrderStatus.color(status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: OrderStatus.color(status).withOpacity(0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  OrderStatus.icon(status),
                                  size: 14,
                                  color: OrderStatus.color(status),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  status,
                                  style: GoogleFonts.lato(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: OrderStatus.color(status),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '#${orderId.substring(0, 8).toUpperCase()}',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount',
                            style: GoogleFonts.lato(color: Colors.grey.shade500),
                          ),
                          Text(
                            'LKR ${total.toStringAsFixed(2)}',
                            style: GoogleFonts.lato(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.primaryRed,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Delivery Address Card ──
                if (data['address'] != null) ...[
                  Text(
                    'Delivery Address',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18, fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.location_on_outlined,
                            color: AppTheme.primaryRed,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['address']['fullName'] ?? '',
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold, fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data['address']['phone'] ?? '',
                                style: GoogleFonts.lato(
                                  color: Colors.grey.shade500, fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${data['address']['addressLine']}, ${data['address']['city']}, ${data['address']['postalCode']}',
                                style: GoogleFonts.lato(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // ── Tracking Timeline ──
                Text(
                  'Order Status',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: List.generate(OrderStatus.steps.length, (index) {
                      final stepName = OrderStatus.steps[index];
                      final isDone   = index <= currentStep;
                      final isActive = index == currentStep;
                      final isLast   = index == OrderStatus.steps.length - 1;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // ── Left: icon + vertical line ──
                          Column(
                            children: [
                              // Circle icon
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDone
                                      ? OrderStatus.color(stepName)
                                      : Colors.grey.shade100,
                                  border: isActive
                                      ? Border.all(
                                          color: OrderStatus.color(stepName),
                                          width: 2,
                                        )
                                      : null,
                                  boxShadow: isActive
                                      ? [
                                          BoxShadow(
                                            color: OrderStatus.color(stepName)
                                                .withOpacity(0.3),
                                            blurRadius: 8,
                                          )
                                        ]
                                      : null,
                                ),
                                child: Icon(
                                  OrderStatus.icon(stepName),
                                  size: 22,
                                  color: isDone
                                      ? Colors.white
                                      : Colors.grey.shade400,
                                ),
                              ),
                              // Vertical connector line
                              if (!isLast)
                                Container(
                                  width: 2,
                                  height: 50,
                                  color: index < currentStep
                                      ? AppTheme.primaryRed
                                      : Colors.grey.shade200,
                                ),
                            ],
                          ),

                          const SizedBox(width: 16),

                          // ── Right: step name + description ──
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        stepName,
                                        style: GoogleFonts.lato(
                                          fontSize: 15,
                                          fontWeight: isActive
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                          color: isDone
                                              ? Colors.black87
                                              : Colors.grey.shade400,
                                        ),
                                      ),
                                      if (isActive) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: OrderStatus.color(stepName)
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            'Current',
                                            style: GoogleFonts.lato(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  OrderStatus.color(stepName),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    OrderStatus.description(stepName),
                                    style: GoogleFonts.lato(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Items in this order ──
                Text(
                  'Items Ordered',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item  = entry.value;
                      final isLastItem = index == items.length - 1;

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Item icon placeholder
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.checkroom,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'] ?? '',
                                        style: GoogleFonts.lato(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Size: ${item['size']}  •  Qty: ${item['quantity']}',
                                        style: GoogleFonts.lato(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'LKR ${((item['price'] ?? 0) * (item['quantity'] ?? 1)).toStringAsFixed(0)}',
                                  style: GoogleFonts.lato(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryRed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isLastItem)
                            Divider(height: 1, color: Colors.grey.shade100),
                        ],
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Cancel Order Button ──
                if (status.toLowerCase() == 'processing' || status.toLowerCase() == 'confirmed') ...[
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        final bool? confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Cancel Order?', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
                            content: Text('Are you sure you want to cancel this order?', style: GoogleFonts.lato()),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('No', style: GoogleFonts.lato(color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text('Yes, Cancel', style: GoogleFonts.lato(color: Colors.red, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await FirestoreService().cancelOrder(orderId);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Order cancelled successfully', style: GoogleFonts.lato()),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      },
                      child: Text(
                        'Cancel Order',
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
