import 'calculator_engine.dart';

class CalculatorController {
  CalculatorController({CalculatorEngine engine = const CalculatorEngine()})
      : _engine = engine;

  static const _operators = {'+', '−', '×', '÷'};

  final CalculatorEngine _engine;
  String _expression = '0';
  bool _justEvaluated = false;

  String get display => _expression;

  void press(String key) {
    switch (key) {
      case 'C':
        _reset();
      case '=':
        _evaluate();
      case '±':
        _toggleSign();
      case '.':
        _appendDecimal();
      case '(':
        _appendOpenParenthesis();
      case ')':
        _appendCloseParenthesis();
      case '%':
        _appendPercent();
      default:
        if (_operators.contains(key)) {
          _appendOperator(key);
        } else if (RegExp(r'^\d$').hasMatch(key)) {
          _appendDigit(key);
        }
    }
  }

  void _reset() {
    _expression = '0';
    _justEvaluated = false;
  }

  void _evaluate() {
    if (_expression == 'Error') return;
    try {
      _expression = _engine.evaluateAndFormat(_expression);
      _justEvaluated = true;
    } on CalculatorException {
      _expression = 'Error';
      _justEvaluated = false;
    }
  }

  void _prepareForFreshValue() {
    if (_expression == 'Error' || _justEvaluated) {
      _expression = '0';
      _justEvaluated = false;
    }
  }

  void _appendDigit(String digit) {
    _prepareForFreshValue();
    if (_expression == '0') {
      _expression = digit;
    } else if (_expression.endsWith(')') || _expression.endsWith('%')) {
      _expression = '$_expression×$digit';
    } else {
      _expression += digit;
    }
  }

  void _appendDecimal() {
    _prepareForFreshValue();
    if (_expression.endsWith(')') || _expression.endsWith('%')) {
      _expression += '×0.';
      return;
    }
    final segment = _currentNumberSegment();
    if (segment.contains('.')) return;
    if (_expression == '0') {
      _expression = '0.';
    } else if (_endsWithOperatorOrOpenParenthesis()) {
      _expression += '0.';
    } else {
      _expression += '.';
    }
  }

  void _appendOperator(String operator) {
    if (_expression == 'Error') return;
    _justEvaluated = false;
    if (_expression == '0' && operator == '−') {
      _expression = '−';
      return;
    }
    if (_expression == '0') return;
    if (_expression.endsWith('(')) {
      if (operator == '−') _expression += operator;
      return;
    }
    if (_endsWithOperator()) {
      _expression = '${_expression.substring(0, _expression.length - 1)}$operator';
    } else if (!_expression.endsWith('.')) {
      _expression += operator;
    }
  }

  void _appendOpenParenthesis() {
    _prepareForFreshValue();
    if (_expression == '0') {
      _expression = '(';
    } else if (_canEndValue()) {
      _expression += '×(';
    } else {
      _expression += '(';
    }
  }

  void _appendCloseParenthesis() {
    if (_expression == 'Error' || _justEvaluated) return;
    if (!_canEndValue()) return;
    if (_openParenthesisCount() > 0) _expression += ')';
  }

  void _appendPercent() {
    if (_expression == 'Error' || _justEvaluated || !_canEndValue()) return;
    _expression += '%';
  }

  void _toggleSign() {
    if (_expression == 'Error') {
      _reset();
      return;
    }
    if (_justEvaluated) _justEvaluated = false;
    if (_expression == '0') return;
    if (_expression.startsWith('−(') && _expression.endsWith(')')) {
      _expression = _expression.substring(2, _expression.length - 1);
    } else {
      _expression = '−($_expression)';
    }
  }

  String _currentNumberSegment() {
    var start = _expression.length;
    while (start > 0) {
      final char = _expression[start - 1];
      if (!_isDigit(char) && char != '.') break;
      start--;
    }
    return _expression.substring(start);
  }

  bool _endsWithOperator() =>
      _expression.isNotEmpty && _operators.contains(_expression[_expression.length - 1]);

  bool _endsWithOperatorOrOpenParenthesis() =>
      _endsWithOperator() || _expression.endsWith('(');

  bool _canEndValue() {
    if (_expression.isEmpty) return false;
    final last = _expression[_expression.length - 1];
    return _isDigit(last) || last == ')' || last == '%';
  }

  bool _isDigit(String value) => RegExp(r'^\d$').hasMatch(value);

  int _openParenthesisCount() {
    var balance = 0;
    for (final rune in _expression.runes) {
      final char = String.fromCharCode(rune);
      if (char == '(') balance++;
      if (char == ')') balance--;
    }
    return balance;
  }
}
