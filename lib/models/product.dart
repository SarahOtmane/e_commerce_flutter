class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final String category;
  final String? image;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] is double)
          ? json['price']
          : double.tryParse(json['price'].toString()) ?? 0.0,
      category: json['category'] ?? '',
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'image': image,
    };
  }
}
