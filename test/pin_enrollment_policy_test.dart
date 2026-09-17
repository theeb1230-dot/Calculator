import 'package:calculator_vault/features/auth/pin_auth_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('enrollment rejects credentials outside numeric length policy', () async {
    final auth = PinAuthController(_Store());
    await expectLater(auth.enroll('12345'), throwsFormatException);
    await expectLater(auth.enroll('12345a'), throwsFormatException);
  });
}

final class _Store implements PinEnrollmentStore {
  @override
  Future<bool> get isEnrolled async => false;
  @override
  Future<void> enroll(String pin) async {}
  @override
  Future<bool> verify(String candidate) async => false;
}
