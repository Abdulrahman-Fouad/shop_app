import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

import '../providers/product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  String? authToken;
  String? userId;
  Products(this.authToken, this._items, this.userId);

  List<Product> get items {
    return [..._items];
  }

  Future<void> fetchAndSetProducts([filterByUser = false]) async {
    final filterText =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    final url = Uri.parse(
        'https://shop-app-fo2-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterText');
    // if (url == null) {
    //   return;
    // }
    final response = await http.get(url);
    if (json.decode(response.body) == null) {
      return;
    }
    final favUrl = Uri.parse(
        'https://shop-app-fo2-default-rtdb.firebaseio.com/userFavourites/products/$userId.json?auth=$authToken');
    final favResponse = await http.get(favUrl);
    final favData = json.decode(favResponse.body);
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    final List<Product> loadedProducts = [];
    extractedData.forEach((prodId, prodData) {
      loadedProducts.add(
        Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          imageUrl: prodData['imageUrl'],
          price: prodData['price'],
          isFav: favData == null ? false : favData[prodId] ?? false,
        ),
      );
    });
    _items = loadedProducts;
    notifyListeners();
  }

  List<Product> get favItems {
    return _items.where((product) => product.isFav).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((item) => item.id == id);
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://shop-app-fo2-default-rtdb.firebaseio.com/products.json?auth=$authToken');

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'creatorId': userId,
            // 'isFav': product.isFav,
          },
        ),
      );
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }

    // .catchError((error) {
    // print(error);
    // });
  }

  Future<void> updateExistingProduct(
      String productId, Product updatedProduct) async {
    final url = Uri.parse(
        'https://shop-app-fo2-default-rtdb.firebaseio.com/products/$productId.json?auth=$authToken');

    final prodIndex = _items.indexWhere((prod) => prod.id == productId);
    if (prodIndex >= 0) {
      await http.patch(
        url,
        body: json.encode(
          {
            'title': updatedProduct.title,
            'description': updatedProduct.description,
            'price': updatedProduct.price,
            'imageUrl': updatedProduct.imageUrl,
          },
        ),
      );
      _items[prodIndex] = updatedProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String prodId) async {
    final url = Uri.parse(
        'https://shop-app-fo2-default-rtdb.firebaseio.com/products/$prodId.json?auth=$authToken');
    final exixstingProductIndex =
        _items.indexWhere((prod) => prod.id == prodId);
    Product? existingProduct = _items[exixstingProductIndex];
    // notifyListeners();
    _items.removeAt(exixstingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(exixstingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete this product!');
    }
    existingProduct = null;
  }
}
