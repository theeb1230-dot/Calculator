import 'dart:typed_data';

/// Versioned metadata required to authenticate an encrypted vault object.
///
/// Ciphertext bytes are stored separately so large media can be processed in
/// bounded chunks. Metadata, thumbnails and indexes must themselves live in
/// encrypted/authenticated storage rather than beside this envelope in clear.
final class VaultObjectEnvelope {
  const VaultObjectEnvelope({
    required this.version,
    required this.keyId,
    required this.nonce,
    required this.authenticationTag,
    required this.plaintextLength,
  });

  static const int currentVersion = 1;

  final int version;
  final String keyId;
  final Uint8List nonce;
  final Uint8List authenticationTag;
  final int plaintextLength;

  bool get hasValidShape =>
      version == currentVersion &&
      keyId.isNotEmpty &&
      nonce.length == 12 &&
      authenticationTag.length == 16 &&
      plaintextLength >= 0;
}

/// Storage transaction boundary enforcing verify-before-commit semantics.
abstract interface class VaultObjectStore {
  /// Writes encrypted output to a private staging location.
  Future<String> stageEncryptedObject({
    required VaultObjectEnvelope envelope,
    required Stream<List<int>> ciphertext,
  });

  /// Authenticates staged bytes and metadata before they become visible.
  Future<void> verifyStagedObject(String stagingId);

  /// Atomically makes a verified staged object visible to vault indexes.
  Future<void> commitStagedObject(String stagingId);

  /// Removes incomplete private output. This never deletes the user's source.
  Future<void> discardStagedObject(String stagingId);
}
