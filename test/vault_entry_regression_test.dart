import 'package:calculator_vault/features/auth/authenticated_equals_router.dart';
import 'package:calculator_vault/features/auth/lifecycle_lock.dart';
import 'package:calculator_vault/features/auth/pin_auth_controller.dart';
import 'package:calculator_vault/features/auth/protected_session.dart';
import 'package:calculator_vault/features/auth/vault_entry_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

final class TestPinStore implements PinEnrollmentStore {
  TestPinStore(this.pin);
  String? pin;
  @override Future<bool> get isEnrolled async => pin != null;
  @override Future<void> enroll(String value) async { pin = value; }
  @override Future<bool> verify(String candidate) async => candidate == pin;
}

void main() {
  test('ordinary equals and wrong PIN never unlock', () async {
    final store = TestPinStore('654321');
    final auth = PinAuthController(store);
    final session = ProtectedSession();
    final entry = VaultEntryCoordinator(auth: auth, router: AuthenticatedEqualsRouter(auth, session));
    expect(await entry.interceptEquals('1+1'), isFalse);
    expect(await entry.interceptEquals('123456'), isFalse);
    expect(session.isUnlocked, isFalse);
  });

  test('lifecycle transition locks an authenticated session', () async {
    final store = TestPinStore('654321');
    final auth = PinAuthController(store);
    final session = ProtectedSession();
    final entry = VaultEntryCoordinator(auth: auth, router: AuthenticatedEqualsRouter(auth, session));
    expect(await entry.interceptEquals('654321'), isTrue);
    expect(session.isUnlocked, isTrue);
    LifecycleLock(session).onAppBackgrounded();
    expect(session.isUnlocked, isFalse);
  });
}
