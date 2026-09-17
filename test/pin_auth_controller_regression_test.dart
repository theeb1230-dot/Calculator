import 'package:calculator_vault/features/auth/pin_auth_controller.dart';
import 'package:flutter_test/flutter_test.dart';

final class EmptyEnrollmentStore implements PinEnrollmentStore {
  @override Future<bool> get isEnrolled async => false;
  @override Future<void> enroll(String pin) async {}
  @override Future<bool> verify(String candidate) async => true;
}

void main() {
  test('verification cannot bypass missing enrollment', () async {
    final auth = PinAuthController(EmptyEnrollmentStore());
    expect(await auth.onEquals('654321'), PinRouteDecision.evaluateNormally);
  });
}
