class PaymentQrConfig {
  final String id;
  final String imageUrl;
  final String? fileName;
  final String? mimeType;
  final bool active;

  PaymentQrConfig({
    required this.id,
    required this.imageUrl,
    this.fileName,
    this.mimeType,
    this.active = true,
  });

  factory PaymentQrConfig.fromJson(Map<String, dynamic> json) {
    return PaymentQrConfig(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      fileName: json['fileName'],
      mimeType: json['mimeType'],
      active: json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'imageUrl': imageUrl,
    'fileName': fileName,
    'mimeType': mimeType,
    'active': active,
  };
}
