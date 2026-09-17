import 'package:calculator_vault/features/auth/pin_enrollment_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts only configured numeric credential shape', () {
    expect(PinEnrollmentPolicy.accepts('654321'), isTrue);
    expect(PinEnrollmentPolicy.accepts('123456789012'), isTrue);
    expect(PinEnrollmentPolicy.accepts('12345'), isFalse);
    expect(PinEnrollmentPolicy.accepts('1234567890123'), isFalse);
    expect(PinEnrollmentPolicy.accepts('12+456'), isFalse);
  });
}
