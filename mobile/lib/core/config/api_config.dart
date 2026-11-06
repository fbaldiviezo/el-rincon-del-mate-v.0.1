import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // Configuración de URL base
  // En Android Emulator: 10.0.2.2 mapea a localhost de la PC host.
  // En iOS Simulator, Web o Desktop: localhost:3000 funciona directamente.
  static String get defaultBaseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

  static String baseUrl = defaultBaseUrl;

  static String get apiUrl => '$baseUrl/api';

  // Resuelve la URL absoluta de cualquier imagen proviniente del backend
  static String resolveImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty) {
      return 'https://images.unsplash.com/photo-1517256064527-49c73771ec9f?w=600&q=80';
    }

    if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
      return rawUrl;
    }

    if (rawUrl.startsWith('data:image')) {
      return rawUrl; // Data URI en base64
    }

    final cleanPath = rawUrl.startsWith('/') ? rawUrl.substring(1) : rawUrl;
    return '$baseUrl/$cleanPath';
  }
}
