import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../widgets/empty_state.dart';
import 'order_tracking_screen.dart';
import '../utils/order_status.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

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
                color: Colors.black87, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
          ),
        ),
        title: Text('MY ORDERS',
            style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: 2)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getOrdersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryRed));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error loading orders', style: GoogleFonts.lato()));
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No orders yet',
              subtitle: 'Once you place an order,\nyou\'ll see it here.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final items = List<dynamic>.from(data['items'] ?? []);
              final total = (data['total'] ?? 0).toDouble();
              final status = data['status'] ?? 'Processing';
              final date = (data['createdAt'] as Timestamp?)?.toDate();

              final doc = docs[index];
              return GestureDetector(
                onTap: () {
                  final data = doc.data() as Map<String, dynamic>;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderTrackingScreen(
                        orderId: doc.id,
                        total: (data['total'] ?? 0).toDouble(),
                      ),
                    ),
                  );
                },
                child: Container(
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
                    children: [
                      // Order icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.receipt_long_outlined, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '#${doc.id.substring(0, 8).toUpperCase()}',
                              style: GoogleFonts.lato(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'LKR ${((doc.data() as Map)['total'] ?? 0).toStringAsFixed(2)}',
                              style: GoogleFonts.lato(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status badge
                      Builder(builder: (_) {
                        final status = ((doc.data() as Map)['status'] ?? 'Processing') as String;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: OrderStatus.color(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status,
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: OrderStatus.color(status),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(width: 8),
                      Icon(Icons.chevron_right, color: Colors.grey.shade400),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
