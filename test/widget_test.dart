import 'package:flutter_test/flutter_test.dart';
import 'package:interquatier/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const InterQuatierApp());
    expect(find.text('Events'), findsOneWidget);
  });
}
