import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PIN verifier implementation is slow-KDF and content-key independent', () {
    final source = File('lib/features/auth/secure_pin_store.dart').readAsStringSync();
    expect(source, contains('Pbkdf2'));
    expect(source, contains('210000'));
    expect(source, contains('Random.secure()'));
    expect(source, contains('FlutterSecureStorage'));
    expect(source, isNot(contains('vault content key =')));
  });

  test('calculator UI routes equals through authentication before evaluation', () {
    final source = File('lib/main.dart').readAsStringSync();
    final authIndex = source.indexOf('_router.tryOpen(_controller.display)');
    final calculatorIndex = source.indexOf("_controller.press(key)");
    expect(authIndex, greaterThanOrEqualTo(0));
    expect(calculatorIndex, greaterThan(authIndex));
    expect(source, contains("onLongPress: key == '=' ? _beginEnrollment : null"));
  });
}
