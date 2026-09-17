import 'package:calculator_vault/features/auth/authenticated_equals_router.dart';
import 'package:calculator_vault/features/auth/pin_auth_controller.dart';
import 'package:calculator_vault/features/auth/protected_session.dart';
import 'package:flutter_test/flutter_test.dart';

final class FixedStore implements PinEnrollmentStore {
  @override Future<bool> get isEnrolled async => true;
  @override Future<void> enroll(String pin) async {}
  @override Future<bool> verify(String candidate) async => candidate == '654321';
}

void main() {
  test('session unlock follows successful authentication only', () async {
    final auth = PinAuthController(FixedStore());
    final session = ProtectedSession();
    final router = AuthenticatedEqualsRouter(auth, session);
    expect(await router.tryOpen('1+1'), isFalse);
    expect(session.isUnlocked, isFalse);
    expect(await router.tryOpen('654321'), isTrue);
    expect(session.isUnlocked, isTrue);
  });
}
