import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './cart_screen.dart';

import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../widgets/side_drawer.dart';

import '../providers/cart.dart';
import '../providers/products.dart';

enum FilterOptions { favourites, all }

class ProductsOverviewScreen extends StatefulWidget {
  static const routeName = '/products-overview-screen';
  const ProductsOverviewScreen({super.key});

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool _showOnlyFav = false;
  bool _isInit = true;
  var _isLoading = false;
  @override
  void initState() {
    //   Future.delayed(Duration.zero).then((_) {
    //     Provider.of<Products>(context).fetchAndSetProducts();
    //   });
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      _isLoading = true;
      await Provider.of<Products>(context).fetchAndSetProducts();
    }
    _isLoading = false;
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideDrawer(),
      appBar: AppBar(
        title: const Text('My Shop'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: ((FilterOptions selectedValue) {
              setState(
                () {
                  if (selectedValue == FilterOptions.favourites) {
                    _showOnlyFav = true;
                  } else {
                    _showOnlyFav = false;
                  }
                },
              );
            }),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: FilterOptions.favourites,
                child: Text('Only Favourites!'),
              ),
              const PopupMenuItem(
                value: FilterOptions.all,
                child: Text('All Items!'),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              color: Theme.of(context).colorScheme.secondary,
              value: cart.itemCount.toString(),
              child: ch!,
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, CartScreen.routeName);
              },
              icon: const Icon(Icons.shopping_cart),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showOnlyFav),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: (() {}),
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
