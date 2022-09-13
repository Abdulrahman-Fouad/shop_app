import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/orders_screen.dart';
import '../screens/user_products_screen.dart';

import '../providers/auth.dart';

class SideDrawer extends StatelessWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: const Text('Shop App'),
            automaticallyImplyLeading: false,
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text(
              'Shop',
              // textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/');
            },
            trailing: const Icon(Icons.arrow_forward),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text(
              'Orders',
              // textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              // Navigator.of(context)
              // .pushReplacement(CustomRoute((ctx) => const OrdersScreen()));
              Navigator.pushReplacementNamed(context, OrdersScreen.routeName);
            },
            trailing: const Icon(Icons.arrow_forward),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit_note),
            title: const Text(
              'User Products',
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pushReplacementNamed(
                  context, UserProductsScreen.routeName);
            },
            trailing: const Icon(Icons.arrow_forward),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text(
              'Logout',
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/');
              Provider.of<Auth>(context, listen: false).logout();
            },
            trailing: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}
