import 'package:calculator_vault/features/auth/pin_authentication.dart';
import 'package:flutter_test/flutter_test.dart';

final class FakePinBackend implements PinCredentialBackend {
  String? pin;

  @override
  Future<bool> get isEnrolled async => pin != null;

  @override
  Future<void> enroll(String value) async => pin = value;

  @override
  Future<bool> verify(String candidate) async => candidate == pin;
}

void main() {
  test('requires user-selected 6 to 12 digit PIN', () async {
    final backend = FakePinBackend();
    final auth = PinAuthenticationService(backend);

    expect(() => auth.enroll('12345'), throwsArgumentError);
    expect(() => auth.enroll('1234567890123'), throwsArgumentError);
    expect(() => auth.enroll('abcdef'), throwsArgumentError);

    await auth.enroll('654321');
    expect(await auth.isEnrolled, isTrue);
    expect(await auth.verify('654321'), isTrue);
    expect(await auth.verify('123456'), isFalse);
  });

  test('verification fails closed before enrollment', () async {
    final auth = PinAuthenticationService(FakePinBackend());
    expect(await auth.verify('654321'), isFalse);
  });
}
