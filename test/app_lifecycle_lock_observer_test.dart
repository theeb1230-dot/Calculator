import 'package:calculator_vault/features/auth/app_lifecycle_lock_observer.dart';
import 'package:calculator_vault/features/auth/protected_session.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('background lifecycle states relock protected session', () {
    final session = ProtectedSession()..unlock();
    final observer = AppLifecycleLockObserver(session);
    observer.didChangeAppLifecycleState(AppLifecycleState.paused);
    expect(session.isUnlocked, isFalse);
  });
}
