// Part 1: Imports
import 'package:ecommerce_app/screens/login_screen.dart'; // For navigating back to login
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Firebase Auth import
import 'package:flutter/material.dart';

// Part 2: Widget Definition
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Form key and text controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ✅ State variables
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Dispose controllers when not needed
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ✅ Sign-Up Function
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return; // Stop if invalid form
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1️⃣ Create a new user with Firebase
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2️⃣ AuthWrapper will auto-navigate to HomeScreen (no manual navigation needed)

    } on FirebaseAuthException catch (e) {
      // 3️⃣ Handle Firebase-specific errors
      String message = 'An error occurred';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email.';
      }

      // Show SnackBar with error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print('Unexpected error: $e');
    }

    // 4️⃣ Stop loading spinner
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ✅ Build Method (UI)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Password Field
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25),

              // ✅ Sign Up Button with Loading Spinner
              ElevatedButton(
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text('Sign Up'),
              ),
              const SizedBox(height: 10),

              // ✅ Navigate back to Login
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text("Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
