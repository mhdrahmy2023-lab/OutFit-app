import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../models/product.dart';

import 'product_detail_screen.dart';
import 'search_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'favorites_screen.dart';
import '../services/firestore_service.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/error_view.dart';

ImageProvider? _getProfileImage(
    String? imageUrl, String? base64Str, String? photoUrl) {
  if (photoUrl != null && photoUrl.isNotEmpty) {
    return CachedNetworkImageProvider(photoUrl);
  }
  if (imageUrl != null && imageUrl.isNotEmpty) {
    return CachedNetworkImageProvider(imageUrl);
  }
  if (base64Str != null && base64Str.isNotEmpty) {
    if (base64Str.startsWith('http')) {
      return CachedNetworkImageProvider(base64Str);
    }
    try {
      return MemoryImage(base64Decode(base64Str));
    } catch (e) {
      debugPrint('Error decoding base64 image: $e');
    }
  }
  return null;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _selectedCategory = 'All';

  final FirestoreService _firestoreService = FirestoreService();

  final List<String> _categories = ['All', 'Men', 'Woman', 'Kids'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          StreamBuilder<List<Product>>(
            stream: _firestoreService.getProductsStream(),
            builder: (context, snapshot) {
              // ── LOADING STATE (shimmer) ──
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 200), // space for header
                      ProductGridShimmer(),
                    ],
                  ),
                );
              }

              // ── ERROR STATE ──
              if (snapshot.hasError) {
                return ErrorView(
                  message:
                      'Could not load products.\nCheck your internet connection.',
                  onRetry: () => setState(() {}), // triggers rebuild
                );
              }

              final products = snapshot.data ?? [];
              final filteredProducts = _selectedCategory == 'All'
                  ? products
                  : products
                      .where((p) => p.category == _selectedCategory)
                      .toList();

              return RefreshIndicator(
                // ← PULL TO REFRESH wrapper
                color: AppTheme.primaryRed,
                onRefresh: () async {
                  setState(() {}); // triggers stream rebuild
                  await Future.delayed(const Duration(milliseconds: 800));
                },
                child: _HomeTab(
                  categories: _categories,
                  selectedCategory: _selectedCategory,
                  filteredProducts: filteredProducts,
                  onCategoryChanged: (cat) =>
                      setState(() => _selectedCategory = cat),
                  onSearchTap: () => setState(() => _currentIndex = 1),
                  onProfileTap: () => setState(() => _currentIndex = 4),
                ),
              );
            },
          ),
          SearchScreen(
            onBack: () => setState(() => _currentIndex = 0),
          ),
          CartScreen(
            onBack: () => setState(() => _currentIndex = 0),
          ),
          FavoritesScreen(
            onBack: () => setState(() => _currentIndex = 0),
          ),
          ProfileScreen(
            onBack: () => setState(() => _currentIndex = 0),
          ),
        ],
      ),
      bottomNavigationBar: StreamBuilder<List<CartItem>>(
        stream: _firestoreService.getCartStream(),
        builder: (context, snapshot) {
          final cartCount = snapshot.data?.length ?? 0;
          return _BottomNav(
            currentIndex: _currentIndex,
            cartCount: cartCount,
            onTap: (i) => setState(() => _currentIndex = i),
          );
        },
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {},
              backgroundColor: AppTheme.primaryRed,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// ─── Home Tab ────────────────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final List<Product> filteredProducts;
  final Function(String) onCategoryChanged;
  final VoidCallback onSearchTap;
  final VoidCallback onProfileTap;

  const _HomeTab({
    required this.categories,
    required this.selectedCategory,
    required this.filteredProducts,
    required this.onCategoryChanged,
    required this.onSearchTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OUT fIT',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'Ready to wear !',
                            style: GoogleFonts.lato(
                                fontSize: 14, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      // Fix 2: profile photo replaces logo; taps navigate to Profile tab
                      GestureDetector(
                        onTap: onProfileTap,
                        child: StreamBuilder<DocumentSnapshot>(
                            stream: FirestoreService().getUserProfileStream(),
                            builder: (context, snapshot) {
                              String? profileImageUrl;
                              String? profilePhoto;
                              String? photoUrl;
                              if (snapshot.hasData && snapshot.data!.exists) {
                                final data = snapshot.data!.data()
                                    as Map<String, dynamic>?;
                                profileImageUrl = data?['profileImageUrl'];
                                profilePhoto = data?['profilePhoto'];
                                photoUrl = data?['photoUrl'];
                              }

                              return Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppTheme.primaryRed, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.12),
                                        blurRadius: 8),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 23,
                                  backgroundColor: Colors.grey.shade200,
                                  backgroundImage: _getProfileImage(
                                      profileImageUrl, profilePhoto, photoUrl),
                                  child: _getProfileImage(profileImageUrl,
                                              profilePhoto, photoUrl) ==
                                          null
                                      ? const Icon(Icons.person,
                                          color: Colors.grey, size: 28)
                                      : null,
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Search bar (tappable → navigates to Search tab) ──
                  GestureDetector(
                    onTap: onSearchTap, // FIX 1
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 10),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Icon(Icons.search, color: Colors.grey.shade400),
                          const SizedBox(width: 10),
                          Text(
                            'Search',
                            style: GoogleFonts.lato(
                                color: Colors.grey.shade400, fontSize: 15),
                          ),
                          const Spacer(),
                          Container(
                            margin: const EdgeInsets.all(6),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryRed,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.tune,
                                color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Category chips ──
                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        final cat = categories[i];
                        final isSelected = cat == selectedCategory;
                        return GestureDetector(
                          onTap: () => onCategoryChanged(cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryRed
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 8),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                cat,
                                style: GoogleFonts.lato(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ── Product grid ──
          filteredProducts.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          'No products yet',
                          style: GoogleFonts.lato(
                              color: Colors.grey.shade400, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.72,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _ProductCard(
                        product: filteredProducts[i],
                      ),
                      childCount: filteredProducts.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

// ─── Product Card ─────────────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

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
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: (product.imagePath.startsWith('http'))
                    ? CachedNetworkImage(
                        imageUrl: product.imagePath,
                        width: double.infinity,
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
                              size: 48, color: Colors.grey),
                        ),
                      )
                    : Image.asset(
                        product.imagePath,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade100,
                          child: const Icon(Icons.image,
                              size: 48, color: Colors.grey),
                        ),
                      ),
              ),
            ),
            // Info
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
                          letterSpacing: 0.5),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'LKR ${product.price.toStringAsFixed(2)}',
                      style: GoogleFonts.lato(
                          color: AppTheme.primaryRed,
                          fontWeight: FontWeight.w700,
                          fontSize: 13),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: AppTheme.starGold, size: 14),
                            const SizedBox(width: 3),
                            Text(product.rating.toString(),
                                style: GoogleFonts.lato(
                                    fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        StreamBuilder<List<String>>(
                          stream: firestoreService.getFavoriteIdsStream(),
                          builder: (context, snapshot) {
                            final favoriteIds = snapshot.data ?? [];
                            final isFav = favoriteIds.contains(product.id);
                            return GestureDetector(
                              onTap: () async {
                                await firestoreService
                                    .toggleFavorite(product.id);
                              },
                              child: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav
                                    ? AppTheme.primaryRed
                                    : Colors.grey.shade400,
                                size: 20,
                              ),
                            );
                          },
                        ),
                      ],
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

// ─── Bottom Nav ───────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final int cartCount;
  final Function(int) onTap;

  const _BottomNav(
      {required this.currentIndex,
      required this.cartCount,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.primaryRed,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
              icon: Icons.home,
              index: 0,
              currentIndex: currentIndex,
              onTap: onTap),
          _NavItem(
              icon: Icons.search,
              index: 1,
              currentIndex: currentIndex,
              onTap: onTap),
          const SizedBox(width: 60),
          _NavItem(
            icon: Icons.shopping_bag_outlined,
            index: 2,
            currentIndex: currentIndex,
            onTap: onTap,
            badge: cartCount > 0 ? cartCount.toString() : null,
          ),
          _NavItem(
            icon: Icons.favorite_border,
            index: 3,
            currentIndex: currentIndex,
            onTap: onTap,
          ),
          _NavItem(
            icon: Icons.person_outline,
            index: 4,
            currentIndex: currentIndex,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final int index;
  final int currentIndex;
  final Function(int) onTap;
  final String? badge;

  const _NavItem({
    required this.icon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon,
                    color: isActive
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.6),
                    size: 26),
                if (isActive)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                  ),
              ],
            ),
          ),
          if (badge != null)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: Text(badge!,
                    style: GoogleFonts.lato(
                        color: AppTheme.primaryRed,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}
