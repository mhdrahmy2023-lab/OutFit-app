import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/shimmer_loader.dart';
import 'product_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final VoidCallback onBack;

  const FavoritesScreen({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: onBack,
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
          'MY WISHLIST',
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
      body: StreamBuilder<List<Product>>(
        stream: firestoreService.getFavoriteProductsStream(),
        builder: (context, snapshot) {

          // ── Loading ──
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ProductGridShimmer();
          }

          // ── Error ──
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Could not load wishlist.',
                style: GoogleFonts.lato(color: Colors.grey),
              ),
            );
          }

          final favorites = snapshot.data ?? [];

          // ── Empty State ──
          if (favorites.isEmpty) {
            return EmptyState(
              icon: Icons.favorite_border,
              title: 'Your wishlist is empty',
              subtitle: 'Tap the heart on any product\nto save it here.',
              buttonLabel: 'Browse Products',
              onButtonTap: onBack,
            );
          }

          // ── Favorites Grid ──
          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.72,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                return _FavoriteCard(
                  product: favorites[index],
                  firestoreService: firestoreService,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ─── Favorite Product Card ────────────────────────────────────────────────────
class _FavoriteCard extends StatelessWidget {
  final Product product;
  final FirestoreService firestoreService;

  const _FavoriteCard({
    required this.product,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(
            product: product,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Product Image ──
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: product.imagePath.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: product.imagePath,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey.shade100,
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey.shade100,
                              child: const Icon(Icons.broken_image,
                                  color: Colors.grey),
                            ),
                          )
                        : Image.asset(
                            product.imagePath,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade100,
                              child: const Icon(Icons.image, color: Colors.grey),
                            ),
                          ),
                  ),
                  // ── Remove from Favorites button ──
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () async {
                        await firestoreService.toggleFavorite(product.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Removed from wishlist',
                                style: GoogleFonts.lato(),
                              ),
                              backgroundColor: Colors.black87,
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: AppTheme.primaryRed,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── Product Info ──
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name.toUpperCase(),
                      style: GoogleFonts.lato(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'LKR ${product.price.toStringAsFixed(2)}',
                      style: GoogleFonts.lato(
                        color: AppTheme.primaryRed,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    // ── Add to Cart button ──
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (product.sizes.isNotEmpty) {
                            firestoreService.addToCart(product, product.sizes.first, 1);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Added to cart!',
                                  style: GoogleFonts.lato(),
                                ),
                                backgroundColor: Colors.black87,
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(0, 30),
                        ),
                        child: Text(
                          'Add to Cart',
                          style: GoogleFonts.lato(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
}
