import 'package:flutter/material.dart';

class CartItemData {
  final String id;
  final String title;
  final int quantity;
  final double price;
  CartItemData({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItemData> _items = {};
  Map<String, CartItemData> get items {
    return {..._items};
  }

  double get totalAmount {
    double total = 0.0;
    _items.forEach(
        (key, cartItem) => total += cartItem.price * cartItem.quantity);
    return total;
  }

  int get itemCount {
    return _items.length;
  }

  void addItem(String prodId, String title, double price) {
    if (_items.containsKey(prodId)) {
      _items.update(
        prodId,
        (existingCartItem) => CartItemData(
          id: existingCartItem.id,
          title: existingCartItem.title,
          quantity: existingCartItem.quantity + 1,
          price: existingCartItem.price,
        ),
      );
    } else {
      _items.putIfAbsent(
        prodId,
        () => CartItemData(
          id: DateTime.now().toString(),
          title: title,
          quantity: 1,
          price: price,
        ),
      );
    }

    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (cartItem) => CartItemData(
          id: cartItem.id,
          title: cartItem.title,
          quantity: cartItem.quantity - 1,
          price: cartItem.price,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
