import 'package:calculator_vault/features/calculator/calculator_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalculatorController', () {
    test('evaluates an expression through the engine', () {
      final controller = CalculatorController();
      for (final key in ['2', '+', '3', '×', '4', '=']) {
        controller.press(key);
      }
      expect(controller.display, '14');
    });

    test('clear resets state and sign toggles the current expression', () {
      final controller = CalculatorController();
      controller.press('8');
      controller.press('±');
      expect(controller.display, '−(8)');
      controller.press('±');
      expect(controller.display, '8');
      controller.press('C');
      expect(controller.display, '0');
    });

    test('invalid calculation exposes only a generic calculator error', () {
      final controller = CalculatorController();
      for (final key in ['1', '÷', '0', '=']) {
        controller.press(key);
      }
      expect(controller.display, 'Error');
      controller.press('7');
      expect(controller.display, '7');
    });

    test('prevents duplicate decimal points in the current number', () {
      final controller = CalculatorController();
      for (final key in ['1', '.', '2', '.', '3']) {
        controller.press(key);
      }
      expect(controller.display, '1.23');
    });

    test('replaces a trailing operator instead of stacking operators', () {
      final controller = CalculatorController();
      for (final key in ['9', '+', '×', '2']) {
        controller.press(key);
      }
      expect(controller.display, '9×2');
    });

    test('starts a fresh value after equals when a digit is pressed', () {
      final controller = CalculatorController();
      for (final key in ['2', '+', '3', '=', '7']) {
        controller.press(key);
      }
      expect(controller.display, '7');
    });

    test('continues from a result when an operator follows equals', () {
      final controller = CalculatorController();
      for (final key in ['2', '+', '3', '=', '×', '4', '=']) {
        controller.press(key);
      }
      expect(controller.display, '20');
    });

    test('adds implicit multiplication around parentheses', () {
      final controller = CalculatorController();
      for (final key in ['2', '(', '3', '+', '1', ')', '=']) {
        controller.press(key);
      }
      expect(controller.display, '8');
    });

    test('ignores unmatched closing parenthesis', () {
      final controller = CalculatorController();
      for (final key in ['2', ')', '+', '3']) {
        controller.press(key);
      }
      expect(controller.display, '2+3');
    });

    test('uses documented postfix percentage semantics', () {
      final controller = CalculatorController();
      for (final key in ['2', '0', '0', '×', '1', '0', '%', '=']) {
        controller.press(key);
      }
      expect(controller.display, '20');
    });
  });
}
