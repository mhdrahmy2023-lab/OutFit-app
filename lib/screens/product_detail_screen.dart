import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../models/product.dart';

import '../services/firestore_service.dart';
import 'search_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String _selectedSize = '';
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.product.sizes.first;
  }

  void _addToCart() async {
    await FirestoreService().addToCart(widget.product, _selectedSize, _quantity);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added to cart!',
            style: GoogleFonts.lato(color: Colors.white)),
        backgroundColor: AppTheme.primaryRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Fix 5: navigate to Search page when search icon tapped
  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          body: SafeArea(
            child: SearchScreen(
              onBack: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
    );
  }

  // Fix 4: shared icon button builder — both back and search use identical style
  Widget _headerIcon({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        // Fix 4: same color as back button (black87 circle, white icon)
        decoration: const BoxDecoration(
          color: Colors.black87,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 360,
            pinned: true,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            // Fix 4 & 5: back button and search icon — identical circular style
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: _headerIcon(
                icon: Icons.arrow_back,
                onTap: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                // Fix 4: same black87 circle as back button
                // Fix 5: navigates to search page
                child: _headerIcon(
                  icon: Icons.search,
                  onTap: _openSearch,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: (widget.product.imagePath.startsWith('http'))
                  ? CachedNetworkImage(
                      imageUrl: widget.product.imagePath,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppTheme.primaryRed),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.broken_image,
                            size: 80, color: Colors.grey),
                      ),
                    )
                  : Image.asset(
                      widget.product.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.checkroom,
                            size: 80, color: Colors.grey),
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    widget.product.name.toUpperCase(),
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1),
                  ),
                  const SizedBox(height: 12),

                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: AppTheme.starGold, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.product.rating}',
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '— ${_deliveryMins()} mins',
                        style: GoogleFonts.lato(
                            color: Colors.grey.shade500, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    widget.product.description,
                    style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.6),
                  ),
                  const SizedBox(height: 28),

                  // ── Size section ──
                  // Fix 1: same 52×52 chip design as all other products
                  Text(
                    'Size',
                    style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: widget.product.sizes.map((size) {
                      final isSelected = size == _selectedSize;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedSize = size),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryRed
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              size,
                              style: GoogleFonts.lato(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  // Quantity
                  Text(
                    'Quantity',
                    style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _QtyButton(
                        icon: Icons.remove,
                        onTap: () => setState(() {
                          if (_quantity > 1) _quantity--;
                        }),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          '$_quantity',
                          style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      _QtyButton(
                        icon: Icons.add,
                        onTap: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      // Bottom bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, -4))
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                  color: AppTheme.primaryRed,
                  borderRadius: BorderRadius.circular(14)),
              child: Center(
                child: Text(
                  'LKR ${(widget.product.price * _quantity).toStringAsFixed(2)}',
                  style: GoogleFonts.lato(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: _addToCart,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                      color: AppTheme.darkBrown,
                      borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_bag_outlined,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'ADD TO CART',
                        style: GoogleFonts.lato(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _deliveryMins() {
    final mins = [10, 15, 20, 26, 30];
    return mins[widget.product.id.hashCode % mins.length].toString();
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
            color: AppTheme.primaryRed,
            borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
