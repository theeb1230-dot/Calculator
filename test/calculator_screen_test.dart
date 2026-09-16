import 'package:calculator_vault/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('calculator accepts digits and clears display', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const CalculatorVaultApp());
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('7'));
    await tester.tap(find.text('8'));
    await tester.pump();
    expect(find.text('78'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('C'));
    await tester.pump();
    expect(find.text('78'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('calculator remains usable on a compact viewport', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 560));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const CalculatorVaultApp());

    expect(find.text('='), findsOneWidget);
    expect(find.text('0'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
