import 'package:flutter_test/flutter_test.dart';
import 'package:medicine_intake/main.dart';

void main() {
  testWidgets('renders intake app title', (WidgetTester tester) async {
    await tester.pumpWidget(const PillIntakeApp());
    expect(find.text('25-day Pill Intake Plan'), findsOneWidget);
  });
}
