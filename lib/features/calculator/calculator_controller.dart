import 'calculator_engine.dart';

class CalculatorController {
  CalculatorController({CalculatorEngine engine = const CalculatorEngine()})
      : _engine = engine;

  final CalculatorEngine _engine;

  String _expression = '0';
  String get display => _expression;

  void press(String key) {
    switch (key) {
      case 'C':
        _expression = '0';
      case '=':
        _evaluate();
      case '±':
        _toggleSign();
      default:
        _append(key);
    }
  }

  void _evaluate() {
    try {
      _expression = _engine.evaluateAndFormat(_expression);
    } on CalculatorException {
      _expression = 'Error';
    }
  }

  void _append(String key) {
    if (_expression == 'Error') _expression = '0';
    _expression = _expression == '0' ? key : '$_expression$key';
  }

  void _toggleSign() {
    if (_expression == 'Error') {
      _expression = '0';
      return;
    }
    if (_expression.startsWith('-')) {
      _expression = _expression.substring(1);
    } else if (_expression != '0') {
      _expression = '-$_expression';
    }
  }
}
