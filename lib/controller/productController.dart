import 'dart:async';

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/productModel.dart';

class ProductController extends GetxController {
  var products = <Product>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }   
  dynamic getProductById(String productId) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('products').where('id', isEqualTo: productId).get();
    if (querySnapshot.docs.isNotEmpty) {
      // Assuming there is only one document with the matching productIdField
      DocumentSnapshot docSnapshot = querySnapshot.docs.first;
      return Product(
        id: docSnapshot.id,
        name: docSnapshot['name'],
        price: docSnapshot['price'].toDouble(),
      );
    } else {
      print('Product not found with ID: $productId');
      return null;
    }
  } catch (e) {
    print('Error getting product: $e');
    return null;
  }
}


  void fetchProducts() {
  try {
    FirebaseFirestore.instance.collection('products').snapshots().listen((snapshot) {
      products.assignAll(snapshot.docs.map((doc) => Product(
        id: doc.id,
        name: doc['name'],
        price: doc['price'].toDouble(),
      )).toList());
    });
  } catch (e) {
    print('Error fetching products: $e');
  }
}

  void addProduct(Product product) async {
    try {
      await FirebaseFirestore.instance.collection('products').add(product.toJson());
      print('Product added successfully');
    } catch (e) {
      print('Error adding product: $e');
    }
  }
}
