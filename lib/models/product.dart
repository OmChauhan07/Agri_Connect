class Product {
  final String id;
  final String farmerId;
  final String name;
  final String description;
  final double price;
  final int stockQuantity;
  final List<String> imageUrls;
  final DateTime harvestDate;
  final DateTime bestBeforeDate;
  final double? rating;
  final int? totalRatings;
  final bool isOrganic;
  final bool isAvailable;
  final String category;

  Product({
    required this.id,
    required this.farmerId,
    required this.name,
    required this.description,
    required this.price,
    required this.stockQuantity,
    required this.imageUrls,
    required this.harvestDate,
    required this.bestBeforeDate,
    this.rating,
    this.totalRatings,
    required this.isOrganic,
    required this.isAvailable,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      farmerId: json['farmer_id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      stockQuantity: json['stock_quantity'],
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      harvestDate: DateTime.parse(json['harvest_date']),
      bestBeforeDate: DateTime.parse(json['best_before_date']),
      rating: json['rating']?.toDouble(),
      totalRatings: json['total_ratings'],
      isOrganic: json['is_organic'] ?? true,
      isAvailable: json['is_available'] ?? true,
      category: json['category'] ?? 'Vegetables',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmer_id': farmerId,
      'name': name,
      'description': description,
      'price': price,
      'stock_quantity': stockQuantity,
      'image_urls': imageUrls,
      'harvest_date': harvestDate.toIso8601String(),
      'best_before_date': bestBeforeDate.toIso8601String(),
      'rating': rating,
      'total_ratings': totalRatings,
      'is_organic': isOrganic,
      'is_available': isAvailable,
      'category': category,
    };
  }

  Product copyWith({
    String? id,
    String? farmerId,
    String? name,
    String? description,
    double? price,
    int? stockQuantity,
    List<String>? imageUrls,
    DateTime? harvestDate,
    DateTime? bestBeforeDate,
    double? rating,
    int? totalRatings,
    bool? isOrganic,
    bool? isAvailable,
    String? category,
  }) {
    return Product(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      imageUrls: imageUrls ?? this.imageUrls,
      harvestDate: harvestDate ?? this.harvestDate,
      bestBeforeDate: bestBeforeDate ?? this.bestBeforeDate,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      isOrganic: isOrganic ?? this.isOrganic,
      isAvailable: isAvailable ?? this.isAvailable,
      category: category ?? this.category,
    );
  }
}
