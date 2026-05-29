import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

/// One-time migration: uploads all products from [sampleProducts]
/// to the Firestore 'products' collection.
/// Each document uses the product's id as its document ID.
Future<void> uploadProductsToFirestore() async {
  final firestore = FirebaseFirestore.instance;
  final collection = firestore.collection('products');

  for (final product in sampleProducts) {
    await collection.doc(product.id).set({
      'id': product.id,
      'name': product.name,
      'price': product.price,
      'rating': product.rating,
      'description': product.description,
      'sizes': product.sizes,
      'category': product.category,
      'imagePath': product.imagePath,
      'isFavorite': product.isFavorite,
    });
  }

  print('Upload complete');
}
