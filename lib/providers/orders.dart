import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../providers/cart.dart';

class OrderItemData {
  final String id;
  final double amount;
  final DateTime dateTime;
  final List<CartItemData> products;

  OrderItemData({
    required this.id,
    required this.amount,
    required this.dateTime,
    required this.products,
  });
}

class Orders with ChangeNotifier {
  List<OrderItemData> _orders = [];
  List<OrderItemData> get orders {
    return [..._orders];
  }

  String? authToken;
  String? userId;
  Orders(this.authToken, this._orders, this.userId);

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        'https://shop-app-fo2-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    final response = await http.get(url);
    if (json.decode(response.body) == null) {
      return;
    }
    final extractedData = json.decode(response.body) as Map<String,
        dynamic>; // Map<String, Map<String, orderItemData>>|| at products:List<Map<String, cartItemData>>
    final List<OrderItemData> loadedOrders = [];
    extractedData.forEach(
      (orderId, orderData) {
        loadedOrders.add(
          OrderItemData(
            id: orderId,
            amount: orderData['amount'],
            dateTime: DateTime.parse(orderData['dateTime']),
            products: (orderData['products'] as List<dynamic>)
                .map(
                  (item) => CartItemData(
                    id: item['id'],
                    title: item['title'],
                    price: item['price'],
                    quantity: item['quantity'],
                  ),
                )
                .toList(),
          ),
        );
      },
    );
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItemData> cartproducts, double total) async {
    final url = Uri.parse(
        'https://shop-app-fo2-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    final timestamp = DateTime.now();
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'amount': total,
            'dateTime': timestamp.toIso8601String(),
            'products': cartproducts
                .map((cartProduct) => {
                      'id': cartProduct.id,
                      'title': cartProduct.title,
                      'quantity': cartProduct.quantity,
                      'price': cartProduct.price,
                    })
                .toList(),
          },
        ),
      );
      _orders.insert(
        0,
        OrderItemData(
          id: json.decode(response.body)['name'],
          amount: total,
          dateTime: timestamp,
          products: cartproducts,
        ),
      );
      notifyListeners();
    } catch (_) {}
  }
}
