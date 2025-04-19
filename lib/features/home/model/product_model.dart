class Product {
  final String id;
  final String name;
  final String category;
  final String brand;
  final String modelNumber;
  final String description;
  final double rentalPrice;
  final int stock;
  final List<String> images;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.brand,
    required this.modelNumber,
    required this.description,
    required this.rentalPrice,
    required this.stock,
    this.images = const [],
  });

  Product copyWith({
    String? id,
    String? name,
    String? category,
    String? brand,
    String? modelNumber,
    String? description,
    double? rentalPrice,
    int? stock,
    List<String>? images,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      modelNumber: modelNumber ?? this.modelNumber,
      description: description ?? this.description,
      rentalPrice: rentalPrice ?? this.rentalPrice,
      stock: stock ?? this.stock,
      images: images ?? this.images,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'brand': brand,
      'modelNumber': modelNumber,
      'description': description,
      'rentalPrice': rentalPrice,
      'stock': stock,
      'images': images,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] as String,
      category: map['category'] as String,
      brand: map['brand'] as String,
      modelNumber: map['modelNumber'] as String,
      description: map['description'] as String,
      rentalPrice: (map['rentalPrice'] as num).toDouble(),
      stock: map['stock'] as int,
      images: List<String>.from(map['images'] ?? []),
    );
  }
}
