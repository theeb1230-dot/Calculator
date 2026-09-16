class CalculatorException implements Exception {
  const CalculatorException(this.message);
  final String message;

  @override
  String toString() => 'CalculatorException: $message';
}

class CalculatorEngine {
  const CalculatorEngine();

  double evaluate(String expression) {
    final normalized = expression
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-')
        .replaceAll(' ', '');
    if (normalized.isEmpty) {
      throw const CalculatorException('Expression is empty');
    }
    final parser = _Parser(normalized);
    final result = parser.parse();
    if (!result.isFinite) {
      throw const CalculatorException('Result is not finite');
    }
    return result;
  }

  String evaluateAndFormat(String expression) => format(evaluate(expression));

  String format(double value) {
    if (!value.isFinite) {
      throw const CalculatorException('Result is not finite');
    }
    if (value == 0) return '0';
    if (value == value.truncateToDouble()) return value.toInt().toString();
    final text = value.toStringAsPrecision(12);
    if (text.contains('e') || text.contains('E')) return text;
    return text.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
}

class _Parser {
  _Parser(this.source);
  final String source;
  int index = 0;

  double parse() {
    final value = _expression();
    if (index != source.length) _fail('Unexpected token');
    return value;
  }

  double _expression() {
    var value = _term();
    while (true) {
      if (_take('+')) {
        value += _term();
      } else if (_take('-')) {
        value -= _term();
      } else {
        return value;
      }
    }
  }

  double _term() {
    var value = _unary();
    while (true) {
      if (_take('*')) {
        value *= _unary();
      } else if (_take('/')) {
        final divisor = _unary();
        if (divisor == 0) _fail('Division by zero');
        value /= divisor;
      } else {
        return value;
      }
    }
  }

  double _unary() {
    if (_take('+')) return _unary();
    if (_take('-')) return -_unary();
    return _primary();
  }

  double _primary() {
    if (_take('(')) {
      final value = _expression();
      if (!_take(')')) _fail('Missing closing parenthesis');
      return _applyPercent(value);
    }

    final start = index;
    var dots = 0;
    while (index < source.length) {
      final code = source.codeUnitAt(index);
      final digit = code >= 48 && code <= 57;
      if (digit) {
        index++;
      } else if (source[index] == '.') {
        dots++;
        if (dots > 1) _fail('Malformed number');
        index++;
      } else {
        break;
      }
    }
    if (start == index || source.substring(start, index) == '.') {
      _fail('Expected number');
    }
    final value = double.tryParse(source.substring(start, index));
    if (value == null) _fail('Malformed number');
    return _applyPercent(value);
  }

  double _applyPercent(double value) {
    while (_take('%')) {
      value /= 100;
    }
    return value;
  }

  bool _take(String token) {
    if (index < source.length && source[index] == token) {
      index++;
      return true;
    }
    return false;
  }

  Never _fail(String message) {
    throw CalculatorException('$message at position $index');
  }
}
