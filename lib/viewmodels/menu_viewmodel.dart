import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../models/order.dart';
import '../repositories/order_repository.dart';

/// ViewModel for managing menu, cart, and order operations
/// Uses Provider for state management
class MenuViewModel extends ChangeNotifier {
  final OrderRepository _repository = OrderRepository();

  // Menu state
  List<MenuItem> _menuItems = [];
  bool _isLoadingMenu = false;
  String? _menuError;

  // Cart state
  final List<CartItem> _cartItems = [];

  // Order state
  bool _isPlacingOrder = false;
  String? _orderError;
  String? _lastOrderId;

  // Getters
  List<MenuItem> get menuItems => _menuItems;
  bool get isLoadingMenu => _isLoadingMenu;
  String? get menuError => _menuError;

  List<CartItem> get cartItems => _cartItems;
  int get cartItemCount =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get cartTotal =>
      _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  bool get isCartEmpty => _cartItems.isEmpty;

  bool get isPlacingOrder => _isPlacingOrder;
  String? get orderError => _orderError;
  String? get lastOrderId => _lastOrderId;

  /// Fetches menu items from the backend
  Future<void> fetchMenu() async {
    _isLoadingMenu = true;
    _menuError = null;
    notifyListeners();

    try {
      _menuItems = await _repository.fetchMenu();
    } catch (e) {
      _menuError = e.toString();
      print('❌ Menu fetch error: $e');
    } finally {
      _isLoadingMenu = false;
      notifyListeners();
    }
  }

  /// Adds an item to the cart
  void addToCart(MenuItem item) {
    // Check if item already exists in cart
    final existingIndex = _cartItems.indexWhere(
      (cartItem) => cartItem.menuItem.id == item.id,
    );

    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity++;
    } else {
      _cartItems.add(CartItem(menuItem: item));
    }

    print('🛒 Added ${item.name} to cart. Total items: $cartItemCount');
    notifyListeners();
  }

  /// Removes an item from the cart
  void removeFromCart(CartItem item) {
    _cartItems.remove(item);
    notifyListeners();
  }

  /// Decreases quantity or removes item if quantity becomes 0
  void decreaseQuantity(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _cartItems.remove(item);
    }
    notifyListeners();
  }

  /// Increases quantity of a cart item
  void increaseQuantity(CartItem item) {
    item.quantity++;
    notifyListeners();
  }

  /// Clears all items from the cart
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  /// Places an order with the current cart items
  /// [address] - Delivery address (will be encrypted)
  /// [phone] - Optional phone number (will be encrypted)
  Future<bool> placeOrder({required String address, String? phone}) async {
    if (_cartItems.isEmpty) {
      _orderError = 'Cart is empty';
      notifyListeners();
      return false;
    }

    if (address.trim().isEmpty) {
      _orderError = 'Delivery address is required';
      notifyListeners();
      return false;
    }

    _isPlacingOrder = true;
    _orderError = null;
    notifyListeners();

    try {
      _lastOrderId = await _repository.placeOrder(
        items: _cartItems,
        total: cartTotal,
        address: address,
        phone: phone,
      );

      // Clear cart after successful order
      _cartItems.clear();

      print('✅ Order placed: $_lastOrderId');
      return true;
    } catch (e) {
      _orderError = e.toString();
      print('❌ Order error: $e');
      return false;
    } finally {
      _isPlacingOrder = false;
      notifyListeners();
    }
  }

  /// Resets order error state
  void clearOrderError() {
    _orderError = null;
    notifyListeners();
  }
}
