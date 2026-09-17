import 'package:calculator/features/auth/key_management.dart';
import 'package:calculator/features/auth/platform_key_manager.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('calculator/platform_keys_test');

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('accepts only opaque platform key handles', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'createVaultKey') {
        return 'vault-key-0123456789abcdef0123456789abcdef';
      }
      return null;
    });
    final manager = PlatformVaultKeyManager(channel: channel);
    final handle = await manager.createVaultKey();
    expect(handle.id, startsWith('vault-key-'));
  });

  test('rejects raw secret-like platform response', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => '0123456789abcdef');
    final manager = PlatformVaultKeyManager(channel: channel);
    expect(manager.createVaultKey(), throwsStateError);
  });

  test('authenticated unwrap fails closed on empty platform output', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => null);
    final manager = PlatformVaultKeyManager(channel: channel);
    expect(
      manager.unwrapDataKey(
        handle: const VaultKeyHandle('vault-key-0123456789abcdef0123456789abcdef'),
        wrappedDataKey: Uint8List.fromList([1]),
        context: Uint8List.fromList([2]),
      ),
      throwsStateError,
    );
  });
}
