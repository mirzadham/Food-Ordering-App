import 'package:flutter/material.dart';
import 'welcome_screen.dart';

/// Order Status Screen - Displays queue number after placing an order
/// Shows "Now Serving" with the current queue number being served
class OrderStatusScreen extends StatelessWidget {
  final int queueNumber;

  const OrderStatusScreen({super.key, required this.queueNumber});

  // Design colors matching the app theme
  static const Color _backgroundColor = Color(0xFFFFFBF5);
  static const Color _primaryOrange = Color(0xFFE8A849);
  static const Color _textDark = Color(0xFF2D2D2D);
  static const Color _textGrey = Color(0xFF6B6B6B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Back button header
            _buildHeader(context),

            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Food illustration
                    _buildFoodIllustration(),

                    const SizedBox(height: 40),

                    // "Now Serving" text
                    const Text(
                      'Now Serving',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: _textDark,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Queue number badge
                    _buildQueueNumberBadge(),

                    const SizedBox(height: 24),

                    // Wait message
                    const Text(
                      'Please wait for your number\nto be called.',
                      style: TextStyle(
                        fontSize: 16,
                        color: _textGrey,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back to home button
          GestureDetector(
            onTap: () {
              // Clear navigation stack and go back to welcome screen
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => WelcomeScreen()),
                (route) => false,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.chevron_left, color: _textGrey, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodIllustration() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6F0),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Sparkle decorations
          ..._buildSparkles(),

          // Food items row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Fries with dipping sauce
              _buildFoodItem(
                icon: Icons.fastfood,
                color: const Color(0xFFFFD93D),
                size: 50,
                offset: const Offset(-5, 10),
              ),

              const SizedBox(width: 8),

              // Burger (center, larger)
              _buildFoodItem(
                icon: Icons.lunch_dining,
                color: const Color(0xFFE8A849),
                size: 80,
                offset: const Offset(0, 0),
              ),

              const SizedBox(width: 8),

              // Drink cup with face
              _buildDrinkWithFace(),
            ],
          ),

          // Pizza slice at bottom left
          Positioned(
            left: 40,
            bottom: 20,
            child: Transform.rotate(
              angle: -0.2,
              child: const Icon(
                Icons.local_pizza,
                color: Color(0xFFFFB347),
                size: 44,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSparkles() {
    return [
      Positioned(top: 20, left: 30, child: _sparkle(8)),
      Positioned(top: 40, right: 50, child: _sparkle(6)),
      Positioned(top: 25, right: 80, child: _sparkle(10)),
      Positioned(bottom: 50, right: 30, child: _sparkle(8)),
      Positioned(top: 60, left: 60, child: _sparkle(6)),
    ];
  }

  Widget _sparkle(double size) {
    return Icon(
      Icons.auto_awesome,
      color: _primaryOrange.withAlpha(180),
      size: size,
    );
  }

  Widget _buildFoodItem({
    required IconData icon,
    required Color color,
    required double size,
    required Offset offset,
  }) {
    return Transform.translate(
      offset: offset,
      child: Icon(icon, color: color, size: size),
    );
  }

  Widget _buildDrinkWithFace() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE4B5).withAlpha(200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.local_cafe,
            color: Color(0xFFFFB347),
            size: 50,
          ),
        ),
        // Cute face overlay
        Positioned(
          bottom: 20,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFF3D3D3D),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFF3D3D3D),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQueueNumberBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
      decoration: BoxDecoration(
        color: _primaryOrange,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _primaryOrange.withAlpha(77),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        '$queueNumber',
        style: const TextStyle(
          fontSize: 42,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
