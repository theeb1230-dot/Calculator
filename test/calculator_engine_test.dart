import 'package:calculator_vault/features/calculator/calculator_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const engine = CalculatorEngine();

  group('CalculatorEngine', () {
    test('respects precedence and parentheses', () {
      expect(engine.evaluateAndFormat('2+3×4'), '14');
      expect(engine.evaluateAndFormat('(2+3)×4'), '20');
      expect(engine.evaluateAndFormat('18÷3÷2'), '3');
    });

    test('supports decimals and unary signs', () {
      expect(engine.evaluateAndFormat('-2.5+1.25'), '-1.25');
      expect(engine.evaluateAndFormat('2×-3'), '-6');
      expect(engine.evaluateAndFormat('+4'), '4');
    });

    test('treats postfix percent as divide by one hundred', () {
      expect(engine.evaluateAndFormat('50%'), '0.5');
      expect(engine.evaluateAndFormat('200×10%'), '20');
      expect(engine.evaluateAndFormat('(25+25)%'), '0.5');
    });

    test('formats common floating point results cleanly', () {
      expect(engine.evaluateAndFormat('0.1+0.2'), '0.3');
      expect(engine.evaluateAndFormat('10÷4'), '2.5');
    });

    test('preserves large integral display values', () {
      expect(engine.format(1e20), '100000000000000000000');
    });

    test('supports scientific notation and continued evaluation', () {
      expect(engine.evaluateAndFormat('1e3+2'), '1002');
      expect(engine.evaluateAndFormat('1E-3×2'), '0.002');
      final tiny = engine.evaluateAndFormat('1÷10000000000000');
      expect(tiny.toLowerCase(), contains('e'));
      expect(engine.evaluate('$tiny×2'), closeTo(2e-13, 1e-25));
    });

    test('rejects malformed scientific notation', () {
      expect(() => engine.evaluate('1e'), throwsA(isA<CalculatorException>()));
      expect(() => engine.evaluate('1e+'), throwsA(isA<CalculatorException>()));
    });

    test('rejects division by zero and malformed expressions', () {
      expect(() => engine.evaluate('1÷0'), throwsA(isA<CalculatorException>()));
      expect(() => engine.evaluate('2+'), throwsA(isA<CalculatorException>()));
      expect(() => engine.evaluate('(2+3'), throwsA(isA<CalculatorException>()));
      expect(() => engine.evaluate('1..2'), throwsA(isA<CalculatorException>()));
      expect(() => engine.evaluate(''), throwsA(isA<CalculatorException>()));
    });
  });
}
