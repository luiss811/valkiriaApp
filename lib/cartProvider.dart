// ignore_for_file: file_names

import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final List<int> _cartItems = [];

  List<int> get cartItems => _cartItems;

  void addToCart(int itemId) {
    _cartItems.add(itemId);
    notifyListeners();
  }

  void removeFromCart(int itemId) {
    _cartItems.remove(itemId);
    notifyListeners();
  }
}
