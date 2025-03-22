import '../utils/constants.dart';

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'],
      productName: json['product_name'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price': price,
    };
  }
}

class Order {
  final String id;
  final String consumerId;
  final String farmerId;
  final List<OrderItem> items;
  final double totalAmount;
  final DateTime orderDate;
  final OrderStatus status;
  final String? deliveryAddress;
  final String? contactNumber;
  final String? cancelReason;
  final bool isRated;

  Order({
    required this.id,
    required this.consumerId,
    required this.farmerId,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    required this.status,
    this.deliveryAddress,
    this.contactNumber,
    this.cancelReason,
    this.isRated = false,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      consumerId: json['consumer_id'],
      farmerId: json['farmer_id'],
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      totalAmount: json['total_amount'].toDouble(),
      orderDate: DateTime.parse(json['order_date']),
      status: OrderStatus.values.byName(json['status']),
      deliveryAddress: json['delivery_address'],
      contactNumber: json['contact_number'],
      cancelReason: json['cancel_reason'],
      isRated: json['is_rated'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'consumer_id': consumerId,
      'farmer_id': farmerId,
      'items': items.map((item) => item.toJson()).toList(),
      'total_amount': totalAmount,
      'order_date': orderDate.toIso8601String(),
      'status': status.name,
      'delivery_address': deliveryAddress,
      'contact_number': contactNumber,
      'cancel_reason': cancelReason,
      'is_rated': isRated,
    };
  }

  Order copyWith({
    String? id,
    String? consumerId,
    String? farmerId,
    List<OrderItem>? items,
    double? totalAmount,
    DateTime? orderDate,
    OrderStatus? status,
    String? deliveryAddress,
    String? contactNumber,
    String? cancelReason,
    bool? isRated,
  }) {
    return Order(
      id: id ?? this.id,
      consumerId: consumerId ?? this.consumerId,
      farmerId: farmerId ?? this.farmerId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      contactNumber: contactNumber ?? this.contactNumber,
      cancelReason: cancelReason ?? this.cancelReason,
      isRated: isRated ?? this.isRated,
    );
  }
}
