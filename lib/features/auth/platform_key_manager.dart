import 'package:flutter/services.dart';

import 'key_management.dart';

/// Method-channel implementation whose native side owns key generation and
/// protected key material. Dart receives opaque handles and operation output,
/// never a vault master key.
final class PlatformVaultKeyManager implements VaultKeyManager {
  PlatformVaultKeyManager({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('calculator/platform_keys');

  final MethodChannel _channel;

  @override
  Future<VaultKeyHandle> createVaultKey() async {
    final id = await _channel.invokeMethod<String>('createVaultKey');
    if (id == null || !isValidVaultKeyHandle(id)) {
      throw StateError('Platform returned an invalid opaque key handle');
    }
    return VaultKeyHandle(id);
  }

  @override
  Future<bool> contains(VaultKeyHandle handle) async {
    _requireValid(handle);
    return await _channel.invokeMethod<bool>('containsVaultKey', handle.id) ?? false;
  }

  @override
  Future<void> destroy(VaultKeyHandle handle) async {
    _requireValid(handle);
    await _channel.invokeMethod<void>('destroyVaultKey', handle.id);
  }

  @override
  Future<Uint8List> unwrapDataKey({
    required VaultKeyHandle handle,
    required Uint8List wrappedDataKey,
    required Uint8List context,
  }) async {
    _requireValid(handle);
    if (wrappedDataKey.isEmpty || context.isEmpty) {
      throw ArgumentError('Wrapped key and authenticated context are required');
    }
    final result = await _channel.invokeMethod<Uint8List>('unwrapDataKey', {
      'handle': handle.id,
      'wrappedDataKey': wrappedDataKey,
      'context': context,
    });
    if (result == null || result.isEmpty) {
      throw StateError('Platform key operation failed closed');
    }
    return result;
  }

  static void _requireValid(VaultKeyHandle handle) {
    if (!isValidVaultKeyHandle(handle.id)) {
      throw ArgumentError.value(handle.id, 'handle', 'Invalid opaque key handle');
    }
  }
}
