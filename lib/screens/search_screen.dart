import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';
import '../widgets/empty_state.dart';
import 'product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final VoidCallback onBack;

  const SearchScreen({
    super.key,
    required this.onBack,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  // ── State ──
  String _query          = '';
  String _selectedCategory = 'All';
  String _selectedSort     = 'Default';
  String _selectedPrice    = 'All';
  double _minRating        = 0.0;
  bool   _showFilters      = false;

  // All products loaded from Firestore
  List<Product> _allProducts = [];
  bool _isLoading = true;

  final List<String> _recentSearches = ['Silk Blazer', 'Sneakers', 'Dress'];

  final List<String> _categories = ['All', 'Men', 'Woman', 'Kids'];
  final List<String> _sortOptions = ['Default', 'Price: Low to High', 'Price: High to Low', 'Top Rated'];
  final List<String> _priceRanges = ['All', 'Under 3000', '3000–7000', 'Above 7000'];

  final List<Map<String, String>> _trending = [
    {
      'label': 'Dresses',
      'url': 'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?w=600&q=85&fit=crop',
      'fallback': 'D8A0A8',
    },
    {
      'label': 'Outerwear',
      'url': 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=600&q=85&fit=crop',
      'fallback': 'A89880',
    },
    {
      'label': 'Bags',
      'url': 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600&q=85&fit=crop',
      'fallback': '8B6347',
    },
    {
      'label': 'Shoes',
      'url': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&q=85&fit=crop',
      'fallback': 'A0876A',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // ── Load all products from Firestore once ──
  void _loadProducts() {
    FirestoreService().getProductsStream().listen((products) {
      if (mounted) {
        setState(() {
          _allProducts = products;
          _isLoading   = false;
        });
      }
    });
  }

  // ── Apply search + filters + sort ──
  List<Product> get _filteredProducts {
    List<Product> results = List.from(_allProducts);

    // 1. Search by name
    if (_query.isNotEmpty) {
      results = results
          .where((p) => p.name.toLowerCase().contains(_query.toLowerCase()))
          .toList();
    }

    // 2. Filter by category
    if (_selectedCategory != 'All') {
      results = results.where((p) => p.category == _selectedCategory).toList();
    }

    // 3. Filter by price range
    switch (_selectedPrice) {
      case 'Under 3000':
        results = results.where((p) => p.price < 3000).toList();
        break;
      case '3000–7000':
        results = results.where((p) => p.price >= 3000 && p.price <= 7000).toList();
        break;
      case 'Above 7000':
        results = results.where((p) => p.price > 7000).toList();
        break;
    }

    // 4. Filter by minimum rating
    if (_minRating > 0) {
      results = results.where((p) => p.rating >= _minRating).toList();
    }

    // 5. Sort
    switch (_selectedSort) {
      case 'Price: Low to High':
        results.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        results.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Top Rated':
        results.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }

    return results;
  }

  bool get _isSearching => _query.isNotEmpty;

  // Count how many filters are active
  int get _activeFilterCount {
    int count = 0;
    if (_selectedCategory != 'All') count++;
    if (_selectedPrice != 'All') count++;
    if (_selectedSort != 'Default') count++;
    if (_minRating > 0) count++;
    return count;
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = 'All';
      _selectedPrice    = 'All';
      _selectedSort     = 'Default';
      _minRating        = 0.0;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onBack,
                      child: Container(
                        width: 40, height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.black87, shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'OUT fIT',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 26, fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Search Bar + Filter Button ──
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onChanged: (value) {
                          setState(() => _query = value);
                          // Save to recent searches
                          if (value.isNotEmpty &&
                              !_recentSearches.contains(value)) {
                            if (_recentSearches.length >= 5) {
                              _recentSearches.removeLast();
                            }
                          }
                        },
                        style: GoogleFonts.lato(),
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          hintStyle: GoogleFonts.lato(color: Colors.grey.shade400),
                          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                          suffixIcon: _isSearching
                              ? IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: () {
                                    _controller.clear();
                                    setState(() => _query = '');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppTheme.primaryRed),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // ── Filter toggle button ──
                    GestureDetector(
                      onTap: () => setState(() => _showFilters = !_showFilters),
                      child: Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(
                          color: _activeFilterCount > 0
                              ? AppTheme.primaryRed
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Icon(
                                Icons.tune,
                                color: _activeFilterCount > 0
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            if (_activeFilterCount > 0)
                              Positioned(
                                top: 6, right: 6,
                                child: Container(
                                  width: 16, height: 16,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$_activeFilterCount',
                                      style: GoogleFonts.lato(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryRed,
                                      ),
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
                const SizedBox(height: 12),
              ],
            ),
          ),

          // ── Filter Panel (expandable) ──
          if (_showFilters) _FilterPanel(
            selectedCategory: _selectedCategory,
            selectedSort: _selectedSort,
            selectedPrice: _selectedPrice,
            minRating: _minRating,
            categories: _categories,
            sortOptions: _sortOptions,
            priceRanges: _priceRanges,
            onCategoryChanged: (v) => setState(() => _selectedCategory = v),
            onSortChanged: (v) => setState(() => _selectedSort = v),
            onPriceChanged: (v) => setState(() => _selectedPrice = v),
            onRatingChanged: (v) => setState(() => _minRating = v),
            onReset: _resetFilters,
          ),

          // ── Body ──
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed))
                : _isSearching || _activeFilterCount > 0
                    ? _SearchResults(
                        results: _filteredProducts,
                        query: _query,
                      )
                    : _DefaultView(
                        recentSearches: _recentSearches,
                        trending: _trending,
                        onRemove: (s) => setState(() => _recentSearches.remove(s)),
                        onClearAll: () => setState(() => _recentSearches.clear()),
                        onRecentTap: (s) {
                          _controller.text = s;
                          setState(() => _query = s);
                        },
                        onTrendingTap: (label) {
                          _controller.text = label;
                          setState(() => _query = label);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter Panel ─────────────────────────────────────────────────────────────
class _FilterPanel extends StatelessWidget {
  final String selectedCategory;
  final String selectedSort;
  final String selectedPrice;
  final double minRating;
  final List<String> categories;
  final List<String> sortOptions;
  final List<String> priceRanges;
  final Function(String) onCategoryChanged;
  final Function(String) onSortChanged;
  final Function(String) onPriceChanged;
  final Function(double) onRatingChanged;
  final VoidCallback onReset;

  const _FilterPanel({
    required this.selectedCategory,
    required this.selectedSort,
    required this.selectedPrice,
    required this.minRating,
    required this.categories,
    required this.sortOptions,
    required this.priceRanges,
    required this.onCategoryChanged,
    required this.onSortChanged,
    required this.onPriceChanged,
    required this.onRatingChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Category ──
          _filterLabel('Category'),
          const SizedBox(height: 8),
          _ChipRow(
            options: categories,
            selected: selectedCategory,
            onSelect: onCategoryChanged,
          ),
          const SizedBox(height: 14),

          // ── Price Range ──
          _filterLabel('Price Range'),
          const SizedBox(height: 8),
          _ChipRow(
            options: priceRanges,
            selected: selectedPrice,
            onSelect: onPriceChanged,
          ),
          const SizedBox(height: 14),

          // ── Sort By ──
          _filterLabel('Sort By'),
          const SizedBox(height: 8),
          _ChipRow(
            options: sortOptions,
            selected: selectedSort,
            onSelect: onSortChanged,
          ),
          const SizedBox(height: 14),

          // ── Min Rating ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _filterLabel('Min Rating'),
              Row(
                children: [
                  const Icon(Icons.star, color: AppTheme.starGold, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    minRating == 0 ? 'Any' : '${minRating.toStringAsFixed(1)}+',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryRed,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Slider(
            value: minRating,
            min: 0,
            max: 5,
            divisions: 10,
            activeColor: AppTheme.primaryRed,
            inactiveColor: Colors.grey.shade200,
            onChanged: onRatingChanged,
          ),

          // ── Reset button ──
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh, size: 16),
              label: Text('Reset Filters', style: GoogleFonts.lato()),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterLabel(String text) => Text(
    text,
    style: GoogleFonts.lato(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.5),
  );
}

// ─── Chip Row ─────────────────────────────────────────────────────────────────
class _ChipRow extends StatelessWidget {
  final List<String> options;
  final String selected;
  final Function(String) onSelect;

  const _ChipRow({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((option) {
          final isSelected = option == selected;
          return GestureDetector(
            onTap: () => onSelect(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryRed : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                option,
                style: GoogleFonts.lato(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Default View ─────────────────────────────────────────────────────────────
class _DefaultView extends StatelessWidget {
  final List<String> recentSearches;
  final List<Map<String, String>> trending;
  final Function(String) onRemove;
  final VoidCallback onClearAll;
  final Function(String) onRecentTap;
  final Function(String) onTrendingTap;

  const _DefaultView({
    required this.recentSearches,
    required this.trending,
    required this.onRemove,
    required this.onClearAll,
    required this.onRecentTap,
    required this.onTrendingTap,
  });

  Color _hex(String h) => Color(int.parse('FF$h', radix: 16));

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Recent Searches ──
          if (recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('RECENT SEARCHES',
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1,
                  ),
                ),
                GestureDetector(
                  onTap: onClearAll,
                  child: Text('CLEAR ALL',
                    style: GoogleFonts.lato(
                      color: AppTheme.primaryRed,
                      fontWeight: FontWeight.w700,
                      fontSize: 13, letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recentSearches.map((s) => GestureDetector(
              onTap: () => onRecentTap(s),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.history, color: Colors.grey.shade400, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(s,
                        style: GoogleFonts.lato(fontSize: 15, color: Colors.black87),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => onRemove(s),
                      child: Icon(Icons.close, size: 18, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 24),
          ],

          // ── Trending Now ──
          Text('TRENDING NOW',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 14),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.15,
            children: trending.map((t) => _TrendingCard(
              label: t['label']!,
              imageUrl: t['url']!,
              fallbackColor: _hex(t['fallback']!),
              onTap: () => onTrendingTap(t['label']!),
            )).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── Trending Card ────────────────────────────────────────────────────────────
class _TrendingCard extends StatelessWidget {
  final String label;
  final String imageUrl;
  final Color fallbackColor;
  final VoidCallback onTap;

  const _TrendingCard({
    required this.label,
    required this.imageUrl,
    required this.fallbackColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: fallbackColor.withOpacity(0.25),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2, color: fallbackColor,
                  ),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                color: fallbackColor.withOpacity(0.3),
                child: Icon(Icons.checkroom, size: 40, color: fallbackColor),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.62)],
                ),
              ),
            ),
            Positioned(
              bottom: 12, left: 12,
              child: Text(
                label,
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold,
                  shadows: [const Shadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 2))],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Search Results ───────────────────────────────────────────────────────────
class _SearchResults extends StatelessWidget {
  final List<Product> results;
  final String query;

  const _SearchResults({
    required this.results,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No results found',
        subtitle: 'Try searching with a different\nword or adjust your filters.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Result count ──
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Text(
            '${results.length} result${results.length == 1 ? '' : 's'} found',
            style: GoogleFonts.lato(
              color: Colors.grey.shade500, fontSize: 13,
            ),
          ),
        ),

        // ── Results list ──
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: results.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final p = results[i];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(
                      product: p,
                    ),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      // Product image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: p.imagePath.startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: p.imagePath,
                                width: 70, height: 70, fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  width: 70, height: 70,
                                  color: Colors.grey.shade100,
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  width: 70, height: 70,
                                  color: Colors.grey.shade100,
                                  child: const Icon(Icons.broken_image, color: Colors.grey),
                                ),
                              )
                            : Image.asset(
                                p.imagePath,
                                width: 70, height: 70, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 70, height: 70,
                                  color: Colors.grey.shade100,
                                  child: const Icon(Icons.checkroom, color: Colors.grey),
                                ),
                              ),
                      ),
                      const SizedBox(width: 14),

                      // Product info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: GoogleFonts.lato(
                                fontWeight: FontWeight.bold, fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              p.category,
                              style: GoogleFonts.lato(
                                color: Colors.grey.shade500, fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  'LKR ${p.price.toStringAsFixed(0)}',
                                  style: GoogleFonts.lato(
                                    color: AppTheme.primaryRed,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(Icons.star, color: AppTheme.starGold, size: 14),
                                const SizedBox(width: 3),
                                Text(
                                  p.rating.toString(),
                                  style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.chevron_right, color: Colors.grey.shade400),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
