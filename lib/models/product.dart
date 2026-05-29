class Product {
  final String id;
  final String name;
  final double price;
  final double rating;
  final String description;
  final List<String> sizes;
  final String category;
  final String imagePath;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.rating,
    required this.description,
    required this.sizes,
    required this.category,
    required this.imagePath,
    this.isFavorite = false,
  });

  factory Product.fromMap(Map<String, dynamic> data, String documentId) {
    return Product(
      id: documentId,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      rating: (data['rating'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      sizes: List<String>.from(data['sizes'] ?? []),
      category: data['category'] ?? '',
      imagePath: data['imagePath'] ?? '',
      isFavorite: data['isFavorite'] ?? false,
    );
  }
}

class CartItem {
  final String? id;
  final Product product;
  String selectedSize;
  int quantity;

  CartItem({
    this.id,
    required this.product,
    required this.selectedSize,
    this.quantity = 1,
  });
}

final List<Product> sampleProducts = [
  // ── Woman ──────────────────────────────────────────
  Product(
    id: '1',
    name: 'Pleated Noir Gown',
    price: 9200,
    rating: 4.9,
    description:
        'The material is 95% polyester and 5% spandex — soft inside, looks expensive, not see-through, and holds pleats all night. If you\'re between sizes, size up. The color is true black, not faded or grayish. Just buy it. You will thank me later.',
    sizes: ['S', 'M', 'L', 'XL'],
    category: 'Woman',
    imagePath: 'assets/images/pleated_noir_gown.jpg',
  ),
  Product(
    id: '2',
    name: 'Steal Pointed Pump',
    price: 6000,
    rating: 4.8,
    description:
        'Soft faux leather, pointed toe, 3.5-inch heel that actually feels stable. No blisters, no slipping. True to size for narrow feet — size up half if wide. Looks expensive, feels comfortable. Just buy them.',
    sizes: ['36', '37', '38', '39', '40'],
    category: 'Woman',
    imagePath: 'assets/images/steal_pointed_pump.jpg',
  ),
  Product(
    id: '3',
    name: 'Steel Leather Tote',
    price: 7000,
    rating: 4.6,
    description:
        'Genuine leather that\'s soft but sturdy — no floppy sides. Fits a 15" laptop, water bottle, and makeup pouch with room to spare. Thick straps, smooth zipper, and true-to-photo colors. Just buy it.',
    sizes: ['One Size'],
    category: 'Woman',
    imagePath: 'assets/images/steel_leather_tote.jpg',
  ),
  Product(
    id: '4',
    name: 'Silk Blazer',
    price: 9000,
    rating: 5.0,
    description:
        'Real silk — soft, breathable, and drapes beautifully. No wrinkles after sitting all day. Fits true to size with a tailored but not tight cut. Dress it up or throw it over jeans. Just buy it.',
    sizes: ['S', 'M', 'L', 'XL'],
    category: 'Woman',
    imagePath: 'assets/images/silk_blazer.jpg',
  ),

  // ── Men ────────────────────────────────────────────
  Product(
    id: '5',
    name: 'Classic Oxford Shirt',
    price: 4500,
    rating: 4.7,
    description:
        'Premium cotton Oxford cloth that breathes well and holds its shape. Button-down collar stays crisp all day. Perfect for casual Fridays or weekend outings. Machine washable. True to size.',
    sizes: ['S', 'M', 'L', 'XL'],
    category: 'Men',
    imagePath: 'assets/images/classic_oxford_shirt.jpg',
  ),
  Product(
    id: '6',
    name: 'Tailored Chinos',
    price: 5500,
    rating: 4.5,
    description:
        'Slim fit with just enough stretch to move freely. These chinos hit the sweet spot between casual and smart. The fabric holds a crease beautifully and doesn\'t wrinkle easily. Buy them in every colour.',
    sizes: ['S', 'M', 'L', 'XL'],
    category: 'Men',
    imagePath: 'assets/images/tailored_chinos.jpg',
  ),
  Product(
    id: '7',
    name: 'Slim Fit Blazer',
    price: 8500,
    rating: 4.8,
    description:
        'A sharp, slim-fit blazer that goes from boardroom to bar effortlessly. The structured shoulders and clean lapels give you instant authority. Pair with chinos or dark jeans for a complete look.',
    sizes: ['S', 'M', 'L', 'XL'],
    category: 'Men',
    imagePath: 'assets/images/men_jacket.jpg',
  ),
  Product(
    id: '8',
    name: 'Premium Polo Shirt',
    price: 3800,
    rating: 4.6,
    description:
        'Pique cotton polo with a clean, structured collar that holds its shape wash after wash. Breathable and moisture-wicking — ideal for both work and weekend. Available in classic navy.',
    sizes: ['S', 'M', 'L', 'XL', 'XXL'],
    category: 'Men',
    imagePath: 'assets/images/men_polo.jpg',
  ),

  // ── Kids ───────────────────────────────────────────
  Product(
    id: '9',
    name: 'Floral Princess Dress',
    price: 3200,
    rating: 4.9,
    description:
        'A dreamy dress with a soft cotton bodice and a full tulle skirt. The polka-dot pattern and satin bow make it perfect for parties or everyday wear. Machine washable. Runs true to size.',
    sizes: ['S', 'M', 'L', 'XL', 'XXL'],
    category: 'Kids',
    imagePath: 'assets/images/kids_dress.jpg',
  ),
  Product(
    id: '10',
    name: 'Graphic Star T-Shirt',
    price: 1800,
    rating: 4.7,
    description:
        'Soft 100% cotton with a fun star graphic print. Bright teal colour that stays vibrant wash after wash. The relaxed fit gives kids room to move. Great for school or play.',
    sizes: ['S', 'M', 'L', 'XL', 'XXL'],
    category: 'Kids',
    imagePath: 'assets/images/kids_tshirt.jpg',
  ),
  Product(
    id: '11',
    name: 'Colour Pop Sneakers',
    price: 2900,
    rating: 4.8,
    description:
        'Lightweight and cushioned for all-day play. The velcro strap makes them easy for little hands to put on and take off. Non-slip sole and breathable mesh upper. Kids absolutely love them.',
    sizes: ['40', '41', '42', '43', '44'],
    category: 'Kids',
    imagePath: 'assets/images/kids_sneakers.jpg',
  ),
];
