import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:calculator_vault/features/storage/protected_asset.dart';
import 'package:calculator_vault/features/storage/vault_object.dart';

void main() {
  test('every vault asset class requires private encrypted storage', () {
    for (final assetClass in ProtectedAssetClass.values) {
      expect(requiresPrivateEncryptedStorage(assetClass), isTrue);
    }
  });

  test('protected asset refuses malformed authentication envelope', () {
    final asset = ProtectedAssetRef(
      objectId: 'object-1',
      assetClass: ProtectedAssetClass.thumbnail,
      envelope: VaultObjectEnvelope(
        version: VaultObjectEnvelope.currentVersion,
        keyId: 'vault-key-abcdefghijklmnop',
        nonce: Uint8List(11),
        authenticationTag: Uint8List(16),
        plaintextLength: 42,
      ),
    );

    expect(asset.isUsable, isFalse);
  });
}
