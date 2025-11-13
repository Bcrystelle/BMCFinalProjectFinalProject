import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:ecommerce_app/screens/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: Colors.purple[50], // light purple background
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: Colors.purple[300], // light purple AppBar
      ),
      body: Column(
        children: [
          Expanded(
            child: cart.items.isEmpty
                ? const Center(
                    child: Text('Your cart is empty.', style: TextStyle(color: Colors.purple)))
                : ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final cartItem = cart.items[index];
                      return Card(
                        color: Colors.purple[100], // light purple card for each item
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.purple[200], // light purple avatar
                            child: Text(cartItem.name[0],
                                style: const TextStyle(color: Colors.white)),
                          ),
                          title: Text(cartItem.name, style: const TextStyle(color: Colors.purple)),
                          subtitle: Text('Qty: ${cartItem.quantity}',
                              style: const TextStyle(color: Colors.purple)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '₱${(cartItem.price * cartItem.quantity).toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.purple),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  cart.removeItem(cartItem.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Card(
            color: Colors.purple[100], // light purple summary card
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal:',
                          style: TextStyle(fontSize: 16, color: Colors.purple)),
                      Text('₱${cart.subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16, color: Colors.purple)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('VAT (12%):',
                          style: TextStyle(fontSize: 16, color: Colors.purple)),
                      Text('₱${cart.vat.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16, color: Colors.purple)),
                    ],
                  ),
                  const Divider(height: 20, thickness: 1, color: Colors.purple),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple)),
                      Text(
                        '₱${cart.totalPriceWithVat.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.purple[200], // light purple button
                foregroundColor: Colors.white,
              ),
              onPressed: cart.items.isEmpty
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              PaymentScreen(totalAmount: cart.totalPriceWithVat),
                        ),
                      );
                    },
              child: const Text('Proceed to Payment'),
            ),
          ),
        ],
      ),
    );
  }
}
