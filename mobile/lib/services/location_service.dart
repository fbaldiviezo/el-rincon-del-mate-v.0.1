import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class AddressDetails {
  final LatLng position;
  final String formattedAddress;
  final String street;
  final String city;
  final String department;
  final String? neighborhood;

  AddressDetails({
    required this.position,
    required this.formattedAddress,
    required this.street,
    required this.city,
    required this.department,
    this.neighborhood,
  });
}

class LocationService {
  // Centro por defecto en Bolivia (Tarija / Sucre / La Paz)
  static const LatLng defaultBoliviaPosition = LatLng(-21.5355, -64.7296); // Tarija centro

  // Verifica y solicita permisos de ubicación del dispositivo
  static Future<Position?> getCurrentDeviceLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  // Geocodificación inversa mediante OpenStreetMap Nominatim
  static Future<AddressDetails> reverseGeocode(LatLng coords) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=json&lat=${coords.latitude}&lon=${coords.longitude}&zoom=18&addressdetails=1',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'ElRinconDelMate-MobileApp/1.0',
          'Accept-Language': 'es',
        },
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['address'] as Map<String, dynamic>? ?? {};

        final road = address['road'] ?? address['pedestrian'] ?? address['street'] ?? '';
        final houseNumber = address['house_number'] ?? '';
        final neighborhood = address['neighbourhood'] ?? address['suburb'] ?? address['residential'] ?? '';
        final city = address['city'] ?? address['town'] ?? address['village'] ?? address['municipality'] ?? 'Tarija';
        final state = address['state'] ?? address['province'] ?? 'Tarija';

        String streetText = road.isNotEmpty ? (houseNumber.isNotEmpty ? '$road $houseNumber' : road) : '';
        if (streetText.isEmpty && neighborhood.isNotEmpty) {
          streetText = neighborhood;
        }

        final fullDisplay = data['display_name'] as String? ?? '';
        final cleanAddress = streetText.isNotEmpty ? streetText : (fullDisplay.isNotEmpty ? fullDisplay.split(',').take(3).join(',') : 'Ubicación seleccionada');

        return AddressDetails(
          position: coords,
          formattedAddress: cleanAddress,
          street: streetText,
          city: city,
          department: state,
          neighborhood: neighborhood.isNotEmpty ? neighborhood : null,
        );
      }
    } catch (_) {}

    // Fallback amigable si falla la conexión de reverse geocoding
    return AddressDetails(
      position: coords,
      formattedAddress: 'Lat: ${coords.latitude.toStringAsFixed(5)}, Lng: ${coords.longitude.toStringAsFixed(5)}',
      street: '',
      city: 'Tarija',
      department: 'Tarija',
    );
  }
}
