import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('App basic smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RinconDelMateApp());
    expect(find.byType(RinconDelMateApp), findsOneWidget);
  });
}
