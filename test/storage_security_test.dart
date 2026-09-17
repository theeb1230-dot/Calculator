import 'dart:typed_data';

import 'package:calculator_vault/features/storage/chunked_asset.dart';
import 'package:calculator_vault/features/storage/protected_asset.dart';
import 'package:calculator_vault/features/storage/transactional_import.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('authenticated chunk rejects malformed framing', () {
    final chunk = AuthenticatedChunk(
      index: 0,
      nonce: Uint8List(11),
      ciphertext: Uint8List.fromList([1]),
      tag: Uint8List(16),
    );
    expect(chunk.hasValidShape, isFalse);
  });

  test('all vault asset classes require private encrypted storage', () {
    for (final assetClass in ProtectedAssetClass.values) {
      expect(requiresPrivateEncryptedStorage(assetClass), isTrue);
    }
  });

  test('staged import requires non-empty private identifier', () {
    const staged = StagedImport(id: '', assetClass: ProtectedAssetClass.temporary);
    expect(staged.isValid, isFalse);
  });
}
