import 'package:calculator_vault/features/auth/authenticated_equals_router.dart';
import 'package:calculator_vault/features/auth/pin_auth_controller.dart';
import 'package:calculator_vault/features/auth/protected_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('router unlocks only for the enrolled credential', () async {
    final store = _Store();
    final auth = PinAuthController(store);
    final session = ProtectedSession();
    final router = AuthenticatedEqualsRouter(auth, session);
    await auth.enroll('777777');

    expect(await router.tryOpen('2+2'), isFalse);
    expect(session.isUnlocked, isFalse);
    expect(await router.tryOpen('888888'), isFalse);
    expect(session.isUnlocked, isFalse);
    expect(await router.tryOpen('777777'), isTrue);
    expect(session.isUnlocked, isTrue);
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
