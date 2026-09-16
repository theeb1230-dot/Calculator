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

    // Avoid double.toInt() here: values outside the platform integer range can
    // saturate and produce a completely unrelated display value.
    final magnitude = value.abs();
    if (value == value.truncateToDouble() && magnitude < 1e21) {
      return value.toStringAsFixed(0);
    }

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
    var digitsBeforeOrAfterDot = 0;
    var dots = 0;
    while (index < source.length) {
      final code = source.codeUnitAt(index);
      final digit = code >= 48 && code <= 57;
      if (digit) {
        digitsBeforeOrAfterDot++;
        index++;
      } else if (source[index] == '.') {
        dots++;
        if (dots > 1) _fail('Malformed number');
        index++;
      } else {
        break;
      }
    }
    if (digitsBeforeOrAfterDot == 0) _fail('Expected number');

    if (index < source.length &&
        (source[index] == 'e' || source[index] == 'E')) {
      index++;
      if (index < source.length &&
          (source[index] == '+' || source[index] == '-')) {
        index++;
      }
      final exponentStart = index;
      while (index < source.length) {
        final code = source.codeUnitAt(index);
        if (code < 48 || code > 57) break;
        index++;
      }
      if (exponentStart == index) _fail('Malformed exponent');
    }

    final value = double.tryParse(source.substring(start, index));
    if (value == null || !value.isFinite) _fail('Malformed number');
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
