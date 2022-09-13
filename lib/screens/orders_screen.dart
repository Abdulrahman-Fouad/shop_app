import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/side_drawer.dart';
import '../widgets/order_item.dart';

import '../providers/orders.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders-screen';
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // final ordersData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Your Orders')),
      drawer: const SideDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
              ),
            );
          }
          if (snapshot.error != null) {
            return const Center(
              child: Text('An Error Occured!'),
            );
          } else {
            return Consumer<Orders>(
              builder: ((context, ordersData, _) => ListView.builder(
                    itemBuilder: ((ctx, i) => OrderItem(
                          ordersData.orders[i],
                        )),
                    itemCount: ordersData.orders.length,
                  )),
            );
          }
        },
      ),
    );
  }
}
