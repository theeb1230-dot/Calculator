import 'dart:typed_data';

/// Opaque identifier for platform-protected vault key material.
///
/// Raw master keys must never be persisted by Dart code or derived from a PIN.
final class VaultKeyHandle {
  const VaultKeyHandle(this.id);

  final String id;
}

/// Platform-backed key lifecycle boundary.
///
/// Implementations generate cryptographically random key material and protect
/// it with Android Keystore/StrongBox when available or iOS Keychain/Secure
/// Enclave where applicable. The API intentionally never returns a master key.
abstract interface class VaultKeyManager {
  Future<VaultKeyHandle> createVaultKey();

  Future<bool> contains(VaultKeyHandle handle);

  Future<void> destroy(VaultKeyHandle handle);

  /// Performs an authenticated operation using protected key material without
  /// exposing the vault master key to callers.
  Future<Uint8List> unwrapDataKey({
    required VaultKeyHandle handle,
    required Uint8List wrappedDataKey,
    required Uint8List context,
  });
}

/// Rejects key handles that could be confused with secrets or filesystem paths.
bool isValidVaultKeyHandle(String value) =>
    RegExp(r'^vault-key-[A-Za-z0-9_-]{16,96}$').hasMatch(value);
