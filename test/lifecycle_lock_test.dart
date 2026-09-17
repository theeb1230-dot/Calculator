import 'package:calculator_vault/features/auth/lifecycle_lock.dart';
import 'package:calculator_vault/features/auth/protected_session.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('non-resumed lifecycle state locks protected session', () {
    final session = ProtectedSession()..unlock();
    final observer = LifecycleLockObserver(session);
    observer.didChangeAppLifecycleState(AppLifecycleState.inactive);
    expect(session.isUnlocked, isFalse);
  });
}
