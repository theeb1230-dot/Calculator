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

    test('rejects division by zero and malformed expressions', () {
      expect(() => engine.evaluate('1÷0'), throwsA(isA<CalculatorException>()));
      expect(() => engine.evaluate('2+'), throwsA(isA<CalculatorException>()));
      expect(() => engine.evaluate('(2+3'), throwsA(isA<CalculatorException>()));
      expect(() => engine.evaluate('1..2'), throwsA(isA<CalculatorException>()));
      expect(() => engine.evaluate(''), throwsA(isA<CalculatorException>()));
    });
  });
}
