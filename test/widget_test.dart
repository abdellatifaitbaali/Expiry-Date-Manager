import 'package:flutter_test/flutter_test.dart';
import 'package:expiry_date_manager/main.dart';

void main() {
  testWidgets('App launches correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpiryDateManagerApp());
    expect(find.text('Expiry Tracker'), findsOneWidget);
  });
}
