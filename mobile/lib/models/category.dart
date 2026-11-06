class Category {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? imageUrl;
  final int productsCount;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.imageUrl,
    this.productsCount = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    int count = 0;
    if (json['_count'] != null && json['_count'] is Map) {
      count = json['_count']['products'] ?? 0;
    }
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'],
      productsCount: count,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'description': description,
    'imageUrl': imageUrl,
  };
}
