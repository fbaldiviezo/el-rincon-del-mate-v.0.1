import 'product.dart';

class OrderItem {
  final String? id;
  final String productId;
  final Product? product;
  final double unitPrice;
  final int quantity;
  final double subtotal;

  OrderItem({
    this.id,
    required this.productId,
    this.product,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      productId: json['productId'] ?? '',
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      unitPrice: (json['unitPrice'] != null) ? double.tryParse(json['unitPrice'].toString()) ?? 0.0 : 0.0,
      quantity: (json['quantity'] != null) ? int.tryParse(json['quantity'].toString()) ?? 1 : 1,
      subtotal: (json['subtotal'] != null) ? double.tryParse(json['subtotal'].toString()) ?? 0.0 : 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'subtotal': subtotal,
  };
}

class Payment {
  final String id;
  final String orderId;
  final double amount;
  final String method;
  final String status; // 'PENDING_VERIFICATION' | 'APPROVED' | 'REJECTED'
  final String? rejectionReason;

  Payment({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.method,
    required this.status,
    this.rejectionReason,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? '',
      orderId: json['orderId'] ?? '',
      amount: (json['amount'] != null) ? double.tryParse(json['amount'].toString()) ?? 0.0 : 0.0,
      method: json['method'] ?? 'QR',
      status: json['status'] ?? 'PENDING_VERIFICATION',
      rejectionReason: json['rejectionReason'],
    );
  }
}

class Order {
  final String id;
  final String orderNumber;
  final String? clientId;
  final double subtotal;
  final double total;
  final String status;
  final String paymentStatus; // 'PENDING_VERIFICATION' | 'APPROVED' | 'REJECTED'
  final String address;
  final String city;
  final String phone;
  final String? notes;
  final DateTime createdAt;
  final List<OrderItem> items;
  final Payment? payment;

  Order({
    required this.id,
    required this.orderNumber,
    this.clientId,
    required this.subtotal,
    required this.total,
    required this.status,
    required this.paymentStatus,
    required this.address,
    required this.city,
    required this.phone,
    this.notes,
    required this.createdAt,
    required this.items,
    this.payment,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'];
    List<OrderItem> itemList = [];
    if (rawItems != null && rawItems is List) {
      itemList = rawItems.map((e) => OrderItem.fromJson(e)).toList();
    }

    return Order(
      id: json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      clientId: json['clientId'],
      subtotal: (json['subtotal'] != null) ? double.tryParse(json['subtotal'].toString()) ?? 0.0 : 0.0,
      total: (json['total'] != null) ? double.tryParse(json['total'].toString()) ?? 0.0 : 0.0,
      status: json['status'] ?? 'PENDING_PAYMENT_VERIFICATION',
      paymentStatus: json['paymentStatus'] ?? (json['payment'] != null ? json['payment']['status'] ?? 'PENDING_VERIFICATION' : 'PENDING_VERIFICATION'),
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      phone: json['phone'] ?? '',
      notes: json['notes'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) ?? DateTime.now() : DateTime.now(),
      items: itemList,
      payment: json['payment'] != null ? Payment.fromJson(json['payment']) : null,
    );
  }
}
