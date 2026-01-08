import '../models/menu_item.dart';
import '../models/order.dart';
import '../services/api_service.dart';
import '../utils/encryption_helper.dart';

/// Repository for handling menu and order data
/// Uses ApiService for backend communication (NOT direct Firestore access)
class OrderRepository {
  final ApiService _apiService = ApiService();

  /// Fetches menu items from the backend
  Future<List<MenuItem>> fetchMenu() async {
    final response = await _apiService.getMenu();

    if (!response.success) {
      throw Exception(response.error ?? 'Failed to fetch menu');
    }

    final List<dynamic> menuData = response.data ?? [];
    return menuData.map((item) => MenuItem.fromJson(item)).toList();
  }

  /// Places an order with encrypted sensitive data
  ///
  /// [items] - List of cart items to order
  /// [address] - Delivery address (will be encrypted before sending)
  /// [phone] - Phone number (optional, will be encrypted if provided)
  ///
  /// Returns an OrderPlacementResult containing orderId and queueNumber on success
  Future<OrderPlacementResult> placeOrder({
    required List<CartItem> items,
    required double total,
    required String address,
    String? phone,
  }) async {
    // Encrypt sensitive data before sending to server
    final encryptedAddress = EncryptionHelper.encryptData(address);
    final encryptedPhone = phone != null
        ? EncryptionHelper.encryptData(phone)
        : null;

    // Prepare order payload
    final orderPayload = {
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'encryptedAddress': encryptedAddress,
      if (encryptedPhone != null) 'encryptedPhone': encryptedPhone,
    };

    final response = await _apiService.placeOrder(orderPayload);

    if (!response.success) {
      throw Exception(response.error ?? 'Failed to place order');
    }

    final orderId = response.data?['orderId'] as String?;
    final queueNumber = response.data?['queueNumber'] as int?;

    if (orderId == null) {
      throw Exception('No order ID received from server');
    }

    if (queueNumber == null) {
      throw Exception('No queue number received from server');
    }

    return OrderPlacementResult(orderId: orderId, queueNumber: queueNumber);
  }

  /// Fetches user's order history from the backend
  Future<List<Order>> fetchOrders() async {
    final response = await _apiService.getOrders();

    if (!response.success) {
      throw Exception(response.error ?? 'Failed to fetch orders');
    }

    final List<dynamic> ordersData = response.data ?? [];
    return ordersData.map((item) => Order.fromJson(item)).toList();
  }
}

/// Result of placing an order
class OrderPlacementResult {
  final String orderId;
  final int queueNumber;

  OrderPlacementResult({
    required this.orderId,
    required this.queueNumber,
  });


}
