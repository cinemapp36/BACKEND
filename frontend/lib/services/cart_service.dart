import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import 'api_client.dart';

class CartService extends ChangeNotifier {
  Cart? _cart;
  bool _isLoading = false;

  Cart? get cart => _cart;
  bool get isLoading => _isLoading;
  int get itemCount => _cart?.items.fold(0, (sum, i) => sum! + i.quantity) ?? 0;

  Future<void> fetchCart() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiClient.get('/cart');
      _cart = Cart.fromJson(data['cart']);
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(String productId, {int quantity = 1}) async {
    try {
      final data = await ApiClient.post('/cart', {
        'productId': productId,
        'quantity': quantity,
      });
      _cart = Cart.fromJson(data['cart']);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFromCart(String productId) async {
    try {
      final data = await ApiClient.delete('/cart/$productId');
      _cart = Cart.fromJson(data['cart']);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearCart() async {
    try {
      await ApiClient.delete('/cart/clear');
      _cart = null;
      notifyListeners();
    } catch (_) {}
  }
}
