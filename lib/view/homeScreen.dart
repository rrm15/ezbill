import 'package:ezbill/controller/authController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../controller/productController.dart';
import '../controller/cartController.dart';
import '../model/cartItemModel.dart';
import '../model/productModel.dart';
import 'addProductPage.dart';
import 'profileScreen.dart';
import 'qr_scanner.dart';

class HomeScreen extends StatelessWidget {
  final ProductController productController = Get.find<ProductController>();
  final CartController cartController = Get.find<CartController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: Text('Products'),
        backgroundColor: Color(0xFFE1BEE7), // Light Purple
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFE1BEE7), // Light Purple
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Get.to(HomeScreen());
              },
            ),
            ListTile(
              title: Text('Add Product'),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => AddProductPage());
              },
            ),
            ListTile(
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Get.to(ProfileScreen());
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Obx(
            () => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Total Amount: ₹${cartController.cartTotalAmount}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
          ),
          Expanded(
            child: Obx(
              () => cartController.cart.isEmpty
                  ? Center(child: Text('No products available', style: TextStyle(color: Colors.black87))) // Black text
                  : ListView.builder(
                      itemCount: cartController.cart.length,
                      itemBuilder: (context, index) {
                        CartItem cartItem = cartController.cart[index];
                        return ListTile(
                          title: Text(cartItem.product.name, style: TextStyle(color: Colors.black87)), // Black text
                          subtitle: Text('Price: ₹${cartItem.product.price}', style: TextStyle(color: Colors.black54)), // Grey text
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  cartController.addToCart(cartItem.product);
                                  Get.snackbar('Added to Cart', '${cartItem.product.name} added to cart');
                                },
                                icon: Icon(Icons.add, color: Colors.black54), // Grey icon
                              ),
                              Obx(
                                () => Text(
                                  '${cartController.quantityInCart(cartItem.product.id)}',
                                  style: TextStyle(fontSize: 18, color: Colors.black87), // Black text
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  cartController.removeFromCart(cartItem.product);
                                  Get.snackbar('Removed from Cart', '${cartItem.product.name} removed from cart');
                                },
                                icon: Icon(Icons.remove, color: Colors.black54), // Grey icon
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showPaymentDialog(context);
                    },
                    child: Text(
                      'Pay Now',
                      style: TextStyle(fontSize: 20, color: Colors.black), // Black text
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Color(0xFFE1BEE7)), 
                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 15)), 
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                FloatingActionButton(
                  backgroundColor: Color(0xFFE1BEE7), 
                  onPressed: () {
                    _showAddToCartDialog(context);
                  },
                  child: new Icon(Icons.add, color: Colors.black,),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddToCartDialog(BuildContext context) {
    TextEditingController productIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Product to Cart', style: TextStyle(color: Colors.black87)), // Black text
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: productIdController,
              decoration: InputDecoration(labelText: 'Product ID'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String productId = productIdController.text.trim();
                if (productId.isNotEmpty) {
                  Product? product = await productController.getProductById(productId);
                  if (product != null) {
                    cartController.addToCart(product);
                    Get.back();
                  } else {
                    Get.snackbar('Error', 'Product not found', snackPosition: SnackPosition.BOTTOM);
                  }
                } else {
                  Get.snackbar('Error', 'Please enter a product ID', snackPosition: SnackPosition.BOTTOM);
                }
              },
              child: Text('Add to Cart', style: TextStyle(color: Colors.black)), // Black text
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Color(0xFFE1BEE7)), // Light Purple
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Get.to(QRScannerPage(onScanned: (productId) {
                final parts = productId.split(' ');
                productIdController.text=parts[0];

                }));
              },
              child: Text('Scan QR Code', style: TextStyle(color: Colors.black)), // Black text
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Color(0xFFE1BEE7)), // Light Purple
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add your payment information', style: TextStyle(color: Colors.black87)), // Black text
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'CARD HOLDER NAME',
                ),
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: 'CARD NUMBER',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  CardNumberInputFormatter(),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'EXPIRY',
                      ),
                      keyboardType: TextInputType.datetime,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(5),
                        ExpiryDateInputFormatter(),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'CVV',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: false,
                    onChanged: (bool? value) {},
                    activeColor: Color(0xFFD1C4E9), // Lighter Purple
                  ),
                  Text('Save Card Details', style: TextStyle(color: Colors.black87)), // Black text
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async{
                   await cartController.saveOrder(authController.user.value?.email ?? 'N/A');
                  // Implement payment processing logic here
                  cartController.cart.clear();
                  Get.back();
                  Get.snackbar('Payment Successful', 'Your payment was successful.', snackPosition: SnackPosition.BOTTOM);
                },
                child: Text('Proceed To Pay', style: TextStyle(fontSize: 15, color: Colors.white)),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color(0xFF9575CD)), // Slightly darker Light Purple
                  padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 60, vertical: 15)),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ),
                            SizedBox(height: 10),
              Text(
                'Total: ₹${cartController.cartTotalAmount}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87), // Black text
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentOptionButton(String text, bool isSelected) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? Color(0xFF9575CD) : Colors.grey), // Slightly darker Light Purple or Grey
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: isSelected ? Color(0xFF9575CD) : Colors.grey), // Slightly darker Light Purple or Grey
          ),
        ),
      ),
    );
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final newTextLength = newValue.text.length;
    final newText = StringBuffer();
    int selectionIndex = newValue.selection.end;

    for (int i = 0; i < newTextLength; i++) {
      if (i % 4 == 0 && i != 0) {
        newText.write(' ');
        if (i <= selectionIndex) selectionIndex++;
      }
      newText.write(newValue.text[i]);
    }

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (text.length == 2 && oldValue.text.length == 1) {
      text += '/';
    } else if (text.length == 2 && oldValue.text.length == 3) {
      text = text.substring(0, 1);
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

