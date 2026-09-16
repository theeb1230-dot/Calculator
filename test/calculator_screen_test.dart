import 'package:calculator_vault/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('calculator accepts digits and clears display', (tester) async {
    await tester.pumpWidget(const CalculatorVaultApp());

    expect(find.text('0'), findsNWidgets(2));

    await tester.tap(find.text('7'));
    await tester.tap(find.text('8'));
    await tester.pump();
    expect(find.text('78'), findsOneWidget);

    await tester.tap(find.text('C'));
    await tester.pump();
    expect(find.text('78'), findsNothing);
  });
}
