import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  bool isFav;
  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.isFav = false,
  });
  void _setFavValue(bool newValue) {
    isFav = newValue;
    notifyListeners();
  }

  Future<void> toggleFav(String? authToken, String? userId) async {
    final oldStatus = isFav;
    isFav = !isFav;
    notifyListeners();
    final url = Uri.parse(
        'https://shop-app-fo2-default-rtdb.firebaseio.com/userFavourites/products/$userId/$id.json?auth=$authToken');
    try {
      final response = await http.put(
        url,
        body: json.encode(
          isFav,
        ),
      );
      if (response.statusCode >= 400) {
        isFav = oldStatus;
        notifyListeners();
      }
    } on Exception catch (_) {
      _setFavValue(oldStatus);
    }
    // print("$title : $isFav");
  }
}
