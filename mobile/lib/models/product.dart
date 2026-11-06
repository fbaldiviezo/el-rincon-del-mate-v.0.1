import 'category.dart';

class Product {
  final String id;
  final String categoryId;
  final String name;
  final String slug;
  final String description;
  final double price;
  final double cost;
  final int stock;
  final String? imageUrl;
  final List<String> images;
  final String? qrCodeUrl;
  final bool active;
  final Category? category;

  Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    this.cost = 0,
    required this.stock,
    this.imageUrl,
    this.images = const [],
    this.qrCodeUrl,
    this.active = true,
    this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> imgList = [];
    if (json['images'] != null && json['images'] is List) {
      imgList = (json['images'] as List).map((e) => e.toString()).toList();
    }
    // Si images está vacío pero tiene imageUrl, agregarlo
    if (imgList.isEmpty && json['imageUrl'] != null && (json['imageUrl'] as String).isNotEmpty) {
      imgList.add(json['imageUrl'] as String);
    }

    return Product(
      id: json['id'] ?? '',
      categoryId: json['categoryId'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] != null) ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0,
      cost: (json['cost'] != null) ? double.tryParse(json['cost'].toString()) ?? 0.0 : 0.0,
      stock: (json['stock'] != null) ? int.tryParse(json['stock'].toString()) ?? 0 : 0,
      imageUrl: json['imageUrl'],
      images: imgList,
      qrCodeUrl: json['qrCodeUrl'],
      active: json['active'] ?? true,
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'categoryId': categoryId,
    'name': name,
    'slug': slug,
    'description': description,
    'price': price,
    'stock': stock,
    'imageUrl': imageUrl,
    'images': images,
    'active': active,
  };
}
