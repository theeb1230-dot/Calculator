import 'package:calculator_vault/features/auth/authenticated_equals_router.dart';
import 'package:calculator_vault/features/auth/pin_auth_controller.dart';
import 'package:calculator_vault/features/auth/protected_session.dart';
import 'package:calculator_vault/features/auth/vault_entry_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

final class MemoryPinStore implements PinEnrollmentStore {
  String? pin;
  @override Future<bool> get isEnrolled async => pin != null;
  @override Future<void> enroll(String value) async { pin = value; }
  @override Future<bool> verify(String candidate) async => candidate == pin;
}

void main() {
  test('requires enrollment and opens only for correct PIN', () async {
    final store = MemoryPinStore();
    final auth = PinAuthController(store);
    final session = ProtectedSession();
    final coordinator = VaultEntryCoordinator(auth: auth, router: AuthenticatedEqualsRouter(auth, session));

    expect(await coordinator.needsEnrollment, isTrue);
    expect(await coordinator.interceptEquals('123456'), isFalse);
    expect(session.isUnlocked, isFalse);

    await coordinator.enroll('654321');
    expect(await coordinator.needsEnrollment, isFalse);
    expect(await coordinator.interceptEquals('123456'), isFalse);
    expect(session.isUnlocked, isFalse);
    expect(await coordinator.interceptEquals('654321'), isTrue);
    expect(session.isUnlocked, isTrue);
  });
}
