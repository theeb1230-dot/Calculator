import 'dart:typed_data';

import 'package:calculator_vault/features/storage/vault_object.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts the v1 AEAD envelope shape', () {
    final envelope = VaultObjectEnvelope(
      version: VaultObjectEnvelope.currentVersion,
      keyId: 'vault-key-AbCdEf0123456789',
      nonce: Uint8List(12),
      authenticationTag: Uint8List(16),
      plaintextLength: 42,
    );

    expect(envelope.hasValidShape, isTrue);
  });

  test('rejects malformed nonce, tag, version, and negative lengths', () {
    VaultObjectEnvelope envelope({
      int version = VaultObjectEnvelope.currentVersion,
      int nonceLength = 12,
      int tagLength = 16,
      int length = 1,
    }) =>
        VaultObjectEnvelope(
          version: version,
          keyId: 'vault-key-AbCdEf0123456789',
          nonce: Uint8List(nonceLength),
          authenticationTag: Uint8List(tagLength),
          plaintextLength: length,
        );

    expect(envelope(version: 99).hasValidShape, isFalse);
    expect(envelope(nonceLength: 11).hasValidShape, isFalse);
    expect(envelope(tagLength: 15).hasValidShape, isFalse);
    expect(envelope(length: -1).hasValidShape, isFalse);
  });
}
