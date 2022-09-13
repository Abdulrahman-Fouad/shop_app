import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/add_edit_product_screen.dart';

import '../widgets/user_product_item.dart';
import '../widgets/side_drawer.dart';

import '../providers/products.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products-screen';
  const UserProductsScreen({super.key});

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productsData = Provider.of<Products>(context);
    return Scaffold(
      drawer: const SideDrawer(),
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(
              context,
              AddEditProductScreen.routeName,
            ),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: ((context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Consumer<Products>(
                        builder: (context, productsData, _) => ListView.builder(
                          itemCount: productsData.items.length,
                          itemBuilder: (ctx, i) => UserProductItem(
                            productsData.items[i].id,
                            productsData.items[i].title,
                            productsData.items[i].imageUrl,
                          ),
                        ),
                      ),
                    ),
                  )),
      ),
    );
  }
}
