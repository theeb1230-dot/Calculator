import 'package:calculator_vault/features/auth/key_management.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts opaque vault key handles', () {
    expect(isValidVaultKeyHandle('vault-key-AbCdEf0123456789'), isTrue);
  });

  test('rejects PIN-like values and filesystem paths as key handles', () {
    expect(isValidVaultKeyHandle('123456'), isFalse);
    expect(isValidVaultKeyHandle('/tmp/vault-key-AbCdEf0123456789'), isFalse);
    expect(isValidVaultKeyHandle('vault-key-short'), isFalse);
  });
}
