import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/productController.dart';
import '../model/productModel.dart';
import './qr_scanner.dart';

class AddProductPage extends StatelessWidget {
  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  final ProductController productController = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product ID'),
            TextField(controller: idController),
            SizedBox(height: 20),
            Text('Product Name'),
            TextField(controller: nameController),
            SizedBox(height: 20),
            Text('Product Price'),
            TextField(controller: priceController),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Create Product object
                Product product = Product(
                  id: idController.text.trim(),
                  name: nameController.text.trim(),
                  price: double.parse(priceController.text.trim()),
                );
                // Add product to Firebase
                productController.addProduct(product);
                // Clear text fields
                idController.clear();
                nameController.clear();
                priceController.clear();
                // Show success message
                Get.snackbar('Product Added', 'Product added successfully');
              },
              child: Text('Add Product'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to QR scanner page
                _scanQR(context);
              },
              child: Text('Scan QR Code'),
            ),
          ],
        ),
      ),
    );
  }

  void _scanQR(BuildContext context) {
    Get.to(() => QRScannerPage(onScanned: (productId) {
      splitStringIntoThree(productId, context);
    }));
  }

  void splitStringIntoThree(String data, BuildContext context) {
    final parts = data.split(' ');
    if (parts.length >= 3) {
      idController.text = parts[0];
      nameController.text = parts[1];
      priceController.text = parts.sublist(2).join(' ');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('The input string must contain at least three parts')),
      );
    }
  }
}
