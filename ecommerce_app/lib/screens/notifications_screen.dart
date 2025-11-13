import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _markNotificationsAsRead(List<QueryDocumentSnapshot> docs) {
    final batch = _firestore.batch();
    
    for (var doc in docs) {
      if (doc['isRead'] == false) {
        batch.update(doc.reference, {'isRead': true});
      }
    }
    
    batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50], // light purple background
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.purple[300], // light purple AppBar
      ),
      body: _user == null
          ? const Center(
              child: Text(
                'Please log in.',
                style: TextStyle(color: Colors.purple), // light purple text
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('notifications')
                  .where('userId', isEqualTo: _user!.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.purple, // light purple spinner
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'You have no notifications.',
                      style: TextStyle(color: Colors.purple), // light purple text
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                _markNotificationsAsRead(docs);

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final timestamp = (data['createdAt'] as Timestamp?);
                    final formattedDate = timestamp != null
                        ? DateFormat('MM/dd/yy hh:mm a').format(timestamp.toDate())
                        : '';
                    
                    final bool wasUnread = data['isRead'] == false;

                    return ListTile(
                      leading: wasUnread
                          ? const Icon(Icons.circle, color: Colors.purple, size: 12) // purple for unread
                          : const Icon(Icons.circle_outlined, color: Colors.grey, size: 12),
                      title: Text(
                        data['title'] ?? 'No Title',
                        style: TextStyle(
                          fontWeight: wasUnread ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        '${data['body'] ?? ''}\n$formattedDate',
                      ),
                      isThreeLine: true,
                    );
                  },
                );
              },
            ),
    );
  }
}
