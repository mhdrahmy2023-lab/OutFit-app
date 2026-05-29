import 'package:flutter/material.dart';

class OrderStatus {
  static const String processing = 'Processing';
  static const String confirmed  = 'Confirmed';
  static const String shipped    = 'Shipped';
  static const String delivered  = 'Delivered';
  static const String cancelled  = 'Cancelled';

  /// All steps in order
  static const List<String> steps = [
    processing,
    confirmed,
    shipped,
    delivered,
  ];

  /// Which step index is this status?
  static int stepIndex(String status) {
    if (status.toLowerCase() == 'cancelled') return -1;
    return steps.indexWhere(
      (s) => s.toLowerCase() == status.toLowerCase(),
    );
  }

  /// Color for each status badge
  static Color color(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Icon for each status
  static IconData icon(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return Icons.hourglass_empty_rounded;
      case 'confirmed':
        return Icons.check_circle_outline_rounded;
      case 'shipped':
        return Icons.local_shipping_outlined;
      case 'delivered':
        return Icons.home_rounded;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  /// Description shown under each step
  static String description(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return 'We received your order\nand are preparing it.';
      case 'confirmed':
        return 'Your order has been\nconfirmed and packed.';
      case 'shipped':
        return 'Your order is on\nits way to you!';
      case 'delivered':
        return 'Your order has been\nsuccessfully delivered.';
      case 'cancelled':
        return 'Your order has been\ncancelled.';
      default:
        return '';
    }
  }
}
