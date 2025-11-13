// ================================
// lib/providers/cart_provider.dart
// ================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ================================
// CART ITEM MODEL
// ================================
class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'],
    );
  }
}

// ================================
// CART PROVIDER
// ================================
class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];

  String? _userId;
  StreamSubscription? _authSubscription;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ----------------
  // Getters
  // ----------------
  List<CartItem> get items => _items;

  int get itemCount => _items.fold(0, (total, item) => total + item.quantity);

  double get subtotal =>
      _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  double get vat => subtotal * 0.12;

  double get totalPriceWithVat => subtotal + vat;

  // ----------------
  // Constructor
  // ----------------
  CartProvider() {
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        _userId = null;
        _items = [];
      } else {
        _userId = user.uid;
        _fetchCart();
      }
      notifyListeners();
    });
  }

  // ----------------
  // Fetch Cart from Firestore
  // ----------------
  Future<void> _fetchCart() async {
    if (_userId == null) return;

    try {
      final doc = await _firestore.collection('userCarts').doc(_userId).get();

      if (doc.exists && doc.data()?['cartItems'] != null) {
        final List<dynamic> cartData = doc.data()!['cartItems'];
        _items = cartData.map((item) => CartItem.fromJson(item)).toList();
      } else {
        _items = [];
      }
    } catch (e) {
      debugPrint('Error fetching cart: $e');
      _items = [];
    }
    notifyListeners();
  }

  // ----------------
  // Save Cart to Firestore
  // ----------------
  Future<void> _saveCart() async {
    if (_userId == null) return;

    try {
      final List<Map<String, dynamic>> cartData =
          _items.map((item) => item.toJson()).toList();

      await _firestore.collection('userCarts').doc(_userId).set({
        'cartItems': cartData,
      });
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  // ----------------
  // Cart Operations
  // ----------------
  void addItem(String id, String name, double price, int quantity) {
    final index = _items.indexWhere((item) => item.id == id);

    if (index != -1) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(
        id: id,
        name: name,
        price: price,
        quantity: quantity,
      ));
    }

    _saveCart();
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    _saveCart();
    notifyListeners();
  }

  // ----------------
  // Place Order
  // ----------------
  Future<void> placeOrder() async {
    if (_userId == null || _items.isEmpty) {
      throw Exception('Cart is empty or user is not logged in.');
    }

    try {
      final List<Map<String, dynamic>> cartData =
          _items.map((item) => item.toJson()).toList();

      await _firestore.collection('orders').add({
        'userId': _userId,
        'items': cartData,
        'subtotal': subtotal,
        'vat': vat,
        'totalPrice': totalPriceWithVat,
        'itemCount': itemCount,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error placing order: $e');
      rethrow;
    }
  }

  // ----------------
  // Clear Cart
  // ----------------
  Future<void> clearCart() async {
    _items = [];

    if (_userId != null) {
      try {
        await _firestore.collection('userCarts').doc(_userId).set({
          'cartItems': [],
        });
      } catch (e) {
        debugPrint('Error clearing Firestore cart: $e');
      }
    }

    notifyListeners();
  }

  // ----------------
  // Cleanup
  // ----------------
  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
