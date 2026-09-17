import 'package:calculator_vault/features/auth/pin_auth_controller.dart';
import 'package:calculator_vault/features/auth/protected_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('session unlocks only after accepted authentication decision', () async {
    final store = _Store();
    final auth = PinAuthController(store);
    final session = ProtectedSession();
    await auth.enroll('333333');

    expect(await auth.onEquals('444444'), PinRouteDecision.evaluateNormally);
    expect(session.isUnlocked, isFalse);

    if (await auth.onEquals('333333') == PinRouteDecision.openProtectedSession) {
      session.unlock();
    }
    expect(session.isUnlocked, isTrue);
    session.lock();
    expect(session.isUnlocked, isFalse);
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
