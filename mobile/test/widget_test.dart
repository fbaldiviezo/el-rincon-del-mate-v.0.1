import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/main.dart';
import 'package:mobile/models/order.dart';
import 'package:mobile/services/location_service.dart';

void main() {
  testWidgets('App basic smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RinconDelMateApp());
    expect(find.byType(RinconDelMateApp), findsOneWidget);
  });

  test('AddressDetails model stores and outputs values correctly', () {
    final details = AddressDetails(
      position: const LatLng(-21.5355, -64.7296),
      formattedAddress: 'Calle Ingavi 456, Tarija, Bolivia',
      street: 'Calle Ingavi 456',
      city: 'Tarija',
      department: 'Tarija',
    );

    expect(details.formattedAddress, equals('Calle Ingavi 456, Tarija, Bolivia'));
    expect(details.street, equals('Calle Ingavi 456'));
    expect(details.city, equals('Tarija'));
    expect(details.department, equals('Tarija'));
    expect(details.position.latitude, equals(-21.5355));
  });

  test('Order model parses latitude and longitude coordinates', () {
    final json = {
      'id': 'ord-123',
      'orderNumber': 'RM-2026-0001',
      'total': 180.0,
      'subtotal': 180.0,
      'status': 'PENDING',
      'clientName': 'Juan Perez',
      'phone': '69891494',
      'city': 'Tarija',
      'address': 'Calle Sucre 123',
      'latitude': -21.5355,
      'longitude': -64.7296,
      'createdAt': '2026-11-16T12:00:00.000Z',
    };

    final order = Order.fromJson(json);
    expect(order.orderNumber, equals('RM-2026-0001'));
    expect(order.latitude, equals(-21.5355));
    expect(order.longitude, equals(-64.7296));
  });

  test('AppTheme light theme has white background and pastel accents', () {
    final theme = AppTheme.lightTheme;
    expect(theme.scaffoldBackgroundColor, equals(AppTheme.background));
    expect(theme.colorScheme.surface, equals(AppTheme.surface));
    expect(theme.colorScheme.primary, equals(AppTheme.woodPrimary));
  });
}
