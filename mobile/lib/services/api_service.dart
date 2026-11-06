import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../core/config/api_config.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/payment_qr.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // 1. Obtener Categorías
  Future<List<Category>> getCategories() async {
    final url = Uri.parse('${ApiConfig.apiUrl}/categories');
    final response = await _client.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Category.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar categorías: ${response.statusCode}');
    }
  }

  // 2. Obtener Categoría por Slug con sus productos
  Future<Map<String, dynamic>> getCategoryBySlug(String slug) async {
    final url = Uri.parse('${ApiConfig.apiUrl}/categories/$slug');
    final response = await _client.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final category = Category.fromJson(data);
      List<Product> products = [];
      if (data['products'] != null && data['products'] is List) {
        products = (data['products'] as List).map((p) => Product.fromJson(p)).toList();
      }
      return {
        'category': category,
        'products': products,
      };
    } else {
      throw Exception('Error al cargar la categoría $slug: ${response.statusCode}');
    }
  }

  // 3. Obtener Productos con filtros de búsqueda y categoría
  Future<List<Product>> getProducts({
    String? search,
    String? categoryId,
    bool activeOnly = true,
  }) async {
    final queryParams = <String, String>{};
    if (activeOnly) queryParams['activeOnly'] = 'true';
    if (search != null && search.trim().isNotEmpty) queryParams['search'] = search.trim();
    if (categoryId != null && categoryId.trim().isNotEmpty) queryParams['categoryId'] = categoryId.trim();

    final url = Uri.parse('${ApiConfig.apiUrl}/products').replace(queryParameters: queryParams);
    final response = await _client.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List list = decoded is List ? decoded : (decoded['data'] ?? []);
      return list.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar productos: ${response.statusCode}');
    }
  }

  // 4. Obtener Producto por Slug
  Future<Product> getProductBySlug(String slug) async {
    final url = Uri.parse('${ApiConfig.apiUrl}/products/$slug');
    final response = await _client.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Product.fromJson(data);
    } else {
      throw Exception('Error al cargar producto: ${response.statusCode}');
    }
  }

  // 5. Obtener QR de Pago Activo del Dueño
  Future<PaymentQrConfig?> getActivePaymentQr() async {
    final url = Uri.parse('${ApiConfig.apiUrl}/payment-qr/active');
    try {
      final response = await _client.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PaymentQrConfig.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // 6. Crear Pedido con Comprobante Fotográfico (Multipart)
  Future<Order> createOrderWithProof({
    required Map<String, dynamic> clientData,
    required List<CartItem> items,
    required File proofFile,
  }) async {
    final url = Uri.parse('${ApiConfig.apiUrl}/orders');
    final request = http.MultipartRequest('POST', url);

    final payload = {
      'clientName': clientData['clientName'] ?? '',
      'clientEmail': clientData['clientEmail'] ?? '',
      'clientPhone': clientData['clientPhone'] ?? '',
      'clientAddress': clientData['clientAddress'] ?? '',
      'clientCity': clientData['clientCity'] ?? 'Santa Cruz',
      'clientCiNit': clientData['clientCiNit'] ?? '',
      'notes': clientData['notes'] ?? '',
      'items': items.map((it) => {
        'productId': it.product.id,
        'quantity': it.quantity,
      }).toList(),
    };

    request.fields['orderData'] = jsonEncode(payload);

    // Detección de MimeType para la imagen
    final fileName = proofFile.path.split(Platform.pathSeparator).last;
    String subtype = 'jpeg';
    if (fileName.toLowerCase().endsWith('.png')) {
      subtype = 'png';
    } else if (fileName.toLowerCase().endsWith('.webp')) {
      subtype = 'webp';
    }

    final multipartFile = await http.MultipartFile.fromPath(
      'paymentProof',
      proofFile.path,
      contentType: MediaType('image', subtype),
    );
    request.files.add(multipartFile);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Order.fromJson(data);
    } else {
      try {
        final err = jsonDecode(response.body);
        throw Exception(err['error'] ?? 'Error al procesar el pedido (${response.statusCode})');
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception('Error al enviar el pedido: ${response.statusCode}');
      }
    }
  }

  // 7. Obtener Pedido por Código de Orden (Polling / Consulta)
  Future<Order> getOrderById(String orderNumber) async {
    final url = Uri.parse('${ApiConfig.apiUrl}/orders/$orderNumber');
    final response = await _client.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Order.fromJson(data);
    } else {
      throw Exception('Error al consultar el pedido: ${response.statusCode}');
    }
  }
}
