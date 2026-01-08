import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/menu_viewmodel.dart';
import '../models/order.dart';
import 'order_status_screen.dart';

/// Cart Screen - Shows cart items and handles order placement
/// Redesigned with clean light theme and warm orange accents
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Warm orange theme colors
  static const Color _primaryOrange = Color(0xFFD4A259);
  static const Color _backgroundColor = Color(0xFFFAF8F5);
  static const Color _cardColor = Colors.white;
  static const Color _textDark = Color(0xFF2D2D2D);
  static const Color _textGrey = Color(0xFF6B6B6B);
  static const Color _borderColor = Color(0xFFE0E0E0);

  Future<void> _placeOrder(BuildContext context) async {
    final viewModel = context.read<MenuViewModel>();

    // For simplified cart, we use a default address
    final success = await viewModel.placeOrder(
      address: 'In-store pickup',
      phone: null,
    );

    if (!context.mounted) return;

    if (success) {
      // Navigate to order status screen with queue number
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              OrderStatusScreen(queueNumber: viewModel.lastQueueNumber!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.orderError ?? 'Failed to place order'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: _textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Order',
          style: TextStyle(
            color: _textDark,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer<MenuViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isCartEmpty) {
            return _buildEmptyCart();
          }
          return _buildCartContent(context, viewModel);
        },
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _primaryOrange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: _primaryOrange,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              color: _textDark,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add some delicious items!',
            style: TextStyle(color: _textGrey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, MenuViewModel viewModel) {
    return Column(
      children: [
        // Cart items list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.cartItems.length,
            itemBuilder: (context, index) {
              return _CartItemTile(
                item: viewModel.cartItems[index],
                primaryOrange: _primaryOrange,
                cardColor: _cardColor,
                textDark: _textDark,
                textGrey: _textGrey,
                borderColor: _borderColor,
              );
            },
          ),
        ),

        // Bottom section with summary and button
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Subtotal row
                _buildSummaryRow(
                  'Subtotal:',
                  '\$${viewModel.cartTotal.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 8),

                // Tax row
                _buildSummaryRow(
                  'Tax:',
                  '\$${viewModel.cartTax.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 12),

                // Divider
                Container(height: 1, color: _borderColor),
                const SizedBox(height: 12),

                // Total row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        color: _textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${viewModel.cartGrandTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: _textDark,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Place Order Button
                Consumer<MenuViewModel>(
                  builder: (context, vm, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: vm.isPlacingOrder
                            ? null
                            : () => _placeOrder(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryOrange,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27),
                          ),
                          elevation: 0,
                        ),
                        child: vm.isPlacingOrder
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Placing Order...'),
                                ],
                              )
                            : const Text(
                                'PLACE ORDER',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Total amount below button
                Text(
                  '\$${viewModel.cartGrandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(color: _textGrey, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: _textGrey, fontSize: 16)),
        Text(
          value,
          style: const TextStyle(
            color: _textDark,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Cart item tile widget with clean design
class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final Color primaryOrange;
  final Color cardColor;
  final Color textDark;
  final Color textGrey;
  final Color borderColor;

  const _CartItemTile({
    required this.item,
    required this.primaryOrange,
    required this.cardColor,
    required this.textDark,
    required this.textGrey,
    required this.borderColor,
  });

  // Get emoji for food category
  String _getFoodEmoji(String category, String name) {
    final nameLower = name.toLowerCase();
    final categoryLower = category.toLowerCase();

    if (nameLower.contains('burger') || nameLower.contains('cheeseburger')) {
      return '🍔';
    } else if (nameLower.contains('pizza') ||
        nameLower.contains('margherita')) {
      return '🍕';
    } else if (nameLower.contains('juice') || nameLower.contains('orange')) {
      return '🧃';
    } else if (nameLower.contains('coffee') || nameLower.contains('latte')) {
      return '☕';
    } else if (nameLower.contains('salad')) {
      return '🥗';
    } else if (nameLower.contains('pasta') || nameLower.contains('spaghetti')) {
      return '🍝';
    } else if (nameLower.contains('sandwich')) {
      return '🥪';
    } else if (nameLower.contains('chicken') || nameLower.contains('wings')) {
      return '🍗';
    } else if (nameLower.contains('fries') || nameLower.contains('fry')) {
      return '🍟';
    } else if (nameLower.contains('soda') ||
        nameLower.contains('cola') ||
        nameLower.contains('drink')) {
      return '🥤';
    } else if (nameLower.contains('ice cream') ||
        nameLower.contains('dessert')) {
      return '🍨';
    } else if (nameLower.contains('cake') || nameLower.contains('brownie')) {
      return '🍰';
    } else if (categoryLower.contains('beverage') ||
        categoryLower.contains('drink')) {
      return '🥤';
    } else if (categoryLower.contains('main') ||
        categoryLower.contains('entree')) {
      return '🍽️';
    } else if (categoryLower.contains('dessert') ||
        categoryLower.contains('sweet')) {
      return '🍰';
    }
    return '🍽️';
  }

  @override
  Widget build(BuildContext context) {
    final emoji = _getFoodEmoji(item.menuItem.category, item.menuItem.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          // Food emoji
          Text(emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 16),

          // Item details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.menuItem.name,
                  style: TextStyle(
                    color: textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.menuItem.price.toStringAsFixed(2)}',
                  style: TextStyle(color: textGrey, fontSize: 14),
                ),
              ],
            ),
          ),

          // Quantity controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Decrease button
              _buildQuantityButton(
                context,
                icon: Icons.remove,
                onTap: () {
                  context.read<MenuViewModel>().decreaseQuantity(item);
                },
              ),

              // Quantity display
              Container(
                width: 40,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    horizontal: BorderSide(color: borderColor),
                  ),
                ),
                child: Text(
                  '${item.quantity}',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Increase button
              _buildQuantityButton(
                context,
                icon: Icons.add,
                onTap: () {
                  context.read<MenuViewModel>().increaseQuantity(item);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 18, color: textGrey),
      ),
    );
  }
}
