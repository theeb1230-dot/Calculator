import 'package:calculator_vault/features/auth/pin_auth_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('authentication is unavailable before enrollment', () async {
    final auth = PinAuthController(_Store());
    expect(await auth.onEquals('111111'), PinRouteDecision.evaluateNormally);
  });

  test('matching enrolled credential opens protected session', () async {
    final store = _Store();
    final auth = PinAuthController(store);
    await auth.enroll('111111');
    expect(await auth.onEquals('111111'), PinRouteDecision.openProtectedSession);
  });

  test('nonmatching and calculator expressions fall through', () async {
    final store = _Store();
    final auth = PinAuthController(store);
    await auth.enroll('111111');
    expect(await auth.onEquals('222222'), PinRouteDecision.evaluateNormally);
    expect(await auth.onEquals('2+2'), PinRouteDecision.evaluateNormally);
  });
}

final class _Store implements PinEnrollmentStore {
  String? value;
  @override
  Future<bool> get isEnrolled async => value != null;
  @override
  Future<void> enroll(String pin) async => value = pin;
  @override
  Future<bool> verify(String candidate) async => value == candidate;
}
