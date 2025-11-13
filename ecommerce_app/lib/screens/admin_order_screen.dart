import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminOrderScreen extends StatefulWidget {
  const AdminOrderScreen({super.key});

  @override
  State<AdminOrderScreen> createState() => _AdminOrderScreenState();
}

class _AdminOrderScreenState extends State<AdminOrderScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _updateOrderStatus(String orderId, String newStatus, String userId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({'status': newStatus});

      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': 'Order Status Updated',
        'body': 'Your order ($orderId) has been updated to "$newStatus".',
        'orderId': orderId,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order status updated!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }

  void _showStatusDialog(String orderId, String currentStatus, String userId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        const statuses = ['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'];
        return AlertDialog(
          backgroundColor: Colors.purple[50], // light purple dialog background
          title: const Text('Update Order Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: statuses.map((status) {
              return ListTile(
                title: Text(status),
                trailing: currentStatus == status ? const Icon(Icons.check, color: Colors.purple) : null,
                onTap: () {
                  _updateOrderStatus(orderId, status, userId);
                  Navigator.of(dialogContext).pop();
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50], // light purple background
      appBar: AppBar(
        title: const Text('Manage Orders'),
        backgroundColor: Colors.purple[300], // light purple AppBar
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('orders').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderData = order.data() as Map<String, dynamic>;

              final Timestamp? timestamp = orderData['createdAt'];
              final String formattedDate = timestamp != null
                  ? DateFormat('MM/dd/yyyy hh:mm a').format(timestamp.toDate())
                  : 'No date';

              final String status = orderData['status'] ?? 'Unknown';
              final String userId = orderData['userId'] ?? 'Unknown User';
              final double totalPrice =
                  (orderData['totalPrice'] ?? 0.0) is num ? (orderData['totalPrice'] as num).toDouble() : 0.0;
              final String formattedTotal = '₱${totalPrice.toStringAsFixed(2)}';

              return Card(
                color: Colors.purple[100], // light purple card
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    'Order ID: ${order.id}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12, color: Colors.purple),
                  ),
                  subtitle: Text(
                    'User: $userId\nTotal: $formattedTotal | Date: $formattedDate',
                    style: const TextStyle(color: Colors.purple),
                  ),
                  isThreeLine: true,
                  trailing: Chip(
                    label: Text(
                      status,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: status == 'Pending'
                        ? Colors.orange
                        : status == 'Processing'
                            ? Colors.blue
                            : status == 'Shipped'
                                ? Colors.deepPurple
                                : status == 'Delivered'
                                    ? Colors.green
                                    : Colors.red,
                  ),
                  onTap: () => _showStatusDialog(order.id, status, userId),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
