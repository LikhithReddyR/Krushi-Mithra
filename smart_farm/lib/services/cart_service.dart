import 'package:flutter/foundation.dart';
import 'package:smart_farm/screens/shop_screen.dart'; // To get Product model

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartService extends ChangeNotifier {
  // Singleton pattern for simple state management without extra packages
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  static CartService get instance => _instance;

  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  int get totalItems {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalPrice {
    return _items.values.fold(0.0, (sum, item) => sum + (item.product.currentPrice * item.quantity));
  }

  void addToCart(Product product) {
    if (_items.containsKey(product.name)) {
      _items[product.name]!.quantity++;
    } else {
      _items[product.name] = CartItem(product: product);
    }
    notifyListeners();
  }

  void addMultipleToCart(Product product, int qty) {
    if (_items.containsKey(product.name)) {
      _items[product.name]!.quantity += qty;
    } else {
      _items[product.name] = CartItem(product: product, quantity: qty);
    }
    notifyListeners();
  }

  void removeFromCart(String productName) {
    _items.remove(productName);
    notifyListeners();
  }

  void decreaseQuantity(String productName) {
    if (!_items.containsKey(productName)) return;

    if (_items[productName]!.quantity > 1) {
      _items[productName]!.quantity--;
    } else {
      _items.remove(productName);
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
