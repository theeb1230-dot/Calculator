import 'dart:typed_data';

import 'vault_object.dart';

/// Logical classes that must never be persisted in plaintext beside vault data.
enum ProtectedAssetClass {
  media,
  file,
  metadata,
  thumbnail,
  cache,
  temporary,
  searchIndex,
  backup,
  trash,
}

/// Reference to authenticated ciphertext only. No filesystem path or raw key is
/// exposed to feature/UI layers.
final class ProtectedAssetRef {
  const ProtectedAssetRef({
    required this.objectId,
    required this.assetClass,
    required this.envelope,
  });

  final String objectId;
  final ProtectedAssetClass assetClass;
  final VaultObjectEnvelope envelope;

  bool get isUsable => objectId.isNotEmpty && envelope.hasValidShape;
}

/// Streaming encrypted storage boundary for media/files and all derived data.
/// Implementations must authenticate every chunk/object before exposing
/// plaintext and must keep staging/cache/temp data inside private storage.
abstract interface class ProtectedAssetStore {
  Future<ProtectedAssetRef> importCiphertext({
    required ProtectedAssetClass assetClass,
    required VaultObjectEnvelope envelope,
    required Stream<List<int>> ciphertext,
  });

  /// Returns authenticated plaintext as bounded chunks. Implementations fail
  /// closed on authentication failure and never return unauthenticated bytes.
  Stream<Uint8List> readAuthenticated(ProtectedAssetRef asset);

  /// Writes encrypted metadata/thumbnail/index payloads through the same
  /// authenticated storage boundary as primary media.
  Future<ProtectedAssetRef> putDerivedCiphertext({
    required ProtectedAssetClass assetClass,
    required VaultObjectEnvelope envelope,
    required Stream<List<int>> ciphertext,
  });
}

bool requiresPrivateEncryptedStorage(ProtectedAssetClass assetClass) => true;
