import 'package:calculator_vault/features/auth/protected_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('protected session starts locked and can be relocked', () {
    final session = ProtectedSession();
    expect(session.isUnlocked, isFalse);
    session.unlock();
    expect(session.isUnlocked, isTrue);
    session.lock();
    expect(session.isUnlocked, isFalse);
  });
}
