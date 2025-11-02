// Part 1: Imports
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Part 2: Widget Definition
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          // 1. Add an IconButton to the AppBar
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              // 2. Call Firebase to sign out
              await FirebaseAuth.instance.signOut();

              // We don't need to navigate manually.
              // The AuthWrapper (which listens to auth state changes)
              // will automatically redirect the user to the login screen.
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'You are logged in!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
