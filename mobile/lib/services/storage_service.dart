import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';

class StorageService {
  static const String _cartKey = 'mate_mobile_cart';
  static const String _clientKey = 'mate_mobile_checkout_client';

  // Guardar carrito
  static Future<void> saveCart(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map((it) => it.toJson()).toList();
    await prefs.setString(_cartKey, jsonEncode(jsonList));
  }

  // Cargar carrito
  static Future<List<CartItem>> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_cartKey);
    if (data == null || data.isEmpty) return [];
    try {
      final List decoded = jsonDecode(data);
      return decoded.map((e) => CartItem.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  // Limpiar carrito
  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }

  // Guardar datos temporales de cliente de checkout
  static Future<void> saveCheckoutClient(Map<String, dynamic> clientData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_clientKey, jsonEncode(clientData));
  }

  // Obtener datos temporales de cliente
  static Future<Map<String, dynamic>?> getCheckoutClient() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_clientKey);
    if (data == null) return null;
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // Limpiar datos temporales de cliente
  static Future<void> clearCheckoutClient() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_clientKey);
  }
}
