import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  // ── Products ──────────────────────────────────────────────

  /// Stream all products from Firestore
  Stream<List<Product>> getProductsStream() {
    return _db.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // ── Cart ──────────────────────────────────────────────────

  /// Stream current user's cart items
  Stream<List<CartItem>> getCartStream() {
    if (userId == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(userId)
        .collection('cart')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return CartItem(
          id: doc.id,
          product: Product(
            id: data['productId'] ?? '',
            name: data['name'] ?? '',
            price: (data['price'] ?? 0).toDouble(),
            imagePath: data['imagePath'] ?? '',
            rating: 0,
            description: '',
            sizes: [],
            category: '',
          ),
          selectedSize: data['size'] ?? '',
          quantity: data['quantity'] ?? 1,
        );
      }).toList();
    });
  }

  /// Add item to cart
  Future<void> addToCart(Product product, String size, int quantity) async {
    if (userId == null) return;
    final cartRef = _db.collection('users').doc(userId).collection('cart');
    
    // Check if the item with same product and size exists
    final existing = await cartRef
        .where('productId', isEqualTo: product.id)
        .where('size', isEqualTo: size)
        .get();

    if (existing.docs.isNotEmpty) {
      final doc = existing.docs.first;
      await doc.reference.update({
        'quantity': FieldValue.increment(quantity),
      });
    } else {
      await cartRef.add({
        'productId': product.id,
        'name': product.name,
        'price': product.price,
        'imagePath': product.imagePath,
        'size': size,
        'quantity': quantity,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Remove item from cart
  Future<void> removeFromCart(String cartItemId) async {
    if (userId == null) return;
    await _db
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(cartItemId)
        .delete();
  }

  /// Clear the entire cart
  Future<void> clearCart() async {
    if (userId == null) return;
    final cartRef = _db.collection('users').doc(userId).collection('cart');
    final snapshots = await cartRef.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }

  // ── Orders ────────────────────────────────────────────────

  /// Stream a single order's details (for live status updates)
  Stream<DocumentSnapshot> getOrderStream(String orderId) {
    if (userId == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(userId)
        .collection('orders')
        .doc(orderId)
        .snapshots();
  }

  /// Stream current user's orders
  Stream<QuerySnapshot> getOrdersStream() {
    if (userId == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(userId)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Create an order from cart data
  Future<void> createOrder(double total, List<CartItem> items) async {
    if (userId == null) return;
    final ordersRef = _db.collection('users').doc(userId).collection('orders');
    
    await ordersRef.add({
      'total': total,
      'status': 'Processing',
      'createdAt': FieldValue.serverTimestamp(),
      'items': items.map((i) => {
        'productId': i.product.id,
        'name': i.product.name,
        'size': i.selectedSize,
        'quantity': i.quantity,
        'price': i.product.price,
      }).toList(),
    });
  }

  /// Cancel an order
  Future<void> cancelOrder(String orderId) async {
    if (userId == null) return;
    await _db
        .collection('users')
        .doc(userId)
        .collection('orders')
        .doc(orderId)
        .update({'status': 'Cancelled'});
  }

  // ── Favorites ──────────────────────────────────────────────

  /// Stream all favorite product IDs for current user
  Stream<List<String>> getFavoriteIdsStream() {
    if (userId == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  /// Stream full favorite products (joins with products collection)
  Stream<List<Product>> getFavoriteProductsStream() {
    if (userId == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .asyncMap((snapshot) async {
      final List<Product> favorites = [];
      for (final doc in snapshot.docs) {
        final productDoc = await _db.collection('products').doc(doc.id).get();
        if (productDoc.exists) {
          favorites.add(Product.fromMap(productDoc.data()!, productDoc.id));
        }
      }
      return favorites;
    });
  }

  /// Toggle favorite — adds if not saved, removes if already saved
  Future<void> toggleFavorite(String productId) async {
    if (userId == null) return;
    final favRef = _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(productId);

    final doc = await favRef.get();
    if (doc.exists) {
      await favRef.delete();
    } else {
      await favRef.set({
        'savedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Check if a single product is favorited
  Future<bool> isFavorite(String productId) async {
    if (userId == null) return false;
    final doc = await _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(productId)
        .get();
    return doc.exists;
  }

  // ── Profile ───────────────────────────────────────────────

  /// Stream user profile data
  Stream<DocumentSnapshot> getUserProfileStream() {
    if (userId == null) return const Stream.empty();
    return _db.collection('users').doc(userId).snapshots();
  }

  /// Update user profile data
  Future<void> updateUserProfile({
    required String name,
    required String address,
    String? profileImageUrl,
  }) async {
    if (userId == null) return;
    
    final updateData = <String, dynamic>{
      'name': name,
      'address': address,
    };
    
    if (profileImageUrl != null) {
      updateData['profileImageUrl'] = profileImageUrl;
    }
    
    await _db.collection('users').doc(userId).set(
      updateData, 
      SetOptions(merge: true)
    );
  }
  
  /// Upload profile image to Firebase Storage and return URL
  Future<String?> uploadProfileImage(File imageFile) async {
    if (userId == null) return null;
    
    try {
      // Create a unique file name for the image
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_profiles')
          .child('$userId.jpg');

      // Upload file
      final uploadTask = await storageRef.putFile(imageFile);
      
      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      return null;
    }
  }

  /// Remove profile photo from Firestore (deletes all profile photo fields)
  Future<void> removeProfilePhoto() async {
    if (userId == null) return;
    await _db.collection('users').doc(userId).update({
      'profilePhoto': FieldValue.delete(),
      'profileImageUrl': FieldValue.delete(),
      'photoUrl': FieldValue.delete(),
    });
  }

  /// Update profile photo URL in Firestore
  Future<void> updateProfilePhoto(String photoUrl) async {
    if (userId == null) return;
    await _db.collection('users').doc(userId).set(
      {'photoUrl': photoUrl}, SetOptions(merge: true));
  }


  // ── Addresses ─────────────────────────────────────────────

  /// Stream all saved addresses for current user
  Stream<List<Map<String, dynamic>>> getAddressesStream() {
    if (userId == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  /// Add a new address
  Future<void> addAddress({
    required String fullName,
    required String phone,
    required String addressLine,
    required String city,
    required String postalCode,
  }) async {
    if (userId == null) return;
    await _db
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .add({
      'fullName':    fullName,
      'phone':       phone,
      'addressLine': addressLine,
      'city':        city,
      'postalCode':  postalCode,
      'createdAt':   FieldValue.serverTimestamp(),
    });
  }

  /// Delete an address
  Future<void> deleteAddress(String addressId) async {
    if (userId == null) return;
    await _db
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .doc(addressId)
        .delete();
  }

  /// Update order with delivery address
  Future<void> createOrderWithAddress({
    required double total,
    required List<CartItem> items,
    required Map<String, dynamic> address,
  }) async {
    if (userId == null) return;
    final ordersRef = _db.collection('users').doc(userId).collection('orders');

    await ordersRef.add({
      'total':     total,
      'status':    'Processing',
      'createdAt': FieldValue.serverTimestamp(),
      'address':   address,
      'items': items.map((i) => {
        'productId': i.product.id,
        'name':      i.product.name,
        'size':      i.selectedSize,
        'quantity':  i.quantity,
        'price':     i.product.price,
      }).toList(),
    });
  }
}
