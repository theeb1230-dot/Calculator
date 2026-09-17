import 'package:calculator_vault/features/auth/pin_auth_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ordinary equals input never becomes an authentication signal', () async {
    final auth = PinAuthController(_Store());
    for (final expression in ['2+2', '50%', '(3+4)*2', '12345']) {
      expect(await auth.onEquals(expression), PinRouteDecision.evaluateNormally);
    }
  });
}

final class _Store implements PinEnrollmentStore {
  @override
  Future<bool> get isEnrolled async => true;
  @override
  Future<void> enroll(String pin) async {}
  @override
  Future<bool> verify(String candidate) async => false;
}
