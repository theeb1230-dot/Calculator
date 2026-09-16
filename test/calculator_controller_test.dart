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
      expect(controller.display, '-8');
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
  });
}
