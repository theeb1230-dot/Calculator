import 'dart:typed_data';

/// Opaque identifier for platform-protected vault key material.
/// Raw master keys must never be persisted by Dart code or derived from a PIN.
final class VaultKeyHandle {
  const VaultKeyHandle(this.id);
  final String id;
}

/// Serialized AES-GCM wrapped data key: nonce || ciphertext || tag.
final class WrappedDataKey {
  const WrappedDataKey(this.bytes);
  final Uint8List bytes;
}

/// Platform-backed key lifecycle boundary.
///
/// The vault master key never crosses into Dart. Data keys are random 256-bit
/// values generated and wrapped natively with AES-256-GCM and authenticated
/// context. Callers receive only opaque handles and wrapped key material.
abstract interface class VaultKeyManager {
  Future<VaultKeyHandle> createVaultKey();
  Future<bool> contains(VaultKeyHandle handle);
  Future<void> destroy(VaultKeyHandle handle);

  Future<WrappedDataKey> createWrappedDataKey({
    required VaultKeyHandle handle,
    required Uint8List context,
  });

  Future<Uint8List> unwrapDataKey({
    required VaultKeyHandle handle,
    required WrappedDataKey wrappedDataKey,
    required Uint8List context,
  });
}

bool isValidVaultKeyHandle(String value) =>
    RegExp(r'^vault-key-[A-Za-z0-9_-]{16,96}$').hasMatch(value);
