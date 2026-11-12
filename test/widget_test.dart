import 'package:flutter_test/flutter_test.dart';
import 'package:anshiily/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AnshiilyApp());
    expect(find.byType(AnshiilyApp), findsOneWidget);
  });
}
