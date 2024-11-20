import 'package:get/get.dart';
import '../model/productModel.dart';
import '../model/cartItemModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartController extends GetxController {
  var cart = <CartItem>[].obs;

  dynamic saveOrder(String userEmail) async {
    CollectionReference orders = FirebaseFirestore.instance.collection('orders');

    List<Map<String, dynamic>> items = cart.map((cartItem) {
      return {
        'productId': cartItem.product.id,
        'name': cartItem.product.name,
        'price': cartItem.product.price,
        'quantity': cartItem.quantity,
      };
    }).toList();

    await orders.add({
      'items': items,
      'totalAmount': cartTotalAmount,
      'userEmail': userEmail,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void addToCart(Product product) {
    int index = cart.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      cart[index] = CartItem(product: product, quantity: cart[index].quantity + 1);
    } else {
      cart.add(CartItem(product: product, quantity: 1));
    }
  }

  void removeFromCart(Product product) {
    int index = cart.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      if (cart[index].quantity > 1) {
        cart[index] = CartItem(product: product, quantity: cart[index].quantity - 1);
      } else {
        cart.removeAt(index);
      }
    }
  }

  int quantityInCart(String productId) {
    int index = cart.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      return cart[index].quantity;
    }
    return 0;
  }

  double get cartTotalAmount {
    double total = 0.0;
    for (var item in cart) {
      total += item.product.price * item.quantity;
    }
    return total;
  }
}
