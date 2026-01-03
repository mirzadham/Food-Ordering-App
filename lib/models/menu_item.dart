/// MenuItem model representing a food item from the menu
class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  /// Creates a MenuItem from JSON data
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  /// Converts MenuItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  @override
  String toString() {
    return 'MenuItem(id: $id, name: $name, price: \$$price)';
  }
}
