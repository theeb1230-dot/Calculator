import 'protected_asset.dart';

/// Transaction boundary for imports. Implementations stage inside private
/// storage, authenticate the complete staged object, then atomically publish it.
/// Source deletion is deliberately outside this contract and requires a
/// separate explicit user-authorized operation.
abstract interface class TransactionalVaultImport {
  Future<StagedImport> stage({
    required ProtectedAssetClass assetClass,
    required Stream<List<int>> source,
  });

  Future<bool> verify(StagedImport staged);

  Future<ProtectedAssetRef> commit(StagedImport staged);

  Future<void> discard(StagedImport staged);
}

final class StagedImport {
  const StagedImport({required this.id, required this.assetClass});

  final String id;
  final ProtectedAssetClass assetClass;

  bool get isValid => id.isNotEmpty && requiresPrivateEncryptedStorage(assetClass);
}

Future<ProtectedAssetRef> verifiedImport({
  required TransactionalVaultImport transaction,
  required ProtectedAssetClass assetClass,
  required Stream<List<int>> source,
}) async {
  final staged = await transaction.stage(assetClass: assetClass, source: source);
  if (!staged.isValid) {
    await transaction.discard(staged);
    throw StateError('Invalid staged import');
  }
  final verified = await transaction.verify(staged);
  if (!verified) {
    await transaction.discard(staged);
    throw StateError('Vault import authentication failed');
  }
  return transaction.commit(staged);
}
