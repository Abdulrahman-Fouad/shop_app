import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/cart_item.dart';

import '../providers/cart.dart';
import '../providers/orders.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart-screen';

  const CartScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<Cart>(context);
    final orderData = Provider.of<Orders>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cart',
        ),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 15),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      '\$${(cartData.totalAmount).toStringAsFixed(2)}',
                      style: TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .color),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  OrderButton(cartData: cartData, orderData: orderData)
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: cartData.items.length,
              itemBuilder: ((context, i) => CartItem(
                    id: cartData.items.values.toList()[i].id,
                    productId: cartData.items.keys.toList()[i],
                    title: cartData.items.values.toList()[i].title,
                    price: cartData.items.values.toList()[i].price,
                    quantity: cartData.items.values.toList()[i].quantity,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
    required this.cartData,
    required this.orderData,
  }) : super(key: key);

  final Cart cartData;
  final Orders orderData;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: (widget.cartData.totalAmount <= 0 || _isLoading == true)
            ? null
            : () {
                showDialog(
                  context: context,
                  builder: ((ctx) => AlertDialog(
                        title: const Text('Confirm Order!'),
                        content: Text(
                          'Are you sure you want to confirm this order with total \$${(widget.cartData.totalAmount).toStringAsFixed(2)}',
                        ),
                        actionsAlignment: MainAxisAlignment.spaceAround,
                        actions: [
                          TextButton(
                            child: const Text('Confirm'),
                            onPressed: () async {
                              setState(() {
                                _isLoading = true;
                              });
                              await widget.orderData.addOrder(
                                widget.cartData.items.values.toList(),
                                widget.cartData.totalAmount,
                              );
                              _isLoading = false;
                              widget.cartData.clear();
                              if (!mounted) {
                                return;
                              }
                              Navigator.of(ctx).pop(true);
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Order #${widget.orderData.orders[0].id} has been placed',
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                          TextButton(
                            onPressed: () {
                              _isLoading = false;
                              Navigator.of(ctx).pop(false);
                            },
                            child: const Text('Cancel'),
                          ),
                        ],
                      )),
                );
              },
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              )
            : Text('ORDER NOW!',
                style: TextStyle(
                    color: widget.cartData.totalAmount <= 0
                        ? Theme.of(context).disabledColor
                        : Theme.of(context).colorScheme.primary)));
  }
}
// action: SnackBarAction(
//   label: 'Undo',
//   onPressed: () {
//     // cartData.addItem(id, title, price);
//   },
// ),
//   );
// },

// ),
//   
// ],
//         )),
//   );
// },
